class MV_MapOverrides expands MV_Util;


const RuleMaxCount = 1024;
var int RuleCount;
var string Filter[1024]; 
var string SongPackage[1024];
var string SongName[1024];



function MV_MapResult ApplyOverrides(MV_MapResult result)
{
	local int i;
    
	for (i=0; i<RuleCount; i++)
	{
		if (RuleMatches(result.Map, i))
		{
			RuleApply(result, i);
		}
	}
}

function private bool RuleMatches(string map, int i)
{
	local string mapCaps;
	mapCaps = Caps(map);
	if (Caps(Filter[i]) == mapCaps)
	{
		return True;
	}
	return False;
}

function private RuleApply(MV_MapResult result, int i)
{
	if (SongName[i] != "")
	{
		result.Song = SongPackage[i] $"."$ SongName[i];
		result.AddPackage(SongPackage[i]);
	}
}