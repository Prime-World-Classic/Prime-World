#pragma once
#include <array>
#include <string>

class IAchievementManager
{
public:	
	class IAchievementProvider
	{
	public:
		virtual bool GetAchievementState(const char* aname) = 0;
		virtual void SetAchievementState(const char* aname) = 0;
		virtual void Submit() = 0;
	};

	enum AchievementID
	{
		PLAY_BORDERLANDS = 0,
		WIN_BORDERLANDS = 1,
		LOSE_BORDERLANDS = 2,
		FIRST_KILL = 3,
		FIRST_DEATH = 4,
		FIRST_ASSIST = 5,

		MAX_ACHIEVEMENT_NAME
	};

	static IAchievementManager* GetInstance();

	virtual bool Init(IAchievementProvider* achievementProvider)=0; //pass ownership of provder to AchievementManager
	virtual void Shutdown()=0;

	virtual bool HasAchievment(AchievementID achivement)=0;
	virtual void SetAchievment(AchievementID achivement)=0;

	virtual std::string GetAchievmentAPI_Name(AchievementID achivement)=0;

	virtual int GetOurUserID() = 0;
	virtual void SetOurUserID(int id) = 0;

	template<class T>
	bool IsOurHero(T hero)
	{
		if(hero->GetPlayer())
		{
			if(hero->GetPlayer()->GetUserID() == GetOurUserID())
				return true;
		}

		return false;
	}
};