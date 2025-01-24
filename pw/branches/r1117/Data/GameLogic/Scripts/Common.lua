-- Core functions

function BitMask( ... )
	local args = { n = select( '#', ... ), ... }
	local mask = 0;
	for i = 1, args.n do
		mask = mask + 2 ^ args[i]
	end
	return mask
end

-------------------------------------------------------------------------------
-- Common states functions
-------------------------------------------------------------------------------
function ConstructWaitConditionState( func, ... )
	local state = function( ... )
		if func == nil then
			LuaDebugTrace( debug.traceback() )
		end
		while true do
			if func( ... ) then
				return
			end
			SleepState()
		end
	end
	AddStateTop( state, ... )
	SleepState()
end

function ConstructWaitFalseConditionState( func, ... )
	local state = function( ... )
		if func == nil then
			LuaDebugTrace( debug.traceback() )
		end
		while true do
			if not func( ... ) then
				return
			end
			SleepState()
		end
	end
	AddStateTop( state, ... )
	SleepState()
end

function FindGender(heroName)
--	LuaDebugTrace( "DEBUG: �������� �� �������� �����������!" )	
	for level = 0, 5 do
		for column = 0, 5 do
			isGender = LuaHeroIsGenderTalent(heroName, level, column)
			if isGender then
--				LuaDebugTrace( "Found gender talent at: " .. tostring(level) .. " : " .. tostring(column) )
				return level, column
			end
		end
	end
	return -1, -1
end

function StartTrigger( func, ... )  -- ��� ������� ��������� ������� ������ ���� ��� �������. ������� ���������� ������ ���� ������� ���������� "true"
	local trigger = function( ... )
		while true do
			if func( ... ) then
				return
			end
			SleepState()
		end
	end
	AddTriggerTop( trigger, ... )
	return trigger
end

function ConstructWaitConditionTrigger( func, ... )
	local state = function( ... )
		while true do
			if func( ... ) then
				return
			end
			SleepState()
		end
	end
	AddTriggerTop( state, ... )
	SleepState()
end

function WaitState( t )
	local timer = 0
	while true do
		timer = timer + GetStepLengthInSeconds()
		if timer >= t then
			return
		end
		SleepState ()
	end
end

-- Adds wait state on the top and calls sleep for the parent state
function Wait( t )
	AddStateTop( WaitState, t )
	SleepState()
end

function DistanceSquared( x1, y1, x2, y2 )
	if x2 == nil then
		LuaDebugTrace( debug.traceback() )
	end
	local dx = x1 - x2
	local dy = y1 - y2
	return dx * dx + dy * dy
end

function IsHeroInArea( heroName, x, y, range )
	local hx, hy = LuaHeroGetPosition( heroName )
--	LuaDebugTrace( "DEBUG: LuaCameraGetPos returned: "..tostring(hx)..", "..tostring(hy) )
	if ( DistanceSquared( hx, hy, x, y ) < range * range ) then
		return true
	end
	return false
end

function IsHeroLeaveArea( heroName, x, y, range )
	local hx, hy = LuaHeroGetPosition( heroName )

	if ( DistanceSquared( hx, hy, x, y ) > range * range ) then
		return true
	end
	return false
end

function IsUnitInArea( unitName, ... )
	local args = { n = select( '#', ... ), ... }
	if ( args.n == 3 ) then
		local hx, hy = LuaUnitGetPosition( unitName )
--		LuaDebugTrace( "DEBUG: LuaCameraGetPos returned: "..tostring(hx)..", "..tostring(hy) )
		if ( DistanceSquared( hx, hy, args[1], args[2] ) < args[3] * args[3] ) then
			return true
		end
		return false
	elseif (args.n == 1) then
		local ax, ay, arange = LuaGetScriptArea( args[1] ) 
		local hx, hy = LuaUnitGetPosition( unitName )
--		LuaDebugTrace( "DEBUG: LuaCameraGetPos returned: "..tostring(hx)..", "..tostring(hy) )
		if ( DistanceSquared( hx, hy, ax, ay ) < arange * arange ) then
			return true
		end
		return false
	end
end

function IsHeroNearUnit( heroName, unitName, range )
	local hx, hy = LuaUnitGetPosition( heroName )
	local x, y = LuaUnitGetPosition( unitName )
--	LuaDebugTrace( "DEBUG: LuaCameraGetPos returned: "..tostring(hx)..", "..tostring(hy) )
	if ( DistanceSquared( hx, hy, x, y ) < range * range ) then
		return true
	end
	return false
end

function HasHeroDealedDamageWithinTime( heroName, dt )
	return (GetGameStep() - LuaHeroGetLastDealtDamageStep( heroName )) * GetStepLengthInSeconds() < dt
end

function AreUnitsDead( names )
	if ( type( names ) == "string" ) then
		local dead, found = LuaUnitIsDead( names )
		return dead	
	elseif ( type( names ) == "table" ) then
		for i = 1, #names do
			local dead, found = LuaUnitIsDead( names[i] )
			if ( dead == false ) then
				return false
			end
		end
	end
	return true
end

function IsAnyUnitDead( name ) -- �������, ��� ���� ���-������ ����
	if ( type( name ) == "table" ) then
		for i = 1, #name do
			local dead, found = LuaUnitIsDead( name[i] )
			if ( dead == true ) then
				return name[i]
			end
		end
	end
	return false
end

function WaitForHeroNearUnit( heroName, unitName, range )
	ConstructWaitConditionState( IsHeroNearUnit, heroName, unitName, range )
end

