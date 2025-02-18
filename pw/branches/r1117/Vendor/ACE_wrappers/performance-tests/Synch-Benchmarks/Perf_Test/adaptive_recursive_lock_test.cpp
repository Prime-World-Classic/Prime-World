// $Id: adaptive_recursive_lock_test.cpp 80826 2008-03-04 14:51:23Z wotte $

#define  ACE_BUILD_SVC_DLL
#include "ace/Log_Msg.h"
#include "Adaptive_Lock_Performance_Test_Base.h"
#include "ace/Lock_Adapter_T.h"
#include "ace/Recursive_Thread_Mutex.h"

ACE_RCSID(Synch_Benchmarks, adaptive_recursive_lock_test, "$Id: adaptive_recursive_lock_test.cpp 80826 2008-03-04 14:51:23Z wotte $")

#if defined (ACE_HAS_THREADS)

class ACE_Svc_Export Adaptive_Recursive_Lock_Test : public Adaptive_Lock_Performance_Test_Base
{
public:
  virtual int init (int, ACE_TCHAR *[]);
};

int
Adaptive_Recursive_Lock_Test::init (int, ACE_TCHAR *[])
{
  ACE_Lock *lock;
  ACE_NEW_RETURN (lock,
                  ACE_Lock_Adapter<ACE_Recursive_Thread_Mutex> (),
                  -1);

  return this->set_lock (lock);
}

ACE_SVC_FACTORY_DECLARE (Adaptive_Recursive_Lock_Test)
ACE_SVC_FACTORY_DEFINE  (Adaptive_Recursive_Lock_Test)

#endif /* ACE_HAS_THREADS */
