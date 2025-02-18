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
  public partial class ReforgeTalentPrices : TBase
  {
    private int _persistentId;
    private int _startTime;
    private int _endTime;
    private bool _enabled;
    private string _description;
    private List<ReforgeTalentPrice> _listReforgeTalentPrices;

    public int PersistentId
    {
      get
      {
        return _persistentId;
      }
      set
      {
        __isset.persistentId = true;
        this._persistentId = value;
      }
    }

    public int StartTime
    {
      get
      {
        return _startTime;
      }
      set
      {
        __isset.startTime = true;
        this._startTime = value;
      }
    }

    public int EndTime
    {
      get
      {
        return _endTime;
      }
      set
      {
        __isset.endTime = true;
        this._endTime = value;
      }
    }

    public bool Enabled
    {
      get
      {
        return _enabled;
      }
      set
      {
        __isset.enabled = true;
        this._enabled = value;
      }
    }

    public string Description
    {
      get
      {
        return _description;
      }
      set
      {
        __isset.description = true;
        this._description = value;
      }
    }

    public List<ReforgeTalentPrice> ListReforgeTalentPrices
    {
      get
      {
        return _listReforgeTalentPrices;
      }
      set
      {
        __isset.listReforgeTalentPrices = true;
        this._listReforgeTalentPrices = value;
      }
    }


    public Isset __isset;
    #if !SILVERLIGHT
    [Serializable]
    #endif
    public struct Isset {
      public bool persistentId;
      public bool startTime;
      public bool endTime;
      public bool enabled;
      public bool description;
      public bool listReforgeTalentPrices;
    }

    public ReforgeTalentPrices() {
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
              PersistentId = iprot.ReadI32();
            } else { 
              TProtocolUtil.Skip(iprot, field.Type);
            }
            break;
          case 2:
            if (field.Type == TType.I32) {
              StartTime = iprot.ReadI32();
            } else { 
              TProtocolUtil.Skip(iprot, field.Type);
            }
            break;
          case 3:
            if (field.Type == TType.I32) {
              EndTime = iprot.ReadI32();
            } else { 
              TProtocolUtil.Skip(iprot, field.Type);
            }
            break;
          case 4:
            if (field.Type == TType.Bool) {
              Enabled = iprot.ReadBool();
            } else { 
              TProtocolUtil.Skip(iprot, field.Type);
            }
            break;
          case 5:
            if (field.Type == TType.String) {
              Description = iprot.ReadString();
            } else { 
              TProtocolUtil.Skip(iprot, field.Type);
            }
            break;
          case 6:
            if (field.Type == TType.List) {
              {
                ListReforgeTalentPrices = new List<ReforgeTalentPrice>();
                TList _list222 = iprot.ReadListBegin();
                for( int _i223 = 0; _i223 < _list222.Count; ++_i223)
                {
                  ReforgeTalentPrice _elem224 = new ReforgeTalentPrice();
                  _elem224 = new ReforgeTalentPrice();
                  _elem224.Read(iprot);
                  ListReforgeTalentPrices.Add(_elem224);
                }
                iprot.ReadListEnd();
              }
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
      TStruct struc = new TStruct("ReforgeTalentPrices");
      oprot.WriteStructBegin(struc);
      TField field = new TField();
      if (__isset.persistentId) {
        field.Name = "persistentId";
        field.Type = TType.I32;
        field.ID = 1;
        oprot.WriteFieldBegin(field);
        oprot.WriteI32(PersistentId);
        oprot.WriteFieldEnd();
      }
      if (__isset.startTime) {
        field.Name = "startTime";
        field.Type = TType.I32;
        field.ID = 2;
        oprot.WriteFieldBegin(field);
        oprot.WriteI32(StartTime);
        oprot.WriteFieldEnd();
      }
      if (__isset.endTime) {
        field.Name = "endTime";
        field.Type = TType.I32;
        field.ID = 3;
        oprot.WriteFieldBegin(field);
        oprot.WriteI32(EndTime);
        oprot.WriteFieldEnd();
      }
      if (__isset.enabled) {
        field.Name = "enabled";
        field.Type = TType.Bool;
        field.ID = 4;
        oprot.WriteFieldBegin(field);
        oprot.WriteBool(Enabled);
        oprot.WriteFieldEnd();
      }
      if (Description != null && __isset.description) {
        field.Name = "description";
        field.Type = TType.String;
        field.ID = 5;
        oprot.WriteFieldBegin(field);
        oprot.WriteString(Description);
        oprot.WriteFieldEnd();
      }
      if (ListReforgeTalentPrices != null && __isset.listReforgeTalentPrices) {
        field.Name = "listReforgeTalentPrices";
        field.Type = TType.List;
        field.ID = 6;
        oprot.WriteFieldBegin(field);
        {
          oprot.WriteListBegin(new TList(TType.Struct, ListReforgeTalentPrices.Count));
          foreach (ReforgeTalentPrice _iter225 in ListReforgeTalentPrices)
          {
            _iter225.Write(oprot);
          }
          oprot.WriteListEnd();
        }
        oprot.WriteFieldEnd();
      }
      oprot.WriteFieldStop();
      oprot.WriteStructEnd();
    }

    public override string ToString() {
      StringBuilder sb = new StringBuilder("ReforgeTalentPrices(");
      sb.Append("PersistentId: ");
      sb.Append(PersistentId);
      sb.Append(",StartTime: ");
      sb.Append(StartTime);
      sb.Append(",EndTime: ");
      sb.Append(EndTime);
      sb.Append(",Enabled: ");
      sb.Append(Enabled);
      sb.Append(",Description: ");
      sb.Append(Description);
      sb.Append(",ListReforgeTalentPrices: ");
      sb.Append(ListReforgeTalentPrices);
      sb.Append(")");
      return sb.ToString();
    }

  }

}
