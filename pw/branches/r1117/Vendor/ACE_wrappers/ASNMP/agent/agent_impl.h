/* -*- C++ -*- */
// $Id: agent_impl.h 80826 2008-03-04 14:51:23Z wotte $

// ============================================================================
//
// = LIBRARY
//    ASNMP
//
// = FILENAME
//    agent_impl.h
//
// = AUTHOR
//    Michael R. MacFaden
//
// ============================================================================

#ifndef AGENT_IMPL_H
#define AGENT_IMPL_H

#include <ace/Event_Handler.h>
#include <ace/SOCK_Dgram.h>
#include <ace/INET_Addr.h>
#include <ace/High_Res_Timer.h>
#include <asnmp/sagent.h>
#include <asnmp/vb.h>

class agent_impl : public sagent
{
public:
  agent_impl(unsigned short port, const char *rd, const char *wr);
  virtual ~agent_impl();

  virtual int handle_get( Pdu &pdu, UdpTarget &target);
  // retrieve data from a peer agent for a given list of oid values

  virtual int handle_get_next( Pdu &pdu, UdpTarget &target);
  // retrieve data lexically adjacent to the oids specified in the pdu
  // from the peer agent

  virtual int handle_set( Pdu &pdu, UdpTarget &target);
  // set data in the agent from the list of oids in the pdu

  int process_requests();
  // main loop here using a reactor object

private:
  UdpTarget tgt_;  // this agent's read, write community strings
  int get_response(Vb& vb);     // set values for a "get" cmd
  ACE_High_Res_Timer agent_clock_; // agent "uptime" ticks reported in 1/100 second
};

#endif /* AGENT_IMPL_H */