function FlagsTakeAlly ( line, flagNumber)
	if LuaFlagGetFaction( line, flagNumber) == FACTION_PLAYER then
		LuaDebugTrace( "��������� ���� ������!" )
	return true
	end
end

function ConstructWaitFlagsUp( line, flagNumber, unitName, faction ) -- � ���� faction, ���� ��������� FACTION_PLAYER ��� FACTION_ENEMY!!!
	local flagsUp = function()
		dead, found = LuaUnitIsDead(unitName)
		local timer = 0
		if line == nil then
			LuaDebugTrace( debug.traceback() )
		elseif flagNumber == nil then
			LuaDebugTrace( debug.traceback() )
		end
		if LuaFlagGetFaction( line, flagNumber) == faction then
			LuaDebugTrace( "��� ���� ������!" )
			return true
		end
		if dead and found then
			LuaDebugTrace( "���� ��� ����� �����!" )
			return
		end
		while true do
			if LuaFlagIsRising( line, flagNumber ) then -- ���� ���� �� ������ ��������� ���� ���� �� ���� ���
				while true do
					if LuaFlagGetFaction( line, flagNumber) == faction then
						LuaDebugTrace( "��� ���� ������!" )
						return
					elseif LuaFlagIsRising( line, flagNumber ) then
						timer = 0
					elseif timer >= 4.5 then -- ���� �� ���� �� ����������, ���� ����� ���������� � ���������� ��� ��������� �����
						timer = 0
						if 	LuaGetUnitType (unitName) == UnitTypeHeroMale then
							LuaDebugTrace( "���� �� ������, ������ ����� ��� ��� ������� ���!" )
							LuaHeroRaiseFlag( unitName, "flag_"..line..flagNumber)
						elseif LuaGetUnitType (unitName) == UnitTypeSiegeCreep then
							LuaDebugTrace( "���� �� ������, ������ ����� ��� ��� ������� ���!" )
							LuaUnitInvokeItsAbility( unitName, 1, "flag_"..line..flagNumber )
						else 
							LuaDebugTrace( "���� ���� �� ����� ������� ����!" )
							return true
						end
					elseif not LuaFlagIsRising (line, flagNumber) then
						timer = timer + GetStepLengthInSeconds()
					end
					SleepState()
				end
			end
			SleepState()
		end
	end
	AddStateTop( flagsUp )
	SleepState()
end

function PushFlagsUp( line, flagNumber, unitName, faction ) -- ������� ���� �������� � ConstructWaitFlagsUp, � ���, ��� �� ����� �������� ����� ���� ����������� ���� � ��������� ���, ���� ��� �� ���!
	local flagsUp = function()
		local timer = 0
		if line == nil then
			LuaDebugTrace( debug.traceback() )
		elseif flagNumber == nil then
			LuaDebugTrace( debug.traceback() )
		end
		if LuaFlagGetFaction( line, flagNumber) == faction then
			LuaDebugTrace( "��� ���� ������!" )
			return true
		end
		while true do
			if LuaFlagGetFaction( line, flagNumber) == faction then
				LuaDebugTrace( "��� ���� ������!" )
				return
			elseif LuaFlagIsRising( line, flagNumber ) then
				timer = 0
			elseif timer >= 2 then -- ���� �� ���� �� ����������, ���� ����� ���������� � ���������� ��� ��������� �����
				timer = 0
				if 	LuaGetUnitType (unitName) == UnitTypeHeroMale then
					LuaDebugTrace( "���� �� ������, ������ ����� ��� ��� ������� ���!" )
					LuaHeroRaiseFlag( unitName, "flag_"..line..flagNumber)
				elseif LuaGetUnitType (unitName) == UnitTypeSiegeCreep then
					LuaDebugTrace( "���� �� ������, ������ ����� ��� ��� ������� ���!" )
					LuaUnitInvokeItsAbility( unitName, 1, "flag_"..line..flagNumber )
				else 
					LuaDebugTrace( "���� ���� �� ����� ������� ����!" )
					return true
				end
			elseif not LuaFlagIsRising (line, flagNumber) then
				timer = timer + GetStepLengthInSeconds()
			end
			SleepState()
		end
	end
	AddStateTop( flagsUp )
	SleepState()
end

function HeroesLevelUp(heroName, unitName, bonus)	
	local herolvl = LuaHeroGetLevel(heroName)
	local unitlvl = LuaHeroGetLevel(unitName)
	if (herolvl+bonus)>unitlvl then -- bonus - ��� �� ������� ���� ������ ���� ���� �������, ��� ��������� �����
		for level = 0, 5 do
			for column = 0, 5 do
				if LuaHeroIsTalentActivated(unitName, level, column) == false then
					LuaHeroActivateTalent(unitName, level, column, false)
					return false
				end
			end
		end
	end
	return false
end

function LevelUp( heroName, levelUpTo)
	finalLevel = levelUpTo
	for level = 0, 5 do
		for column = 0, 5 do
			if LuaHeroGetLevel(heroName) >= finalLevel then return end
			if LuaHeroIsTalentActivated(heroName, level, column) == false then
				LuaHeroActivateTalent(heroName, level, column, false)				
			end
		end
	end
end

