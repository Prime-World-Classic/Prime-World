﻿namespace MemoryMonitor.Forms
{
  partial class MemoryMapControl
  {
    /// <summary> 
    /// Required designer variable.
    /// </summary>
    private System.ComponentModel.IContainer components = null;

    /// <summary> 
    /// Clean up any resources being used.
    /// </summary>
    /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
    protected override void Dispose( bool disposing )
    {
      if ( disposing && ( components != null ) )
      {
        components.Dispose();
      }
      base.Dispose( disposing );
    }

    #region Component Designer generated code

    /// <summary> 
    /// Required method for Designer support - do not modify 
    /// the contents of this method with the code editor.
    /// </summary>
    private void InitializeComponent()
    {
      this.components = new System.ComponentModel.Container();
      this.toolTip = new System.Windows.Forms.ToolTip( this.components );
      this.SuspendLayout();
      // 
      // toolTip
      // 
      this.toolTip.ShowAlways = true;
      this.toolTip.ToolTipTitle = "Memory block:";
      // 
      // MemoryMapControl
      // 
      this.AutoScroll = true;
      this.Name = "MemoryMapControl";
      this.ResumeLayout( false );

    }

    #endregion

    private System.Windows.Forms.ToolTip toolTip;


  }
}
