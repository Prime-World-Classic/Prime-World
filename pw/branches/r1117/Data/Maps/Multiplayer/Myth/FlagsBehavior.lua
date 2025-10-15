
-- Constants
    FOREST_FLAG_POLES = {"leftCreepHutFlag3", "leftCreepHutFlag1", "leftCreepHutFlag2", "upCreepHutFlag1", "rightCreepHutFlag2", "rightCreepHutFlag1", "rightCreepHutFlag3", "downCreepHutFlag1"}
	CREEP_HUTS = {"leftCreepHut1", "leftCreepHut2", "leftCreepHut3", "downCreepHut1", "rightCreepHut1", "rightCreepHut2", "rightCreepHut3", "upCreepHut1"}

 -- Global vars
raisedFlagpoles = nil -- ����� ������ ��� ����� �� ����� � �� ���������. ���� ����� ������������� true, ������ �� ������, ���� false - ������ ������
flagsInitCompleted = false --transient


function FlagsInit( reconecting )	
    raisedFlagpoles = {}
	if not reconnecting then
		SetGlobalVar( "raisedFlagpoles", raisedFlagpoles )
	end
end
function FlagsReconnect()
   	raisedFlagpoles = GetGlobalVar( "raisedFlagpoles" )
    flagsInitCompleted = true
end

