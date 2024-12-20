#include "TamarinPCH.h"

#include "../../FlashMovieAvmCore.h"

#include "StageEnums.h"

namespace avmplus
{

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
StageAlign::StageAlign( AvmCore * _core ) :
  MMgc::GCRoot(_core->gc),
  value(TOP)
{
  kTOP = _core->internConstantStringLatin1("T");
  kBOTTOM = _core->internConstantStringLatin1("B");
  kLEFT = _core->internConstantStringLatin1("L");
  kRIGHT = _core->internConstantStringLatin1("R");
  kTOP_LEFT = _core->internConstantStringLatin1("TL");
  kTOP_RIGHT = _core->internConstantStringLatin1("TR");
  kBOTTOM_LEFT = _core->internConstantStringLatin1("BL");
  kBOTTOM_RIGHT = _core->internConstantStringLatin1("BR");
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void StageAlign::SetStringValue( AvmString _stringValue )
{
  if ( _stringValue == kTOP ) value = TOP;
  else if ( _stringValue == kBOTTOM ) value = BOTTOM;
  else if ( _stringValue == kLEFT ) value = LEFT;
  else if ( _stringValue == kRIGHT ) value = RIGHT;
  else if ( _stringValue == kTOP_LEFT ) value = TOP_LEFT;
  else if ( _stringValue == kTOP_RIGHT ) value = TOP_RIGHT;
  else if ( _stringValue == kBOTTOM_LEFT ) value = BOTTOM_LEFT;
  else if ( _stringValue == kBOTTOM_RIGHT ) value = BOTTOM_RIGHT;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
AvmString StageAlign::GetStringValue()
{
  switch ( value )
  {
  case TOP: return kTOP;
  case BOTTOM: return kBOTTOM;
  case LEFT: return kLEFT;
  case RIGHT: return kRIGHT;
  case TOP_LEFT: return kTOP_LEFT;
  case TOP_RIGHT: return kTOP_RIGHT;
  case BOTTOM_LEFT: return kBOTTOM_LEFT;
  case BOTTOM_RIGHT: return kBOTTOM_RIGHT;
  }

  NI_ALWAYS_ASSERT("Wrong StageAlign");

  return kTOP;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
StageScaleMode::StageScaleMode( AvmCore * _core ) :
  MMgc::GCRoot(_core->gc),
  value(SHOW_ALL)
{
  kEXACT_FIT = _core->internConstantStringLatin1("exactFit");
  kNO_BORDER = _core->internConstantStringLatin1("noBorder");
  kNO_SCALE = _core->internConstantStringLatin1("noScale");
  kSHOW_ALL = _core->internConstantStringLatin1("showAll");
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void StageScaleMode::SetStringValue( AvmString _stringValue )
{
  if ( _stringValue == kEXACT_FIT ) value = EXACT_FIT;
  else if ( _stringValue == kNO_BORDER ) value = NO_BORDER;
  else if ( _stringValue == kNO_SCALE ) value = NO_SCALE;
  else if ( _stringValue == kSHOW_ALL ) value = SHOW_ALL;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
AvmString StageScaleMode::GetStringValue()
{
  switch ( value )
  {
  case EXACT_FIT: return kEXACT_FIT;
  case NO_BORDER: return kNO_BORDER;
  case NO_SCALE: return kNO_SCALE;
  case SHOW_ALL: return kSHOW_ALL;
  }

  NI_ALWAYS_ASSERT("Wrong StageScaleMode");

  return kSHOW_ALL;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
StageQuality::StageQuality( AvmCore * _core ) :
  MMgc::GCRoot(_core->gc),
  value(HIGH)
{
  kBEST = _core->internConstantStringLatin1("best");
  kLOW = _core->internConstantStringLatin1("low");
  kMEDIUM = _core->internConstantStringLatin1("medium");
  kHIGH = _core->internConstantStringLatin1("high");
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void StageQuality::SetStringValue( AvmString _stringValue )
{
  if ( _stringValue == kBEST ) value = BEST;
  else if ( _stringValue == kLOW ) value = LOW;
  else if ( _stringValue == kMEDIUM ) value = MEDIUM;
  else if ( _stringValue == kHIGH ) value = HIGH;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
AvmString StageQuality::GetStringValue()
{
  switch ( value )
  {
  case BEST: return kBEST;
  case LOW: return kLOW;
  case MEDIUM: return kMEDIUM;
  case HIGH: return kHIGH;
  }

  NI_ALWAYS_ASSERT("Wrong StageQuality");

  return kHIGH;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
StageDisplayState::StageDisplayState( AvmCore * _core ) :
  MMgc::GCRoot(_core->gc),
  value(NORMAL)
{
  kFULL_SCREEN = _core->internConstantStringLatin1("fullScreen");
  kNORMAL = _core->internConstantStringLatin1("normal");
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void StageDisplayState::SetStringValue( AvmString _stringValue )
{
  if ( _stringValue == kFULL_SCREEN ) value = FULL_SCREEN;
  else if ( _stringValue == kNORMAL ) value = NORMAL;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
AvmString StageDisplayState::GetStringValue()
{
  switch ( value )
  {
  case FULL_SCREEN: return kFULL_SCREEN;
  case NORMAL: return kNORMAL;
  }

  NI_ALWAYS_ASSERT("Wrong StageDisplayState");

  return kNORMAL;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
ColorCorrection::ColorCorrection( AvmCore * _core ) :
  MMgc::GCRoot(_core->gc),
  value(DEFAULT)
{
  kDEFAULT = _core->internConstantStringLatin1("default");
  kON = _core->internConstantStringLatin1("on");
  kOFF = _core->internConstantStringLatin1("off");
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void ColorCorrection::SetStringValue( AvmString _stringValue )
{
  if ( _stringValue == kDEFAULT ) value = DEFAULT;
  else if ( _stringValue == kON ) value = ON;
  else if ( _stringValue == kOFF ) value = OFF;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
AvmString ColorCorrection::GetStringValue()
{
  switch ( value )
  {
  case DEFAULT: return kDEFAULT;
  case ON: return kON;
  case OFF: return kOFF;
  }

  NI_ALWAYS_ASSERT("Wrong ColorCorrection");

  return kDEFAULT;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
ColorCorrectionSupport::ColorCorrectionSupport( AvmCore * _core ) :
  MMgc::GCRoot(_core->gc),
  value(DEFAULT_ON)
{
  kDEFAULT_OFF = _core->internConstantStringLatin1("defaultOff");
  kUNSUPPORTED = _core->internConstantStringLatin1("unsupported");
  kDEFAULT_ON = _core->internConstantStringLatin1("defaultOn");
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void ColorCorrectionSupport::SetStringValue( AvmString _stringValue )
{
  if ( _stringValue == kDEFAULT_OFF ) value = DEFAULT_OFF;
  else if ( _stringValue == kUNSUPPORTED ) value = UNSUPPORTED;
  else if ( _stringValue == kDEFAULT_ON ) value = DEFAULT_ON;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
AvmString ColorCorrectionSupport::GetStringValue()
{
  switch ( value )
  {
  case DEFAULT_OFF: return kDEFAULT_OFF;
  case UNSUPPORTED: return kUNSUPPORTED;
  case DEFAULT_ON: return kDEFAULT_ON;
  }

  NI_ALWAYS_ASSERT("Wrong ColorCorrectionSupport");

  return kDEFAULT_ON;
}

} // namespace flash