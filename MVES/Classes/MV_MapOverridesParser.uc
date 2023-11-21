class MV_MapOverridesParser expands MV_Parser;

function ParseConfiguration(MV_MapOverrides target, MapOverridesConfig config)
{
	local int i, errorCount;
	target.RuleCount = 0;
	for ( i = 0; i < config.MapOverridesCount; i ++ )
	{
		errorCount = TryAddConfigLine(target, config.MapOverrides[i]);
		if ( errorCount > 0 )
		{
			Err(errorCount$" errors in MapOverrides["$i$"]");
		}
	}
}

function private int TryAddConfigLine(MV_MapOverrides target, string line)
{
	local string rule, filter, properties;
	local int errors;
	errors = 0;
	while ( TrySplit(line, ";", rule, line) )
	{
		if ( target.RuleCount >= target.RuleMaxCount )
		{
			errors ++ ;
			Err("max rule count "$target.RuleMaxCount$" was reached");
			return errors;
		}
		if ( TryAddRule(target, rule) )
		{
			target.RuleCount ++ ;
		}
		else
		{
			errors ++ ;
			Err("error in rule `"$rule$"`");
			ResetRuleIndex(target, target.RuleCount);
		}
	}
	return errors;
}

function private bool TryAddRule(MV_MapOverrides target, string rule)
{
	local string filter, properties, property;
	if ( !TrySplit(rule, "?", filter, properties) )
	{
		Err("missing properties for rule, expected `?`");
		return False;
	}
	while ( TrySplit(properties, "?", property, properties) )
	{
		if ( TryAddRuleProperty(target, property) )
		{
			target.Filter[target.RuleCount] = filter;
		}
		else
		{
			Err("error in property `"$property$"`");
			return False;
		}
	}
	return True;
}

function private bool TryAddRuleProperty(MV_MapOverrides target, string property)
{
	local string key, K, value, keyUpper, package;
    
	if ( !TrySplit(property, "=", key, value) )
	{
		Err("expected `=`");
		return False;
	}
	K = Caps(key);
	if ( K == "SONG" )
	{   
		if ( !TrySplit(value, ".", package, value) )
		{
			Err("Song requires `Package.Name` format"); 
		}
		target.SongPackage[target.RuleCount] = package;
		target.SongName[target.RuleCount] = value;
	}
	else 
	{
		Err("unknown property key `"$key$"`");
	}
	return True;
}

function private ResetRuleIndex(MV_MapOverrides target, int i)
{
	target.Filter[i] = "";
	target.SongName[i] = "";
	target.SongPackage[i] = "";
}

defaultproperties
{
}