function DrinkPotion(warnPercent) -- ������ ������ �������, ���� �������� ����� ���������� ������ ���������� %
	local health, maxHealth = LuaUnitGetHealth( "local" )
	local heroHavePotion, potionSlotNumber = LuaHeroHasConsumable( "local", "HealingPotion")
	local timer = 0

	potionSlotNumber = LuaGetInventoryItemActionBarIndex ("HealingPotion")
	healingPotion = LuaGetDBIDByKey( "HealingPotion")	

	if ( health / maxHealth <=  warnPercent / 100 ) and heroHavePotion and not isCinematicCurrentlyPlayed and not heroCanUsePotion then
		isHintLineShow = true -- ��� �������� 1, ����� ������� ������ �� ��������
		DrinkPotionOn = true
		LuaDebugTrace( "Debug: ������ ����! ������ ����� � ����� "..tostring(potionSlotNumber).." (� ������ �������� ="..tostring(heroHavePotion) )
		LuaShowTutorialElementHighlight( "HealthBar" , true )
		LuaShowTutorialActionBarItemHighlight( potionSlotNumber , true)
		ShowBubble("TM2_D05_1", "ActionBar", potionSlotNumber)
		while true do
			if not isCinematicCurrentlyPlayed then
				health, maxHealth = LuaUnitGetHealth( "local" )
				if LuaGetLastItemClicked () == healingPotion then
					LuaDebugTrace( "Debug: ����� ����������� �������!")
					DrinkPotionEnd ()
					heroCanUsePotion = true
					isHintLineShow = false
					return false
				elseif ( health / maxHealth > (warnPercent+10) / 100 ) then
					LuaDebugTrace( "Debug: ����� ��� � ��� ������!")
					DrinkPotionEnd ()
					return false
--[[			elseif not DrinkPotionOn then
					LuaDebugTrace( "Debug: ������� ������� ���������!")
]]--				return true
				end
			else
				LuaDebugTrace( "Debug: ������� ���������!")
				LuaShowTutorialActionBarItemHighlight ( potionSlotNumber , false)
				LuaShowTutorialElementHighlight ( "HealthBar" , false )
				HideLastBubble ()
				return false
			end
			SleepState()
		end
	elseif heroCanUsePotion then
		while true do
			if timer >= 60 then -- ����� ������� �������
				timer = 0
				heroCanUsePotion = false
				LuaDebugTrace( "Debug: ������� �������!")
				return false
			else
				timer = timer + GetStepLengthInSeconds()
			--	LuaDebugTrace( "Debug: ��������� �����!")
			--return false
			end
			SleepState()
		end
	end
	return false
end

function DrinkPotionEnd ()
	if DrinkPotionOn then-- ������ ���� ��� �������, ���� ����� �� ������� ��� ���
		potionSlotNumber = LuaGetInventoryItemActionBarIndex ("HealingPotion")
		DrinkPotionOn = false
		LuaShowTutorialActionBarItemHighlight ( potionSlotNumber , false)
		LuaShowTutorialElementHighlight ( "HealthBar" , false )
		HideLastBubble ()
	end
end

function WaitForUnitInArea( heroName, ... )
	local args = { n = select( '#', ... ), ... }
	if ( args.n == 3 ) then
		ConstructWaitConditionState( IsHeroInArea, heroName, args[1], args[2], args[3] )
	elseif ( args.n == 1 ) then
		if ( args[1].x == nil or args[1].y == nil or args[1].radius == nil ) then
			LuaDebugTrace( "Invalid parameter passed to WaitForUnitInArea" )
			return
		end
		ConstructWaitConditionState( IsHeroInArea, heroName, args[1].x, args[1].y, args[1].radius )
	else
		LuaDebugTrace( "WaitForUnitInArea: expected 2 or 4 arguments, got " .. ( 1 + args.n ) )
	end
end

function WaitForHeroLeaveArea( heroName, ... )
	local args = { n = select( '#', ... ), ... }
	if ( args.n == 3 ) then
		ConstructWaitConditionState( IsHeroLeaveArea, heroName, args[1], args[2], args[3] )
	elseif ( args.n == 1 ) then
		if ( args[1].x == nil or args[1].y == nil or args[1].radius == nil ) then
			LuaDebugTrace( "Invalid parameter passed to WaitForUnitInArea" )
			return
		end
		ConstructWaitConditionState( IsHeroLeaveArea, heroName, args[1].x, args[1].y, args[1].radius )
	else
		LuaDebugTrace( "WaitForUnitInArea: expected 2 or 4 arguments, got " .. ( 1 + args.n ) )
	end
end

function WaitForHeroDealedDamage( heroName, dt )
	ConstructWaitConditionState( HasHeroDealedDamageWithinTime, heroName, dt )
end

function WaitForUnitsDead( arrayNames )
	ConstructWaitConditionState( AreUnitsDead, arrayNames )
end

function WaitSomeUnitDead( arrayName ) -- ���� ����� ���-������ � ������� ����
	ConstructWaitConditionState( IsAnyUnitDead, arrayName )
end

function WaitForCondition( func )
	ConstructWaitConditionState( func )
end

function WaitForUnitIdle( unitName )
	ConstructWaitConditionState( LuaUnitIsIdle, unitName )
end

function ForAll( array, func )
	for i = 1, #array do
		func( array[i] )
	end
end

function PlaceObjectiveMarker( name, x, y )
	LuaPlaceStandaloneEffect( name, "ArrowTerrainEfft", x, y ) -- or by Enum from KnownEffects list
end

function RemoveObjectiveMarker( name )
	LuaRemoveStandaloneEffect( name )
end

function CameraMoveAndReturn( x, y )
	local state = function( x, y )
		LuaHeroAddFlag( "local", ForbidPlayerControl )
		LuaCameraLock( true )
		LuaCameraMoveToPosTimed( x, y, 2 )
		Wait( 4 )
		LuaCameraMoveToUnit( "local" )
		LuaCameraLock( false )
		LuaHeroRemoveFlag( "local", ForbidPlayerControl )
	end
	AddStateTop( state, x, y )
	SleepState()
