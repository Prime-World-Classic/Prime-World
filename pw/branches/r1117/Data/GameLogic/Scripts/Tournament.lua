include ("GameLogic/Scripts/Debug.lua")
include ("GameLogic/Scripts/StatesManager.lua")
include ("GameLogic/Scripts/Common.lua")
include ("GameLogic/Scripts/Consts.lua")

IS_FINAL = false
SHOW_QUEST = false
LIMIT_SCORE = 150
PRICE_HERO = 50

function Init()
	
	AddTriggerTop( DelayInit )
	
end

function OnUnitDie()

	if IS_FINAL then 
		
		return
	
	end
	
	local A, B = GetScore()
	
	UpdateQuest( A, B )
	
	if A > B then 
		
		CheckFinalA( A )
		
	else
		
		CheckFinalB( B )
		
	end
	
end

function GetScore()

	local A = 0
	
	local B = 0

	for team = 0, 1 do
	
		--for hero = 0, 1 do
		
			local heroNameId = tostring( team ) .. tostring( 0 )
			
			local TotalNumHeroKills = LuaStatisticsGetTotalNumHeroKills( heroNameId )
			
			local KillsTotal = LuaHeroGetKillsTotal( heroNameId )
			
			local UnitFaction = LuaGetUnitFaction( heroNameId )
			
			if UnitFaction == 1 then 
				
				A = ( A + ( TotalNumHeroKills * PRICE_HERO ) + KillsTotal )
				
			else
				
				B = ( B + ( TotalNumHeroKills * PRICE_HERO ) + KillsTotal )
				
			end
		
		--end
	
	end
	
	return A, B
	
end

function CheckFinalA( score )

	if score >= LIMIT_SCORE then 
	
		IS_FINAL = true
		
		LuaKillUnit("MainB")
		
	end
	
end

function CheckFinalB( score )

	if score >= LIMIT_SCORE then 
		
		IS_FINAL = true
		
		LuaKillUnit("MainA")
		
	end
	
end

function DelayInit()

	WaitState( 5 )
	
	LuaMessageToChat("Tournament for Prime World: Classic by ifst v1.0.0")
	
	WaitState( 15 )

	AddStateEnd( InitQuest )

end

function InitQuest()

	LuaAddSessionQuest( "Q_A" )
	
	LuaAddSessionQuest( "Q_B" )
	
	SHOW_QUEST = true

end

function UpdateQuest( A, B )

	if not SHOW_QUEST then 
	
		return
	
	end

	if A > LIMIT_SCORE then
		
		A = LIMIT_SCORE
		
	end
	
	if B > LIMIT_SCORE then
		
		B = LIMIT_SCORE
		
	end
	
	LuaUpdateSessionQuest( "Q_A", A )
	
	LuaUpdateSessionQuest( "Q_B", B )
	
end