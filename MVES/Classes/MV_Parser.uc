class MV_Parser expands MV_Util abstract;

const EMPTY_STRING = "";

// Full functional parse function splits off a token from the input, returns it separately
static function bool TrySplit(string input, string separator, out string first, out string rest)
{
	local int pos;

	if ( input == EMPTY_STRING ) 
	{
		first = EMPTY_STRING;
		rest = EMPTY_STRING;
		return False;
	}

	pos = InStr(input, separator);

	if ( pos >= 0 ) 
	{
		first = Left(input, pos);
		rest = Mid(input, pos + Len(separator));
		return True;
	} 
	else if (pos == -1) 
	{
		first = input;
		rest = EMPTY_STRING;
		return True;
	}
}

defaultproperties
{
}
