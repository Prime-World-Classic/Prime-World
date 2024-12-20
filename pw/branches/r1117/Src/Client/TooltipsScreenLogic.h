#pragma once
#include "Tooltips.h"
#include "../UI/ScreenLogicBase.h"

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
namespace NMainLoop { _interface IScreenBase; }

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
namespace UI
{
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
class TooltipsScreenLogic : public ScreenLogicBase
{
  NI_DECLARE_REFCOUNT_CLASS_1( TooltipsScreenLogic, ScreenLogicBase );
  DECLARE_LUA_TYPEINFO( TooltipsScreenLogic );

public:
	TooltipsScreenLogic();

	void AddTooltip( const wstring & text, const UI::STooltipDesc & desc );
  void HideTooltip();
  void CheckTooltip();
	void SetCurrentScreen( NMainLoop::IScreenBase * pScreen );

private:
	Weak<NMainLoop::IScreenBase> currentTopScreen;
};

} //namespace UI
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