-- ��������� ������
function FlagsStartup()	
	LuaDebugTrace("STARTED: [InitFlags]")
	flagsInitCompleted = false
	
	SetFlagChainNature( "leftPolygon", {"1", "2", "3"}, -1, FACTION_NEUTRAL ) -- ��������� ��� ��������� ��� ������ ����� ��� ������� ������ �� ����� ������. "leftPolygon" - �������� ����, ������� {"1", "2", "3"} ������� ������� ����� ��������������� ��� ������� ������
	SetFlagChainNature( "upPolygon", {"1", "2", "3"}, -1, FACTION_NEUTRAL ) -- ��������� ��� ��������� ��� ������ ����� ��� ������� ������ �� ������� ������. "upPolygon" - �������� ����, ������� {"1", "2", "3"} ������� ������� ����� ��������������� ��� ������� ������
	SetFlagChainNature( "rightPolygon", {"1", "2", "3"}, -1, FACTION_NEUTRAL ) -- ��������� ��� ��������� ��� ������ ����� ��� ������� ������ �� ������ ������. "rightPolygon" - �������� ����, ������� {"1", "2", "3"} ������� ������� ����� ��������������� ��� ������� ������
	SetFlagChainNature( "downPolygon", {"1", "2", "3"}, -1, FACTION_NEUTRAL ) -- ��������� ��� ��������� ��� ������ ����� ��� ������� ������ �� ������ ������. "downPolygon" - �������� ����, ������� {"1", "2", "3"} ������� ������� ����� ��������������� ��� ������� ������
	SetFlagChainNature( "leftCreepHutPolygon1", {"1"}, -1, FACTION_NEUTRAL ) -- �������������� ������� ������ (�� ������ ����� ) ��� ������� �����
	SetFlagChainNature( "leftCreepHutPolygon3", {"1"}, -1, FACTION_NEUTRAL ) -- �������������� ������� ������ (�� ������ ����� ) ��� ������� �����
	SetFlagChainNature( "downCreepHutPolygon1", {"1"}, -1, FACTION_NEUTRAL ) -- �������������� ������� ������ (�� ������ ����� ) ��� ������� �����
	SetFlagChainNature( "rightCreepHutPolygon1", {"1"}, -1, FACTION_NEUTRAL ) -- �������������� ������� ������ (�� ������ ����� ) ��� ������� �����
	SetFlagChainNature( "rightCreepHutPolygon2", {"1"}, -1, FACTION_NEUTRAL ) -- �������������� ������� ������ (�� ������ ����� ) ��� ������� �����
	SetFlagChainNature( "rightCreepHutPolygon3", {"1"}, -1, FACTION_NEUTRAL ) -- �������������� ������� ������ (�� ������ ����� ) ��� ������� �����
	SetFlagChainNature( "upCreepHutPolygon1", {"1"}, -1, FACTION_NEUTRAL ) -- �������������� ������� ������ (�� ������ ����� ) ��� ������� �����
	SetFlagChainNature( "leftCreepHutPolygon2", {"1"}, -1, FACTION_NEUTRAL ) -- �������������� ������� ������ (�� ������ ����� ) ��� ������� �����
	local leftChainFlags = {"leftFlag1", "leftFlag2", "leftFlag3"} -- ����� ������ � ������� ����� ����� ������
	local rightChainFlags = {"rightFlag1", "rightFlag2", "rightFlag3"} -- ����� ������ � ������� ����� ������ ������
	local upChainFlags = {"upFlag1", "upFlag2", "upFlag3"} -- ����� ������ � ������� ����� ������� ������
	local downChainFlags = {"downFlag1", "downFlag2", "downFlag3"} -- ����� ������ � ������� ����� ������ ������
	for i=1, #leftChainFlags do raisedFlagpoles[ leftChainFlags[i] ] = false end -- ��������� � ������ ���� ������ raisedFlagpoles ����� ����� ������. ��������� "�� ������", �� ���� false
	for i=1, #rightChainFlags do raisedFlagpoles[ rightChainFlags[i] ] = false end -- ��������� � ������ ���� ������ raisedFlagpoles ����� ������ ������. ��������� "�� ������", �� ���� false
	for i=1, #upChainFlags do raisedFlagpoles[ upChainFlags[i] ] = false end -- ��������� � ������ ���� ������ raisedFlagpoles ����� ������� ������. ��������� "�� ������", �� ���� false
	for i=1, #downChainFlags do raisedFlagpoles[ downChainFlags[i] ] = false end -- ��������� � ������ ���� ������ raisedFlagpoles ����� ������ ������. ��������� "�� ������", �� ���� false
		
	CreateFlagChain( "leftChain", leftChainFlags, "leftPolygon", {"1", "2", "3"}, factionPlayer, FlagIsRaised ) -- ������������� ������� ������ ����� ����� ������. FlagIsRaised �������, ������� ����� ����������� ��� �������/������ ������ ����� �� �������
	CreateFlagChain( "upChain", upChainFlags, "upPolygon", {"1", "2", "3"}, factionPlayer, FlagIsRaised) -- ������������� ������� ������ ����� ������� ������. FlagIsRaised �������, ������� ����� ����������� ��� �������/������ ������ ����� �� �������
	CreateFlagChain( "rightChain", rightChainFlags, "rightPolygon", {"1", "2", "3"}, factionPlayer, FlagIsRaised) -- ������������� ������� ������ ����� ������ ������. FlagIsRaised �������, ������� ����� ����������� ��� �������/������ ������ ����� �� �������
	CreateFlagChain( "downChain", downChainFlags, "downPolygon", {"1", "2", "3"}, factionPlayer, FlagIsRaised)	-- ������������� ������� ������ ����� ������ ������. FlagIsRaised �������, ������� ����� ����������� ��� �������/������ ������ ����� �� �������
	CreateFlagChain( "leftCreepHutChain1", {"leftCreepHutFlag1"}, "leftCreepHutPolygon1", {"1"}, factionPlayer, ForestFlagRaised) --������������� ������� ������ (�� ������ �����) ��� ���� � ����. ForestFlagRaised ���������� ���� ���� ��������/�������
	CreateFlagChain( "leftCreepHutChain2", {"leftCreepHutFlag2"}, "leftCreepHutPolygon2", {"1"}, factionPlayer, ForestFlagRaised) --������������� ������� ������ (�� ������ �����) ��� ���� � ����. ForestFlagRaised ���������� ���� ���� ��������/�������	
	CreateFlagChain( "leftCreepHutChain3", {"leftCreepHutFlag3"}, "leftCreepHutPolygon3", {"1"}, factionPlayer, ForestFlagRaised)		 --������������� ������� ������ (�� ������ �����) ��� ���� � ����. ForestFlagRaised ���������� ���� ���� ��������/�������
	CreateFlagChain( "downCreepHutChain1", {"downCreepHutFlag1"}, "downCreepHutPolygon1", {"1"}, factionPlayer, ForestFlagRaised)	 --������������� ������� ������ (�� ������ �����) ��� ���� � ����. ForestFlagRaised ���������� ���� ���� ��������/�������
	CreateFlagChain( "rightCreepHutChain1", {"rightCreepHutFlag1"}, "rightCreepHutPolygon1", {"1"}, factionPlayer, ForestFlagRaised)	 --������������� ������� ������ (�� ������ �����) ��� ���� � ����. ForestFlagRaised ���������� ���� ���� ��������/�������
	CreateFlagChain( "rightCreepHutChain2", {"rightCreepHutFlag2"}, "rightCreepHutPolygon2", {"1"}, factionPlayer, ForestFlagRaised)	 --������������� ������� ������ (�� ������ �����) ��� ���� � ����. ForestFlagRaised ���������� ���� ���� ��������/�������
	CreateFlagChain( "rightCreepHutChain3", {"rightCreepHutFlag3"}, "rightCreepHutPolygon3", {"1"}, factionPlayer, ForestFlagRaised)	 --������������� ������� ������ (�� ������ �����) ��� ���� � ����. ForestFlagRaised ���������� ���� ���� ��������/�������
	CreateFlagChain( "upCreepHutChain1", {"upCreepHutFlag1"}, "upCreepHutPolygon1", {"1"}, factionPlayer, ForestFlagRaised)	 --������������� ������� ������ (�� ������ �����) ��� ���� � ����. ForestFlagRaised ���������� ���� ���� ��������/�������
	
	
	for i=1, #FOREST_FLAG_POLES do -- ��� ���� ������ ������
		LuaCreatureHide( string.sub( FOREST_FLAG_POLES[i], 1, string.find( FOREST_FLAG_POLES[i], '%u') - 1).."GlyphSpawner"..string.sub( FOREST_FLAG_POLES[i], -1 ), true ) -- ������ ������� �����
		raisedFlagpoles[ FOREST_FLAG_POLES[i] ] = false -- ��������� � ������ ���� ������ ��� ����, �������, ��� �� ������
		AddTriggerEnd( SpawnFlagDefenders, FOREST_FLAG_POLES[i] ) -- � ������� SpawnFlagDefenders ����� �������� ������ �����
	end
	
	AddTriggerEnd( SpawnCreepsWhileFlagIsDown, "leftCreepHutFlag1" ) -- ���� ���� ������, ����� � ��� ������������ ��������� ����� � ����� �� ����
	AddTriggerEnd( SpawnCreepsWhileFlagIsDown, "leftCreepHutFlag2" ) -- ���� ���� ������, ����� � ��� ������������ ��������� ����� � ����� �� ����
	AddTriggerEnd( SpawnCreepsWhileFlagIsDown, "leftCreepHutFlag3" ) -- ���� ���� ������, ����� � ��� ������������ ��������� ����� � ����� �� ����
	AddTriggerEnd( SpawnCreepsWhileFlagIsDown, "downCreepHutFlag1" ) -- ���� ���� ������, ����� � ��� ������������ ��������� ����� � ����� �� ����
	AddTriggerEnd( SpawnCreepsWhileFlagIsDown, "rightCreepHutFlag1" ) -- ���� ���� ������, ����� � ��� ������������ ��������� ����� � ����� �� ����
	AddTriggerEnd( SpawnCreepsWhileFlagIsDown, "rightCreepHutFlag2" ) -- ���� ���� ������, ����� � ��� ������������ ��������� ����� � ����� �� ����
	AddTriggerEnd( SpawnCreepsWhileFlagIsDown, "rightCreepHutFlag3" ) -- ���� ���� ������, ����� � ��� ������������ ��������� ����� � ����� �� ����
	AddTriggerEnd( SpawnCreepsWhileFlagIsDown, "upCreepHutFlag1" ) -- ���� ���� ������, ����� � ��� ������������ ��������� ����� � ����� �� ����
	
	
	for i=1, #CREEP_HUTS do -- ������ ��� ������ ������, ���������� �� ������ �� ��������
		local hutX, hutY = LuaUnitGetPosition( CREEP_HUTS[i] )
		local hutMinimapIcon = CREEP_HUTS[i].."icon"
		LuaPlaceMinimapIcon( hutMinimapIcon, MinmapIconCreepsStrong, hutX, hutY, 0 )
	end
	
	PrintArray( raisedFlagpoles )
    UpdateNatureProgress()
	
	AddQuest("raiseForestFlags", false, false ) -- ������ ������� "��������� ��� ����� � ����"
	
	AddTriggerEnd( CaptureForestFlags )
	
	WaitState(2)	
	flagsInitCompleted = true	

	LuaDebugTrace("FINISHED: [InitFlags]")
