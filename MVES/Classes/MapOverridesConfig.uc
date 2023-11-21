class MapOverridesConfig extends MV_Util config(MVE_Config);

const CurrentVersion = 1;
const MapOverridesCount = 64;

var() config int MapOverridesVersion;
var() config string MapOverrides[64];

function RunMigration()
{
	if ( MapOverridesVersion == CurrentVersion )
	{
		return; // we're good to go!
	}
	if ( MapOverridesVersion > CurrentVersion )
	{
		Err("unknown MapOverrides version, MapOverrides may not function correctly");
		return;
	}
	if ( MapOverridesVersion <= 0 )
	{
		Nfo("initializing MapOverrides with examples, check and modify if necesary");
		MapOverridesVersion = 1;
		MapOverrides[0] = "DM-LevelNameGoesHere?Song=Organic.Organic";
	}
	SaveConfig();
}

defaultproperties
{
}