end

function MarkEnemy( name, enable )
	if enable then
		LuaUnitApplyApplicatorFromUnit( name, name, "ArrowUnitAppl" )
	else
		LuaUnitRemoveApplicator( name, "ArrowUnitAppl" )
	end
end

function MarkAlly( name, enable )
	if enable then
		LuaUnitApplyApplicatorFromUnit( name, name, "ArrowUnitAppl" )
	else
		LuaUnitRemoveApplicator( name, "ArrowUnitAppl" )
	end
end

function DecreaseUnitSight( name, enable )
	if ( enable ) then
		LuaUnitApplyApplicatorFromUnit( name, name, "DecreaseSightAppl" )
	else
		LuaUnitRemoveApplicator( name, "DecreaseSightAppl" )
	end
end

function GetScriptArea( name )
	LuaDebugTrace( name )
	x, y, radius = LuaGetScriptArea( name )
	LuaDebugTrace( x .. " " .. y .. " " .. radius )
	return { x = x, y = y, radius = radius }
end

------------------------ ���� ������ � ��������� -------------------------------------------------------------------------------------------------

function PlayCinematic ( dialogName ) 
	isCinematicCurrentlyPlayed = true
	LuaSetAdventureControlsEnabled( false, false )
	LuaStartCinematic ( dialogName )
	ConstructWaitConditionState( LuaIsDialogFinished, dialogName )
	Wait (0.1)
	LuaSetAdventureControlsEnabled( true, true )
	isCinematicCurrentlyPlayed = false
end

cameraReturn = true
function StartCinematic( dialogName, cameraReturn )
	LuaDebugTrace( "Debug: ������ ���������� "..tostring(dialogName))
	LuaSetAdventureControlsEnabled( false, false )
	_, _, cameraRodBeforeCinematic = LuaCameraGetPos();
	LuaUnitClearStates( "local" )
	isCinematicCurrentlyPlayed = true
	isCameraLocked = LuaCameraGetLock () --AdventureScreen::IsObservingObject
	LuaDebugTrace( "Debug: ��������� isCameraLocked = "..tostring(isCameraLocked))
	local hx, hy = LuaCameraGetPos ()
	local x, y = LuaUnitGetPosition ("local")
	if not ( DistanceSquared( hx, hy, x, y ) < 0.01 ) and cameraReturn then -- �� ������ ���� ����� ������� ������
		CameraReturn (0.4)
	end
	currentCinematicName = dialogName
	LuaStartCinematic ( currentCinematicName )
end

function EndCinematic( ... )
	local args = { n = select( '#', ... ), ... }
	
	ConstructWaitConditionState( LuaIsDialogFinished, currentCinematicName )
	LuaSetAdventureControlsEnabled( true, true )
	LuaDebugTrace( "Debug: ����� ���������� "..tostring(currentCinematicName))
	isCinematicCurrentlyPlayed = false
	
	NeedToPauseAfterPhrases()
	
	if args.n == 1 and type( args[1] ) == "boolean" and args[1] == true then
		LuaZoomCamera( cameraRodBeforeCinematic, 0.5 )
	end
	if not isCameraLocked then
		LuaDebugTrace( "Debug: �� ���������� ���� isCameraLocked = "..tostring(isCameraLocked)..", ������ ���������� ������")
		LuaCameraObserveUnit( "" )
	end
end

function WaitForPhraseEnd( phraseID ) 
	ConstructWaitConditionState( LuaIsPhraseFinished, phraseID )
end

-- Called by c++ code just after next phrase started
function OnAfterNextDialogPhrase( prevPhraseID )
end

function NeedToPauseAfterPhrases( ... )
	local args = { n = select( '#', ... ), ... }
	OnAfterNextDialogPhrase = function( prevPhraseID )
		for i = 1, args.n do
			if args[i] == prevPhraseID then
				LuaPauseDialog( true )
			end
		end
	end
end

function EndTriggerCinematic()
	ConstructWaitConditionTrigger( LuaIsDialogFinished, currentCinematicName )
end

function PlayNarrator( dialogName ) -- �� ������������
	narratorDialog = dialogName
	LuaShowUIBlock( "PlayerHeroBlock", false )
	LuaStartDialog( narratorDialog )
	StartTrigger( EndNarrator, narratorDialog)
	forceEndNarrator = false
end

function EndNarrator( dialogName ) -- �� ������������
	if forceEndNarrator then return end
	if LuaIsDialogFinished( dialogName) then
		LuaDebugTrace( "DEBUG: Sraboral EndNarrator!" )
		LuaShowUIBlock( "PlayerHeroBlock", true )
		return true
	end
	SleepState()
end

-------------------------------- 

function GreyWait( t , func, ... )
	greyWaitStop = false
	startStep = GetGameStep()
	finishTime  = startStep + t * GetStepsCountInSecond()
	LuaDebugTrace( "DEBUG:"..tostring(startStep) )
	local StepCheck = function( ... )
		while true do
			if greyWaitStop then 
				LuaDebugTrace( "DEBUG: GreyWait stopped  " )
				return true
			elseif GetGameStep() == finishTime then
				LuaDebugTrace( "DEBUG: worked GreyWait " )
				func( ... )	
				return true
			end			
			SleepState()
		end	
	end
	AddTriggerTop( StepCheck, ... )
end

function GreyWaitEnd()
	greyWaitStop = true
end

