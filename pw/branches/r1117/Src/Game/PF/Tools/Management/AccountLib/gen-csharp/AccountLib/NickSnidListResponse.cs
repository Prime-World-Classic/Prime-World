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
  public partial class NickSnidListResponse : TBase
  {
    private RequestResult _result;
    private int _totalFound;
    private List<AccountShortInfo> _foundAccounts;

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

    public int TotalFound
    {
      get
      {
        return _totalFound;
      }
      set
      {
        __isset.totalFound = true;
        this._totalFound = value;
      }
    }

    public List<AccountShortInfo> FoundAccounts
    {
      get
      {
        return _foundAccounts;
      }
      set
      {
        __isset.foundAccounts = true;
        this._foundAccounts = value;
      }
    }


    public Isset __isset;
    #if !SILVERLIGHT
    [Serializable]
    #endif
    public struct Isset {
      public bool result;
      public bool totalFound;
      public bool foundAccounts;
    }

    public NickSnidListResponse() {
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
            if (field.Type == TType.I32) {
              TotalFound = iprot.ReadI32();
            } else { 
              TProtocolUtil.Skip(iprot, field.Type);
            }
            break;
          case 3:
            if (field.Type == TType.List) {
              {
                FoundAccounts = new List<AccountShortInfo>();
                TList _list50 = iprot.ReadListBegin();
                for( int _i51 = 0; _i51 < _list50.Count; ++_i51)
                {
                  AccountShortInfo _elem52 = new AccountShortInfo();
                  _elem52 = new AccountShortInfo();
                  _elem52.Read(iprot);
                  FoundAccounts.Add(_elem52);
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
      TStruct struc = new TStruct("NickSnidListResponse");
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
      if (__isset.totalFound) {
        field.Name = "totalFound";
        field.Type = TType.I32;
        field.ID = 2;
        oprot.WriteFieldBegin(field);
        oprot.WriteI32(TotalFound);
        oprot.WriteFieldEnd();
      }
      if (FoundAccounts != null && __isset.foundAccounts) {
        field.Name = "foundAccounts";
        field.Type = TType.List;
        field.ID = 3;
        oprot.WriteFieldBegin(field);
        {
          oprot.WriteListBegin(new TList(TType.Struct, FoundAccounts.Count));
          foreach (AccountShortInfo _iter53 in FoundAccounts)
          {
            _iter53.Write(oprot);
          }
          oprot.WriteListEnd();
        }
        oprot.WriteFieldEnd();
      }
      oprot.WriteFieldStop();
      oprot.WriteStructEnd();
    }

    public override string ToString() {
      StringBuilder sb = new StringBuilder("NickSnidListResponse(");
      sb.Append("Result: ");
      sb.Append(Result);
      sb.Append(",TotalFound: ");
      sb.Append(TotalFound);
      sb.Append(",FoundAccounts: ");
      sb.Append(FoundAccounts);
      sb.Append(")");
      return sb.ToString();
    }

  }

}
