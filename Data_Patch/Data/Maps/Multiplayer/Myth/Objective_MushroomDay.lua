
-- ���������� ������� ������� � ���������� �������. ���������� - ������ ��� ���� ����� "questTimer",
-- ������� ���������� �����. ���������� � ������� QuestLittleBoroviks()
-- quest - ��� ������, duration - ����������������� ������ � ��������
function TimerQuestMushroomDayUpdate( quest, duration )
	while IsQuestActive( quest ) and duration >= 0 do -- ���� ����� ������� � ����� �� �����
		SetQuestParams( quest, "sec", duration) -- ���������� ����� 
		WaitState( 1 ) -- ���� �������
		duration = duration - 1 -- ��������� ����� �� �������
	end
	SetGlobalVar("Quest_mushroomDay_timeIsUp", true) 
end

-- ������ �����, ������������ ��� ���������, ��������� ��� ������ ���.
function QuestLittleBoroviks()
	LuaDebugTrace("STARTED: [QuestLittleBoroviks]")
	local randomPointsIndexes = {}
	local QUEST_DURATION = 120 -- ����������������� ������
	local TOTAL_BOROVIKS = 10 -- ������� ����� ��������� ����� ����������
	local ARTIFACT_COUNTER_BONUS = ARTIFACT_COUNTER_BONUS or 20 -- ������� ����� ����� ���������� � �������� ���������
	--local REWARD_HERO_PRIME = 500 -- ������� ����� �� ���������� ������
	
	AddQuest( "mushroomDay", false, false ) -- ������ ����� ��� ���������
	AddQuest( "questTimer", false, false )	-- ������ �������������� �����-������
	SetQuestParams( "questTimer", "sec", QUEST_DURATION ) -- �������� ������-������� ���������
	LuaUnitApplyApplicatorFromUnit(allyHeroes[1], allyHeroes[1], "QuestReceivedEvent") -- ���������� ���������� "�������� �������"
	
	AddTriggerEnd( TimerQuestMushroomDayUpdate, "questTimer", QUEST_DURATION ) -- ��������� �������, ������� ����� �������� ������� ������� � ������-�������
	
	SetGlobalVar( "Quest_mushroomDay_deadBoroviks", 0 ) -- ������� ������ ���������
	SetGlobalVar( "Quest_mushroomDay_timeIsUp", false ) -- ���������� ��� �������� ����, �� ��������� �� ����� ������
	SetGlobalVar( "Quest_mushroomDay_timeToAttackBase", false ) 
	--AddTriggerEnd( SetGlobalVarWhenTimeIsUp, "Quest_mushroomDay_timeIsUp", QUEST_DURATION, true )
	
	for i=1, 28 do randomPointsIndexes[i] = i end -- ��������� ������ randomPointsIndexes ���������� �� 1 �� 28
	randomPointsIndexes = ShuffleArray( randomPointsIndexes ) -- ������������ ���
	local tmp = CopyArray( randomPointsIndexes ) -- �������� ��� �� ��������� ������ tmp
	randomPointsIndexes = {} -- �������� �������� ������ randomPointsIndexes
	for i=1, TOTAL_BOROVIKS do randomPointsIndexes[i] = tmp[i] end	-- ������ ���� � ���� ������� �������� �� tmp, ������� � ��� ���������
	table.sort( randomPointsIndexes ) -- ��������� (����� �� ���� ��������)
	
	
	for i=1, TOTAL_BOROVIKS do
		AddTriggerEnd( SpawnLittleBoroviks, randomPointsIndexes[i] ) -- ������� �������� � ������ �� ��������� ��������� �����
	end
	
	local superabilityUsesCounter = GetGlobalVar( "superabilityUsesCount" )	
	while true do
		if GetGlobalVar( "Quest_mushroomDay_deadBoroviks" ) == TOTAL_BOROVIKS or GetGlobalVar( "superabilityUsesCount" ) > superabilityUsesCounter  then -- ���� ��� �������������� �������� ��������
			DebugTrace("[QuestLittleBoroviks]: objective completed")
			CompleteQuest( "mushroomDay" ) -- ��������� �����
			CompleteQuest( "questTimer" ) -- � �����-������ ���� ���������
			LuaUnitApplyApplicatorFromUnit(allyHeroes[1], allyHeroes[1], "QuestCompletedEvent") -- ���������� ��������� "������� ���������"
			for i=1, #allyHeroes do
				--LuaHeroAddPrime( allyHeroes[i], REWARD_HERO_PRIME )
				LuaUnitApplyApplicatorFromUnit(allyHeroes[i], allyHeroes[i], "AddNaftaForExplode") -- ������ ������� ����� �����
			end
			
			local newArtifactValue = GetGlobalVar( "superability_killsCounter" ) + ARTIFACT_COUNTER_BONUS -- ��������� � �������� ��������� �������� ����
			if newArtifactValue > SUPERABILITY_KILLS_COUNTER then newArtifactValue = SUPERABILITY_KILLS_COUNTER end	-- ���� ����� ���������� ������ 100, ������������ ������� ��������� 100		
			SetGlobalVar("superability_killsCounter", newArtifactValue)
			
			SetQuestProgress( "chargeArtefact", GetGlobalVar( "superability_killsCounter" ) ) -- ���������� � ���������� ����� �������� �������� ���������
			local dead, exist = LuaUnitIsDead( "local" )
			if not dead and exist then -- ���� ����� ������ ���
				local x, y = LuaUnitGetPosition( "local" )
				LuaPlaceClientEffect( "fireWork", x, y) --�������� ��� ��� ���������
			end
			break
		end
		if GetGlobalVar( "Quest_mushroomDay_timeIsUp" ) == true then -- ���� ����� ������ ����� ��� ������ ��������
			DebugTrace("[QuestLittleBoroviks]: objective failed")
			SetGlobalVar( "Quest_mushroomDay_timeToAttackBase", true )			
			CompleteQuest( "mushroomDay" ) -- ������ �������� �����
			CompleteQuest( "questTimer" )	-- � �����-������ ���� ������
			LuaUnitApplyApplicatorFromUnit(allyHeroes[1], allyHeroes[1], "QuestFailedEvent") -- ���������� ��������� "������� ���������"
			break -- ������� �� �����
		end
		SleepState()
	end