end

-- ������� ��������� ������ � ����
function SpawnFlagDefenders( flagName )
	LuaDebugTrace("STARTED: [SpawnFlagDefenders] for flag "..flagName)
	local flagX, flagY = LuaUnitGetPosition( flagName )
	local n = string.sub( flagName, -1 )
	local direction = string.sub( flagName, 1, string.find( flagName, '%u') - 1 )
	local areaName = tostring(direction).."CreepHutArea"..tostring(n)
	local areaX, areaY, r = LuaGetScriptArea( areaName )
	local spawned = {}
	
	WaitForUnitNearPoint( allyHeroes, flagX, flagY, 10 ) -- ����, ����� ���-�� �� ������ ����������� � �����
	DebugTrace("[SpawnFlagDefenders] some hero is near flag "..flagName)
	if not raisedFlagpoles[ flagName ] then
		if flagName == "leftCreepHutFlag3" or flagName == "rightCreepHutFlag3" then -- ���� ���� ����� � ������� ��������, ������� ��������
			spawned = SpawnerSpawn( "OrdinaryBorovik", factionEnemy )				
		else
			spawned = SpawnerSpawn( "SatyrForest", factionEnemy )		-- ���� ���, �� ������
		end
		TeleportUnitList( spawned, areaX, areaY )	
        local x, y = LuaUnitGetPosition( ivaCreep )        
		for i = 1, #spawned do 
            LuaApplyPassiveAbility( spawned[i], "flagpolesBonus" ) -- ������ �� �������������� ������ ����� �� ��������� ������
			--if not (flagName == "leftCreepHutFlag3" or flagName == "rightCreepHutFlag3") then			
				LuaSetCreepBehavior( spawned[i], "MoveTo", x, y, 2, 15 ) -- ���������� �� ��������� ���
			--end
        end	
        
	end
	LuaDebugTrace("FINISHED: [SpawnFlagDefenders] for flag "..flagName)