function PeriodicalSpawn( spawnPointName, spawnPeriod, creepCap )
	startStep = GetGameStep()
	stepOfLastSpawn = 0
	periodicalSpawnStop = false
	local StepCheckForSpawn = function( spawnPeriod, startStep )
		while true do
			--LuaDebugTrace( "DEBUG: PeriodicalSpawn ���� ��������� �����" )
			if periodicalSpawnStop then 
				LuaDebugTrace( "DEBUG: PeriodicalSpawn "..tostring(spawnPointName).." stopped  " )
				return false
			end
			if (((GetGameStep() - startStep) * GetStepLengthInSeconds() / spawnPeriod ) % 1  == 0 ) and not (stepOfLastSpawn == GetGameStep()) then  -- ���� ������� ���� - ��������� ���� / ������ == ����� �����
			LuaDebugTrace( "DEBUG: PeriodicalSpawn ����� ���������, ��������� �� ���" )
				local creepsArray = NameAllLivingCreepsFromSpawner( spawnPointName )
				if # creepsArray < creepCap then 
					LuaDebugTrace( "DEBUG: �������� PeriodicalSpawn ��� "..tostring(spawnPointName).." creeps "..tostring(creepsArray) )
					LuaSpawnerSpawnWave( spawnPointName )
					stepOfLastSpawn = GetGameStep()
				end
			end			
			SleepState()
		end	
	end	
	AddTriggerTop( StepCheckForSpawn, spawnPeriod, startStep)
end

function StopAllPeriodicalSpawn()
	periodicalSpawnStop = true
end

function NameAllLivingCreepsFromSpawner( spawnerName )
	local lastWaveNumb = LuaSpawnerGetLastWave( spawnerName )
	local arr = {}
	local ii = 1
	local creepsInWave = 4
	for i = 1, lastWaveNumb do
		for j = 1, creepsInWave do
			localName = spawnerName .. "_w" .. tostring(i) .. "_c" .. tostring(j)
			if not LuaUnitIsDead( localName ) then
--				local numberInArray = (i-1)*creepsInWave + j 
				arr[ ii ] = localName
				ii = ii +1
			end
		end
	end	
--	for i = 1, # arr do
--		LuaMessageToChat( tostring( arr[i] ) )
--	end
	return arr
end

function CheckClickedTalent(level, column) -- ��������� ����� ������ "�������"
	local levelClick, columnClick = LuaGetLastTalentClicked()
--	LuaDebugTrace( "DEBUG: ����� ���������" ..tostring(levelClick).." "..tostring(columnClick))
	if levelClick==level and columnClick==column then
		LuaDebugTrace( "DEBUG: �� �������� �� �������" ..tostring(levelClick).." "..tostring(columnClick))
		return true
	end
	return false
end

function CheckSuccessfulBuyTalent()
	LuaGetLastTalentClicked() -- �������� ������ ����� �������� ����� �� ���������� �������� ��������
	local listOfTalentsAvalibleToBuy = {}
	local countTalents = 0
	local maxStroka = LuaHeroGetTalentsLevel( "local")
	local availableTalents = {}
	LuaDebugTrace( "DEBUG: ��������� ������� ������������. maxStroka= "..tostring(maxStroka) )
	for stroka = 0, maxStroka do
		for stolbec = 0, 5 do
			LuaDebugTrace( "DEBUG: ��������: " ..tostring(stolbec)  )
			if LuaHeroCanActivateTalent( "local", stroka, stolbec) then
				countTalents = countTalents + 1
				availableTalents[countTalents] = { stroka, stolbec }
				listOfTalentsAvalibleToBuy[countTalents] = tostring(stroka).." "..tostring(stolbec)
				LuaDebugTrace( "DEBUG: ����� ������, ������� ����� ������: "..listOfTalentsAvalibleToBuy[countTalents])
			end
		end
	end
	while true do
		for tal = 1, countTalents do
			local stroka, stolbec = availableTalents[tal][1], availableTalents[tal][2]
			if LuaHeroIsTalentActivated( "local", stroka, stolbec) then
				LuaDebugTrace( "DEBUG: ������ ������: " .. listOfTalentsAvalibleToBuy[tal] )
				return true
			end
		end
		SleepState()
	end
end

 function OnlyPlayerCanKillAtThisPoint( unitName, linePercent )
	local health, maxHealth = LuaUnitGetHealth( unitName )
	if ( health / maxHealth <=  linePercent / 100 ) then
		LuaUnitApplyApplicatorFromUnit( unitName, "local", "DamageOnlyFromSenderAppl" )
		LuaDebugTrace( "Debug: ".. unitName ..  "������ ����� ���� ���� ������ �������" )
		return true
	end
 end
 
 function HelthDownPercent( unitName, linePercent )
	local health, maxHealth = LuaUnitGetHealth( unitName )
	if ( health / maxHealth <=  linePercent / 100 ) then
		return true
	end
 end
 
rotateGameStep = -1
rotateTime = 0.7
rotateTimeTunder = 0.5 -- c���������� ����� ��������� �����, ���� ����� = ����
function RotateHeroTo( heroName, targetName)
	--local rotateTime = 1
	-- �������� � ����, ����� ���������, ��� ���-����� (���� �� ���) ���������� � �� ������� �������� idle ����� ������ ��������
	-- ����������� �����, ����� �������� ���� ������ 1 ��� ��� ������ ���������� RotateHeroTo � ����� �����
	if ( rotateGameStep ~= gameStep ) then
		Wait(GetStepLengthInSeconds())
		rotateGameStep = gameStep
	end
	if heroName == "local" and LuaIsHeroMale("local") then -- ����������� ���� ����� ���������� ����� ���������� ����� ��������� �����
		currentRotateTime = rotateTimeTunder
	else 
		currentRotateTime = rotateTime
	end
	if ( type( targetName ) == "string" ) then
		local x, y = LuaUnitGetPosition( targetName )
		LuaRotateHero( heroName, x, y , currentRotateTime, true )
	elseif ( type( targetName ) == "table" ) then
		LuaRotateHero( heroName, targetName.x, targetName.y , currentRotateTime, true )
	end
