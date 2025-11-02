//================================================================================
// MapListCacheHelper.
//================================================================================
class MapListCacheHelper extends Object;

var name ServerCodeN;

static function NeedServerMapList (MapListCache C);

static simulated function name ConvertServerCode (MapListCache C)
{
	return ConvertStringToName(PlayerPawn(C.Owner), C.ServerCode);
}

static simulated function name ConvertStringToName(PlayerPawn P, string C)
{
	P.GetEntryLevel().ConsoleCommand("set"@string(Default.Class)@"ServerCodeN"@C);
	return Default.ServerCodeN;
}
