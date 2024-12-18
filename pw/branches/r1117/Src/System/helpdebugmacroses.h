#ifndef HELPDEBUGMACROSES_H__
#define HELPDEBUGMACROSES_H__
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// global functions can't be watched by unknown reasons
// so, look functions have to be members
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#ifdef _NSTL_HELP_DEBUG
#define LOOK_INIT( a ) NHelpDebug::LookInit( (a) )
#define LOOK_FUNC const char* Look() const { return NHelpDebug::Look( *this ); } \
									value_type& LookIter( iterator *pIter ) { return *(*pIter); }
#else
#define LOOK_INIT( a )
#define LOOK_FUNC
#endif // _NSTL_HELP_DEBUG
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#endif //HELPDEBUGMACROSES_H__
