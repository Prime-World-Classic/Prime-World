include ("GameLogic/Scripts/Debug.lua")
include ("GameLogic/Scripts/StatesManager.lua")
include ("GameLogic/Scripts/Common.lua")
include ("GameLogic/Scripts/Consts.lua")

IS_FINAL = false
LIMIT_SCORE = 150
PRICE_HERO = 50

function Init()
	
	LuaMessageToChat("Tournament for Prime World Classic by ifst 1.0.0")
	
	InitQuest()
	
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
	
		for hero = 0, 1 do
		
			local heroNameId = tostring( team ) .. tostring( hero )
		
			local TotalNumHeroKills = LuaStatisticsGetTotalNumHeroKills( heroNameId )
			
			local KillsTotal = LuaHeroGetKillsTotal( heroNameId )
			
			local UnitFaction = LuaGetUnitFaction( heroNameId )
			
			if UnitFaction == 1 then 
				
				A = ( A + ( TotalNumHeroKills * PRICE_HERO ) + KillsTotal )
				
			else
				
				B = ( B + ( TotalNumHeroKills * PRICE_HERO ) + KillsTotal )
				
			end
		
		end
	
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

function InitQuest()

	LuaAddSessionQuest( "Q_A" )
	
	LuaAddSessionQuest( "Q_B" )

end

function UpdateQuest( A, B )
	
	LuaUpdateSessionQuest( "Q_A", A )
	
	LuaUpdateSessionQuest( "Q_B", B )
	
end