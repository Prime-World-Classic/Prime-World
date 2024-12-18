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
  public partial class FriendInfo : TBase
  {
    private long _auid;
    private string _nickname;
    private string _guildShortName;

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

    public string Nickname
    {
      get
      {
        return _nickname;
      }
      set
      {
        __isset.nickname = true;
        this._nickname = value;
      }
    }

    public string GuildShortName
    {
      get
      {
        return _guildShortName;
      }
      set
      {
        __isset.guildShortName = true;
        this._guildShortName = value;
      }
    }


    public Isset __isset;
    #if !SILVERLIGHT
    [Serializable]
    #endif
    public struct Isset {
      public bool auid;
      public bool nickname;
      public bool guildShortName;
    }

    public FriendInfo() {
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
            if (field.Type == TType.String) {
              Nickname = iprot.ReadString();
            } else { 
              TProtocolUtil.Skip(iprot, field.Type);
            }
            break;
          case 3:
            if (field.Type == TType.String) {
              GuildShortName = iprot.ReadString();
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
      TStruct struc = new TStruct("FriendInfo");
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
      if (Nickname != null && __isset.nickname) {
        field.Name = "nickname";
        field.Type = TType.String;
        field.ID = 2;
        oprot.WriteFieldBegin(field);
        oprot.WriteString(Nickname);
        oprot.WriteFieldEnd();
      }
      if (GuildShortName != null && __isset.guildShortName) {
        field.Name = "guildShortName";
        field.Type = TType.String;
        field.ID = 3;
        oprot.WriteFieldBegin(field);
        oprot.WriteString(GuildShortName);
        oprot.WriteFieldEnd();
      }
      oprot.WriteFieldStop();
      oprot.WriteStructEnd();
    }

    public override string ToString() {
      StringBuilder sb = new StringBuilder("FriendInfo(");
      sb.Append("Auid: ");
      sb.Append(Auid);
      sb.Append(",Nickname: ");
      sb.Append(Nickname);
      sb.Append(",GuildShortName: ");
      sb.Append(GuildShortName);
      sb.Append(")");
      return sb.ToString();
    }

  }

}
