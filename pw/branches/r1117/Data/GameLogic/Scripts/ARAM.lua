include ("GameLogic/Scripts/Debug.lua")
include ("GameLogic/Scripts/StatesManager.lua")
include ("GameLogic/Scripts/Common.lua")
include ("GameLogic/Scripts/Consts.lua")

ZombieSpawnDelay = 3
KilledHeroProc = 100
KilledBySummonProc = 0
KilledByMeleeAAProc = 100
KilledByRangedAAProc = 100
KilledByAbilityProc = 0

COMPANION_DATA = {}

function initCompanion()

	for team = 0, 1 do
	
		for hero = 0, 4 do
		
			local heroId = tostring( team ) .. tostring( hero )
			
			local x, y = LuaHeroGetPosition( heroId )
			
			local body = "CompanionA"
			
			if team == 1 then
			
				body = "CompanionB"
			
			end
			
			COMPANION_DATA[heroId] = { id = body .. heroId, attack = "", recovery = false, target = heroId, distance = 0, body = body, status = "", alive = false, targetX = 0, targetY = 0, notAction = 0, limitNotAction = LuaRandom( 15, 30 ), home = { x = x, y = y } }
			
			--StartTrigger( spawnCompanion, heroId )
			
		end
		
	end
	
	StartTrigger( spawnCompanion, "00" )
	
	StartTrigger( spawnCompanion, "10" )
	
end

function spawnCompanion( heroId )

	local x1, y1 = LuaHeroGetPosition( heroId )
	
	local faction = LuaGetUnitFaction( heroId )
	
	COMPANION_DATA[heroId].distance = 75

	if not COMPANION_DATA[heroId].alive then
		
		local rx, ry = randomPosition( x1, y1, 3)
	
		LuaCreateCreep( COMPANION_DATA[heroId].id, COMPANION_DATA[heroId].body, rx, ry, faction, 1 )
		
		LuaUnitAddFlag( COMPANION_DATA[heroId].id, ForbidSelectTarget )
		
		LuaUnitAddFlag( COMPANION_DATA[heroId].id, ForbidAutoAttack )
		
		-- LuaUnitAddFlag( COMPANION_DATA[heroId].id, ForbidAutotargetMe ) -- чтобы крипы не брали цель
		
		LuaSetUnitStat( COMPANION_DATA[heroId].id , 0, 1000 ) -- хп
		
		COMPANION_DATA[heroId].alive = true
	
	end
	
	if LuaUnitIsDead(COMPANION_DATA[heroId].id) then 
	
		COMPANION_DATA[heroId].alive = false
		
		return
	
	end
	
	local heroMoveSpeed = LuaGetUnitStat( COMPANION_DATA[heroId].target, 3 )
	
	LuaSetUnitStat( COMPANION_DATA[heroId].id , 3, heroMoveSpeed )
	
	local kills = LuaHeroGetKillsTotal( COMPANION_DATA[heroId].target )
	
	LuaSetUnitStat( COMPANION_DATA[heroId].id , 15, kills * 64 )
	
	if COMPANION_DATA[heroId].recovery then 
	
		if HelthDownPercent( COMPANION_DATA[heroId].id, 100 ) then
		
			COMPANION_DATA[heroId].recovery = false
		
		else
			
			LuaUnitClearStates( COMPANION_DATA[heroId].id )
			
			return LuaCreatureMoveTo( COMPANION_DATA[heroId].id , COMPANION_DATA[heroId].home.x , COMPANION_DATA[heroId].home.y, 0 )
			
		end
	
	end
	
	local x2, y2 = LuaUnitGetPosition( COMPANION_DATA[heroId].id )
	
	-- LuaPlaceMinimapIcon( COMPANION_DATA[heroId].id, 1, x2, y2, 2 ) -- отображаем на миникарте
	
	if LuaIsUnitAttacked( COMPANION_DATA[heroId].id ) then 
		
		-- LuaCreateMinimapSignal(x2, y2) -- сигнал о помощи
	
	end
	
	if HelthDownPercent( COMPANION_DATA[heroId].id, 25 ) then
	
		LuaUnitClearStates( COMPANION_DATA[heroId].id )
		
		LuaSetUnitStat( COMPANION_DATA[heroId].id , 3, 100 )
		
		COMPANION_DATA[heroId].recovery = true
		
		return LuaCreatureMoveTo( COMPANION_DATA[heroId].id , COMPANION_DATA[heroId].home.x , COMPANION_DATA[heroId].home.y, 0 )
		
	end
	
	if HelthDownPercent( COMPANION_DATA[heroId].id, 50 ) then 
	
		COMPANION_DATA[heroId].distance = 30
		
	end
	
	local mask = 2 -- 2 крипы A, 4 крипы B
	
	if faction == 1 then
	
		mask = 4
	
	end
	
	local creepsInArea = LuaGetCreepsInArea( x1, y1, 256, mask )
	
	local minDistance = COMPANION_DATA[heroId].distance
	
	local targetAttack = ""
	
	for index, unitId in pairs(creepsInArea) do 
	
		local x2, y2 = LuaUnitGetPosition( unitId )
	
		local distance = DistanceSquared(x1,y1,x2,y2)
		
		if distance <= COMPANION_DATA[heroId].distance then 
		
			if distance < minDistance then 
		
				minDistance = distance
			
				targetAttack = unitId
		
			end
		
		end
		
	end
	
	if targetAttack ~= "" then 
	
		COMPANION_DATA[heroId].attack = targetAttack
	
	end
	
	local distance = DistanceSquared(x1,y1,x2,y2)
	
	if ( distance < COMPANION_DATA[heroId].distance ) then
	
		if COMPANION_DATA[heroId].attack ~= "" then 
			
			WaitState( 0.25 )
			
			if not LuaUnitIsDead(COMPANION_DATA[heroId].attack) then 
				
				return LuaUnitAttackUnit( COMPANION_DATA[heroId].id, COMPANION_DATA[heroId].attack )
			
			end
		
		else 
		
			if (x1 == COMPANION_DATA[heroId].targetX and y1 == COMPANION_DATA[heroId].targetY) then
		
				COMPANION_DATA[heroId].notAction = COMPANION_DATA[heroId].notAction + 1

			end
			
			if COMPANION_DATA[heroId].notAction > COMPANION_DATA[heroId].limitNotAction then
			
				COMPANION_DATA[heroId].notAction = 0
				
				COMPANION_DATA[heroId].limitNotAction = LuaRandom( 15, 30 )
		
				local rx, ry = randomPosition( x1, y1, 3 )
		
				LuaCreatureMoveTo( COMPANION_DATA[heroId].id, rx , ry, 0 )
				
				WaitState( 1 )
				
				return
		
			end
			
			COMPANION_DATA[heroId].targetX = x1
			
			COMPANION_DATA[heroId].targetY = y1
			
		end
		
	else
		
		LuaUnitClearStates( COMPANION_DATA[heroId].id )
		
	end
	
	LuaCreatureMoveTo( COMPANION_DATA[heroId].id , x1 + 5 , y1, 0 )
	
	-- WaitState( 0.25 )

