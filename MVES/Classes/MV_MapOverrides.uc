class MV_MapOverrides expands MV_Util;

const FilterLimit = 256;

var int MapFilterCount;
var string MapFilter[256];
var string MapEffects[256];

var int SongFilterCount;
var string SongFilter[256];
var string SongEffects[256];

function private ApplyOverrides(MV_Result result)
{
	local int i;

	for ( i = 0; i < MapFilterCount; i+=1 )
		if ( result.Map ~= MapFilter[i] )
			ApplyEffects(result, MapEffects[i]);
	
	for ( i = 0; i < SongFilterCount; i+=1 )
		if ( result.OriginalSong ~= SongFilter[i] )
			ApplyEffects(result, SongEffects[i]);
}

function private ApplyEffects(MV_Result result, string effects)
{
	local string kv,key,value,package,obj;

	while ( class'MV_Parser'.static.Tokenize(effects, "?", kv) )
	{
		if ( !class'MV_Parser'.static.SplitOne(kv, "=", key, value) )
		{
			Err("expected `=` inside `"$kv$"`");
			continue;
		}

		if ( key ~= "Song" )
		{   
			if ( class'MV_Parser'.static.SplitOne(value, ".", package, obj) )
			{
				result.Song = package$"."$obj;
				result.AddPackage(package);
			}
			else 
				Err("in `"$value$"` Song requires `Package.Name` format");
		}
		else 
			Err("unknown property key `"$key$"` in `"$kv$"`");
	}
}
