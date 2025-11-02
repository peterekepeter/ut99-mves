//================================================================================
// MapListCacheHelper.
//================================================================================
class MapListCacheHelper extends Object;

var name ServerCodeN;

static function NeedServerMapList (MapListCache C);

static simulated function name ConvertServerCode (MapListCache C)
{
	PlayerPawn(C.Owner).GetEntryLevel().ConsoleCommand("set" @ string(Default.Class) @ "ServerCodeN" @ C.ServerCode);
	return Default.ServerCodeN;
}

defaultproperties
{
      ServerCodeN="None"
}
