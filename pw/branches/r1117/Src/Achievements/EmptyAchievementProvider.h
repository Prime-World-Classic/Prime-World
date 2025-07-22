#include "AchievementManager.h"

class EmptyAchievementProvider : public IAchievementManager::IAchievementProvider
{
public:
	EmptyAchievementProvider();
	~EmptyAchievementProvider();
	bool GetAchievementState(const char* aname);
	void SetAchievementState(const char* aname);
	void Submit();
};