end

function HeroTalking( hero1Name, hero2Name )
	RotateHeroTo( hero1Name, hero2Name)
	RotateHeroTo( hero2Name, hero1Name)
end

function MoveTo( creatureName, targetName, distance)
	local x, y
	if ( type( targetName ) == "string" ) then
		x, y = LuaUnitGetPosition( targetName )
	elseif ( type( targetName ) == "table" ) then
		x, y = targetName.x, targetName.y
	end
	LuaCreatureMoveTo( creatureName, x, y , distance )
	if ( distance > 0 ) then
		local trigger = function( creatureName, x, y, distance ) 
			--LuaDebugTrace( "Debug: ���� ��������� 594!" )
			if ( IsUnitInArea( creatureName, x, y, distance ) ) then
				LuaUnitClearStates( creatureName )
				--LuaDebugTrace( "Debug: ���� � ����� 597!" )
				return true
			end
			return false;
		end
		StartTrigger( trigger, creatureName, x, y, distance )
	end
end

function UnitMoveTo( creatureName, targetName, distance)
	local x, y
	if ( type( targetName ) == "string" ) then
		x, y = LuaUnitGetPosition( targetName )
	elseif ( type( targetName ) == "table" ) then
		x, y = targetName.x, targetName.y
	end
	--LuaDebugTrace( "DEBUG: ��������� ="..tostring( distance) )
	LuaCreatureMoveTo( creatureName, x, y ,1 )
	if ( distance > 0 ) then
		while true do
			--LuaDebugTrace( "Debug: ���� ����� � ������ ��� ����������" )
			if ( IsUnitInArea( creatureName, x, y, distance ) ) then
				--LuaDebugTrace( "Debug: ���� �������� �� ������ ��� ���������!" )
				return true
			end
			SleepState()
		end
	end
end

 function WaitForMoveTo( creatureName, targetName, distance)
	local x, y
	local timer = 0
	local WaitPointOn = false
	if ( type( targetName ) == "string" ) then
		x, y = LuaUnitGetPosition( targetName )
	elseif ( type( targetName ) == "table" ) then
		x, y = targetName.x, targetName.y
	end
	if ( distance <= 0 ) then distance =0.1 end
	LuaCreatureMoveTo( creatureName, x, y , distance )	
	LuaDebugTrace( "DEBUG: ����������, ��������� ="..tostring( distance) )
	local state = function ( x, y )
		while true do 
			--local hx, hy = LuaUnitGetPosition( creatureName )
			if ( IsUnitInArea( creatureName, x, y, distance ) ) then
				LuaDebugTrace( "DEBUG: �� � �������� ���������, ��������� ="..tostring( distance) )
				LuaUnitClearStates( creatureName )
				return true
			elseif timer >= 6 then -- �� ������ ������ 6 ���! ����� ���� ����� ��������� � ���� ������� ��������� �����.
				timer = 0
				LuaCreatureMoveTo( creatureName, x, y , distance )	
			else
				timer = timer + GetStepLengthInSeconds()
			end
			SleepState()
		end
--	SleepState()	
	end
	AddStateTop( state, x, y )
	SleepState()
end

hintArrowFirstTimeRun = true
function HintArrow( targetName, hintArrowDistanceFromHero )
	LuaDirectionHintHide() --������� ������ ���������� �������
	local x, y
	isChekingHeroNearTarget = false
	Wait(GetStepLengthInSeconds()) -- ����� ���������� ���� ����, ����� ������� IsHeroNearHintArrowTarget ������ �����������
	if targetName == "" then return end-- �����! ���� � ��������� ��������� "", �� ������ ������� ������� �������
	if hintArrowFirstTimeRun then  -- ���� ���� �������, ����� �������� ��� �� �������� ������������ HintArrow � ������ ���, �� ����� ���������� 2�� ��������
		LuaDirectionHintSet( "DirectionHintMtrl", 4, 2, 0 )
		hintArrowFirstTimeRun = false
	end
	if not(hintArrowDistanceFromHero == nil) or hintArrowFirstTimeRun then
		LuaDebugTrace( "DEBUG: ������� ��������� ���������, ���������� �� ����� ="..tostring(hintArrowDistanceFromHero))
		LuaDirectionHintSet( "DirectionHintMtrl", 4, 2, hintArrowDistanceFromHero )
	end 
	if ( type( targetName ) == "string" ) then
		x, y = LuaUnitGetPosition( targetName )
	elseif ( type( targetName ) == "table" ) then
		x, y = targetName.x, targetName.y
	end	
	LuaDirectionHintShow( x, y)
	isChekingHeroNearTarget = true
	StartTrigger( IsHeroNearHintArrowTarget, x, y)
