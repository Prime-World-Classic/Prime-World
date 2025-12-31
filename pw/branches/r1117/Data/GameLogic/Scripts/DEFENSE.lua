include ("GameLogic/Scripts/Debug.lua")
include ("GameLogic/Scripts/StatesManager.lua")
include ("GameLogic/Scripts/Common.lua")
include ("GameLogic/Scripts/Consts.lua")

BRIDGE_EVENT_LOCAL = ""

BAD_IO = false

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
		
		SetGlobalVar( "BRIDGE_EVENT", "" )
		
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
			
			SetGlobalVar( "BRIDGE_EVENT", content )
			
			BRIDGE_EVENT_LOCAL = content
			
			SpawnGhost()
			
			LuaMessageToChat( content )
			
			ClearBridgeEvent()
			
		end
		
	else 
		
		if not BAD_IO then
			
			BAD_IO = true
			
			SpawnGhost()
		
		end
		
	end
	
	if GetGlobalVar( "BRIDGE_EVENT" ) ~= "" and GetGlobalVar( "BRIDGE_EVENT" ) ~= BRIDGE_EVENT_LOCAL then 
		
		BRIDGE_EVENT_LOCAL = GetGlobalVar( "BRIDGE_EVENT" )
		
		SpawnGhost()
	
	end
	
end

function ClearBridgeEvent()

	io.open( "bridge", "w" ):close()

end

function SpawnGhost()

	if LuaRandom(0,100) >= 50 then 
	
		Spawn( "Ghost", 187, 126, 2 )
	
	else 
		
		Spawn( "Ghost", 64, 125, 2 )
	
	end
	
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