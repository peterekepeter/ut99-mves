class MV_MapTags expands MV_Parser;

const MaxCount = 1024;
const NoTags = "";

var int Count;
var string MapName[1024]; 
var string MapTags[1024];
var string queryTags;
var string queryTagSplit[16];
var int queryTagSplitCount;

function bool TestTagMatch(string name, string newQueryTags)
{
	local string tags;
	local int i;
	AcceptNewQueryTags(newQueryTags);
	if (queryTagSplitCount <= 0)
	{
		return True; // empty query always matches
	}
	tags = FindTags(name);
	if (tags == NoTags)
	{
		return False; // some query against empty tags never matches
	}
	for (i = 0; i < queryTagSplitCount; i += 1)
	{
		if (InStr(tags, queryTagSplit[i]) < 0) 
		{
			return False; // one of the query tags didn't match, fail the test
		}
	}
	return True; // all of the query tags matched
}


function AddMapTags(string name, string tags)
{
	local int index;
	index = FindIndex(name);
	if (index >= 0)
	{
		// add to existing
		MapTags[index] = MapTags[index]$tags;
		return;
	}
	if (Count + 1 >= MaxCount)
	{
		Err("Reached max number of map tags "$MaxCount$"!");
		Err("Discarding tags '"$tags$"' for map '"$name$"'");
		return;
	}
	MapName[Count] = name;
	MapTags[Count] = ":"$tags$":";
	Count += 1;
}


function private string FindTags(string name)
{
	local int index;
	index = FindIndex(name);
	if (index >= 0) 
	{
		return MapTags[index];
	}
	return NoTags;
}


function private int FindIndex(string name)
{
	local int i;
	for (i = 0; i < Count; i += 1)
	{
		if (MapName[i] ~= name)
		{
			return i;
		}
	}
	return -1;
}


function private AcceptNewQueryTags(string newQueryTags)
{
	local string newTag;
	if (newQueryTags == queryTags)
	{
		return; // already cached
	}
	queryTagSplitCount = 0;
	queryTags = newQueryTags;
	while (TrySplit(newQueryTags, ":", newTag, newQueryTags))
	{
		if (newTag == "")
		{
			continue;
		}
		queryTagSplit[queryTagSplitCount] = ":"$newTag$":";
		queryTagSplitCount += 1;
	}
}