#include "AchievementManager.h"

class SteamAchievementProvider : public IAchievementManager::IAchievementProvider
{
public:
	SteamAchievementProvider();
	~SteamAchievementProvider();
	bool GetAchievementState(const char* aname);
	void SetAchievementState(const char* aname);
	void Submit();
};