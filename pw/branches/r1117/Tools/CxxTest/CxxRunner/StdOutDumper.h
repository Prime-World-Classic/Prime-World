#pragma once

#include "Dumper.h"
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
namespace NLogg
{
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
class CStdOutDumper : public CDumper
{
	CStdOutDumper();
protected:
	virtual void OnDump( const CLogger *pLogger, const char *szFileName, const DWORD dwLine, const TTime time, const ELevel eLevel, const char *szMessage );
public:
	CStdOutDumper( CLogger *pDefaultLogger, const char *szName ) : CDumper( pDefaultLogger, szName ) {}
};
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
