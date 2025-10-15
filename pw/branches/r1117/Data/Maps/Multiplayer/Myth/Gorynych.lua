

function GorynychObjective( direction )
	LuaDebugTrace("STARTED: [GorynychObjective]")
	while GetGlobalVar( "stopSpawnStandardWaves" ) do SleepState() end	-- ����, ���� �� ����������� ����������� ��������� ���� �����
	DebugTrace("[GorynychObjective] Gorynych spawn time!")
	LuaSpawnerSpawnWave( "Gorynych" )
	local creep = "Gorynych_w1_c1"
	UpgradeCreepStats( creep ) -- ���������� �������� ���������� �����
	LuaSetCreepFaction( creep, factionEnemy ) 
	WaitState(1.5)
	local startPositionX, startPositionY = LuaGetScriptArea( direction.."EnemySpawnerArea" )
	LuaCreatureTeleportTo( creep, startPositionX, startPositionY )
	
	RED_DIFFICULTY = RED_DIFFICULTY or false
	
	--AddTriggerEnd( HintLineWait, "hintLine_defeatGorynich", 5 )
    LuaUnitApplyApplicatorFromUnit( allyHeroes[1], allyHeroes[1], "gorynychSpawnedEvent" ) -- ���������� ��������� "������������ ���� �������"
	
	AddQuest("killGorynich") -- ��������� ������� "�������� ���� ��������"
	
	AddTriggerEnd( GorynychSoldierSupport, direction ) -- ��������� ��������, ������ ������
	AddTriggerEnd( GorynychBossesSupport, direction ) -- ��������� ��������, ��������
	AddTriggerEnd( GorynychMoving, direction ) -- ���������� �������� ��������� �����������
    
    local dead
	repeat
		dead = LuaUnitIsDead( creep )
		SleepState()
	until dead -- ���� ���� ������� �� ��������. ���� �� ���� ����� ����.
    
	LuaDebugTrace("FINISHED: [GorynychObjective]")
end

-- ���������� �������� �� ��� � ��������, ���� �� ����
function GorynychMoving( direction )
	LuaDebugTrace("STARTED: [GorynychMoving] for direction"..direction)
	local creep = "Gorynych_w1_c1"
	local pathName = direction.."Path"
	LuaSetCreepBehavior( creep, "PathMove", pathName, 5 ) -- ���������� �������� ����� ���� "PathMove" (���� ����� ������ �� �����)
	local dead, exist
	local x, y
		
	repeat
		dead, exist = LuaUnitIsDead( creep )
		if not dead then
			x,y =  LuaUnitGetPosition( creep )
		end
		SleepState()
	until dead --���� ���� ������� �� ��������, ��������� ��� ����������
	LuaPlaceStandaloneEffect("victoryEffect", "fireWorks", x, y) -- ����� �����, � ����� ��� �� ������ ���� ����������� �������� ���������
	AddTriggerEnd( KillAllCreeps ) --������� ���� ������
	WaitState(3)

    local factionLoser 
    if factionPlayer == FACTION_DOCT then factionLoser = FACTION_ADORN else factionLoser = FACTION_DOCT end
    CompleteQuest("killGorynich")
	
	-- reset special points
	for i = 1, #allyHeroes do
		LuaSetHeroSpecialPoints( allyHeroes[i], 0 )
	end
	
	LuaGameFinish( factionLoser ) -- not factionEnemy, 'cause factionEnemy in now NEUTRAL
	PrintArray( SPAWNEDCREEPS )
end


-- ��������� �������� ������� �������. � ������� ������ ������� ������������� �� ��������� ���������� ������
-- ��������� ��� � 15 ������, ���� ������� ���
function GorynychSoldierSupport( direction )
	--local supportUnits = {"Kobolds", "Kobolds", "DemolitionMan2", "Kobolds1", "Satyrs1", "Vodyanoi1", "Assida1"}
	local supportUnits = {"Kobolds"}
	local logicMod = GetGlobalVar("logicMod")
	local waitGorynychSupportInterval = 15
	if RED_DIFFICULTY then
		waitGorynychSupportInterval = waitGorynychSupportInterval * (1 - 0.3 * logicMod) 
	end
	local dead, exist = LuaUnitIsDead( "Gorynych_w1_c1" )
	while  not dead do
		local spawned = SpawnerSpawn( supportUnits[LuaRandom(1, #supportUnits) ], factionEnemy )		
		
		PushPathAndApplyFlagBonus( spawned, direction )
		
		LuaDebugTrace("STARTED: [GorynychMoving] creeps inverval: "..waitGorynychSupportInterval)
		LuaDebugTrace("STARTED: [GorynychMoving] logmodOn: "..logicMod)
		
		WaitState( waitGorynychSupportInterval + LuaRandom( -2, 2) )
		dead, exist = LuaUnitIsDead( "Gorynych_w1_c1" )
	end
end		

-- ��������� �������� ����������. ��������� �� 3 ����� ��� � ������.
function GorynychBossesSupport( direction )
	local dead, exist = LuaUnitIsDead( "Gorynych_w1_c1" )
	local logicMod = GetGlobalVar("logicMod")
	local groups = {"LeshijAlone", "KikimorAlone", "Spriggan1", "Spriggan2", "Assassin1" } -- �� ���� ����� �������� ������
	local waitBossInterval = 40
	if RED_DIFFICULTY then
		waitBossInterval = waitBossInterval * (1 - 0.5 * logicMod) 
	end
	
	LuaDebugTrace("STARTED: [GorynychMoving] boss creeps inverval: "..waitBossInterval)
	while not dead do -- ���� ������� ���
		for i=1, 3 do
			local spawned = SpawnerSpawn( groups[LuaRandom(1,#groups)], factionEnemy )	-- ������� ��������� ������
			PushPathAndApplyFlagBonus( spawned, direction )		
			WaitState(4) -- ����� 4 ������� ��������� ������ ������
		end
		WaitState( waitBossInterval )
		dead, exist = LuaUnitIsDead( "Gorynych_w1_c1" )
	end
end