end

-- ����������� ������ ���, ����� ���� (�� ������) ������ ��� ������
-- chainName - ��� ������� ������
-- flagName - ��� �����
-- polygonName - ��� ����
function FlagIsRaised( isRaised, chainName, flagName, polygonName )
	LuaDebugTrace("STARTED: [FlagIsRaised]")
	if not flagsInitCompleted then return end
	
	raisedFlagpoles[ flagName ] = isRaised
	if not isRaised then
        AddTriggerEnd( FlagIsCapturedUserFeedback,  flagName ) -- ���� ���� ������, ������ �� ������� �������� � ����� � ��� ���������
	end
    UpdateNatureProgress()
end

-- ����������� ������ ���, ����� ���� � ���� ������ ��� ������
-- chainName - ��� ������� ������
-- flagName - ��� �����
-- polygonName - ��� ����
function ForestFlagRaised( isRaised, chainName, flagName, polygonName )	
	DebugTrace("[ForestFlagRaised] for chain = "..chainName.." and flag "..flagName)	
		
	local direction = string.sub( chainName, 1, string.find( chainName, '%u') - 1 )
	local n = string.sub( chainName, -1 )
	
	local hutName = tostring(direction).."CreepHut"..tostring(n)		
	local glyphName = tostring(direction).."GlyphSpawner"..tostring(n)	
	local spawnerName = tostring(direction).."CreepHutSpawner"..tostring(n)	
	local hutX, hutY = LuaUnitGetPosition( hutName )
	local hutMinimapIcon = tostring(hutName).."icon"
	
	local prevStepRaisedFlags = GetRaisedForestFlags()
	local forestFlagsCount = #FOREST_FLAG_POLES
	
	raisedFlagpoles[ flagName ] = isRaised
	if prevStepRaisedFlags == forestFlagsCount and GetRaisedForestFlags() == forestFlagsCount - 1 then
		LuaDebugTrace("DEBUG: [ForestFlagRaised] quest Raise Forest Flags is active again ")
		AddQuest( "raiseForestFlags", false, false ) -- ������ ���, ����� ���� �� ���� ���� � ���� �� �������� ��������, �������� ����� "������� ����� � ����"
	end	
    UpdateNatureProgress()
	
	SetQuestProgress("raiseForestFlags", GetRaisedForestFlags() )	-- ���������� � UI ������ ���������� ����������� ������
			
	if not isRaised then -- ���� ���� ������
		DebugTrace("[ForestFlagRaised] "..flagName.." is dropped down")	
				
		LuaCreatureHide( hutName, false ) -- ������ ����� ������
		LuaPlaceMinimapIcon( hutMinimapIcon, MinmapIconCreepsStrong, hutX, hutY, 0 ) --���������� �� �������� ������ ������
		LuaCreatureHide( glyphName, true ) -- ������� ����
		
		AddTriggerEnd( FlagIsCapturedUserFeedback, flagName ) -- ������ �� ������� ������, ��� ���� �������, ����� � ���
	elseif isRaised then -- ���� ���� ������
		DebugTrace("[ForestFlagRaised] "..flagName.." is raised")	
		
		LuaCreatureHide( hutName, true ) -- ������� ����� ������
		LuaRemoveMinimapIcon( hutMinimapIcon ) -- ������� ������ ������ � ��������
		LuaCreatureHide( glyphName, false )		 -- ������ �� ����� ������� ������
	end
	
	if GetRaisedForestFlags() == forestFlagsCount then -- ���� ��� ������ ����� ��� ��������� �������, ��������� �����
		CompleteQuest( "raiseForestFlags" )
	end
