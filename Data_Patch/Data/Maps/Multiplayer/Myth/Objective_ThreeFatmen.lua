function QuestThreeFatman()
	local randomPointsIndexes = {}
	local FATMEN_COUNT = 3 -- ���������� ���������
	local ARTIFACT_COUNTER_BONUS = ARTIFACT_COUNTER_BONUS or 20 -- ����� ���������� ����� � �������� ��������� ������� ��������� � ������ ���������� �������	

	
	AddQuest( "threeFatmen", false, false )
	--AddTriggerEnd( HintLineWait, "objectiveActive", 4 )
	LuaUnitApplyApplicatorFromUnit(allyHeroes[1], allyHeroes[1], "QuestReceivedEvent") -- ���������� ��������� "�������� �������"
	
	SetGlobalVar( "Quest_threeFatmen_deadFatmen", 0 ) 
	SetGlobalVar( "Quest_threeFatmen_escapedFatmen", 0 )
		
	randomPointsIndexes = {18, 17, 25, 4, 5, 7, 6, 14, 12, 16} -- ������� �����, � ������� ����� ����������� ��������. ����� - ��� ���� �� ����� � ���������� ���� forestRandomPoint<number>
	randomPointsIndexes = ShuffleArray( randomPointsIndexes )	-- ������������ ������
	local tmp = CopyArray( randomPointsIndexes )
	randomPointsIndexes = {}
	for i=1, FATMEN_COUNT do randomPointsIndexes[i] = tmp[i] end	
	table.sort( randomPointsIndexes )
	
	for i=1, FATMEN_COUNT do
		AddTriggerEnd( SpawnFatman, randomPointsIndexes[i] ) -- ��������� �������, ������� ��������� ��������
	end
	
	while true do
		if GetGlobalVar( "Quest_threeFatmen_deadFatmen" ) == FATMEN_COUNT and GetGlobalVar( "Quest_threeFatmen_escapedFatmen" ) == 0 then -- ���� ������� ��������� (��� 3 �������� ����������)
			CompleteQuest( "threeFatmen" )
			CompleteQuest( "questTimer" )
			LuaUnitApplyApplicatorFromUnit(allyHeroes[1], allyHeroes[1], "QuestCompletedEvent") -- ���������� ��������� "�������� �������"
			for i=1, #allyHeroes do
				LuaUnitApplyApplicatorFromUnit(allyHeroes[i], allyHeroes[i], "AddNaftaForExplode") -- ������ ������� ����� 500 ������ �� ���������� �������
			end
			
			local newArtifactValue = GetGlobalVar( "superability_killsCounter" ) + ARTIFACT_COUNTER_BONUS -- ����� �������� ��� �������� ������������ ���������
			if newArtifactValue > SUPERABILITY_KILLS_COUNTER then newArtifactValue = SUPERABILITY_KILLS_COUNTER end	-- ���� ����� �������� ��������� ������ 100, ���������� ��� 100			
			SetGlobalVar("superability_killsCounter", newArtifactValue)
			
			SetQuestProgress( "chargeArtefact", GetGlobalVar( "superability_killsCounter" ) ) --��������� � ���������� ������ ��� ������� ��������� ����� �������� ��� ��������
			local dead, exist = LuaUnitIsDead( "local" )
			if not dead and exist then
				local x, y = LuaUnitGetPosition( "local" )
				LuaPlaceClientEffect( "fireWork", x, y) -- ������ ��� ������ ������ ����������
			end
			return
		end
		if GetGlobalVar( "Quest_threeFatmen_escapedFatmen" ) + GetGlobalVar( "Quest_threeFatmen_deadFatmen" ) >= FATMEN_COUNT then -- ���� ������� ��������� (��� ��������� �������� ������ ���� � �����)
			--AddTriggerEnd( HintLineWait, "objectiveFailed", 4 )
			CompleteQuest( "threeFatmen" )
			CompleteQuest( "questTimer" )
			LuaUnitApplyApplicatorFromUnit(allyHeroes[1], allyHeroes[1], "QuestFailedEvent") --���������� ��������� "������� ���������"
			return
		end
		SleepState()
	end
