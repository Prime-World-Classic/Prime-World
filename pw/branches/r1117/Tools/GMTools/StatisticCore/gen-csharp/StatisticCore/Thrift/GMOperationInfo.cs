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

namespace StatisticCore.Thrift
{

  #if !SILVERLIGHT
  [Serializable]
  #endif
  public partial class GMOperationInfo : TBase
  {
    private long _auid;
    private GMOperationType _operation;
    private string _gmlogin;
    private int _timestamp;
    private string _data;

    public long Auid
    {
      get
      {
        return _auid;
      }
      set
      {
        __isset.auid = true;
        this._auid = value;
      }
    }

    /// <summary>
    /// 
    /// <seealso cref="GMOperationType"/>
    /// </summary>
    public GMOperationType Operation
    {
      get
      {
        return _operation;
      }
      set
      {
        __isset.operation = true;
        this._operation = value;
      }
    }

    public string Gmlogin
    {
      get
      {
        return _gmlogin;
      }
      set
      {
        __isset.gmlogin = true;
        this._gmlogin = value;
      }
    }

    public int Timestamp
    {
      get
      {
        return _timestamp;
      }
      set
      {
        __isset.timestamp = true;
        this._timestamp = value;
      }
    }

    public string Data
    {
      get
      {
        return _data;
      }
      set
      {
        __isset.data = true;
        this._data = value;
      }
    }


    public Isset __isset;
    #if !SILVERLIGHT
    [Serializable]
    #endif
    public struct Isset {
      public bool auid;
      public bool operation;
      public bool gmlogin;
      public bool timestamp;
      public bool data;
    }

    public GMOperationInfo() {
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
            if (field.Type == TType.I64) {
              Auid = iprot.ReadI64();
            } else { 
              TProtocolUtil.Skip(iprot, field.Type);
            }
            break;
          case 2:
            if (field.Type == TType.I32) {
              Operation = (GMOperationType)iprot.ReadI32();
            } else { 
              TProtocolUtil.Skip(iprot, field.Type);
            }
            break;
          case 3:
            if (field.Type == TType.String) {
              Gmlogin = iprot.ReadString();
            } else { 
              TProtocolUtil.Skip(iprot, field.Type);
            }
            break;
          case 4:
            if (field.Type == TType.I32) {
              Timestamp = iprot.ReadI32();
            } else { 
              TProtocolUtil.Skip(iprot, field.Type);
            }
            break;
          case 5:
            if (field.Type == TType.String) {
              Data = iprot.ReadString();
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
      TStruct struc = new TStruct("GMOperationInfo");
      oprot.WriteStructBegin(struc);
      TField field = new TField();
      if (__isset.auid) {
        field.Name = "auid";
        field.Type = TType.I64;
        field.ID = 1;
        oprot.WriteFieldBegin(field);
        oprot.WriteI64(Auid);
        oprot.WriteFieldEnd();
      }
      if (__isset.operation) {
        field.Name = "operation";
        field.Type = TType.I32;
        field.ID = 2;
        oprot.WriteFieldBegin(field);
        oprot.WriteI32((int)Operation);
        oprot.WriteFieldEnd();
      }
      if (Gmlogin != null && __isset.gmlogin) {
        field.Name = "gmlogin";
        field.Type = TType.String;
        field.ID = 3;
        oprot.WriteFieldBegin(field);
        oprot.WriteString(Gmlogin);
        oprot.WriteFieldEnd();
      }
      if (__isset.timestamp) {
        field.Name = "timestamp";
        field.Type = TType.I32;
        field.ID = 4;
        oprot.WriteFieldBegin(field);
        oprot.WriteI32(Timestamp);
        oprot.WriteFieldEnd();
      }
      if (Data != null && __isset.data) {
        field.Name = "data";
        field.Type = TType.String;
        field.ID = 5;
        oprot.WriteFieldBegin(field);
        oprot.WriteString(Data);
        oprot.WriteFieldEnd();
      }
      oprot.WriteFieldStop();
      oprot.WriteStructEnd();
    }

    public override string ToString() {
      StringBuilder sb = new StringBuilder("GMOperationInfo(");
      sb.Append("Auid: ");
      sb.Append(Auid);
      sb.Append(",Operation: ");
      sb.Append(Operation);
      sb.Append(",Gmlogin: ");
      sb.Append(Gmlogin);
      sb.Append(",Timestamp: ");
      sb.Append(Timestamp);
      sb.Append(",Data: ");
      sb.Append(Data);
      sb.Append(")");
      return sb.ToString();
    }

  }

}
