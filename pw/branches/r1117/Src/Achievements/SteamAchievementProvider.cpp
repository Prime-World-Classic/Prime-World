#include "stdafx.h"
#include "SteamAchievementProvider.h"

#include "steam/steam_api.h"
#include "steam/isteamuserstats.h"
#include "steam/isteamremotestorage.h"

SteamAchievementProvider::SteamAchievementProvider()
{
}

SteamAchievementProvider::~SteamAchievementProvider()
{
}

bool SteamAchievementProvider::GetAchievementState(const char* aname)
{
	bool hasAcchieved = false;
	SteamUserStats()->GetAchievement(aname, &hasAcchieved);

	return hasAcchieved;
}

void SteamAchievementProvider::SetAchievementState(const char* aname)
{
	SteamUserStats()->SetAchievement(aname);
}

void SteamAchievementProvider::Submit()
{
	SteamUserStats()->StoreStats();
}
