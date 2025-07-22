#include "stdafx.h"
#include "AchievementManager.h"
#include "EmptyAchievementProvider.h"

class AchievementManager : public IAchievementManager
{
	int ourUserId;
public:	
	AchievementManager();
	~AchievementManager();

	virtual bool Init(IAchievementProvider* achievementProvider); //pass ownership of provder to AchievementManager
	virtual void Shutdown();

	virtual bool HasAchievment(AchievementID achivement);
	virtual void SetAchievment(AchievementID achivement);

	virtual std::string GetAchievmentAPI_Name(AchievementID achivement);

	virtual int GetOurUserID()
	{
		return ourUserId;
	}
	virtual void SetOurUserID(int id)
	{
		ourUserId = id;
	}

private:
	bool gottenAchievement[MAX_ACHIEVEMENT_NAME];
	IAchievementProvider* provider;
};

bool AchievementManager::Init(IAchievementProvider* achievementProvider)
{
	if(achievementProvider == 0)
		achievementProvider = new EmptyAchievementProvider();

	provider = achievementProvider;

	for(int i=0;i<MAX_ACHIEVEMENT_NAME;++i)
	{
		std::string achievementAPI_Name = GetAchievmentAPI_Name((AchievementID)i);
		gottenAchievement[i] = provider->GetAchievementState(achievementAPI_Name.c_str());
	}

	return true;
}

void AchievementManager::Shutdown()
{
	if(provider)
		provider->Submit();

	delete provider;

	provider = 0;
}

bool AchievementManager::HasAchievment(AchievementID achivement)
{
	if(!provider)
		return false;

	int achievementIndex = (int)achivement;

	if(achievementIndex <0 || achievementIndex >= MAX_ACHIEVEMENT_NAME)
		return false;

	if(gottenAchievement[achievementIndex]) //has cached achievement value
		return true;

	std::string achievementAPI_Name = GetAchievmentAPI_Name(achivement);

	gottenAchievement[achievementIndex] = provider->GetAchievementState(achievementAPI_Name.c_str());
	return gottenAchievement[achievementIndex];
}

void AchievementManager::SetAchievment(AchievementID achivement)
{
	if(!provider)
		return;

	int achievementIndex = (int)achivement;

	if(achievementIndex <0 || achievementIndex >= MAX_ACHIEVEMENT_NAME)
		return;

	if(gottenAchievement[achievementIndex]) //already setted
		return;

	std::string achievementAPI_Name = GetAchievmentAPI_Name(achivement);


	provider->SetAchievementState(achievementAPI_Name.c_str());
	provider->Submit();
}

std::string AchievementManager::GetAchievmentAPI_Name(AchievementID achivement)
{
	int achievementIndex = (int)achivement;

	if(achievementIndex <0 || achievementIndex >= MAX_ACHIEVEMENT_NAME)
		return "NON_IMPLEMENTED";

	static const char* API_Names[MAX_ACHIEVEMENT_NAME] = {
		"PLAY_BORDERLANDS",
		"WIN_BORDERLANDS",
		"LOSE_BORDERLANDS",
		"FIRST_KILL",
		"FIRST_DEATH",
		"FIRST_ASSIST"};

	return API_Names[achievementIndex];
}

AchievementManager::AchievementManager()
{
	ourUserId = 0;
	provider = 0;
}

AchievementManager::~AchievementManager()
{
	Shutdown();
}

IAchievementManager* IAchievementManager::GetInstance()
{
	static AchievementManager amanager;
	return &amanager;
}