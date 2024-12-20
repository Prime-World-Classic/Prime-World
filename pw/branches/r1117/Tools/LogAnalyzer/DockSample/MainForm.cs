using System;
using System.Drawing;
using System.Collections;
using System.ComponentModel;
using System.Reflection;
using System.Windows.Forms;
using System.IO;
using WeifenLuo.WinFormsUI.Docking;
using DockSample.Customization;

namespace DockSample
{
  public partial class MainForm : Form
  {
    private bool m_bSaveLayout = true;
    private DeserializeDockContent m_deserializeDockContent;

    private volatile bool pluginIsAccessible = true;

    public bool LockPluginAtMain()
    {
      if (pluginIsAccessible)
      {
        pluginIsAccessible = false;
        return true;
      }
      else
        return false;
    }
    public void UnlockPluginAtMain()
    {
      pluginIsAccessible = true;
    }

    public MainForm()
    {
      InitializeComponent();
      showRightToLeft.Checked = ( RightToLeft == RightToLeft.Yes );
      RightToLeftLayout = showRightToLeft.Checked;
      m_deserializeDockContent = new DeserializeDockContent( GetContentFromPersistString );
      dockPanel.DockTopPortion = 250;
    }

    private void menuItemExit_Click( object sender, System.EventArgs e )
    {
      Close();
    }

    private void menuItemAbout_Click( object sender, System.EventArgs e )
    {
      AboutDialog aboutDialog = new AboutDialog();
      aboutDialog.ShowDialog( this );
    }

    private IDockContent FindDocument( string text, Type t )
    {
      if ( dockPanel.DocumentStyle == DocumentStyle.SystemMdi )
      {
        foreach ( Form form in MdiChildren )
          if ( form.Text == text && form.GetType() == t )
            return form as IDockContent;

        return null;
      }
      else
      {
        foreach ( IDockContent content in dockPanel.Documents )
          if ( content.DockHandler.TabText == text && content.GetType() == t)
            return content;

        return null;
      }
    }
    private DummyDoc CreateNewDocument()
    {
      DummyDoc dummyDoc = new DummyDoc();
      int count = 1;
      string text = "Document" + count.ToString();
      while ( FindDocument( text, typeof( DummyDoc ) ) != null )
      {
        count++;
        text = "Document" + count.ToString();
      }
      dummyDoc.Text = text;
      return dummyDoc;
    }

    private DummyDoc CreateNewDocument( string text )
    {
      DummyDoc dummyDoc = new DummyDoc();
      dummyDoc.Text = text;
      return dummyDoc;
    }
    private void menuItemNew_Click( object sender, System.EventArgs e )
    {
      OpenFileDialog openFile = new OpenFileDialog();
      openFile.InitialDirectory = Application.ExecutablePath;
      openFile.Filter = "All files (*.*)|*.*|txt files (*.txt)|*.txt";
      openFile.FilterIndex = 1;
      openFile.RestoreDirectory = true;

      if ( openFile.ShowDialog() == DialogResult.OK )
      {
        string fullName = openFile.FileName;
        string fileName = Path.GetFileName( fullName );

        if ( FindDocument( fileName, typeof(FilterDoc) ) != null )
        {
          MessageBox.Show( "The document: " + fileName + " has already opened!" );
          return;
        }

        FilterDoc filterDoc = new FilterDoc();
        filterDoc.Text = fileName;
        if ( dockPanel.DocumentStyle == DocumentStyle.SystemMdi )
        {
          filterDoc.MdiParent = this;
          filterDoc.Show();
        }
        else
          filterDoc.Show( dockPanel );
        try
        {
          filterDoc.FileName = fullName;
        }
        catch ( Exception exception )
        {
          filterDoc.Close();
          MessageBox.Show( exception.Message );
        }
      }
    }
    private void menuItemOpen_Click( object sender, System.EventArgs e )
    {
      OpenFileDialog openFile = new OpenFileDialog();
      openFile.InitialDirectory = Application.ExecutablePath;
      openFile.Filter = "All files (*.*)|*.*|txt files (*.txt)|*.txt";
      openFile.FilterIndex = 1;
      openFile.RestoreDirectory = true;

      if ( openFile.ShowDialog() == DialogResult.OK )
      {
        string fullName = openFile.FileName;
        string fileName = Path.GetFileName( fullName );

        if ( FindDocument( fileName, typeof( DummyDoc ) ) != null )
        {
          MessageBox.Show( "The document: " + fileName + " has already opened!" );
          return;
        }

        DummyDoc dummyDoc = new DummyDoc();
        dummyDoc.Text = fileName;
        if ( dockPanel.DocumentStyle == DocumentStyle.SystemMdi )
        {
          dummyDoc.MdiParent = this;
          dummyDoc.Show();
        }
        else
          dummyDoc.Show( dockPanel );
        try
        {
          dummyDoc.FileName = fullName;
        }
        catch ( Exception exception )
        {
          dummyDoc.Close();
          MessageBox.Show( exception.Message );
        }
      }
    }

