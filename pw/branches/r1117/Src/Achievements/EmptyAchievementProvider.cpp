#include "stdafx.h"
#include "EmptyAchievementProvider.h"


EmptyAchievementProvider::EmptyAchievementProvider()
{
}

EmptyAchievementProvider::~EmptyAchievementProvider()
{
}

bool EmptyAchievementProvider::GetAchievementState(const char* aname)
{
	return false;
}

void EmptyAchievementProvider::SetAchievementState(const char* aname)
{
}

void EmptyAchievementProvider::Submit()
{
}
