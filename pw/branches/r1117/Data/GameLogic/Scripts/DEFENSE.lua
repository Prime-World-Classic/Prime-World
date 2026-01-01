include ("GameLogic/Scripts/Debug.lua")
include ("GameLogic/Scripts/StatesManager.lua")
include ("GameLogic/Scripts/Common.lua")
include ("GameLogic/Scripts/Consts.lua")

function Init( reconnecting )

	--LuaShowUIBlock( "TalentsSetBlock", false )
	LuaShowUIBlock( "PlayerHeroBlock", false )
	LuaShowUIBlock( "MiniMapBlock", false )
	--LuaShowUIBlock( "ActionBarBlock", false )
	--LuaShowUIBlock( "MoneyBlock", false )
	--LuaShowUIBlock( "ActionBarEscBtn", false )
	--LuaShowUIBlock( "ActionBarTalentBtn", false )
	LuaShowUIBlock( "SelectionBlock", false )
	--LuaShowUIBlock( "ImpulseTalent", false )
	
	if not reconnecting then
		
		
		
	end
	
	LOCAL_FACTION = LuaGetUnitFaction( "local" )
	
	ClearBridgeEvent()
	
	AddTriggerTop( DelayInit )
	
end

function StartBridge()
	
	local file = io.open( "bridge", "r" )
	
	if file then
		
		local content = file:read( "*a" )
		
		file:close()
		
		if content and #content > 0 then
			
			SpawnGhost()
			
			LuaMessageToChat( content )
			
			ClearBridgeEvent()
			
		end
		
	end
	
end

function ClearBridgeEvent()

	io.open( "bridge", "w" ):close()

end

function SpawnGhost()
	
	Spawn( "Ghost", 187, 126, 2 )
	--Spawn( "Ghost", 64, 125, 2 )
	
end

function DelayInit()

	StartTrigger( StartBridge )
	
end

function Spawn( unit, x, y, faction )
	
	local name = unit .. "_" .. faction .. "_"

	LuaCreateCreep( name, unit, x, y, faction, faction )
	
	local objectId = LuaGetObjectId( name )
	
	LuaCreateZombieById( objectId, unit, faction )
	
	LuaKillUnit( name )
	
end

function PointReceived( victimId, killerId )

	if LuaGetUnitTypeById( killerId ) == UnitTypeHeroMale and not LuaHeroIsCloneById( killerId ) then 
	
		local killerName = LuaGetUnitObjectNameById( killerId )
	
		local victimName = LuaGetUnitObjectNameById( victimId )
		
		LuaUnitApplyApplicator( killerName, "AddLife10" )
		
		local effectId = "PointReceived_" .. victimName;
		
		LuaPlaceAttachedEffect( effectId, "PointReceived", killerName )
		
		WaitState( 2 )
		
		LuaRemoveStandaloneEffect( effectId )
		
	end

end

function OnUnitDie( victimId, killerId, lastHitterId, deathParamsInfo )
	
	if killerId == -1 then
	
		return
		
	end
	
	if LuaGetUnitTypeById( victimId ) ~= UnitTypeHeroMale then 
	
		AddTriggerTop( PointReceived, victimId, killerId )
	
	end
	
end