end

-- ���� ����� � ��������� ��� �� ������ �����
-- �������� ������������ ������ �� ��������
function SpawnSignalOnMinimap( period, unit )
	for i=1, 3 do
		if UnitIsRealyDead( unit ) then break end
		local x, y = LuaUnitGetPosition( unit )		
		local near = false
		for i=1, #allyHeroes do		
			local dead, exist = LuaUnitIsDead( allyHeroes[i] )
			if not dead and exist then
				if DistanceUU( allyHeroes[i], unit ) <= 10 then
					near = true
					break
				end
			end
		end
		if not near then
			LuaCreateMinimapSignal( x, y )		
		end
		WaitState( period )
	end
end

-- �������, ������� ������� ��������,
-- ���������� ��� ������� � ����� � ������ �� ��� ��������
function SpawnFatman( pointIndex )
	LuaDebugTrace("STARTED: [SpawnFatman] for point "..pointIndex )
	local x, y = LuaGetScriptArea( "forestRandomPoint"..pointIndex )-- ���������� ��������� ����� �� �����, ������ ������� ������ ���� ����
	local spawned = SpawnerSpawn( "LeshijBig", factionEnemy ) -- ������� ��������
	local fatman = spawned[1] -- � ���� �������� ������ 1 ����, ��� ��� ��� �������� ��� 1-� �������� � ������� 
	LuaApplyPassiveAbility( fatman, "flagpolesBonus" ) -- ������ ����� �� ������
	LuaUnitAddFlag( fatman, ForbidAutoAttack + ForbidAttack + ForbidSelectTarget ) -- ��������� �������� ���������
	LuaCreatureTeleportTo( fatman, x, y ) -- ���������� ��� � ��� �����, ������ �� ������ � �����
	AddTriggerEnd( SpawnSignalOnMinimap, 10, fatman  )	-- ������� �� ������� ��������, ���� ����� � ��������� ��� �� ������ �����
	
	local directions = GetAvailableDirections()
	
	-- �������� �����, � ������� ����� ������� �������
	local escapePoints= {} 
	for i=1, #directions do
		local pointName = directions[i].."EnemySpawnerArea"
		local pointX, pointY = LuaGetScriptArea( pointName )
		local pathName = directions[i].."Path"
		escapePoints[i] = {name = pointName, x = pointX, y = pointY, path = pathName} -- ������ � ������ escapePoints ���������� ���� �������� ����� ����� �� �����
	end
	local escapePointX, escapePointY, escapePointName, escapePath = GetNearestPointToPointList( x, y, escapePoints ) --�������� �� ��� ��������� � �������� (������������� ���������)
	
	AddTriggerEnd( RemoveFatmanWhenHeEscapes, fatman, escapePointX, escapePointY, escapePath ) -- ��������� �������, ������� ������ ��������, ����� �� ������ �� ��������� ����� ������ ����
	WaitState(10) -- ������� ���� 10 ������ ����� ���, ��� ����� (���� ������ ����)
	if UnitIsRealyDead( fatman ) then -- ���� �� ����� ����� �� ��� 10 ������
		LuaDebugTrace("[SpawnFatman] fatman "..fatman.." is dead!")
		SetGlobalVar( "Quest_threeFatmen_deadFatmen", GetGlobalVar( "Quest_threeFatmen_deadFatmen" ) + 1 )--����������� ���������� ������������ ���������
		SetQuestProgress( "threeFatmen", GetGlobalVar( "Quest_threeFatmen_deadFatmen" ) ) -- ���������� � ���������� ����������� �������� ���������� ������������ ���������
		LuaDebugTrace("[SpawnFatman] Quest_threeFatmen_deadFatmen = "..GetGlobalVar( "Quest_threeFatmen_deadFatmen" ))
		return -- �������
	end
	LuaSetCreepBehavior( fatman, "MoveTo",  escapePointX, escapePointY, 0) -- ���������� �������� � ��� ����� ��������
	
	while true do 
		if UnitIsRealyDead( fatman ) then -- ���� ������� ��� ���������
			LuaDebugTrace("[SpawnFatman] fatman "..fatman.." is dead!")
			SetGlobalVar( "Quest_threeFatmen_deadFatmen", GetGlobalVar( "Quest_threeFatmen_deadFatmen" ) + 1 ) --����������� ���������� ������������ ���������
			SetQuestProgress( "threeFatmen", GetGlobalVar( "Quest_threeFatmen_deadFatmen" ) ) -- ���������� � ���������� ����������� �������� ���������� ������������ ���������
			LuaDebugTrace("[SpawnFatman] Quest_threeFatmen_deadFatmen = "..GetGlobalVar( "Quest_threeFatmen_deadFatmen" ))
			break --�������
		end
		if not IsQuestActive( "threeFatmen" ) then -- ���� ����� ��������
			LuaDebugTrace("[SpawnFatman] quest threeFatmen is not active!")
			LuaKillUnit( fatman ) -- ������� ��������
			break --�������
		end
		SleepState()
	end
