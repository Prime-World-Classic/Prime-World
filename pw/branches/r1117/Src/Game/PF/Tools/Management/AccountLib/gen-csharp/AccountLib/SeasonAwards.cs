/**
 * Autogenerated by Thrift Compiler (0.9.1)
 *
 * DO NOT EDIT UNLESS YOU ARE SURE THAT YOU KNOW WHAT YOU ARE DOING
 *  @generated
 */
using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using System.IO;
using Thrift;
using Thrift.Collections;
using System.Runtime.Serialization;
using Thrift.Protocol;
using Thrift.Transport;

namespace AccountLib
{

  #if !SILVERLIGHT
  [Serializable]
  #endif
  public partial class SeasonAwards : TBase
  {
    private int _seasonId;
    private string _seasonName;
    private long _startDate;
    private long _endDate;
    private int _perls;
    private string _skin;
    private string _flag;
    private string _talents;
    private string _lootboxes;

    public int SeasonId
    {
      get
      {
        return _seasonId;
      }
      set
      {
        __isset.seasonId = true;
        this._seasonId = value;
      }
    }

    public string SeasonName
    {
      get
      {
        return _seasonName;
      }
      set
      {
        __isset.seasonName = true;
        this._seasonName = value;
      }
    }

    public long StartDate
    {
      get
      {
        return _startDate;
      }
      set
      {
        __isset.startDate = true;
        this._startDate = value;
      }
    }

    public long EndDate
    {
      get
      {
        return _endDate;
      }
      set
      {
        __isset.endDate = true;
        this._endDate = value;
      }
    }

    public int Perls
    {
      get
      {
        return _perls;
      }
      set
      {
        __isset.perls = true;
        this._perls = value;
      }
    }

    public string Skin
    {
      get
      {
        return _skin;
      }
      set
      {
        __isset.skin = true;
        this._skin = value;
      }
    }

    public string Flag
    {
      get
      {
        return _flag;
      }
      set
      {
        __isset.flag = true;
        this._flag = value;
      }
    }

    public string Talents
    {
      get
      {
        return _talents;
      }
      set
      {
        __isset.talents = true;
        this._talents = value;
      }
    }

    public string Lootboxes
    {
      get
      {
        return _lootboxes;
      }
      set
      {
        __isset.lootboxes = true;
        this._lootboxes = value;
      }
    }


    public Isset __isset;
    #if !SILVERLIGHT
    [Serializable]
    #endif
    public struct Isset {
      public bool seasonId;
      public bool seasonName;
      public bool startDate;
      public bool endDate;
      public bool perls;
      public bool skin;
      public bool flag;
      public bool talents;
      public bool lootboxes;
    }

    public SeasonAwards() {
    }

    public void Read (TProtocol iprot)
    {
      TField field;
      iprot.ReadStructBegin();
      while (true)
      {
        field = iprot.ReadFieldBegin();
        if (field.Type == TType.Stop) { 
          break;
        }
        switch (field.ID)
        {
          case 1:
            if (field.Type == TType.I32) {
              SeasonId = iprot.ReadI32();
            } else { 
              TProtocolUtil.Skip(iprot, field.Type);
            }
            break;
          case 2:
            if (field.Type == TType.String) {
              SeasonName = iprot.ReadString();
            } else { 
              TProtocolUtil.Skip(iprot, field.Type);
            }
            break;
          case 3:
            if (field.Type == TType.I64) {
              StartDate = iprot.ReadI64();
            } else { 
              TProtocolUtil.Skip(iprot, field.Type);
            }
            break;
          case 4:
            if (field.Type == TType.I64) {
              EndDate = iprot.ReadI64();
            } else { 
              TProtocolUtil.Skip(iprot, field.Type);
            }
            break;
          case 5:
            if (field.Type == TType.I32) {
              Perls = iprot.ReadI32();
            } else { 
              TProtocolUtil.Skip(iprot, field.Type);
            }
            break;
          case 6:
            if (field.Type == TType.String) {
              Skin = iprot.ReadString();
            } else { 
              TProtocolUtil.Skip(iprot, field.Type);
            }
            break;
          case 7:
            if (field.Type == TType.String) {
              Flag = iprot.ReadString();
            } else { 
              TProtocolUtil.Skip(iprot, field.Type);
            }
            break;
          case 8:
            if (field.Type == TType.String) {
              Talents = iprot.ReadString();
            } else { 
              TProtocolUtil.Skip(iprot, field.Type);
            }
            break;
          case 9:
            if (field.Type == TType.String) {
              Lootboxes = iprot.ReadString();
            } else { 
              TProtocolUtil.Skip(iprot, field.Type);
            }
            break;
          default: 
            TProtocolUtil.Skip(iprot, field.Type);
            break;
        }
        iprot.ReadFieldEnd();
      }
      iprot.ReadStructEnd();
    }

