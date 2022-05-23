class MV_MapTagsFactory expands MV_Parser;

function MV_MapTags CreateMapTags(MapTagsConfig config)
{
	local MV_MapTags result;
	local int i;
	result = new class'MV_MapTags';
	for (i = 0; i < config.MapTagsCount; i += 1)
	{
		AddConfigLine(result, config.MapTags[i]);
	}
	return result;
}

function AddConfigLine(MV_MapTags target, string line)
{
	local int colonPosition;
	local string name, tags;
	if (line == "")
	{
		return;
	}
	colonPosition = InStr(line, ":");
	if (colonPosition < 0)
	{
		Err("Invalid tags config: "$line);
		return;
	}
	name = Mid(line, 0, colonPosition);
	tags = Mid(line, colonPosition);
	target.AddMapTags(name, tags);
}