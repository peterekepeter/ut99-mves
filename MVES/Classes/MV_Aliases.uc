class MV_Aliases extends MV_Util;

const MAX_ALIAS_COUNT = 32;

var int AliasCount;
var string AliasKey[MAX_ALIAS_COUNT];
var string AliasValue[MAX_ALIAS_COUNT];
var int AliasKeyLen[MAX_ALIAS_COUNT];
var string Prefix;
var bool bNeedsPrefixDetection;
var int ErrorAt;
var int NextErrorCheckAt;
var int DetectionStack[MAX_ALIAS_COUNT];
var int DetectionStackAt;

function AddAliasLine(string configLine)
{
	local int pos;
	local string key, value;

	pos = InStr(configLine, "=");
	if ( pos == -1 ) 
	{
		pos = InStr(configLine, " ");
	}

	key = Left(configLine, pos);
	AliasKey[AliasCount] = key;
	AliasValue[AliasCount] = Mid(configLine, pos + 1);
	AliasKeyLen[AliasCount] = Len(key);
	bNeedsPrefixDetection = True;
	
	AliasCount += 1;
}

function bool DetectConfigurationError(out string message)
{
	local int i, j;
	local string str;

	while ( NextErrorCheckAt < AliasCount ) 
	{
		i = NextErrorCheckAt;
		ErrorAt = i;
		NextErrorCheckAt += 1;

		if ( AliasKey[i] == "" ) 
		{
			message = "Invalid alias '"$AliasValue[i]$"' expected format '<name>=something'";
			return True;
		}

		if ( InStr(AliasValue[i], AliasKey[i]) != -1 )
		{
			message = "Self referencing alias '"$AliasKey[i]$"' not allowed...";
			return True;
		}

		for ( j = 0; j < i; j+=1 ) 
		{
			if ( AliasKey[i] == AliasKey[j] ) 
			{
				message = "Duplicate alias '"$AliasKey[i]$"' not allowed...";
				return True;
			}
		}

		str = GetCircularChainStr(i);
		if ( str != "" ) 
		{
			message = "Circular alias chain "$str$" not allowed...";
			return True;
		}
	}
	
}

function string GetCircularChainStr(int i)
{
	DetectionStack[0] = i;
	return RecursivelyGetCircularChainStr(0);
}

function string RecursivelyGetCircularChainStr(int at) 
{
	local int i, j, k;
	local string result, sep, name;

	i = DetectionStack[at];

	if ( at != 0 && DetectionStack[0] == i )
	{
		// detected 
		result = "";
		sep = "'";
		for ( j = 0; j < at; j+=1 )
		{
			name = AliasKey[DetectionStack[j]];
			result = result$sep$name$"'";
			sep = " -> '";
		}
		return result;
	}

	for ( j = 0; j < AliasCount; j+=1 )
	{
		if ( InStr(AliasValue[i], AliasKey[j]) != -1 ) 
		{
			// dependency i -> j
			k = at + 1;
			DetectionStack[k] = j;
			result = RecursivelyGetCircularChainStr(k);
			if ( result != "" ) 
			{
				return result;
			}
		}
	}

	return "";
}

function string Resolve(string input)
{
	local int i, at, depth;
	local bool done;

	if ( AliasCount == 0 ) 
	{
		return input;
	}

	if ( bNeedsPrefixDetection ) 
	{
		DetectPrefix();
	}

	while ( !done && InStr(input, Prefix) != -1 )
	{
		done = True;
		for ( i = 0; i < AliasCount; i+=1 ) 
		{
			if ( AliasKey[i] == "" ) 
			{
				continue;
			}
			at = InStr(input, AliasKey[i]);
			while ( at != -1 )
			{
				input = Left(input, at)
					$AliasValue[i]
					$Mid(input, at + AliasKeyLen[i]);

				at = InStr(input, AliasKey[i]);
				done = False;
			}
		}
		depth += 1;
		if ( depth > 32 ) 
		{
			Err("Alias expansion reached depth 32, stopping expansion...");
			return input;
		}
	}

	return input;
}

function DetectPrefix()
{
	local int i, prefixLen;

	bNeedsPrefixDetection = False;

	if ( AliasCount <= 0 ) 
	{
		Prefix = "";
		return;
	}

	Prefix = AliasKey[0];
	prefixLen = Len(Prefix);


	for ( i = 1; i < AliasCount; i+=1 ) 
	{
		while ( Prefix != "" && InStr(AliasKey[i], Prefix) != 0 ) 
		{
			prefixLen -= 1;
			Prefix = Left(Prefix, prefixLen - 1);
		}
	}

}