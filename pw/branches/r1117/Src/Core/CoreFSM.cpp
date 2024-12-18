#include "stdafx.h"
#include "CoreFSM.h"
#include "../System/Functor.h"
#include "../System/InlineProfiler.h"
#include "BaseState.h"

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
namespace NCore
{

CoreFSM::CoreFSM()
{
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void CoreFSM::Init()
{
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void CoreFSM::SetState( IBaseFSMState* state )
{
  CFSMBase::SetState( state );
  const StateId id = state->GetTypeId();
  //
  NI_ASSERT( id != -1, NStr::StrFmt( "Unknown type id = %d!", id ) );
  if( messages.find( id ) != messages.end() )
    PushMessageFromCore( messages[id]() );
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void CoreFSM::Step(float dt)
{
  NI_PROFILE_FUNCTION

    // process messages from subscribers
    updatesFromUI.Step();

  // change FSM state
  CFSMBase::Step(dt);

  // send messages to subcribers
  updatesToUI.Step();
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void CoreFSM::RegisterProcessorToCore( Updater::CUpdateProcessor *pProcessor )
{
  updatesFromUI.Register( pProcessor );
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void CoreFSM::RegisterProcessorFromCore( Updater::CUpdateProcessor *pProcessor )
{
  updatesToUI.Register( pProcessor );
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void CoreFSM::RegisterToCore( int id, Updater::IUpdateProcessorFunc* functor )
{
  updatesFromUI.Register( id, functor );		
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void CoreFSM::RegisterFromCore( int id, Updater::IUpdateProcessorFunc* functor )
{
  updatesToUI.Register( id, functor );
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void CoreFSM::PushMessageToCore( CObjectBase *pMsg )
{
  CPtr<CObjectBase> pGarbage = pMsg;
  systemLog( NLogg::LEVEL_DEBUG ) << "*** Pushed message to core SM: " << pMsg->GetObjectTypeName();
  updatesFromUI.Push( pMsg, true );
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void CoreFSM::PushMessageFromCore( CObjectBase *pMsg )
{
  CPtr<CObjectBase> pGarbage = pMsg;
  systemLog( NLogg::LEVEL_DEBUG ) << "*** Pushed message from core SM: " << pMsg->GetObjectTypeName() << endl;
  updatesToUI.Push( pMsg, true );
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void CoreFSM::RegisterMessageBuilder( StateId id, MessageBuilder builder )
{
  messages[id] = builder;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
static CObj<CoreFSM>& _GetGlobalGameFSM()
{
  static CObj<CoreFSM> stateMachine = new CoreFSM();
  static bool initialized = false;

  if ( !initialized )
  {
    stateMachine->Init();
    initialized = true;
  }

  return stateMachine;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
CoreFSM* GetGlobalGameFSM()
{
  if ( !IsValid( _GetGlobalGameFSM() ) )
    return 0;

  return _GetGlobalGameFSM();
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void ReleaseGlobalGameFSM()
{
  CObj<CoreFSM> deleteFSM = _GetGlobalGameFSM().Extract();
}

} //namespace NCore

BASIC_REGISTER_CLASS( NCore::CoreFSM );