end

-- �������, ��������� �������� � �����, ����� �� ������� �� ����� ������ ����
function RemoveFatmanWhenHeEscapes( fatman, escapePointX, escapePointY, escapePath )
	LuaDebugTrace("STARTED: [RemoveFatmanWhenHeEscapes] for "..fatman)
	while not UnitIsRealyDead( fatman ) and IsQuestActive( "threeFatmen") do -- ���� ������� ���
		if DistanceUP( fatman, escapePointX, escapePointY ) < 7 then --���� �� ��������� ����� �������� ������ 7-� ������
			LuaDebugTrace("[RemoveFatmanWhenHeEscapes] "..fatman.." escapes")
			local fatmanEscape = true	
			LuaCreatureHide( fatman, true ) --������ ��������
			SetGlobalVar( "Quest_threeFatmen_escapedFatmen", GetGlobalVar( "Quest_threeFatmen_escapedFatmen") + 1 ) --����������� ���������� ��������� ���������
			AddTriggerEnd( SpawnLeshijNextWave, escapePointX, escapePointY, escapePath ) -- ��������� �������, ������� ����� �������� ������������� �� �����������, ���� ������ �������
			break
		end
		SleepState()
	end
	LuaDebugTrace("FINISHED: [RemoveFatmanWhenHeEscapes] for "..fatman)
end

-- �������, ������� ������� ������������� �� �����������, ���� ���� ������� �������
function SpawnLeshijNextWave( escapePointX, escapePointY, escapePath )
	LuaDebugTrace("STARTED: [SpawnLeshijNextWave] for point "..escapePointX..", "..escapePointY )
	local leshij = {"Leshij2", "Leshij1"} -- �������� 1 �� ���� ��������� ��� ������
	local ivaX, ivaY = LuaUnitGetPosition( ivaCreep )
	for i=1, 3 do -- ������� 3 ����
		WaitState(20) -- ������ 20 ������
		if GetGlobalVar("WaveInProgress") then 
			spawned = SpawnerSpawn( leshij[ LuaRandom(1,2) ], factionEnemy )
			TeleportUnitList( spawned, escapePointX, escapePointY )
			for i=1, #spawned do
				LuaApplyPassiveAbility( spawned[i], "flagpolesBonus" )
				LuaSetCreepBehavior( spawned[i], "PathMove", escapePath, 20 ) 
			end
		end		
	end
	LuaDebugTrace("FINISHED: [SpawnLeshijNextWave] for point "..escapePointX..", "..escapePointY )
end