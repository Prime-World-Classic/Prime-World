include ("GameLogic/Scripts/Debug.lua")
include ("GameLogic/Scripts/StatesManager.lua")
include ("GameLogic/Scripts/Common.lua")
include ("GameLogic/Scripts/Consts.lua")

FINISH = false

function Init( reconnecting )

	
	
end

function OnUnitDie( victimId, killerId, lastHitterId, deathParamsInfo )

	if FINISH then 
		
		return
	
	end
	
	if killerId == -1 then
	
		return
		
	end
	
	if( LuaGetUnitTypeById( killerId ) == UnitTypeHeroMale and not LuaHeroIsCloneById( victimId ) ) then
		
		local heroNameId = LuaGetUnitObjectNameById(killerId)
		
		local faction = LuaGetUnitFaction( heroNameId )
		
		local kills = LuaStatisticsGetTotalNumHeroKills(heroNameId)
		
		if kills > 1 then 
			
			FINISH = true
			
			AddTriggerTop( FinishTournament, faction )
		
		end
		
	end
	
end

function FinishTournament( faction )
	
	WaitState( 0.2 )
	
	LuaSetTimeScale(0.2)
	
	WaitState( 1 )
	
	LuaSetTimeScale(1)
	
	if faction == 1 then 
	
		LuaKillUnit("MainB")
		
	else 
		
		LuaKillUnit("MainA")
		
	end

end
