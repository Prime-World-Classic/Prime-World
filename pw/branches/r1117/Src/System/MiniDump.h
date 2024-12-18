#ifndef _MINIDUMP_H_
#define _MINIDUMP_H_


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
enum MiniDumpType
{
	MINI_DUMP = 0,
	FULL_DUMP,
};
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
enum ExceptionType
{
	EXCEPTION_ASSERT = 0,
	EXCEPTION_SEH,
};
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void CreateMiniDump( const struct tm &tim, EXCEPTION_POINTERS* ExceptionInfo, MiniDumpType dumpFlags, ExceptionType exceptionType );
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#endif