end

-- ������������ ���������� �������� ������ � ��������� ������ ��� ������ ����������
function UpdateNatureProgress()
    local flagsTotal, flagsRaised = 2 , 1   -- �������, ��� � ������ � � ���� ���� �� ������ "�����", ����� ������� ����� ����� �� ������ � ���� � � �������
    for n, raised in pairs( raisedFlagpoles ) do
        flagsTotal = flagsTotal + 1
        if raised then flagsRaised = flagsRaised + 1 end
    end
    if factionPlayer == FACTION_DOCT then 
        LuaSetNatureProgress( flagsRaised/ flagsTotal, 0 )
    else 
        LuaSetNatureProgress( 0, flagsRaised/ flagsTotal )
    end
end

-- ���� ���� � ���� ������, ������� � ��������� �������������� ������, ������� ����� ���� �� ����
function SpawnCreepsWhileFlagIsDown( flagName )
	DebugTrace("[SpawnCreepsWhileFlagIsDown] for flag "..flagName)
	local direction = string.sub( flagName, 1, string.find( flagName, '%u') - 1 )
	local n = string.sub( flagName, -1 )
	local spawnerName = tostring(direction).."CreepHutSpawner"..tostring(n)	
	local spawned = {}
	local lastSpawnStep
	local spawnInterval
	if FOREST_CREEP_MIN_SPAWN_INTERVAL == nil then
		spawnInterval = LuaRandom( 25, 45 )	-- ��������� ��������, � ������� ����� ��������
	else
		spawnInterval = LuaRandom( FOREST_CREEP_MIN_SPAWN_INTERVAL, FOREST_CREEP_MIN_SPAWN_INTERVAL + 20 )	
	end
	
	while not flagsInitCompleted do SleepState() end -- ���� �� ����� ��������� �� ����, ��� ����� ���� ����������������, ����
	
	while GetGlobalVar("superabilityUsesCount") ~= 1 do SleepState() end -- ���� �� ������� ������ ��������� (�� ����� �� �������)
	
	while true do
		while raisedFlagpoles[ flagName ] do SleepState() end -- ���� ���� ������, ����, �������, ���� ������
		DebugTrace("[SpawnCreepsWhileFlagIsDown] flag "..flagName.." is dropped down")
		while not raisedFlagpoles[ flagName ] do 			-- ���� ���� ������
			spawned = SpawnerSpawn( spawnerName, factionEnemy ) -- ������� ������
			for i = 1,#spawned do LuaApplyPassiveAbility( spawned[i], "flagpolesBonus" ) end	-- ������ �� ��� ����� �� ��������� ������
			lastSpawnStep = GetGameStep()
			while GetGameStep() - lastSpawnStep < spawnInterval * GetStepsCountInSecond() do SleepState() end -- ���� spawnInterval	
			SleepState()
		end	
		DebugTrace("[SpawnCreepsWhileFlagIsDown] flag "..flagName.." is raised up")		
		SleepState()		
	end