end

function randomPosition( x, y, range )

	if LuaRandom(0,100) > 50 then 
		
		x = x + range;
		
	else 
	
		x = x - range;
		
	end
	
	if LuaRandom(0,100) > 50 then 
		
		y = y + range;
		
	else 
	
		y = y - range;
		
	end
	
	return x, y

end

function Init( reconnecting )

	if not reconnecting then
		-- LuaApplyPassiveAbility ("MainA", "MainBuildingBuff") -- раздаем статус своим зданиям
		-- LuaApplyPassiveAbility ("MainB", "MainBuildingBuff")
	end
	
	initCompanion()
	
end

function OnUnitDie( victimId, killerId, lastHitterId, deathParamsInfo )
	if killerId == -1 then
		return
	end
	
	if LuaGetUnitVariableById( victimId, "InventorSpecial" ) ~= 0 then
		local dbid = "SuperInventor"
		local faction = LuaGetUnitFactionById( killerId )
		LuaCreateZombieById( victimId, dbid, faction )
		return
	end

	local victimType = LuaGetUnitTypeById( victimId )
	local killerType = LuaGetUnitTypeById( killerId )
	
	if killerType ~= UnitTypeHeroMale or LuaHeroIsCloneById( killerId ) then
		return
	end
		
	local heroIsKilled = victimType == UnitTypeHeroMale and not LuaHeroIsCloneById( victimId )
	
	if victimType ~= UnitTypeCreep and victimType ~= UnitTypeSiegeCreep and not heroIsKilled then
		return
	end
	
	if LuaGetUnitVariableById( victimId, "ImZombie" ) ~= 0 then
		return
	end
	
	local lastHitterType = LuaGetUnitTypeById( lastHitterId )
	
	local killedBySummon = lastHitterType == UnitTypeSummon or lastHitterType == UnitTypeDummyUnit
	local killedByAutoAttack = deathParamsInfo.isAutoAttack
	local killedByMelee = deathParamsInfo.isMelee
	
	local check = false
	local roll = LuaRandom( 0, 100 )
	if heroIsKilled then -- если был убит герой (как угодно)
		LuaDebugTrace( "Killed hero" )
		check = roll < KilledHeroProc
	elseif killedBySummon then -- если был убит крип суммоном
		LuaDebugTrace( "Killed by summon" )
		check = roll < KilledBySummonProc
	elseif killedByMelee then -- если  был убит крип милишной автоатакой героя
		LuaDebugTrace( "Killed by melee" )
		check = roll < KilledByMeleeAAProc
	elseif killedByAutoAttack then -- если был убит крип ренджовой автоатакой героя
		LuaDebugTrace( "Killed by ranged" )
		check = roll < KilledByRangedAAProc
	else -- если был убит крип абилкой героя
		LuaDebugTrace( "Killed by ability" )
		check = roll < KilledByAbilityProc
	end
	
	if not check then
		return
	end
	
	local dbid = "Zombie"
	
	local faction = LuaGetUnitFactionById( killerId )
	if faction == 1 then
		dbid = dbid .. "A"
	else
		dbid = dbid .. "B"
	end

	AddTriggerTop( SpawnZombie, victimId, dbid, faction, heroIsKilled)
	
end

function SpawnZombie( victimId, dbid, faction, heroIsKilled )

	if heroIsKilled then
	
		if faction == 1 then
			faction = 2
		else
			faction = 1
		end
	
		LuaCreateZombieById( victimId, "Ghost", faction )
	
	else
	
		WaitState( ZombieSpawnDelay )
		LuaCreateZombieById( victimId, dbid, faction )
		WaitState( ZombieSpawnDelay )
		LuaCreateZombieById( victimId, dbid, faction )
		WaitState( ZombieSpawnDelay )
		LuaCreateZombieById( victimId, dbid, faction )
	
	end
	
end