end
function IsHeroNearHintArrowTarget( x, y)  -- �������, ������ ������� �������, ���� ����� ������� ������ ������� � ���� � ���������� ��, ����� �� ���� ��������
	if not isChekingHeroNearTarget then return true end
	radiusOfNear = 5
	if IsUnitInArea( "local", x, y, radiusOfNear) and arrowVisible then 
		LuaDirectionHintHide()
		arrowVisible = false
	end
	if not (IsUnitInArea( "local", x, y, radiusOfNear)) and not arrowVisible then 
		LuaDirectionHintShow( x, y)
		arrowVisible = true
	end
	--LuaDebugTrace( "DEBUG: �������� "..tostring(x)..tostring(y))
 end
 
 function PlaceMarker( markerName, x, y )
	StartTrigger( HideMarkerIfHeroNear, markerName, x, y )
	lastMarkerExist = true
 end
 
 function RemoveLastMarker()
	lastMarkerExist = false
 end
 
 function HideMarkerIfHeroNear( markerName, x, y )
 	if not lastMarkerExist then 
		if markerVisible then RemoveObjectiveMarker( markerName) end
		return true 
	end
	radiusOfNear = 5
	if IsUnitInArea( "local", x, y, radiusOfNear) and markerVisible then 
		RemoveObjectiveMarker( markerName)
		markerVisible = false
	end
	if not (IsUnitInArea( "local", x, y, radiusOfNear)) and not markerVisible then 
		PlaceObjectiveMarker( markerName, x, y )
		markerVisible = true
	end
	--LuaDebugTrace( "DEBUG: ��������, ��� ������� "..tostring(markerName))
 
 end

function CameraWaitPosition (x, y, timeMove)
	LuaCameraMoveToPosTimed (x, y, timeMove)
	local state = function ( x, y )
		local guardStep = GetGameStep()
		while true do
			local hx, hy = LuaCameraGetPos ()
--			LuaDebugTrace( "DEBUG: LuaCameraGetPos returned: "..tostring(hx)..", "..tostring(hy) )
			if ( DistanceSquared( hx, hy, x, y ) < 0.01 ) then
				return true
			end
			if ( GetGameStep() - guardStep > timeMove*11 ) then
				LuaDebugTrace( "ERROR: Camera buzz" )
				LuaCameraMoveToPos( x, y )
				return true
			end
			SleepState()
	--		return false
		end
	end
	AddStateTop( state, x, y )
	SleepState()
end

function CameraMove( x, y, timeMove )
	LuaCameraObserveUnit( "" )
	LuaCameraLock( false )
	CameraWaitPosition( x, y, timeMove )
	LuaCameraLock( true )
end

function CameraReturn( returnTime, ... )
	local args = { n = select( '#', ... ), ... }
	
	local x, y = LuaUnitGetPosition ("local")
	LuaCameraLock( false )
	CameraWaitPosition( x, y, returnTime )	
	LuaCameraObserveUnit( "local" )
	if args.n == 1 and type( args[1] ) == "boolean" and args[1] == true then
		LuaZoomCamera( cameraRodBeforeCinematic, 0.5 )
	end
end

function SetPrime( primeCount) 
	local currentPrime = LuaHeroGetPrime( "local" )
	LuaHeroAddPrime( "local", primeCount - currentPrime) 
end

function AddSetPrime( heroName, primeCount) 
	local currentPrime = LuaHeroGetPrime( heroName )
	LuaHeroAddPrime( heroName, primeCount - currentPrime) 
end

function WaitForHeroUseAnyConsumable( heroName ) 
	consumCount = LuaHeroGetConsumablesCount( heroName )
	LuaDebugTrace( "DEBUG: ����� ��������� �� ������ �������:"..tonumber(consumCount) )
	local state = function ( heroName, consumCount )
		while true do
			consumCount2 = LuaHeroGetConsumablesCount( heroName )
			LuaDebugTrace( "DEBUG: ����� ���������:"..tonumber(consumCount2) )
			if LuaHeroGetConsumablesCount( heroName ) < consumCount then
				LuaDebugTrace( "DEBUG: ����� ��������� �����������" )
				return true
			end
			SleepState()
		end
	end
	AddStateTop( state, heroName, consumCount )
	SleepState()
end

function WaitForOpenUI( windowName )
	local state = function ( windowName )
		while true do
			if LuaIsWindowVisible( windowName ) then
				return true
			end
			SleepState()
		end
	end
	AddStateTop( state, windowName )
	SleepState()
end

function WaitForCloseUI( windowName )
	local state = function ( windowName )
		while true do
			if LuaIsWindowVisible( windowName )==false then
				return true
			end
			SleepState()
		end
	end
	AddStateTop( state, windowName )
	SleepState()
end

