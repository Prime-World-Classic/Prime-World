#include "naio/stdafx.h"
#include "IOTerabit/ChannelManager.h"
#include "IOTerabit/IOThreadPool.h"
#include "IOTerabit/Protocol.h"

#include "naio/Channel.h"
#include "naio/Acceptor.h"

using namespace Terabit;

namespace naio
{

Acceptor::Acceptor(IOThreadPool &     task,
                  ProtocolFactory &  protocol_factory, 
                  ChannelManager &   manager)
: ChannelAcceptor(task, protocol_factory, manager)
, task_             (task)
, protocol_factory_ (protocol_factory)
, manager_          (manager)
{
}

Acceptor::~Acceptor()
{
}

int Acceptor::start (const ACE_Addr & addr,
           void* act,
           int num_initial_accepts,
           int bytes_to_read)
{
  act_ = act;
  return Terabit::ChannelAcceptor::start(addr, num_initial_accepts, bytes_to_read);
}

int Acceptor::on_accept_completed (const TRB_Asynch_Accept::Result &result)
{
  //
  //  copy/paste of ChannelAcceptor::on_accept_completed with couple changes 
  //  changes are marked as <-- -->
  //
  bool  success = result.success ();
  //  <-- changes here : begin -->
  if (!success) //  handle only success accept
  {
    ACE_ERROR ((LM_WARNING,
      ACE_TEXT ("%s: FAILED. System error %d"),
      __FUNCTION__,
      result.error()));

    return -1;
  }

  const void * act = act_; //result.act ();
  //  <-- changes here : end -->

  const ACE_Addr & local_addr = result.local_address ();
  const ACE_Addr & remote_addr = result.remote_address ();

  int rc = this->protocol_factory_.validate_connection (success,
                                                        remote_addr,
                                                        local_addr,
                                                        act);
  if (!success || rc != 0)  // accept/connect failure
  {                         // or factory rejected to process
      return -1;            // new connection
  }


  AsynchChannelPtr  channel = this->manager_.allocate_channel ();
  if (!channel)
  {
      return -1;
  }

  channel->addresses (remote_addr, local_addr);
  //  <-- changes here : begin -->
  if (ChannelAcceptor::get_log_level () < 2)
  //  <-- changes here : end -->
  {
      ACE_TCHAR str_peer [256];
      ACE_TCHAR str_local[256];

      TRB_Sock_Addr::to_string (remote_addr, str_peer, sizeof (str_peer)/sizeof (ACE_TCHAR));
      TRB_Sock_Addr::to_string (local_addr, str_local, sizeof (str_local)/sizeof (ACE_TCHAR));

      ACE_DEBUG ((LM_INFO,
            ACE_TEXT ("ACCEPTED channel id=(S)%d remote=%s local=%s"),
            channel->get_id (),
            str_peer,
            str_local));
  }

  ACE_HANDLE handle = result.accept_handle ();
  rc = channel->open (handle, true);
  if (rc < 0)
  {
      return 0;  // open failed, but handle ownership must be taken
  }

  // ownership of handle is taken
  Protocol *protocol = protocol_factory_.create_protocol (act);
  if (!protocol)
  {
      channel->close ();
      return 0;
  }

  const ACE_Message_Block *mb   = result.get_message_block_ptr ();
  int                      len  = mb ? mb->length () : 0;
  const char              *data = len ? mb->rd_ptr () : 0;

  //  <-- changes here : begin -->
  (static_cast<naio::Channel*>(channel.get()))->activate_protocol (protocol, data, len);
  //  <-- changes here : end -->

  return 0;
}

}
