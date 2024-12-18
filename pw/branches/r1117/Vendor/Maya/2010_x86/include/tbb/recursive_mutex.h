/*
    Copyright 2005-2009 Intel Corporation.  All Rights Reserved.

    The source code contained or described herein and all documents related
    to the source code ("Material") are owned by Intel Corporation or its
    suppliers or licensors.  Title to the Material remains with Intel
    Corporation or its suppliers and licensors.  The Material is protected
    by worldwide copyright laws and treaty provisions.  No part of the
    Material may be used, copied, reproduced, modified, published, uploaded,
    posted, transmitted, distributed, or disclosed in any way without
    Intel's prior express written permission.

    No license under any patent, copyright, trade secret or other
    intellectual property right is granted to or conferred upon you by
    disclosure or delivery of the Materials, either expressly, by
    implication, inducement, estoppel or otherwise.  Any license under such
    intellectual property rights must be express and approved by Intel in
    writing.
*/

#ifndef __TBB_recursive_mutex_H
#define __TBB_recursive_mutex_H

#if _WIN32||_WIN64

#include <windows.h>
#if !defined(_WIN32_WINNT)
// The following Windows API function is declared explicitly;
// otherwise any user would have to specify /D_WIN32_WINNT=0x0400
extern "C" BOOL WINAPI TryEnterCriticalSection( LPCRITICAL_SECTION );
#endif

#else /* if not _WIN32||_WIN64 */

#include <pthread.h>
namespace tbb { namespace internal {
// Use this internal TBB function to throw an exception
  extern void handle_perror( int error_code, const char* what );
} } //namespaces

#endif /* _WIN32||_WIN64 */

#include "tbb_stddef.h"
#include "tbb_profiling.h"

namespace tbb {
//! Mutex that allows recursive mutex acquisition.
/** Mutex that allows recursive mutex acquisition.
    @ingroup synchronization */
class recursive_mutex {
public:
    //! Construct unacquired recursive_mutex.
    recursive_mutex() {
#if TBB_USE_ASSERT || TBB_USE_THREADING_TOOLS
        internal_construct();
#else
  #if _WIN32||_WIN64
        InitializeCriticalSection(&impl);
  #else
        pthread_mutexattr_t mtx_attr;
        int error_code = pthread_mutexattr_init( &mtx_attr );
        if( error_code )
            tbb::internal::handle_perror(error_code,"recursive_mutex: pthread_mutexattr_init failed");

        pthread_mutexattr_settype( &mtx_attr, PTHREAD_MUTEX_RECURSIVE );
        error_code = pthread_mutex_init( &impl, &mtx_attr );
        if( error_code )
            tbb::internal::handle_perror(error_code,"recursive_mutex: pthread_mutex_init failed");

        pthread_mutexattr_destroy( &mtx_attr );
  #endif /* _WIN32||_WIN64*/
#endif /* TBB_USE_ASSERT */
    };

    ~recursive_mutex() {
#if TBB_USE_ASSERT
        internal_destroy();
#else
  #if _WIN32||_WIN64
        DeleteCriticalSection(&impl);
  #else
        pthread_mutex_destroy(&impl); 

  #endif /* _WIN32||_WIN64 */
#endif /* TBB_USE_ASSERT */
    };

    class scoped_lock;
    friend class scoped_lock;

    //! The scoped locking pattern
    /** It helps to avoid the common problem of forgetting to release lock.
        It also nicely provides the "node" for queuing locks. */
    class scoped_lock: internal::no_copy {
    public:
        //! Construct lock that has not acquired a recursive_mutex. 
        scoped_lock() : my_mutex(NULL) {};

        //! Acquire lock on given mutex.
        /** Upon entry, *this should not be in the "have acquired a mutex" state. */
        scoped_lock( recursive_mutex& mutex ) {
            acquire( mutex );
        }

        //! Release lock (if lock is held).
        ~scoped_lock() {
            if( my_mutex ) 
                release();
        }

        //! Acquire lock on given mutex.
        void acquire( recursive_mutex& mutex ) {
#if TBB_USE_ASSERT
            internal_acquire( mutex );
#else
            my_mutex = &mutex;
  #if _WIN32||_WIN64
            EnterCriticalSection(&mutex.impl);
  #else
            pthread_mutex_lock( &mutex.impl );
  #endif /* _WIN32||_WIN64 */
#endif /* TBB_USE_ASSERT */
        }

        //! Try acquire lock on given recursive_mutex.
        bool try_acquire( recursive_mutex& mutex ) {
#if TBB_USE_ASSERT
            return internal_try_acquire( mutex );
#else
            bool result;
  #if _WIN32||_WIN64
            result = TryEnterCriticalSection(&mutex.impl)!=0;
  #else
            result = pthread_mutex_trylock(&mutex.impl)==0;
  #endif /* _WIN32||_WIN64 */
            if( result )
                my_mutex = &mutex;

            return result;
#endif /* TBB_USE_ASSERT */
        }

        //! Release lock
        void release() {
#if TBB_USE_ASSERT
            internal_release ();
#else
  #if _WIN32||_WIN64
            LeaveCriticalSection(&my_mutex->impl);
  #else
            pthread_mutex_unlock(&my_mutex->impl);
  #endif /* _WIN32||_WIN64 */
            my_mutex = NULL;
#endif /* TBB_USE_ASSERT */
        }

    private:
        //! The pointer to the current recursive_mutex to work
        recursive_mutex* my_mutex;

        //! All checks from acquire using mutex.state were moved here
        void __TBB_EXPORTED_METHOD internal_acquire( recursive_mutex& m );

        //! All checks from try_acquire using mutex.state were moved here
        bool __TBB_EXPORTED_METHOD internal_try_acquire( recursive_mutex& m );

        //! All checks from release using mutex.state were moved here
        void __TBB_EXPORTED_METHOD internal_release();
    };

    // Mutex traits
    static const bool is_rw_mutex = false;
    static const bool is_recursive_mutex = true;
    static const bool is_fair_mutex = false;

private:
#if _WIN32||_WIN64
    CRITICAL_SECTION impl;
    enum state_t {
        INITIALIZED=0x1234,
        DESTROYED=0x789A,
    } state;
#else
    pthread_mutex_t impl;
#endif /* _WIN32||_WIN64 */

    //! All checks from mutex constructor using mutex.state were moved here
    void __TBB_EXPORTED_METHOD internal_construct();

    //! All checks from mutex destructor using mutex.state were moved here
    void __TBB_EXPORTED_METHOD internal_destroy();
};

__TBB_DEFINE_PROFILING_SET_NAME(recursive_mutex)

} // namespace tbb 

#endif /* __TBB_recursive_mutex_H */
