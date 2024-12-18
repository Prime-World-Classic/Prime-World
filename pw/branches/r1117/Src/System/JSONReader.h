#pragma once
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#include <Vendor/JsonCpp/include/json/json.h>
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
namespace NFile
{
	class CFilePath;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
namespace NJson
{
class CJsonReader : public BaseObjectMT
{
  NI_DECLARE_REFCOUNT_CLASS_1( CJsonReader, BaseObjectMT );
  
  Json::Reader reader;
  Json::Value rootNode;

	string jsonString;
	void Start();

private:
	CJsonReader() {}

public:
	CJsonReader(const string &jsonString);

	const Json::Value* GetRootElement() const { return &rootNode; }
  Json::Value* GetRootElement() { return &rootNode; }
};
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
