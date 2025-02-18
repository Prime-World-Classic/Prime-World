﻿/*
#about Импорт описаний из Excel-файла
*/
using System;
using System.Collections.Generic;
using System.Text;
using System.Xml;
using System.IO;
using System.Windows.Forms;
using EditorLib;
using EditorLib.FieldProcessor;
using System.Collections;
using libdb.DB;
using libdb.Diagnostics;

namespace Scripts2
{
  public class ImportDescriptions
  {
    private string ShowOpenFileDialog()
    {
      OpenFileDialog file = new OpenFileDialog();
      file.Filter = "Excel xml files (*.xml)|*.xml";
      file.Multiselect = false;
      file.CheckFileExists = true;
      file.RestoreDirectory = true;
      file.SupportMultiDottedExtensions = true;
      file.CheckPathExists = true;
      if ( file.ShowDialog() != DialogResult.OK )
        return string.Empty;

      return file.FileName;
    }

    private void Import( string fileName, DescriptionConfigObject descsConfig )
    {
      Table[] tables = ExcelXmlUtility.ReadFile( fileName );
      
      Dictionary<string, Type> knownTypes = new Dictionary<string, Type>();
      foreach( Type type in DataBase.KnownTypes )
      {
        knownTypes.Add( type.Name.ToLower(), type );
      }

      descsConfig.descriptions.Clear();
      for ( int i = 0; i < tables[0].Rows; ++i )
      {
        Type type;
        if ( !knownTypes.TryGetValue( tables[0][0, i].ToLower(), out type ) )
        {
          Log.TraceWarning( "Cannot find type {0}", tables[0][0, i] );
          continue;
        }

        Dictionary<string, string> descs = null;
        if ( !descsConfig.descriptions.TryGetValue( type, out descs ) )
        {
          descs = new Dictionary<string, string>();
          descsConfig.descriptions.Add( type, descs );
        }
        if ( !descs.ContainsKey( tables[0][1, i] ) )
          descs.Add( tables[0][1, i], tables[0][3, i] );
      }
    }

    public IEnumerable Main( IEditorCommonApplication app )
    {
      string fileName = ShowOpenFileDialog();
      if ( !string.IsNullOrEmpty( fileName ) )
        Import( fileName, app.Settings.Get<DescriptionConfigObject>() );

      yield return true;
    }
  }

  public class Table
  {
    private string name;
    private int cols;
    private int rows;
    private int realCols;
    private int realRows;
    private string[,] data;

    public Table( string name, int reserveCols, int reserveRows )
    {
      this.name = name;
      realCols = reserveCols;
      realRows = reserveRows;
      cols = 0;
      rows = 0;
      data = new string[realCols, realRows];
    }

    public string Name { get { return name; } }
    public int Columns { get { return cols; } }
    public int Rows { get { return rows; } }
    public string this[int col, int row]
    {
      get
      {
        if ( col < 0 || col >= Columns || row < 0 || row >= Rows )
          throw new ArgumentException( String.Format( "Cannot get value for cell {0}x{1}, size of table {2}x{3}", col, row, Columns, Rows ) );
        return data[col, row];
      }
      set
      {
        if ( col < 0 || col >= realCols || row < 0 || row >= realRows )
          throw new ArgumentException( String.Format( "Cannot set value for cell {0}x{1}, size of table {2}x{3}", col, row, realCols, realRows ) );
        data[col, row] = value;
        if ( !string.IsNullOrEmpty( value ) )
        {
          if ( col >= Columns )
            cols = col + 1;
          if ( row >= Rows )
            rows = row + 1;
        }
      }
    }
  }

  public static class ExcelXmlUtility
  {
    private static bool IsNumber( string str )
    {
      if ( str == null )
        return false;

      bool dotFound = false;
      foreach ( char c in str.ToCharArray() )
      {
        if ( c == '.' )
        {
          if ( dotFound )
            return false;
          dotFound = true;
        }
        else if ( c < '0' || c > '9' )
          return false;
      }
      return true;
    }

    public static Table[] ReadFile( string fileName )
    {
      List<Table> tables = new List<Table>();
      XmlDocument xmlDoc = new XmlDocument();
      using ( FileStream streamFile = new FileStream( fileName, System.IO.FileMode.Open, System.IO.FileAccess.Read, System.IO.FileShare.ReadWrite ) )
      {
        xmlDoc.Load( streamFile );
        streamFile.Close();
      }
      XmlNode xmlWorkbook = xmlDoc["Workbook"];
      for ( XmlNode xmlNode = xmlWorkbook.FirstChild; xmlNode != null; xmlNode = xmlNode.NextSibling )
      {
        if ( xmlNode.Name == "Worksheet" )
        {
          XmlNode xmlTable = xmlNode["Table"];
          if ( xmlTable != null )
          {
            int nColumns = Convert.ToInt32( xmlTable.Attributes["ss:ExpandedColumnCount"].Value );
            int nRows = Convert.ToInt32( xmlTable.Attributes["ss:ExpandedRowCount"].Value );
            Table table = new Table( xmlNode.Attributes["ss:Name"].Value, nColumns, nRows );
            int nRow = 0;
            for ( XmlNode xmlRow = xmlTable.FirstChild; xmlRow != null; xmlRow = xmlRow.NextSibling )
            {
              if ( xmlRow.Name == "Row" )
              {
                int nCell = 0;
                for ( XmlNode xmlCell = xmlRow.FirstChild; xmlCell != null; xmlCell = xmlCell.NextSibling )
                {
                  if ( xmlCell.Name == "Cell" )
                  {
                    XmlNode xmlIndex = xmlCell.Attributes["ss:Index"];
                    if ( xmlIndex != null )
                      nCell = Convert.ToInt32( xmlIndex.Value ) - 1;
                    XmlNode xmlData = xmlCell["Data"];
                    if ( xmlData != null )
                    {
                      table[nCell, nRow] = xmlData.InnerText;
                    }
                    nCell++;
                  }
                }
                nRow++;
              }
            }
            tables.Add( table );
          }
        }
      }

      return tables.ToArray();
    }

