function QuestEscortDude()
	LuaDebugTrace("STARTED: [QuestEscortDude]")
	local ARTIFACT_COUNTER_BONUS = ARTIFACT_COUNTER_BONUS or 30 -- ������� ����� ����� ���������� � �������� ��������� � ������ ���������� �������
	
	SetGlobalVar( "Quest_escortDude_isEscaped", false )	
				
	local directions = {} -- ����� ����� ������� ��� ��������� ��� ����������� ������� ����������� (��, ������� ������� ��� ������)
		
	for direction, isForbidden in pairs( forbiddenDirections ) do
		if isForbidden then
			table.insert( directions, direction )
		end
	end
    table.sort( directions )


	if #directions == 0 then -- ������� ����� ������� ������ �� "��������" ��� ������ ������, ���� ����� ���, ����� �� ��������
		LuaDebugTrace("ERROR! [QuestEscortDude]. No path to escape!")
		return
	end
	
	AddQuest( "escortDude", false, false )	
	LuaUnitApplyApplicatorFromUnit(allyHeroes[1], allyHeroes[1], "QuestReceivedEvent") --������ ��������� "�������� �������"
	-- �������� ��� ������� � ����������� �� ���� ������
	local dudeSpawner = "unknown"
	if LuaGetLocalFaction() == FACTION_DOCT then
		dudeSpawner = "dude_doct" --���� ����� ������ �� ������, ������ �� ����� ����������� �������
	else
		dudeSpawner = "dude_adorn" -- ���� �� ����������, ��, ��������������, - ������������
	end
	
	local direction = directions[ LuaRandom(1, #directions ) ] --�������� ��������� ����������� �� ��������� 
	local endPointArea = direction.."EnemySpawnerArea" -- �������� ����, ������� ��������� � ����� ���� �� ��������� ����������� 
	local endPointX, endPointY = LuaGetScriptArea( endPointArea ) -- ���������� ���� ����. � ��� ����� ������ �������
	
	local startPointX, startPointY = LuaGetScriptArea( direction.."_dudeStartPoint" ) -- ������� ����, � ������� ������� �����������.
	-- ��� ������� ����������� ��� ���� ����. ��� ��� ���������� �� ����. 
	local spawned = SpawnerSpawn( dudeSpawner, factionPlayer )
	local dude = spawned[1] 
	
	LuaUnitAddFlag( dude, ForbidDeath ) --�������� ��������� ������� �������
	LuaSetUnitHealth( dude, 2500 ) -- ���� ��� �������� ��������
			
	LuaCreatureTeleportTo( dude, startPointX, startPointY ) -- ������ � ��������� �������
	AddTriggerEnd( AmbushesChain, direction, dude ) -- ��������� ������������������ ���� �� �������
	LuaCreateMinimapSignal( startPointX, startPointY ) -- �������� �� ������� ������ � ��������� ���������� �������
	WaitState(5)
	LuaCreateMinimapSignal( startPointX, startPointY ) -- ��������� ������ ����� 5 ������
	LuaUnitRemoveFlag( dude, ForbidDeath ) -- ��������� ������� �������
	
	if UnitIsRealyDead( dude ) then -- ���� ������� ��������� ��������
		LuaDebugTrace("[CheckDudeStatus] Dude is dead! Objective failed!")
		CompleteQuest( "escortDude" ) -- ��������� �����
		LuaUnitApplyApplicatorFromUnit(allyHeroes[1], allyHeroes[1], "QuestFailedEvent") -- ���������� ��������� "������� ���������"
		return 
	end
	LuaSetCreepBehavior( dude, "MoveTo",  endPointX, endPointY, 0, 5 )		-- ���������� ������� � �������� ����� �� ��������� ����
		
	while true do
		if UnitIsRealyDead( dude ) then -- ���� ������� �����
			LuaDebugTrace("[CheckDudeStatus] Dude is dead! Objective failed!")
			CompleteQuest( "escortDude" ) -- ��������� �����
			LuaUnitApplyApplicatorFromUnit(allyHeroes[1], allyHeroes[1], "QuestFailedEvent") -- ���������� ��������� "������� ���������"
			break
		end
		if DistanceUP( dude, endPointX, endPointY ) < 5 then -- ���� �������  �������
			LuaDebugTrace("[CheckDudeStatus] Dude is successfully escaped! Objective completed!")
			SetGlobalVar( "Quest_escortDude_isEscaped", true )	
			CompleteQuest( "escortDude" ) -- ��������� �����
			LuaUnitApplyApplicatorFromUnit(allyHeroes[1], allyHeroes[1], "QuestCompletedEvent") -- ���������� ��������� "������� ���������"
			LuaCreatureHide( dude, true ) -- ������ �������
			SleepState() 
			LuaKillUnit( dude ) -- ������� ��� (��-��, �� ��� ����� �����!)
			for i=1, #allyHeroes do
				LuaUnitApplyApplicatorFromUnit(allyHeroes[i], allyHeroes[i], "AddNaftaForExplode") -- ���� ������ ����� �� ���������� �������
			end
			
			local newArtifactValue = GetGlobalVar( "superability_killsCounter" ) + ARTIFACT_COUNTER_BONUS
			if newArtifactValue > SUPERABILITY_KILLS_COUNTER then newArtifactValue = SUPERABILITY_KILLS_COUNTER end				
			SetGlobalVar("superability_killsCounter", newArtifactValue) 
			
			SetQuestProgress( "chargeArtefact", GetGlobalVar( "superability_killsCounter" ) ) -- ��������� � �������� ��������� �������� ����
			local dead, exist = LuaUnitIsDead( "local" )
			if not dead and exist then -- ���� ����� ������ ���
				local x, y = LuaUnitGetPosition( "local" )
				LuaPlaceClientEffect( "fireWork", x, y) --���������� ��� ��� ���������
			end
			break
		end
		SleepState()
	end
end

-- ��������� �������� ���� �� �������.
-- ���� ������ ������ 17-�� ������ ��� ������� ����� � ���� ������
-- ��� �������
function AmbushesChain( direction, dude )
	LuaDebugTrace("STARTED: [AmbushesChain] for direction "..direction)
	local waitTime = 17 -- ����� ����� �������� ������
	local ambushes = {}
	for i=1, 3 do -- �������� � ����������� �� ����������� 3 ����, � ������� ����� ��������� �����
		ambushes[i] = direction.."_objectiveEscortDudePoint"..tostring(i)
	end	
	local x, y = 0, 0
	for i=1, #ambushes do
		x, y = LuaGetScriptArea( ambushes[i] )
		--while DistanceUP( dude, x, y ) < 22 do SleepState() end
		local timer = 0
		while timer < waitTime do -- ���� �� ������ ����� ��������
			if UnitIsRealyDead( dude ) then -- ���� ������� �����, ������� �� �������
				LuaDebugTrace("[AmbushesChain] dude is dead!")
				return
			end
			if IsUnitInArea( dude, ambushes[i] ) then -- ���� ������� ����� � ���� ������
				break -- ������� �� �����
			end
			timer = timer + GetStepLengthInSeconds()
			SleepState()
		end
		AddTriggerEnd( SpawnAmbushers, ambushes[i], dude )	-- ������� ������	
	end
	LuaDebugTrace("FINISHED: [AmbushesChain] for direction "..direction)
end


-- ������� ������
function SpawnAmbushers( areaName, dude )
	LuaDebugTrace("STARTED: [SpawnAmbushers] for area "..areaName)
	local spawners = {"Kobolds1", "Rogatiki1", "Satyrs1", "Assida2", "Assassin1" } -- �� ���� ��������� ����� ���������� ����� ��� ����
	local n = 1
	local spawned = {}
	while not UnitIsRealyDead( dude ) do -- ���� ������� ���
		LuaDebugTrace("[SpawnAmbushers] area "..areaName.." spawn number "..n)
		spawned = SpawnerSpawn( spawners[ LuaRandom(1, #spawners)] ) -- ������� ��������� ������� ������
		for i=1,#spawned do
			LuaApplyPassiveAbility( spawned[i], "flagpolesBonus" ) -- ���� �� ����� �� ������
		end
		local x, y = LuaGetScriptArea( areaName )
		TeleportUnitList( spawned, x, y ) 
		
		while not UnitIsRealyDead( dude ) do -- ���� ������� ���
			local dudeX, dudeY = LuaUnitGetPosition( dude )
			if not UnitIsRealyDead( spawned ) then	-- � ���� ��� ���� ���-������ �� �������������� ������		
				for i=1, #spawned do
					if not UnitIsRealyDead( spawned[i] ) then
						LuaSetCreepBehavior( spawned[i], "MoveTo",  dudeX, dudeY, 1, 5 ) -- ������ � ������� (��� ���� ��� ����� ��� ���������)
					end
				end
			else
				LuaDebugTrace("[SpawnAmbushers] All creeps are dead!")
				break
			end
			WaitState(4) 
		end
		WaitState(9)
		n = n + 1
	end
	-- ���� �� �����, ������� �����
	LuaDebugTrace("[SpawnAmbushers] for area "..areaName..", dude is dead, let's go to the base!")
	if not UnitIsRealyDead( spawned ) then -- ���� ��� ���� ����� ��������� �����
		LuaDebugTrace("[SpawnAmbushers] for area "..areaName..", there is someone alive!")
		local ivaX, ivaY = LuaUnitGetPosition( ivaCreep )
		for i=1, #spawned do
			if not UnitIsRealyDead( spawned[i] ) then
				LuaSetCreepBehavior( spawned[i], "MoveTo",  ivaX, ivaY, 3, 15 ) -- ��������� ������ ��������� ����
				LuaDebugTrace("[SpawnAmbushers] for area "..areaName..", unit "..spawned[i].." goes to iva")
			end
		end
	end
	LuaDebugTrace("FINISHED: [SpawnAmbushers] for area "..areaName)
end 