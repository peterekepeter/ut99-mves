class MV_MapOverrides expands MV_Util;


const RuleMaxCount = 1024;
var int RuleCount;
var string Filter[1024]; 
var string FilterBySong[1024];
var string SongPackage[1024];
var string SongName[1024];


function MV_MapResult ApplyOverrides(MV_MapResult result)
{
	local int i;
    
	for (i=0; i<RuleCount; i++)
	{
		if (RuleMatches(result, i))
		{
			RuleApply(result, i);
		}
	}
}

function private bool RuleMatches(MV_MapResult result, int i)
{
	local string mapCaps;
	local string filterValue, filterBy, filterByCaps;

	filterValue = Filter[i];

	if (InStr(filterValue, "==") >= 0 && class'MV_Parser'.static.TrySplit(filterValue, "==", filterBy, filterValue))
	{
		filterByCaps = Caps(filterBy);
		if (filterByCaps == "SONG")
		{
			if (Caps(Result.OriginalSong) == Caps(filterValue))
			{
				return True;
			}
		}
		else 
		{
			Err("Cannot filter by `"$filterBy$"`");
		}
	}
	else if (Caps(Result.Map) == Caps(filterValue))
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