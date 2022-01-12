class MV_MapOverrides expands MV_Util;


struct OverrideRule
{
	var string Filter; 
	var string SongPackage;
	var string SongName;
}
;

const RuleMaxCount = 1024;
const EmptyString = "";
var OverrideRule Rules[1024];
var int RuleCount;

function Configure(MapOverridesConfig config)
{
	local int i, errorCount;
	RuleCount = 0;
	for (i=0; i<config.MapOverridesCount; i++)
	{
		errorCount = TryAddConfigLine(config.MapOverrides[i]);
		if (errorCount > 0)
		{
			Err(errorCount$" errors in MapOverrides["$i$"]");
		}
	}
	Nfo(RuleCount$" map override rules were loaded!");
}

function private int TryAddConfigLine(string line)
{
	local string rule, filter, properties;
	local int errors;
	errors = 0;
	while (TrySplit(line, ";", rule, line))
	{
		if (RuleCount >= RuleMaxCount)
		{
			errors++;
			Err("max rule count "$RuleMaxCount$" was reached");
			return errors;
		}
		if (TryAddRule(rule))
		{
			RuleCount++;
		}
		else
		{
			errors++;
			Err("error in rule `"$rule$"`");
			ResetRuleIndex(RuleCount);
		}
	}
	return errors;
}

function private bool TryAddRule(string rule)
{
	local string filter, properties, property;
	if (!TrySplit(rule, "?", filter, properties))
	{
		Err("missing properties for rule, expected `?`");
		return False;
	}
	Nfo("Parsed filter: "$filter);
	while (TrySplit(properties, "?", property, properties))
	{
		if (TryAddRuleProperty(property))
		{
			Rules[RuleCount].Filter = filter;
		}
		else
		{
			Err("error in property `"$property$"`");
			return False;
		}
	}
	return True;
}

function private bool TryAddRuleProperty(string property)
{
	local string key, K, value, keyUpper, package;
    
	if (!TrySplit(property, "=", key, value))
	{
		Err("expected `=`");
		return False;
	}
	K = Caps(key);
	if (K == "SONG")
	{   
		if (!TrySplit(value, ".", package, value))
		{
			Err("Song requires `Package.Name` format"); 
		}
		Rules[RuleCount].SongPackage = package;
		Rules[RuleCount].SongName = value;
		Nfo("Rules[RuleCount].SongPackage"@Rules[RuleCount].SongPackage);
		Nfo("Rules[RuleCount].SongName"@Rules[RuleCount].SongName);
	}
	else 
	{
		Err("unknown property key `"$key$"`");
	}
	return True;
}

function private ResetRuleIndex(int i)
{
	Rules[i].Filter = EmptyString;
	Rules[i].SongName = EmptyString;
	Rules[i].Filter = EmptyString;
}

function private bool TrySplit(string input, string separator, out string first, out string rest)
{
	return class'MV_Parser'.static.TrySplit(input, separator, first, rest);
}