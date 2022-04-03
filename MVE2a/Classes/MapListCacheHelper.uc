//================================================================================
// MapListCacheHelper.
//================================================================================
class MapListCacheHelper extends Object;

var name ServerCodeN;

static function NeedServerMapList (MapListCache C);

static simulated function ConvertServerCode (MapListCache C)
{
	PlayerPawn(C.Owner).GetEntryLevel().ConsoleCommand("set" @ string(Default.Class) @ "ServerCodeN" @ C.ServerCode);
}