end

-- ������� �������� � ����� forestRandomPoint + pointIndex. ��������,
-- ���� � pointIndex ���� �������� 13, �� ������� ����������� � ����� forestRandomPoint13
-- ����� ������ �� ��� �������. ���� ������� ����, ��������� ������� ������, ���� ����� ������ �����,
-- ���������� �������� � ����� �� ����.
function SpawnLittleBoroviks( pointIndex )
	LuaDebugTrace("STARTED [SpawnLittleBoroviks]: for point "..pointIndex)
	local x, y = LuaGetScriptArea( "forestRandomPoint"..pointIndex ) -- �������� ���������� �����
	local spawned = SpawnerSpawn( "LittleBorovik", factionEnemy ) -- ������� ��������
	local ivaX, ivaY = LuaUnitGetPosition( ivaCreep ) -- ���� ����� ���������� ��� ����� �� ����
	TeleportUnitList( spawned, x, y ) -- ������ �������� � �����
	--LuaSetCreepBehavior( spawned[1], "MoveTo", x, y, 3, 10 )
	--LuaSetCreepBasePlace( spawned[1], x, y )
	LuaUnitAddFlag( spawned[1], ForbidAttack + ForbidAutoAttack ) -- ��������� ��� ���������
	AddTriggerEnd( Migration, spawned[1] )	-- ��������� �������, ������� ����� ���������� �������� ������ �������.
	while true do
		if UnitIsRealyDead( spawned[1] ) then -- ���� ������� �����			
			SetGlobalVar( "Quest_mushroomDay_deadBoroviks", GetGlobalVar( "Quest_mushroomDay_deadBoroviks" ) + 1 )	
			SetQuestProgress( "mushroomDay", GetGlobalVar( "Quest_mushroomDay_deadBoroviks" ) ) -- ��������� ������� ������ ��������� � ������
			LuaDebugTrace("[SpawnLittleBoroviks] "..spawned[1].." is dead. Dead boroviks count = "..GetGlobalVar( "Quest_mushroomDay_deadBoroviks" ))
			break
		end
		if GetGlobalVar( "Quest_mushroomDay_timeToAttackBase" ) then --���� ����� �������� � ���� ��������� ����
			LuaUnitRemoveFlag( spawned[1], ForbidAttack + ForbidAutoAttack ) -- ��������� �������� ���������
			LuaReplaceCreep( spawned[1], "bigBorovik", factionEnemy ) -- �������� ��� �� �������� ��������
			UpgradeCreepStats( spawned[1] ) -- ��������� ��� �����, � ����������� �� ���������
			LuaSetCreepBehavior( spawned[1], "MoveTo", ivaX, ivaY, 1, 20 ) -- ���������� ��� ��������� ����
			LuaDebugTrace("[SpawnLittleBoroviks] unit "..spawned[1].." goes to base")
			break
		end
		SleepState()
	end
	LuaDebugTrace("FINISHED [SpawnLittleBoroviks]: for point "..pointIndex)
end

-- ���������� �������� ������������ ������ �������. 
-- ��� � 20 ������ ������� �����, � ���������
-- ����� �� ���� ��������� �� ����� ����� � ������� ���� forestRandomPoint<number>
function Migration( borovik )
	LuaDebugTrace("STARTED [Migration] for "..borovik)
	local points = {}
	local pointX, pointY = 0,0
	local borovikX, borovikY = LuaUnitGetPosition( borovik )	
	local newPointX, newPointY = 0, 0
	
	while IsQuestActive( "mushroomDay" ) do -- ���� ����� �������
		WaitState( 20 ) --���� 20 ������
		
		if UnitIsRealyDead( borovik ) or not IsQuestActive( "mushroomDay" ) then -- ���� ������� ����� ��� ����� ����������, �������
			LuaDebugTrace("[Migration] borovik "..borovik.." is dead or quest is not active")
			return 
		end
				
		points = {} -- � points ������ ��� ��������� ����� ���� "forestRandomPoint"<number>, ����� �����, � ������� ����� �������
		for i=1, 28 do
			pointX, pointY = LuaGetScriptArea( "forestRandomPoint"..i) 
			if DistanceUP( borovik, pointX, pointY ) > 5 then
				table.insert( points, {x = pointX, y = pointY} )
			end
		end		
		
		newPointX, newPointY = GetNearestPointToPointList( borovikX, borovikY, points )	-- ������� ��������� ����� � ������� ��������	
		LuaDebugTrace("[Migration] "..borovik.." goes to point "..newPointX..", "..newPointY)
		
		-- ���� ������� ��� � ����  ���������� �� ����� ������� ������ 4 � ���� ����� �������
		while not UnitIsRealyDead( borovik ) and DistanceUP( borovik, newPointX, newPointY ) > 4 and IsQuestActive( "mushroomDay" ) do
			LuaCreatureMoveTo( borovik, newPointX, newPointY, 0 ) -- ���������� �������� ������ � ����� �������
			WaitState(1)
		end
		SleepState()
	end
	LuaDebugTrace("FINISHED [Migration] for "..borovik)
end