/* -*- c++ -*- */
// $Id: SS_State_WRITE.h 80826 2008-03-04 14:51:23Z wotte $

#ifndef TERA_SS_STATE_WRITE_H
#define TERA_SS_STATE_WRITE_H

#include "ace/OS.h"
#include "ace/Singleton.h"

#include "jaws3/Protocol_Handler.h"

class TeraSS_State_WRITE : public JAWS_Protocol_State
{
public:

  int service (JAWS_Event_Completer *, void *data);

  JAWS_Protocol_State * transition ( const JAWS_Event_Result &result
                                   , void *data
                                   , void *act
                                   );

  static JAWS_Protocol_State * instance (void)
  {
    return ACE_Singleton<TeraSS_State_WRITE, ACE_SYNCH_MUTEX>::instance ();
  }

};

#endif /* TERA_SS_STATE_WRITE_H */