end

-- ��� ���� polygonName � ��������� areas �������� ����������� ��� ����� newNature
function SetFlagChainNature( polygonName, areas, oldNature, newNature )
	for i=1, #areas do
		LuaChangeNatureMapPolyArea( polygonName, areas[i], oldNature, newNature )
	end
end

-- ����������� � ������ ������� �����
function FlagIsCapturedUserFeedback( flagName )
	if flagsInitCompleted then
		local flagX, flagY = LuaUnitGetPosition( flagName )		
		
		LuaCreateMinimapSignal( flagX, flagY ) -- ������ �� ������� ��������
		LuaUnitApplyApplicatorFromUnit( allyHeroes[1],  allyHeroes[1], "FlagIsLostMessageToChat" ) -- ����� � ��� ��������� "���� �������"
		--LuaSetHintLine( "flagCaptured", "None" )
		--WaitState(4)
		--LuaSetHintLine( "", "None" )
	end
end

-- ���������� ���������� �������� ������ ������
function GetRaisedForestFlags()
	local raisedFlags = 0
	for flagName, isRaised in pairs( raisedFlagpoles ) do
		if string.find( flagName, "CreepHutFlag" ) ~= nil and isRaised then
			raisedFlags = raisedFlags + 1
		end
	end
	return raisedFlags
end