    public void Write(TProtocol oprot) {
      TStruct struc = new TStruct("SeasonAwards");
      oprot.WriteStructBegin(struc);
      TField field = new TField();
      if (__isset.seasonId) {
        field.Name = "seasonId";
        field.Type = TType.I32;
        field.ID = 1;
        oprot.WriteFieldBegin(field);
        oprot.WriteI32(SeasonId);
        oprot.WriteFieldEnd();
      }
      if (SeasonName != null && __isset.seasonName) {
        field.Name = "seasonName";
        field.Type = TType.String;
        field.ID = 2;
        oprot.WriteFieldBegin(field);
        oprot.WriteString(SeasonName);
        oprot.WriteFieldEnd();
      }
      if (__isset.startDate) {
        field.Name = "startDate";
        field.Type = TType.I64;
        field.ID = 3;
        oprot.WriteFieldBegin(field);
        oprot.WriteI64(StartDate);
        oprot.WriteFieldEnd();
      }
      if (__isset.endDate) {
        field.Name = "endDate";
        field.Type = TType.I64;
        field.ID = 4;
        oprot.WriteFieldBegin(field);
        oprot.WriteI64(EndDate);
        oprot.WriteFieldEnd();
      }
      if (__isset.perls) {
        field.Name = "perls";
        field.Type = TType.I32;
        field.ID = 5;
        oprot.WriteFieldBegin(field);
        oprot.WriteI32(Perls);
        oprot.WriteFieldEnd();
      }
      if (Skin != null && __isset.skin) {
        field.Name = "skin";
        field.Type = TType.String;
        field.ID = 6;
        oprot.WriteFieldBegin(field);
        oprot.WriteString(Skin);
        oprot.WriteFieldEnd();
      }
      if (Flag != null && __isset.flag) {
        field.Name = "flag";
        field.Type = TType.String;
        field.ID = 7;
        oprot.WriteFieldBegin(field);
        oprot.WriteString(Flag);
        oprot.WriteFieldEnd();
      }
      if (Talents != null && __isset.talents) {
        field.Name = "talents";
        field.Type = TType.String;
        field.ID = 8;
        oprot.WriteFieldBegin(field);
        oprot.WriteString(Talents);
        oprot.WriteFieldEnd();
      }
      if (Lootboxes != null && __isset.lootboxes) {
        field.Name = "lootboxes";
        field.Type = TType.String;
        field.ID = 9;
        oprot.WriteFieldBegin(field);
        oprot.WriteString(Lootboxes);
        oprot.WriteFieldEnd();
      }
      oprot.WriteFieldStop();
      oprot.WriteStructEnd();
    }

    public override string ToString() {
      StringBuilder sb = new StringBuilder("SeasonAwards(");
      sb.Append("SeasonId: ");
      sb.Append(SeasonId);
      sb.Append(",SeasonName: ");
      sb.Append(SeasonName);
      sb.Append(",StartDate: ");
      sb.Append(StartDate);
      sb.Append(",EndDate: ");
      sb.Append(EndDate);
      sb.Append(",Perls: ");
      sb.Append(Perls);
      sb.Append(",Skin: ");
      sb.Append(Skin);
      sb.Append(",Flag: ");
      sb.Append(Flag);
      sb.Append(",Talents: ");
      sb.Append(Talents);
      sb.Append(",Lootboxes: ");
      sb.Append(Lootboxes);
      sb.Append(")");
      return sb.ToString();
    }

  }

}
