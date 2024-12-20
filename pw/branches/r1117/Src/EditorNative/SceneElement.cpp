#include "stdafx.h"
#include "SceneElement.h"
#include "Utility.h"
#include "EditorScene.h"

using namespace EditorNative;
using namespace EditorNative::SceneElements;

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
SceneElement::SceneElement()
:	location( Vector3::Zero )
,	rotation( Quaternion::Identity )
,	scale( Vector3::Ones )
, isVisible( true )
{
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
SceneElement::SceneElement( Vector3^ location, Quaternion^ rotation, Vector3^ scale )
:	location( location )
,	rotation( rotation )
,	scale( scale )
, isVisible( true )
{
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
int SceneElement::GetOwnerId()
{
  return ownerId;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void SceneElement::SetOwnerId(int id)
{
  ownerId = id;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
bool SceneElement::IsSelected::get()
{
	return !ReferenceEquals( Scene, nullptr ) && Scene->SelectedObjects->Contains( this );
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void SceneElement::IsSelected::set( bool value )
{
	if ( ReferenceEquals( Scene, nullptr ) )
    return;

  if ( value )
	{
		if ( IsSelectable )
		{
			if ( !IsSelected )
				Scene->Select( this );
		}
		else 
			Scene->Deselect( this );
	}
	else
	{
		if ( IsSelected )
			Scene->Deselect( this );
	}
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void SceneElement::IsSelectable::set( bool value )
{
	selectable = value;
	if ( !selectable )
		IsSelected = false;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
