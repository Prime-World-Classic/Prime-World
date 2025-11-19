#include "stdafx.h"
#include "StarForce.h"

#pragma code_seg(push, "~")

// Закомментировать ВЕСЬ блок включая #ifdef
//#ifdef STARFORCE_PROTECTED
//  #include "StarForce/PsaApi.h"
//  #include "../AsyncInvoker.h"
//#endif

namespace Protection
{
// Закомментировать ВЕСЬ блок STARFORCE_PROTECTED
//#ifdef STARFORCE_PROTECTED
//
// ... весь код внутри ...
//
//#endif  // STARFORCE_PROTECTED

STARFORCE_EXPORT void CheckReadOnlyAndExecutable()
{
//#ifdef STARFORCE_PROTECTED
    // Пустая реализация
//#endif 
}

STARFORCE_EXPORT bool CheckReadOnlyAndExecutableImmediate()
{
    return true;
}

STARFORCE_EXPORT void CheckSystemDlls()
{
//#ifdef STARFORCE_PROTECTED
    // Пустая реализация
//#endif 
}

STARFORCE_EXPORT void CallFunctionInProtectedSpace( SeparateThreadFuncPtr funcPtr, const void *pData )
{
//#ifdef STARFORCE_PROTECTED
    // Закомментированная реализация
//#else
    (*funcPtr)( pData );
//#endif 
}

} //namespace Protection

#pragma code_seg(pop)