-- ���������� ��������� �������� ����� � ������ ����������� ���� �����
-- ��������� ���������� �� ������, ��� ����� ������� ������ ���������
function CaptureForestFlags()
	LuaDebugTrace("STARTED: [CaptureForestFlags]")
	local availableDirections = {}
	local direction = "left"
	local flagName = "leftCreepHutFlag1"
	local hutNumber = 1
	local directions = { left = {1, 2, 3}, right = {1, 2, 3}, up = {1}, down = {1} } -- ����������� � ������������� �� ������ � ����. �������� � ����������� left ���� ������ � ������, �������� ������� ���������� �� "left", � ������������� �� "1", "2" ��� "3" 
	local simultaneousDirections = 1	
	local minSpawnInterval = 25 
	
	while GetGlobalVar("superabilityUsesCount") ~= 1 do SleepState() end -- ���� �� ������� ������ ��������� (�� ����� �� �������)
	
	while true do
		LuaDebugTrace("DEBUG: [CaptureForestFlags]: Waiting for next wave")
		
		WaitState( math.max( minSpawnInterval, 0 )  + 30 )  -- ���� minSpawnInterval, �� �� ������ 30-�� ������

		while ( not GetGlobalVar( "WaveInProgress") ) do -- ���� ������ �� ����� ��� ����������� ����, ����
		 SleepState()
		end
		
		LuaDebugTrace("DEBUG: [CaptureForestFlags]: wait completed")
		availableDirections = {}
		
		for directionName, numbers in pairs( directions ) do
			if not forbiddenDirections[directionName] then
				for n=1, #numbers do
					table.insert( availableDirections, {directionName, numbers[n]} )
					LuaDebugTrace("DEBUG: [CaptureForestFlags]: value inserted")
				end
			end
		end
		
        table.sort(availableDirections, function(a, b) return a[1]..tostring(a[2]) < b[1]..tostring(b[2]) end ); -- ���������� �������. ����� ��� ����������� ����������
        
    	LuaDebugTrace("-----------------Available directions array----------------")
		for i=1, #availableDirections do			
			LuaDebugTrace( "direction: "..tostring(availableDirections[i][1])..", number: "..tostring(availableDirections[i][2]) )
		end
		
		if #availableDirections > 0 then
            simultaneousDirections = LuaRandom( 1, math.min( #availableDirections, 3 ) ) -- �������� ��������� ����������� ��� ������ � �� ����������
			for k=1, simultaneousDirections do -- �� ���� ��������� ������������
            
				local directionIndex = LuaRandom( 1, #availableDirections )
            
				direction = availableDirections[ directionIndex ][1]
				hutNumber = availableDirections[ directionIndex ][2]
                table.remove( availableDirections, directionIndex )
                
				DebugTrace("[CaptureForestFlags] direction is "..direction..", hut number is "..hutNumber)
				
				local chainName = direction.."CreepHutChain"..hutNumber
				local flagName = direction.."CreepHutFlag"..hutNumber				
				local spawned = SpawnerSpawn( "Kobolds", factionEnemy ) -- ������� ���������
				for i=1, #spawned do
					LuaApplyPassiveAbility( spawned[i], "flagpolesBonus" ) -- ���� �� ����� �� ��������� ������
				end
				local startPositionX, startPositionY = LuaGetScriptArea( direction.."EnemySpawnerArea" ) -- ������ ����
				local destinationX, destinationY = LuaUnitGetPosition( flagName ) -- ���� ����
				
				TeleportUnitList( spawned, startPositionX, startPositionY ) 
								
				for i = 1,#spawned do
					LuaApplyPassiveAbility( spawned[i], "flagpolesBonus" )										
					LuaSetCreepBehavior( spawned[i], "MoveTo", destinationX, destinationY, 3, 20 ) -- ���������� ��������� ����������� ����
					LuaSetUnitStat( spawned[i], StatMoveSpeed, 50)
					AddTriggerEnd( GoAttackWhenFlagDown, flagName, spawned ) -- ����� ���� ����� ��������, ���������� ��������� ��������� ����
				end
			end
		end
		minSpawnInterval = minSpawnInterval - 1 -- ��������� �������� ���������� ������ ��������� �� 1
		SleepState()		
	end
	LuaDebugTrace("FINISHED: [CaptureForestFlags]")
end

-- ���������� ��������� ���� ��������� ����, ����� ����, � �������� ��� ���, �������� ������
function GoAttackWhenFlagDown( flagName, unitList )
	LuaDebugTrace("STARTED: [GoAttackWhenFlagDown] for flag "..flagName)
	local targetX, targetY = 0, 0
	
	while raisedFlagpoles[ flagName ] == true do -- ���� ���� ������, ����
		SleepState()	
		if LuaUnitCheckFlag( flagName, ForbidTakeDamage ) then
			break
		end
	end
	LuaDebugTrace("[GoAttackWhenFlagRaised] flag "..flagName.." is down")

	local dead, exist = false, false
	local destinationX, destinationY = LuaUnitGetPosition( ivaCreep )
	
	for i=1, #unitList do
		dead, exist = LuaUnitIsDead( unitList[i] )
		if not dead and exist then
			LuaSetCreepBehavior( unitList[i], "MoveTo", destinationX, destinationY, 3, 20 ) -- ���������� ��������� ��������� ����, ��� ������ ���� �������� ������
		end
	end
end


-- ���������� ���������� ����� �������� ������
function GetRaisedFlagsCount()
	local n = 0
	for i,v in pairs( raisedFlagpoles ) do
		if v == true then n = n + 1 end
	end
	LuaDebugTrace("[GetRaisedFlagsCount] raised flags count = "..n)
	return n
end

-- �� ������������
function SpawnSupportUnits( supportUnits )
	local directions = GetAvailableDirections()
	local UNITS_FROM_DIRECTION_COUNT = 1
	local spawned = {}
	for k=1, UNITS_FROM_DIRECTION_COUNT do
		for i=1, #directions do
			spawned = SpawnerSpawn( supportUnits[ LuaRandom(1, #supportUnits) ], factionEnemy )
			PushPathAndApplyFlagBonus( spawned, directions[i] )
		end
		WaitState(2)
	end
end