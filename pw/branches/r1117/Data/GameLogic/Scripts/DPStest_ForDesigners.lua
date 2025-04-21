-- Tutorial Mission 1 script

include ("GameLogic/Scripts/Debug.lua")
include ("GameLogic/Scripts/StatesManager.lua")
include ("GameLogic/Scripts/Common.lua")
include ("GameLogic/Scripts/Consts.lua")

M_PI2 = 1.57

function Init()
	AddStateEnd( TestBegin )
	LuaDebugTrace( "DEBUG: ����� ���������� �� �������� �����" )
	MY = "local"
end

function TestBegin()
	LuaDebugTrace( "DEBUG: �� ��������� ������ ��� ������������ ���-� �����" )
	--LuaSetSpawnCreeps( false )
	--Wait( 2 )
	--LevelUp( MY, 3)
	--LuaSetUnitStat( "local", 12, 5) -- ������ ���� ����������� ����
	--file = io.open("GreyOutput.txt", "w+")
	--file:write("Hello world!")
	--file:write( LuaGetUnitStat(MY,0))
	--file:close()
	LuaDebugTrace( "DEBUG: ����� ������� ��� ������������ �����" )
end

function ShowHeroLevel (heroName)
	LuaShowTutorialOvertipLevelHighlight ( heroName, true )
	WaitForUnitsDead( heroName )
end