bubbleButton = ""
bubbleIndex = 1
function ShowBubble( bubText, bubType, bubParam1, bubParam2 )
	HideLastBubble()
	bubbleType = bubType
	bubbleParametr1 = bubParam1
	bubbleParametr2 = bubParam2
	dialogID = bubText
	bubbleID = bubText..tostring("_Hint")
	if  bubbleType == "ActionBar" then 
		LuaShowActionBarButtonBubble(bubbleParametr1, true, bubbleID , bubbleButton, bubbleIndex  )
		LuaAddNonBlockedElementActionBarBubble( bubbleParametr1, true )
	elseif bubbleType == "Inventory" then   -- ���� �� �����, �.�. �����-�� ����� � ���������������
		LuaShowInventoryBarButtonBubble (bubbleParametr1, true, bubbleID , bubbleButton, bubbleIndex )
		LuaAddNonBlockedElementInventoryBarBubble( bubbleParametr1, true ) -- ������ ��-�� ���� ������ ������
	elseif bubbleType == "Shop" then   -- ���� �� �����, �.�. �����-�� ����� � ���������������
		LuaShowShopBarButtonBubble(bubbleParametr1, true, bubbleID , bubbleButton, bubbleIndex )
		LuaAddNonBlockedElementShopBarBubble( bubbleParametr1, true ) -- ������ ��-�� ���� ������ ������
	elseif bubbleType == "Talent" then
		LuaShowTalentBubble(bubbleParametr1, bubbleParametr2, true, bubbleID , bubbleButton, bubbleIndex  )
		LuaAddNonBlockedElementTalentBarBubble( bubbleParametr1, bubbleParametr2, true )
	elseif bubbleType == "NaftaBottle" then -- �� ������, ����� ���-������ �� ������ � ��� �������� ������ ���������
		bubbleType = "PrimeBottle"
		LuaShowBubble( bubbleType, true, bubbleID , bubbleButton, bubbleIndex  )
		LuaAddNonBlockedElementBubble( bubbleType , true)
	elseif bubbleType == "ActionBarInventoryBtn" then -- �� ������, ����� ���-������ �� ������ � ��� �������� ������ ���������
		LuaShowBubble( bubbleType, true, bubbleID , bubbleButton, bubbleIndex  )
		LuaAddNonBlockedElementBubble( bubbleType , true)			
	elseif bubbleType == "Hero" then
		LuaShowHeroBubble( bubbleParametr1, true, bubbleID , bubbleButton, bubbleIndex )
		LuaAddNonBlockedElementHero( bubbleParametr1 , true)	
	else
		LuaShowBubble( bubbleType, true, bubbleID , bubbleButton, bubbleIndex  )
		LuaAddNonBlockedElementBubble( bubbleType , true)
	end
	--	LuaDebugTrace( "DEBUG: 444444444444444444" ) 
	LuaStartDialog( dialogID ) -- ����������� ������, ����� �������� ����������� ����� �����
end

function ShowBubbleButton( bubText, bubType, bubParam1, bubParam2 )
	bubbleButton = "NextBtn"
	ShowBubble( bubText, bubType, bubParam1, bubParam2 )
	someButttonBubbleWasClicked = false
	bubbleButton = ""
end

function HideLastBubble()
	if bubbleType == nil then LuaDebugTrace( "DEBUG: �� ���� ������������ HideLastBubble �� ��� ���, ���� �� ������� �� ������ �����" )
	elseif bubbleType == "ActionBar" then LuaShowActionBarButtonBubble( bubbleParametr1, false, bubbleID, bubbleButton, bubbleIndex  )
	elseif bubbleType == "Talent" then LuaShowTalentBubble(bubbleParametr1, bubbleParametr2, false, bubbleID, bubbleButton, bubbleIndex  )
	elseif bubbleType == "Shop" then LuaShowShopBarButtonBubble(bubbleParametr1, false, bubbleID , bubbleButton, bubbleIndex )
	elseif bubbleType == "Inventory" then LuaShowInventoryBarButtonBubble(bubbleParametr1, false, bubbleID , bubbleButton, bubbleIndex )
	elseif bubbleType == "Hero" then LuaShowHeroBubble(bubbleParametr1, false, bubbleID , bubbleButton, bubbleIndex )
	else LuaShowBubble( bubbleType, false, bubbleID, bubbleButton, bubbleIndex ) 
	end
end

someButttonBubbleWasClicked = false
function OnBubbleNextButtonClick( returnedBubbleIndex) --��� ���� ������� = �������. ��� �������������� ���������� � �������� ������ "����������"
	HideLastBubble() 
	someButttonBubbleWasClicked = true
	LuaDebugTrace( "DEBUG: ��������� ������� �� ������ �����, ������ ����� = "..tostring(returnedBubbleIndex) ) 
end

function BubbleClickEvent()
	if someButttonBubbleWasClicked then 
		LuaDebugTrace( "DEBUG: �� ��������� ������� �� ������ �����" ) 
		someButttonBubbleWasClicked = false
		return true
	end
end

function WaitForBubbleClick()
	ConstructWaitConditionState( BubbleClickEvent )
end

function ShowHintline( hintID, playBeep, icon )
	if playBeep == nil then playBeep = true end -- ����� ����� ���� �� �� ����������� playBeep ��� ������� �������������
	if icon == nil then
		icon = "None"
	end
	beepTime = 0.1
	LuaDebugTrace( "DEBUG: ShowHintline "..tostring(hintID)..", playBeep = "..tostring(playBeep) )
	if not(hintID=="") then
		GreyWaitEnd()
		dialogID = hintID
		hintID = hintID..tostring("_Hint")	
		LuaSetHintLine( hintID, icon )	
		if playBeep and not isCinematicCurrentlyPlayed then  -- ����������� ����������� ����, ������������ ��������� ���������
			LuaStartDialog( "Hint_beep" )
			beepTime = 1.2
		end
		GreyWait( beepTime, StartDialogSecondary, dialogID  ) -- ����������� ������, ����� �������� ����������� ��������� �����
	else
		LuaSetHintLine( hintID, icon )
	end
--	LuaSetHintLine( hintID )
end

function StartDialogSecondary( dialogID ) 
	if not isCinematicCurrentlyPlayed then 
		LuaStartDialog( dialogID )
	end
end

function LogSessionEvent(eventName, dontGuard)
	if dontGuard == true then
		LuaDontGuardNextWorldSessionEvent()
	end

	LuaLogWorldSessionEvent(eventName, "", 0, 0, 0, 0, 0)
end

function GetTableSize(SomeTable)
  local count = 0
  for _ in pairs(SomeTable) do count = count + 1 end
  return count
end