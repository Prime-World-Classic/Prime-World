#include "stdafx.h"
#include "RdpClientTransport.h"
#include "Network/RUDP/SockSrvWinsockBlocking.h"
#include "Network/RUDP/IRdp.h"
#include "Server/RdpTransport/RdpTransportChannel.h"
#include "Server/RdpTransport/RdpSocketFactory.h"
#include "Server/RdpTransport/RdpTransportMsg.h"
#include "System/RandomInterfaceImpl.h"
#include "RdpLoginClient.h"
#include "System/NiTimer.h"
#include "System/InlineProfiler.h"

namespace rdp_transport
{

// Конфигурационные переменные
static TransportConfig s_transportConfig;
REGISTER_VAR( "login_timeout", s_transportConfig.loginTimeout, STORAGE_NONE );
REGISTER_VAR( "login_chann_timeout", s_transportConfig.channelTimeout, STORAGE_NONE );
REGISTER_VAR( "rdp_log_events", s_transportConfig.rdpLogEvents, STORAGE_NONE );
REGISTER_VAR( "rdp_logic_priority", s_transportConfig.logicPriority, STORAGE_NONE );
REGISTER_VAR( "rdp_sock_server_priority", s_transportConfig.sockServPriority, STORAGE_NONE );
REGISTER_VAR( "rdp_sock_buffer_size", s_transportConfig.sockBufferSize, STORAGE_NONE );

class ClientTransport::Worker : public threading::IThreadJob, public BaseObjectMT
{
  NI_DECLARE_REFCOUNT_CLASS_2( Worker, threading::IThreadJob, BaseObjectMT );
public:
  Worker( ClientTransport * _owner ) : owner( _owner ) {}
private:
  ClientTransport * owner;

  virtual void Work( volatile bool & isRunning )
  {
    NI_PROFILE_THREAD;

    while ( isRunning )
    {
      owner->ParallelPoll();
      Sleep( 100 );
    }
  }
};

ClientTransport::ClientTransport( const ni_udp::NetAddr & _bindAddr, unsigned _portSearchRange, Transport::MessageFactory * _msgFactory ) :
  bindAddr( _bindAddr ),
  portSearchRange( _portSearchRange )
{
  commonCtx.msgFactory = _msgFactory;
  commonCtx.schedule = 0;
  commonCtx.allocator = new HeapAllocator;
}

ClientTransport::~ClientTransport()
{
  Logout();
}

void ClientTransport::Cleanup()
{
  rdp = 0;
  sockServer = 0;
  loginClient = 0;
}

void ClientTransport::ParallelPoll()
{
  StrongMT<LoginClient> localClient;
  
  {
    threading::MutexLock lock(mutex);
    if ( !loginClient )
      return;
    localClient = loginClient;
  }

  timer::Time now = timer::Now();
  localClient->ParallelPoll( now );
}

bool ClientTransport::InitializeNetworkStack(const ni_udp::NetAddr& loginSvcAddr)
{
  // ИСПОЛЬЗУЕМ s_transportConfig вместо config
  sockServer = new ni_udp::BlockingUdpSocketServer( s_transportConfig.sockServPriority, s_transportConfig.sockBufferSize );
  if ( !sockServer )
    return false;

  Strong<ni_rnd::Factory> rndFact = new ni_rnd::Factory;
  StrongMT<SocketFactory> sockFact = new SocketFactory( sockServer, bindAddr, portSearchRange, rndFact->Produce( timer::GetTicks() & 0xffffffffu ) );

  ni_udp::RdpOptions opts;
  opts.logEvents = s_transportConfig.rdpLogEvents;
  opts.logicThreadPriority = s_transportConfig.logicPriority;

  rdp = ni_udp::NewRdpInstance();
  if ( !rdp || !rdp->Init( sockFact, opts, rndFact->Produce( (unsigned)timer::GetTicks() ), new timer::RealTimer ) )
    return false;

  return true;
}

int ClientTransport::GetUserId() const
{
  threading::MutexLock lock(mutex);

  if ( !loginClient )
    return 0;

  return loginClient->LoginSvcReply().uid;
}

StrongMT<Transport::IChannel> ClientTransport::OpenChannel( Transport::TServiceId interfaceId, unsigned int pingperiod, unsigned int to )
{
  threading::MutexLock lock(mutex);

  if ( !loginClient )
    return 0;

  if ( loginClient->State() != ELoginClientState::Ready )
    return 0;

  return loginClient->NewSvcChannel( commonCtx, interfaceId );
}

void ClientTransport::GetNewAcceptedChannels(vector<StrongMT<Transport::IChannel>> & _chnls)
{
  // Реализация для принятых каналов
  _chnls.clear();
}

void ClientTransport::Login( const Network::NetAddress & _loginServerAddress, const nstl::string & _login, const nstl::string & _password, const nstl::string & _sessionKey, Login::LoginType::Enum _loginType )
{
  threading::MutexLock initLock(initShutdownMutex);
  thread = 0;

  {
    threading::MutexLock stateLock(mutex);
    Cleanup();
  }

  ni_udp::NetAddr loginSvcAddr;
  unsigned loginSvcMux = 0;
  if ( !ParseAddress( loginSvcAddr, loginSvcMux, _loginServerAddress.c_str() ) )
    return;

  if ( loginSvcAddr.Address() == INADDR_ANY )
    loginSvcAddr.Set( "localhost", loginSvcAddr.Port() );

  if ( !InitializeNetworkStack(loginSvcAddr) )
    return;

  {
    threading::MutexLock lock(mutex);
    // ИСПОЛЬЗУЕМ s_transportConfig вместо config
    loginClient = new LoginClient( rdp, loginSvcAddr, loginSvcMux, _login, _password, _sessionKey, s_transportConfig.loginTimeout );
  }

  thread = new threading::JobThread( new Worker( this ), "ClientTransport" );
}

void ClientTransport::Logout()
{
  threading::MutexLock initLock(initShutdownMutex);
  thread = 0;

  threading::MutexLock stateLock(mutex);
  Cleanup();
}

Login::ELoginResult::Enum ClientTransport::GetLoginResult() const
{
  threading::MutexLock lock(mutex);

  if ( loginClient )
  {
    ELoginClientState::Enum clSt = loginClient->State();
    if ( ( clSt == ELoginClientState::Ready ) || ( clSt == ELoginClientState::Failed ) )
      return loginClient->LoginSvcReply().code;
  }

  return Login::ELoginResult::NoResult;
}

Transport::EStatus::Enum ClientTransport::GetStatus()
{
  threading::MutexLock lock(mutex);

  if ( !loginClient )
    return Transport::EStatus::NONE;

  ELoginClientState::Enum clSt = loginClient->State();

  if ( clSt == ELoginClientState::Ready )
    return Transport::EStatus::OK;

  if ( clSt == ELoginClientState::Failed )
    return Transport::EStatus::FAIL;

  return Transport::EStatus::NONE;
}

Transport::TServiceId ClientTransport::GetSessionPath() const
{
  threading::MutexLock lock(mutex);

  if ( !loginClient )
    return Transport::TServiceId();

  return loginClient->LoginSvcReply().welcomingSvcId.c_str();
}

Network::NetAddress ClientTransport::GetRelayAddress() const
{
  threading::MutexLock lock(mutex);

  if ( !loginClient )
    return Network::NetAddress();

  char buf[128] = "";
  loginClient->LoginSvcAddr().Str( buf, 128 );

  return buf;
}

Network::NetAddress ClientTransport::GetSecondaryRelayAddress() const
{
  return Network::NetAddress();
}

} // namespace rdp_transport