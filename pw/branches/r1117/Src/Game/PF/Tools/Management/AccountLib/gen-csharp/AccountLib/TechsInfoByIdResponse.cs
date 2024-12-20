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
  public partial class TechsInfoByIdResponse : TBase
  {
    private RequestResult _result;
    private TechsInfo _techInfo;

    /// <summary>
    /// 
    /// <seealso cref="RequestResult"/>
    /// </summary>
    public RequestResult Result
    {
      get
      {
        return _result;
      }
      set
      {
        __isset.result = true;
        this._result = value;
      }
    }

    public TechsInfo TechInfo
    {
      get
      {
        return _techInfo;
      }
      set
      {
        __isset.techInfo = true;
        this._techInfo = value;
      }
    }


    public Isset __isset;
    #if !SILVERLIGHT
    [Serializable]
    #endif
    public struct Isset {
      public bool result;
      public bool techInfo;
    }

    public TechsInfoByIdResponse() {
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
              Result = (RequestResult)iprot.ReadI32();
            } else { 
              TProtocolUtil.Skip(iprot, field.Type);
            }
            break;
          case 2:
            if (field.Type == TType.Struct) {
              TechInfo = new TechsInfo();
              TechInfo.Read(iprot);
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
      TStruct struc = new TStruct("TechsInfoByIdResponse");
      oprot.WriteStructBegin(struc);
      TField field = new TField();
      if (__isset.result) {
        field.Name = "result";
        field.Type = TType.I32;
        field.ID = 1;
        oprot.WriteFieldBegin(field);
        oprot.WriteI32((int)Result);
        oprot.WriteFieldEnd();
      }
      if (TechInfo != null && __isset.techInfo) {
        field.Name = "techInfo";
        field.Type = TType.Struct;
        field.ID = 2;
        oprot.WriteFieldBegin(field);
        TechInfo.Write(oprot);
        oprot.WriteFieldEnd();
      }
      oprot.WriteFieldStop();
      oprot.WriteStructEnd();
    }

    public override string ToString() {
      StringBuilder sb = new StringBuilder("TechsInfoByIdResponse(");
      sb.Append("Result: ");
      sb.Append(Result);
      sb.Append(",TechInfo: ");
      sb.Append(TechInfo== null ? "<null>" : TechInfo.ToString());
      sb.Append(")");
      return sb.ToString();
    }

  }

}
