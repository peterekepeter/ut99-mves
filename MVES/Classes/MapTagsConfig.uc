class MapTagsConfig extends MV_Util config(MVE_Config);

const CurrentVersion = 1;
const MapTagsCount = 1024;

var() config int MapTagsVersion;
var() config string MapTags[1024];

function MV_MapTags GetConfiguredMapTags()
{
	RunMigration();
	return CreateMapTags();	
} 


function private RunMigration()
{
	if ( MapTagsVersion == CurrentVersion )
	{
		return; // we're good to go!
	}
	if ( MapTagsVersion > CurrentVersion )
	{
		Err("unknown MapTags version, MapTags may not function correctly");
		return;
	}
	if ( MapTagsVersion <= 0 )
	{
		Nfo("initializing MapTags with examples, check and modify if necesary");
		MapTagsVersion = 1;
		MapTags[0] = "DM-Fractal:1on1";
		MapTags[1] = "DM-Morbias][:1on1";
		MapTags[2] = "DM-HyperBlast:1on1:remove";
		MapTags[3] = "DM-Stalwart:1on1:small";
	}
	SaveConfig();
}

function private MV_MapTags CreateMapTags()
{
	local MV_MapTags result;
	local int i;
	result = new class'MV_MapTags';
	for ( i = 0; i < Self.MapTagsCount; i += 1 )
	{
		result.AddConfigLine(Self.MapTags[i]);
	}
	return result;
}
