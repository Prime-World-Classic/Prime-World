#include "stdafx.h"
#include "RdpClientChannel.h"
#include "Network/PacketDispatcher.h"

namespace rdp_transport
{

#pragma warning( disable: 4355 )

ClientChannel::ClientChannel( ni_udp::IRdp * _rdp, const CommonCtx & _ctx, const Transport::Address & _ta, int _requestId, float _operationTimeout ) :
  Channel( EChanRole::ActiveDelayed, ni_udp::NetAddr(), _ta, Transport::TLoginData(), _ctx ),
  rdp( _rdp ),
  requestId( _requestId ),
  operationTimeout( _operationTimeout ),
  state( EClientChanState::WaitingSvcAddr ),
  timeout( _operationTimeout, this, &ClientChannel::OnTimeout )
{
}

bool ClientChannel::ValidateData(const void* data, int size) const
{
  return data != NULL && size > 0 && size <= static_cast<int>(Constants::MAX_PACKET_SIZE);
}

void ClientChannel::OnSvcRequestReply( const newLogin::ServiceReqReply & _reply )
{
  MessageTrace( "ClientChannel: Connection details arrived. code=%s(%d), svcid=%s, req_id=%d, addr=%s", 
               newLogin::ESvcConnectionResult::ToString( _reply.code ), (int)_reply.code, 
               _reply.svcId.c_str(), _reply.requestId, _reply.externalAddress.c_str() );

  threading::MutexLock lock(mutex);

  if ( ( _reply.svcId != GetAddress().target ) || ( _reply.requestId != requestId ) )
  {
    ErrorTrace( "ClientChannel: Wrong connection details, expected. svcid=%s, req_id=%d", 
               GetAddress().target.c_str(), requestId );
    CloseClientChannel();
    return;
  }

  if ( state != EClientChanState::WaitingSvcAddr )
  {
    ErrorTrace( "ClientChannel: Unexpected connection details. svcid=%s, req_id=%d", 
               GetAddress().target.c_str(), requestId );
    CloseClientChannel();
    return;
  }

  svcReqReply = _reply;

  if ( _reply.code != newLogin::ESvcConnectionResult::Ok )
  {
    ErrorTrace( "ClientChannel: Server refused connection to service. svcid=%s, req_id=%d, code=%d", 
               GetAddress().target.c_str(), requestId, (int)svcReqReply.code );
    CloseClientChannel();
    return;
  }

  ni_udp::NetAddr svcAddr;
  unsigned mux = 0;
  if ( !ParseAddress( svcAddr, mux, _reply.externalAddress.c_str() ) )
  {
    ErrorTrace( "ClientChannel: Cannot parse service address. svcid=%s, addr=%s, req_id=%d", 
               GetAddress().target.c_str(), _reply.externalAddress.c_str(), requestId );
    CloseClientChannel();
    return;
  }

  MessageTrace( "ClientChannel: Connecting to service. svcid=%s, addr=%s, mux=%u, req_id=%d", 
               _reply.svcId.c_str(), _reply.externalAddress.c_str(), mux, requestId );

  if ( !InitAsActive( rdp, svcAddr, mux ) )
  {
    ErrorTrace( "ClientChannel: Cannot start connection to service. svcid=%s, addr=%s, req_id=%d", 
               GetAddress().target.c_str(), _reply.externalAddress.c_str(), requestId );
    CloseClientChannel();
    return;
  }

  Switch( EClientChanState::ConnectingToSvc );
  timeout.Restart( operationTimeout );
}

void ClientChannel::OnConnectionEstablished( ni_udp::IRdpConnection * _conn )
{
  MessageTrace( "ClientChannel: Connection established. svcid=%s, req_id=%d", 
               GetAddress().target.c_str(), requestId );

  Channel::OnConnectionEstablished( _conn );

  threading::MutexLock lock(mutex);

  if ( state != EClientChanState::ConnectingToSvc )
  {
    ErrorTrace( "ClientChannel: Unexpected connection: svcid=%s, req_id=%d", 
               GetAddress().target.c_str(), requestId );
    CloseClientChannel();
    return;
  }

  NI_VERIFY( RdpConnection(), "", return );

  dispatcher = new Network::PacketDispatcher;
  dispatcher->AddHandler( this, &ClientChannel::OnHelloReply );

  writer = new rdp_transport::PacketWriter( RdpConnection() );

  newLogin::FrontendHello hello;
  hello.uid = GetAddress().client;
  hello.key = svcReqReply.key;
  writer->Send( hello );

  Switch( EClientChanState::WaitingSvcAck );
  timeout.Restart( operationTimeout );
}

void ClientChannel::OnConnectionClosed( ni_udp::IRdpConnection * _conn )
{
  Channel::OnConnectionClosed( _conn );

  threading::MutexLock lock(mutex);
  ErrorTrace( "ClientChannel: Connection to service closed. svcid=%s", GetAddress().target.c_str() );
  CloseClientChannel();
}

void ClientChannel::OnConnectionFailed( ni_udp::IRdpConnection * _conn )
{
  Channel::OnConnectionFailed( _conn );

  threading::MutexLock lock(mutex);
  ErrorTrace( "ClientChannel: Connection to service failed. svcid=%s", GetAddress().target.c_str() );
  CloseClientChannel();
}

void ClientChannel::OnDatagram( ni_udp::IRdpConnection * _conn, const void * _data, size_t _size, timer::Time _absRecvTime )
{
  EClientChanState::Enum currentState = EClientChanState::Closed;

  {
    threading::MutexLock lock(mutex);
    
    if ( state == EClientChanState::WaitingSvcAck )
    {
      if ( !ValidateData(_data, static_cast<int>(_size)) )
      {
        ErrorTrace( "ClientChannel: Invalid datagram from svc connection. svcid=%s, req_id=%d, size=%d", 
                   GetAddress().target.c_str(), requestId, _size );
        CloseClientChannel();
        return;
      }

      NI_VERIFY( dispatcher, "", return );
      StrongMT<Network::PacketDispatcher> keeper = dispatcher;
      if ( !keeper->Dispatch( _data, _size ) )
      {
        ErrorTrace( "ClientChannel: Broken datagram from svc connection. svcid=%s, req_id=%d, size=%d", 
                   GetAddress().target.c_str(), requestId, _size );
        CloseClientChannel();
        return;
      }
    }
    else if ( state == EClientChanState::Active )
    {
      currentState = state;
    }
    else
    {
      ErrorTrace( "ClientChannel: Unexpected datagram in channel. svcid=%s, req_id=%d, size=%d", 
                 GetAddress().target.c_str(), requestId, _size );
      CloseClientChannel();
      return;
    }
  }

  if ( currentState == EClientChanState::Active )
    Channel::OnDatagram( _conn, _data, _size, _absRecvTime );
}

Network::ConnectionState::Enum ClientChannel::GetStatus() const
{
  threading::MutexLock lock(mutex);
  
  switch ( state )
  {
    case EClientChanState::WaitingSvcAddr:
    case EClientChanState::ConnectingToSvc:
    case EClientChanState::WaitingSvcAck:
      return Network::ConnectionState::Connecting;

    case EClientChanState::Closed:
      return Network::ConnectionState::Closed;

    case EClientChanState::Active:
      {
        Network::ConnectionState::Enum channelStatus = Channel::GetStatus();
        return (channelStatus == Network::ConnectionState::Connected) ? 
               Network::ConnectionState::Connected : 
               Network::ConnectionState::Closed;
      }

    default:
      return Network::ConnectionState::Invalid;
  }
}

void ClientChannel::SendRaw( const byte * _data, int _size )
{
  if ( !ValidateData(_data, _size) )
  {
    ErrorTrace( "ClientChannel: Trying to send invalid data. svcid=%s, size=%d", 
               GetAddress().target.c_str(), _size );
    return;
  }

  EClientChanState::Enum currentState = EClientChanState::Closed;
  {
    threading::MutexLock lock(mutex);
    currentState = state;
  }

  if ( currentState == EClientChanState::Closed )
  {
    ErrorTrace( "ClientChannel: Trying to write to closed channel. svcid=%s, state=%d", 
               GetAddress().target.c_str(), (int)currentState );
    return;
  }

  if ( currentState == EClientChanState::Active )
    Channel::SendRaw( _data, _size );
  else
    PostponeMsg( _data, _size );
}

bool ClientChannel::Poll( timer::Time _now )
{
  threading::MutexLock lock(mutex);
  timeout.Poll();

  // Продолжаем опрос, если канал не в финальном состоянии
  return (state != EClientChanState::Closed);
}

void ClientChannel::Switch( EClientChanState::Enum _st )
{
  state = _st;
  timeout.Stop();
}

void ClientChannel::OnTimeout()
{
  ErrorTrace( "ClientChannel: State timed out. svcid=%s, req_id=%d, state=%d", 
             GetAddress().target.c_str(), requestId, (int)state );
  CloseClientChannel();
}

void ClientChannel::OnHelloReply( const newLogin::FrontendHelloReply & _reply )
{
  MessageTrace( "ClientChannel: Got service ack. svcid=%s, req_id=%d, code=%s(%d), state=%d", 
               GetAddress().target.c_str(), requestId, 
               newLogin::ESvcConnectionResult::ToString( _reply.code ), (int)_reply.code, (int)state );

  threading::MutexLock lock(mutex);

  if ( state != EClientChanState::WaitingSvcAck )
  {
    ErrorTrace( "ClientChannel: Unexpected service ack. svcid=%s, req_id=%d, state=%d", 
               GetAddress().target.c_str(), requestId, (int)state );
    CloseClientChannel();
    return;
  }

  if ( _reply.code != newLogin::ESvcConnectionResult::Ok )
  {
    ErrorTrace( "ClientChannel: Service refused connection. svcid=%s, req_id=%d, code=%d", 
               GetAddress().target.c_str(), requestId, (int)_reply.code );
    CloseClientChannel();
    return;
  }

  dispatcher = 0;
  writer = 0;

  Switch( EClientChanState::Active );
  DelayedActiveConnectionEstablished();
}

void ClientChannel::CloseClientChannel()
{
  Close();
  Switch( EClientChanState::Closed );
}

} // namespace rdp_transport