    private void menuItemFile_Popup( object sender, System.EventArgs e )
    {
      if ( dockPanel.DocumentStyle == DocumentStyle.SystemMdi )
      {
        menuItemClose.Enabled = menuItemCloseAll.Enabled = loadQueryToolStripMenuItem.Enabled =
        saveQueryToolStripMenuItem.Enabled = ( ActiveMdiChild != null );
      }
      else
      {
        menuItemClose.Enabled = loadQueryToolStripMenuItem.Enabled =
          saveQueryToolStripMenuItem.Enabled = ( dockPanel.ActiveDocument != null );
        menuItemCloseAll.Enabled = ( dockPanel.DocumentsCount > 0 );
      }
    }

    private void menuItemClose_Click( object sender, System.EventArgs e )
    {
      if ( dockPanel.DocumentStyle == DocumentStyle.SystemMdi )
        ActiveMdiChild.Close();
      else if ( dockPanel.ActiveDocument != null )
        dockPanel.ActiveDocument.DockHandler.Close();
    }

    private void menuItemCloseAll_Click( object sender, System.EventArgs e )
    {
      CloseAllDocuments();
    }

    private void CloseAllDocuments()
    {
      if ( dockPanel.DocumentStyle == DocumentStyle.SystemMdi )
      {
        foreach ( Form form in MdiChildren )
          form.Close();
      }
      else
      {
        for ( int index = dockPanel.Contents.Count - 1; index >= 0; index-- )
        {
          if ( dockPanel.Contents[index] is IDockContent )
          {
            IDockContent content = (IDockContent)dockPanel.Contents[index];
            content.DockHandler.Close();
          }
        }
      }
    }

    private IDockContent GetContentFromPersistString( string persistString )
    {
      // DummyDoc overrides GetPersistString to add extra information into persistString.
        // Any DockContent may override this value to add any needed information for deserialization.

        string[] parsedStrings = persistString.Split( new char[] { ',' } );
        if ( parsedStrings.Length != 3 )
          return null;

        if ( parsedStrings[0] != typeof( DummyDoc ).ToString() )
          return null;

        DummyDoc dummyDoc = new DummyDoc();
        if ( parsedStrings[1] != string.Empty )
          dummyDoc.FileName = parsedStrings[1];
        if ( parsedStrings[2] != string.Empty )
          dummyDoc.Text = parsedStrings[2];

        return dummyDoc;
    }

    private void MainForm_Load( object sender, System.EventArgs e )
    {
      string configFile = Path.Combine( Path.GetDirectoryName( Application.ExecutablePath ), "DockPanel.config" );

      if ( File.Exists( configFile ) )
        dockPanel.LoadFromXml( configFile, m_deserializeDockContent );
    }

    private void MainForm_Closing( object sender, System.ComponentModel.CancelEventArgs e )
    {
      string configFile = Path.Combine( Path.GetDirectoryName( Application.ExecutablePath ), "DockPanel.config" );
      if ( m_bSaveLayout )
        dockPanel.SaveAsXml( configFile );
      else if ( File.Exists( configFile ) )
        File.Delete( configFile );
    }

    private void menuItemToolBar_Click( object sender, System.EventArgs e )
    {
      toolBar.Visible = menuItemToolBar.Checked = !menuItemToolBar.Checked;
    }

    private void menuItemStatusBar_Click( object sender, System.EventArgs e )
    {
      statusBar.Visible = menuItemStatusBar.Checked = !menuItemStatusBar.Checked;
    }

