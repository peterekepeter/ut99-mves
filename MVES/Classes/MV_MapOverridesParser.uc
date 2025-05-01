class MV_MapOverridesParser expands MV_Parser;

function ParseConfiguration(MV_MapOverrides target, MapOverridesConfig config)
{
	local int i, errorCount;
	target.MapFilterCount = 0;
	target.SongFilterCount = 0;
	for ( i = 0; i < config.MapOverridesCount; i++ )
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
	local string rule;
	local int errors;
	errors = 0;
	while ( Tokenize(line, ";", rule) )
	{
		if ( !TryAddRule(target, rule) )
		{
			errors++;
			Err("error in rule `"$rule$"`");
		}
	}
	return errors;
}

function private bool TryAddRule(MV_MapOverrides target, string rule)
{
	local string filter, properties, filterkey, filtervalue;

	if ( !SplitOne(rule, "?", filter, properties) )
	{
		Err("missing properties for rule, expected `?`");
		return False;
	}

	if ( !SplitOne(filter, "==", filterkey, filtervalue) ) 
	{
		target.MapFilter[target.MapFilterCount] = filter;
		target.MapEffects[target.MapFilterCount++] = properties;
		return True;
	}

	if ( filterkey ~= "Song" ) 
	{
		target.SongFilter[target.SongFilterCount] = filtervalue;
		target.SongEffects[target.SongFilterCount++] = properties;
		return True;
	}
	else 
	{
		Err("unknown filter key in `"$filter$"`");
		return False;
	}
}
