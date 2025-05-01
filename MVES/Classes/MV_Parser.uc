class MV_Parser expands MV_Util abstract;

const EMPTY_STRING = "";

// DEPRECATED: Please use Tokenize or SplitOne
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

// Will tokenize an input using separator char, return true while there is input to tokenize
// Returns false when input is empty
static function bool Tokenize(out string inout, string separator, out string token)
{
	local int pos;

	if ( inout == EMPTY_STRING ) 
		return False; // no more tokens

	pos = InStr(inout, separator);

	if ( pos >= 0 ) 
	{
		token = Left(inout, pos); // next token
		inout = Mid(inout, pos + Len(separator));
		return True;
	}

	token = inout; // last token
	inout = EMPTY_STRING;
	return True;
}

// Will succeed only if separator exists inside the string
// Output substring before separator and rest of the string
static function bool SplitOne(string input, string separator, out string first, out string rest)
{
	local int pos;

	pos = InStr(input, separator);

	if ( pos < 0 )
		return False;

	first = Left(input, pos);
	rest = Mid(input, pos + Len(separator));
	return True;
}

defaultproperties
{
}
