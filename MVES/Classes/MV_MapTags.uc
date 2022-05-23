class MV_MapTags expands MV_Util;

const MaxCount = 1024;
const NoTags = "";

var int Count;
var string MapName[1024]; 
var string MapTags[1024];


function bool TestTagMatch(string name, string tag)
{
	local string tags;
	tags = FindTags(name);
	if (tags == NoTags)
	{
		return False;
	}
	if (InStr(tags, tag) < 0)
	{
		return False;
	}
	return True;
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
	MapTags[Count] = tags;
	Count += 1;
}


function string FindTags(string name)
{
	local int index;
	index = FindIndex(name);
	if (index >= 0) 
	{
		return MapTags[index];
	}
	return NoTags;
}


function int FindIndex(string name)
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
