/*
#about Нахождение всех атак с workTime = 0
*/
/*
#ref EditorNative.dll
#ref EditorPlugins.dll
#ref PF_Types.DBTypes.dll
#ref PF_Editor.exe
*/

using System.Collections;
using System.Collections.Generic;
using System.IO;
using DBTypes;
using EditorLib.IO;
using libdb.DB;
using libdb.Diagnostics;


public class CheckAttackWorkingTime
{
  public IEnumerable Main( EditorLib.IEditorCommonApplication application )
  {
    Log.TraceMessage( "Start" );

    List<DBID> items;
    ObjectsSelector.CollectObjects( application, "", typeof( DBTypes.BaseAttack ), true, true, out items );

    foreach ( var dbId in items )
    {
        DBPtr<DBTypes.BaseAttack> resource = DataBase.Get<DBTypes.BaseAttack>(dbId);
      if ( !ReferenceEquals( resource, null ) )
      {
        Check( application, resource );
      }
    }

    Log.TraceMessage( "Done" );

    yield return true;
  }

  public bool Check( EditorLib.IEditorCommonApplication application,
                          DBPtr<DBTypes.BaseAttack> resource)
  {
      if ( resource.Get().workTime == 0.0f )
      {
          Log.TraceMessage(resource.Get().DBId.GetFullFileName());
          return true;
      }

    return true;
  }
}
