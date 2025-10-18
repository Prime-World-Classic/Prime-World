#include "stdafx.h"
#include "RdpLoginClient.h"
#include "Server/RdpTransport/RdpTransportUtils.h"
#include "Network/PacketDispatcher.h"
#include "RdpClientChannel.h"
#include "PW_Game/server_ip.h"

namespace rdp_transport
{

#pragma warning( disable: 4355 )

LoginClient::LoginClient( ni_udp::IRdp * _rdp, const ni_udp::NetAddr & _loginSvcAddr, unsigned _loginSvcMux, 
                         const nstl::string & _login, const nstl::string & _password, const nstl::string & _sessionKey, float _operationTimeout ) :
  state( ELoginClientState::Connecting ),
  login( _login ),
  password( _password ),
  sessionKey( _sessionKey ),
  loginSvcAddr( _loginSvcAddr ),
  operationTimeout( _operationTimeout ),
  rdp( _rdp ),
  timeout( _operationTimeout, this, &LoginClient::OnTimeout ),
  nextChanReqId( 1 )
{
  dispatcher = new Network::PacketDispatcher;
  dispatcher->AddHandler( this, &LoginClient::OnHelloReply );
  dispatcher->AddHandler( this, &LoginClient::OnSvcReqReply );

  connection = rdp->Connect( _loginSvcAddr, _loginSvcMux, this );
  writer = new PacketWriter( connection );
}

bool LoginClient::ValidateDatagram(const void* data, size_t size) const
{
  return data != NULL && size > 0 && size <= Constants::MAX_PACKET_SIZE;
}

void LoginClient::SafeUpdateServiceAddress(newLogin::ServiceReqReply& reply) const
{
    // ДОБАВИТЬ ПРОВЕРКУ ДОСТУПНОСТИ SERVER_IP_ARRAY
    #ifdef SERVER_IP_ARRAY_SIZE
    if (usedServer < 0 || usedServer >= SERVER_IP_ARRAY_SIZE) {
        ErrorTrace("LoginClient: Invalid server index: %d", usedServer);
        return;
    }
    #endif

    const char* port = std::find(reply.externalAddress.begin(), reply.externalAddress.end(), ':');
    size_t portSize = 0;
    
    if (port != reply.externalAddress.end())
    {
        portSize = strlen(port);
    }

    if (portSize > 0) 
    {
        char newAddress[Constants::MAX_BUFFER_SIZE] = {0};
        const char* whiteIp = SERVER_IP_ARRAY[usedServer];
        
        // БЕЗОПАСНОЕ КОПИРОВАНИЕ - ИСПРАВЛЕННЫЙ ОТСТУП
        strncpy(newAddress, whiteIp, Constants::MAX_BUFFER_SIZE - 1);
        newAddress[Constants::MAX_BUFFER_SIZE - 1] = '\0';
        strncat(newAddress, port, Constants::MAX_BUFFER_SIZE - strlen(newAddress) - 1);
        
        reply.externalAddress = newAddress;
    } 
    else 
    {
        nstl::string newAddress = SERVER_IP_ARRAY[usedServer];
        newAddress += ':';
        newAddress += reply.externalAddress;
        reply.externalAddress = newAddress;
    }
}

void LoginClient::ParallelPoll( timer::Time _now )
{
  threading::MutexLock lock(mutex);

  timeout.Poll();

  for ( TChannelsByReqId::iterator it = channelsByReqId.begin(); it != channelsByReqId.end(); )
  {
    ClientChannel * chan = it->second;

    if ( chan->Poll( _now ) )
    {
      ++it;
    }
    else
    {
      MessageTrace( "LoginClient: Stopping channel poll. svcid=%s, req_id=%d", chan->GetAddress().target.c_str(), chan->RequestId() );
      TChannelsByReqId::iterator toErase = it;
      ++it;
      channelsByReqId.erase( toErase );
    }
  }
}

ELoginClientState::Enum LoginClient::State()
{
  threading::MutexLock lock(mutex);
  return state;
}

void LoginClient::Switch( ELoginClientState::Enum _st )
{
  state = _st;
}

void LoginClient::Fail( Login::ELoginResult::Enum _result )
{
  if ( state == ELoginClientState::Failed )
    return;

  Switch( ELoginClientState::Failed );
  loginSvcReply.code = _result;
  connection = 0;
}

newLogin::LoginReply LoginClient::LoginSvcReply() const
{
  threading::MutexLock lock(mutex);
  return loginSvcReply;
}

StrongMT<Transport::IChannel> LoginClient::NewSvcChannel( const CommonCtx & _ctx, const Transport::TServiceId & _svcId )
{
  threading::MutexLock lock(mutex);

  NI_VERIFY( state == ELoginClientState::Ready, "", return 0 );

  int reqId = nextChanReqId++;

  MessageTrace( "LoginClient: Creating outgoing service channel. svcid=%s, req_id=%d", _svcId.c_str(), reqId );
  Transport::Address ta( Transport::TServiceId(), _svcId, loginSvcReply.uid );
  StrongMT<ClientChannel> chan = new ClientChannel( rdp, _ctx, ta, reqId, operationTimeout );
  
  StrongMT<ClientChannel> & slot = channelsByReqId[reqId];
  NI_ASSERT( !slot.Valid(), "" );
  slot = chan;

  newLogin::ServiceRequest svcReq;
  svcReq.requestId = reqId;
  svcReq.svcId = _svcId;
  writer->Send( svcReq );

  return chan.Get();
}

void LoginClient::OnConnectionEstablished( ni_udp::IRdpConnection * _conn )
{
  threading::MutexLock lock(mutex);

  if ( state == ELoginClientState::Failed )
    return;

  if ( state != ELoginClientState::Connecting )
  {
    ErrorTrace( "LoginClient: Unexpected connection. st=%d", (int)state );
    Fail( Login::ELoginResult::NoResult );
    return;
  }

  newLogin::LoginHello hello;
  hello.clientRevision = 0; //TODO
  hello.protocolVersion = 0; //TODO
  hello.login = login;
  hello.password = password;
  hello.sessionkey = sessionKey;

  writer->Send( hello );
  Switch( ELoginClientState::WaitingReply );
}

void LoginClient::OnConnectionClosed( ni_udp::IRdpConnection * _conn )
{
  MessageTrace( "LoginClient: Connection closed" );
  threading::MutexLock lock(mutex);
  Fail( Login::ELoginResult::NoConnection );
}

void LoginClient::OnConnectionFailed( ni_udp::IRdpConnection * _conn )
{
  ErrorTrace( "LoginClient: Connection failed" );
  threading::MutexLock lock(mutex);
  Fail( Login::ELoginResult::NoConnection );
}

void LoginClient::OnDatagram( ni_udp::IRdpConnection * _conn, const void * _data, size_t _size, timer::Time _absRecvTime )
{
  threading::MutexLock lock(mutex);

  if ( state == ELoginClientState::Failed )
    return;

  if ( !ValidateDatagram(_data, _size) )
  {
    ErrorTrace( "LoginClient: Invalid datagram. size=%d", _size );
    Fail( Login::ELoginResult::ServerOutdated );
    return;
  }

  if ( !dispatcher->Dispatch( _data, _size ) )
  {
    ErrorTrace( "LoginClient: Broken datagram" );
    Fail( Login::ELoginResult::ServerOutdated );
    return;
  }
}

void LoginClient::OnHelloReply( const newLogin::LoginReply & _reply )
{
  MessageTrace( "LoginClient: Got login reply. code=%s(%d), uid=%d, welcome=%s", 
               Login::ELoginResult::ToString( _reply.code ), (int)_reply.code, _reply.uid, _reply.welcomingSvcId.c_str() );

  threading::MutexLock lock(mutex);

  if ( state == ELoginClientState::Failed )
    return;

  if ( state != ELoginClientState::WaitingReply )
  {
    Fail( Login::ELoginResult::NoResult );
    return;
  }

  loginSvcReply = _reply;
  if ( loginSvcReply.code != Login::ELoginResult::Success )
  {
    WarningTrace( "LoginClient: Login failed!" );
    Fail( loginSvcReply.code );
    return;
  }

  Switch( ELoginClientState::Ready );
  timeout.Stop();
}

void LoginClient::OnTimeout()
{
  threading::MutexLock lock(mutex);
  ErrorTrace( "LoginClient: Operation timed out. state=%d", (int)state );
  Fail( Login::ELoginResult::AsyncTimeout );
}

void LoginClient::OnSvcReqReply( const newLogin::ServiceReqReply  & _reply )
{
  // Создаем копию для модификации
  newLogin::ServiceReqReply modifiedReply = _reply;
  SafeUpdateServiceAddress(modifiedReply);
  
  MessageTrace( "LoginClient: Got svc request reply. svcid=%s, req_id=%d, code=%d, addr=%s", 
               modifiedReply.svcId.c_str(), modifiedReply.requestId, (int)modifiedReply.code, modifiedReply.externalAddress.c_str() );

  threading::MutexLock lock(mutex);

  if ( state != ELoginClientState::Ready )
  {
    ErrorTrace( "LoginClient: Unexpected svc request reply. svcid=%s, req_id=%d, state=%d", 
               modifiedReply.svcId.c_str(), modifiedReply.requestId, (int)state );
    return;
  }

  TChannelsByReqId::iterator it = channelsByReqId.find( modifiedReply.requestId );
  if ( it == channelsByReqId.end() )
  {
    WarningTrace( "LoginClient: Svc reqest reply for unknown request id. svcid=%s, req_id=%d", 
                 modifiedReply.svcId.c_str(), modifiedReply.requestId );
    return;
  }

  ClientChannel * chan = it->second;
  chan->OnSvcRequestReply( modifiedReply );
}

} // namespace rdp_transport