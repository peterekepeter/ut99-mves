class ShowLevelSummaryCommandlet
	expands Commandlet;


function int Main( string Parms )
{
	local string item;
	while(class'MV_Parser'.static.TrySplit(Parms, "\"", item, Parms))
	{
		if (item == "" || item == " " || item == "MVES.ShowLevelSummary")
		{
			continue;
		}
		return ShowLevelSummary(item);
	}
}

function int ShowLevelSummary(string mapname)
{
	local LevelSummary info;
	info = LevelSummary(DynamicLoadObject(mapname$".LevelSummary", class'LevelSummary'));
	if (info == None)
	{
		Log("Failed to load LevelSummary for"$mapname);
		return 1;
	}
	ShowProperty("LevelSummary",mapname);
	ShowProperty("Title", info.Title);
	ShowProperty("Author", info.Author);
	ShowProperty("IdealPlayerCount", info.IdealPlayerCount);
	ShowProperty("RecommendedEnemies", info.RecommendedEnemies);
	ShowProperty("RecommendedTeammates", info.RecommendedTeammates);
	ShowProperty("LevelEnterText", info.LevelEnterText);
	return 0;
}

function ShowProperty(coerce string name, coerce string value)
{
	Log(name$":```"$value$"```");
}