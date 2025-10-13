include ("GameLogic/Scripts/Debug.lua")
include ("GameLogic/Scripts/StatesManager.lua")
include ("GameLogic/Scripts/Common.lua")
include ("GameLogic/Scripts/Consts.lua")

IS_START = false
IS_FINAL = false
SHOW_QUEST = false
LIMIT_SCORE = 150
PRICE_HERO = 50

function Init()
	
	HideUI()
	
	AddTriggerTop( DelayInit )
	
end

function OnUnitDie()

	if IS_FINAL then 
		
		return
	
	end
	
	if not IS_START then
	
		IS_START = true
		
		ShowUI()
	
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
			
			local dead, found = LuaUnitIsDead(heroNameId)
			
			if found then
				
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
	
	end
	
	return A, B
	
end

function CheckFinalA( score )

	if score >= LIMIT_SCORE then 
	
		IS_FINAL = true
		
		LuaKillUnit( "MainB" )
		
	end
	
end

function CheckFinalB( score )

	if score >= LIMIT_SCORE then 
		
		IS_FINAL = true
		
		LuaKillUnit( "MainA" )
		
	end
	
end

function DelayInit()
	
	WaitState( 2 )
	
	ShowHint( "welcome" )
	
	WaitState( 3 )
	
	HideHint()
	
	WaitState( 2 )
	
	ShowHint( "target" )
	
	WaitState( 3 )
	
	HideHint()
	
	WaitState( 2 )
	
	ShowHint( "pricelist" )
	
	WaitState( 3 )
	
	HideHint()
	
	WaitState( 5 )
	
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

function ShowHint( hintId )
	
	LuaSetHintLine( hintId, "LeftClick" )
	
end

function HideHint()

	LuaSetHintLine( "", "None" )
	
end

function HideUI()
	
	LuaShowUIBlock( "PlayerHeroBlock", false )
	LuaShowUIBlock( "ChatBlock", false )
	LuaShowUIBlock( "MiniMapBlock", false )
	LuaShowUIBlock( "ActionBarBlock", false )
	LuaShowUIBlock( "MoneyBlock", false )

end

function ShowUI()
	
	LuaShowUIBlock( "PlayerHeroBlock", true )
	LuaShowUIBlock( "MiniMapBlock", true )
	LuaShowUIBlock( "ActionBarBlock", true )
	LuaShowUIBlock( "MoneyBlock", true )
	
end