    private void toolBar_ButtonClick( object sender, System.Windows.Forms.ToolStripItemClickedEventArgs e )
    {
      if ( e.ClickedItem == toolBarButtonNew )
        menuItemNew_Click( null, null );
      else if ( e.ClickedItem == toolBarButtonOpen )
        menuItemOpen_Click( null, null );
      else if ( e.ClickedItem == toolBarButtonLayoutByXml )
        menuItemLayoutByXml_Click( null, null );
    }

    private void menuItemNewWindow_Click( object sender, System.EventArgs e )
    {
      MainForm newWindow = new MainForm();
      newWindow.Text = newWindow.Text + " - New";
      newWindow.Show();
    }

    private void menuItemTools_Popup( object sender, System.EventArgs e )
    {
      menuItemLockLayout.Checked = !this.dockPanel.AllowEndUserDocking;
    }

    private void menuItemLockLayout_Click( object sender, System.EventArgs e )
    {
      dockPanel.AllowEndUserDocking = !dockPanel.AllowEndUserDocking;
    }

    private void menuItemLayoutByXml_Click( object sender, System.EventArgs e )
    {
      dockPanel.SuspendLayout( true );

      // In order to load layout from XML, we need to close all the DockContents
      CloseAllContents();

      Assembly assembly = Assembly.GetAssembly( typeof( MainForm ) );
      Stream xmlStream = assembly.GetManifestResourceStream( "DockSample.Resources.DockPanel.xml" );
      dockPanel.LoadFromXml( xmlStream, m_deserializeDockContent );
      xmlStream.Close();

      dockPanel.ResumeLayout( true, true );
    }

    private void CloseAllContents()
    {
      // we don't want to create another instance of tool window, set DockPanel to null
      // Close all other document windows
      CloseAllDocuments();
    }

    private void SetSchema( object sender, System.EventArgs e )
    {
      CloseAllContents();

      if ( sender == menuItemSchemaVS2005 )
        Extender.SetSchema( dockPanel, Extender.Schema.VS2005 );
      else if ( sender == menuItemSchemaVS2003 )
        Extender.SetSchema( dockPanel, Extender.Schema.VS2003 );

      menuItemSchemaVS2005.Checked = ( sender == menuItemSchemaVS2005 );
      menuItemSchemaVS2003.Checked = ( sender == menuItemSchemaVS2003 );
    }

    private void SetDocumentStyle( object sender, System.EventArgs e )
    {
      DocumentStyle oldStyle = dockPanel.DocumentStyle;
      DocumentStyle newStyle;
      if ( sender == menuItemDockingMdi )
        newStyle = DocumentStyle.DockingMdi;
      else if ( sender == menuItemDockingWindow )
        newStyle = DocumentStyle.DockingWindow;
      else if ( sender == menuItemDockingSdi )
        newStyle = DocumentStyle.DockingSdi;
      else
        newStyle = DocumentStyle.SystemMdi;

      if ( oldStyle == newStyle )
        return;

      if ( oldStyle == DocumentStyle.SystemMdi || newStyle == DocumentStyle.SystemMdi )
        CloseAllDocuments();

      dockPanel.DocumentStyle = newStyle;
      menuItemDockingMdi.Checked = ( newStyle == DocumentStyle.DockingMdi );
      menuItemDockingWindow.Checked = ( newStyle == DocumentStyle.DockingWindow );
      menuItemDockingSdi.Checked = ( newStyle == DocumentStyle.DockingSdi );
      menuItemSystemMdi.Checked = ( newStyle == DocumentStyle.SystemMdi );
      menuItemLayoutByCode.Enabled = ( newStyle != DocumentStyle.SystemMdi );
      menuItemLayoutByXml.Enabled = ( newStyle != DocumentStyle.SystemMdi );
      toolBarButtonLayoutByCode.Enabled = ( newStyle != DocumentStyle.SystemMdi );
      toolBarButtonLayoutByXml.Enabled = ( newStyle != DocumentStyle.SystemMdi );
    }