    private static XmlNode CreateWorkbook( XmlDocument xmlDoc, Table table )
    {
      XmlNode xmlNodeWorkSheet = xmlDoc.CreateElement( "Worksheet" );
      xmlNodeWorkSheet.Attributes.Append( xmlDoc.CreateAttribute( "ss", "Name", "urn:schemas-microsoft-com:office:spreadsheet" ) ).Value = table.Name;

      XmlNode xmlTable = xmlDoc.CreateElement( "Table" );
      xmlNodeWorkSheet.AppendChild( xmlTable );
      xmlTable.Attributes.Append( xmlDoc.CreateAttribute( "ss", "ExpandedColumnCount", "urn:schemas-microsoft-com:office:spreadsheet" ) ).Value = table.Columns.ToString();
      xmlTable.Attributes.Append( xmlDoc.CreateAttribute( "ss", "ExpandedRowCount", "urn:schemas-microsoft-com:office:spreadsheet" ) ).Value = table.Rows.ToString();
      xmlTable.Attributes.Append( xmlDoc.CreateAttribute( "x", "FullColumns", "urn:schemas-microsoft-com:office:excel" ) ).Value = "1";
      xmlTable.Attributes.Append( xmlDoc.CreateAttribute( "x", "FullRows", "urn:schemas-microsoft-com:office:excel" ) ).Value = "1";

      for ( int nRow = 0; nRow < table.Rows; ++nRow )
      {
        XmlNode xmlRow = xmlDoc.CreateElement( "Row" );
        xmlTable.AppendChild( xmlRow );
        for ( int nCol = 0; nCol < table.Columns; ++nCol )
        {
          XmlNode xmlCell = xmlDoc.CreateElement( "Cell" );
          xmlRow.AppendChild( xmlCell );
          if ( table[nCol, nRow] != null && table[nCol, nRow].Length > 0 )
          {
            XmlNode xmlData = xmlDoc.CreateElement( "Data" );
            xmlCell.AppendChild( xmlData );
            xmlData.Attributes.Append( xmlDoc.CreateAttribute( "ss", "Type", "urn:schemas-microsoft-com:office:spreadsheet" ) ).Value = IsNumber( table[nCol, nRow] ) ? "Number" : "String";
            xmlData.AppendChild( xmlDoc.CreateTextNode( table[nCol, nRow] ) );
          }
        }
      }

      return xmlNodeWorkSheet;
    }

    public static void WriteFile( string fileName, Table[] tables )
    {
      XmlDocument xmlDoc = new XmlDocument();
      xmlDoc.Prefix = "";

      XmlNode xmlNodeWorkbook = xmlDoc.CreateElement( "Workbook" );
      xmlDoc.AppendChild( xmlNodeWorkbook );
      xmlNodeWorkbook.Attributes.Append( xmlDoc.CreateAttribute( "xmlns" ) ).Value = "urn:schemas-microsoft-com:office:spreadsheet";
      xmlNodeWorkbook.Attributes.Append( xmlDoc.CreateAttribute( "xmlns:o" ) ).Value = "urn:schemas-microsoft-com:office:office";
      xmlNodeWorkbook.Attributes.Append( xmlDoc.CreateAttribute( "xmlns:x" ) ).Value = "urn:schemas-microsoft-com:office:excel";
      xmlNodeWorkbook.Attributes.Append( xmlDoc.CreateAttribute( "xmlns:ss" ) ).Value = "urn:schemas-microsoft-com:office:spreadsheet";
      xmlNodeWorkbook.Attributes.Append( xmlDoc.CreateAttribute( "xmlns:html" ) ).Value = "http://www.w3.org/TR/REC-html40";

      foreach ( Table table in tables )
      {
        XmlNode xmlNodeWorksheet = CreateWorkbook( xmlDoc, table );
        xmlNodeWorkbook.AppendChild( xmlNodeWorksheet );
      }

      using ( XmlTextWriter xmlWriter = new XmlTextWriter( new FileStream( fileName, FileMode.Create ), System.Text.Encoding.Unicode ) )
      {
        xmlWriter.Indentation = 2;
        xmlWriter.IndentChar = ' ';
        xmlWriter.Formatting = Formatting.Indented;
        xmlDoc.Save( xmlWriter );
        xmlWriter.Flush();
        xmlWriter.Close();
      }
    }
  }
}