    private void menuItemCloseAllButThisOne_Click( object sender, System.EventArgs e )
    {
      if ( dockPanel.DocumentStyle == DocumentStyle.SystemMdi )
      {
        Form activeMdi = ActiveMdiChild;
        foreach ( Form form in MdiChildren )
        {
          if ( form != activeMdi )
            form.Close();
        }
      }
      else
      {
        foreach ( IDockContent document in dockPanel.DocumentsToArray() )
        {
          if ( !document.DockHandler.IsActivated )
            document.DockHandler.Close();
        }
      }
    }

    private void menuItemShowDocumentIcon_Click( object sender, System.EventArgs e )
    {
      dockPanel.ShowDocumentIcon = menuItemShowDocumentIcon.Checked = !menuItemShowDocumentIcon.Checked;
    }

    private void showRightToLeft_Click( object sender, EventArgs e )
    {
      CloseAllContents();
      if ( showRightToLeft.Checked )
      {
        this.RightToLeft = RightToLeft.No;
        this.RightToLeftLayout = false;
      }
      else
      {
        this.RightToLeft = RightToLeft.Yes;
        this.RightToLeftLayout = true;
      }
      showRightToLeft.Checked = !showRightToLeft.Checked;
    }

    private void exitWithoutSavingLayout_Click( object sender, EventArgs e )
    {
      m_bSaveLayout = false;
      Close();
      m_bSaveLayout = true;
    }

    private void loadQueryToolStripMenuItem_Click( object sender, EventArgs e )
    {
      if ( dockPanel.DocumentStyle == DocumentStyle.SystemMdi )
      {
        if ( ActiveMdiChild != null )
        {
          DummyDoc currentAnalyzer = (DummyDoc)ActiveMdiChild;
          LoadTextToRichTextBox( currentAnalyzer.txtCurrentQuery );
        }
      }
      else
      {
        if ( dockPanel.ActiveDocument != null )
        {
          DummyDoc currentAnalyzer = (DummyDoc)ActiveMdiChild;
          LoadTextToRichTextBox( currentAnalyzer.txtCurrentQuery );
        }
      }
    }
    private void saveQueryToolStripMenuItem_Click( object sender, EventArgs e )
    {
      if ( dockPanel.DocumentStyle == DocumentStyle.SystemMdi )
      {
        if ( ActiveMdiChild != null )
        {
          DummyDoc currentAnalyzer = (DummyDoc)ActiveMdiChild;
          SaveRichTextToFile( currentAnalyzer.txtCurrentQuery );
        }
      }
      else
      {
        if ( dockPanel.ActiveDocument != null )
        {
          DummyDoc currentAnalyzer = (DummyDoc)ActiveMdiChild;
          SaveRichTextToFile( currentAnalyzer.txtCurrentQuery );
        }
      }
    }

    public void LoadTextToRichTextBox( RichTextBox richTxt )
    {
      OpenFileDialog openFileDialog = new OpenFileDialog();
      openFileDialog.InitialDirectory = Application.ExecutablePath;
      openFileDialog.Filter = "All files (*.*)|*.*|txt files (*.txt)|*.txt";
      openFileDialog.FilterIndex = 1;
      openFileDialog.RestoreDirectory = true;

      if ( openFileDialog.ShowDialog() == DialogResult.OK )
      {
        Stream queryStream = null;
        try
        {
          if ( ( queryStream = openFileDialog.OpenFile() ) != null )
          {
            using ( queryStream )
            {
              richTxt.LoadFile( queryStream, RichTextBoxStreamType.PlainText );
            }
          }
        }
        catch ( Exception ex )
        {
          MessageBox.Show( "Could not read file. Error : " + ex.Message );
        }
      }
    }
    public void SaveRichTextToFile( RichTextBox richTxt )
    {
      SaveFileDialog saveFileDialog = new SaveFileDialog();

      saveFileDialog.Filter = "txt files (*.txt)|*.txt|All files (*.*)|*.*";
      saveFileDialog.FilterIndex = 2;
      saveFileDialog.RestoreDirectory = true;

      if ( saveFileDialog.ShowDialog() == DialogResult.OK )
      {
        try
        {
          File.WriteAllText( saveFileDialog.FileName, richTxt.Text );
        }
        catch ( Exception ex )
        {
          MessageBox.Show( "Could not save file. Error : " + ex.Message );
        }
      }
    }
  }
}