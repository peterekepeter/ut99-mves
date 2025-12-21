class NameConverter extends Object;

var name ResultName;
var NameConverter Instance;

static function name ToName(string input)
{
	if ( Default.Instance == None )
		Default.Instance = new (None) class'NameConverter';
	Default.Instance.SetString(input);
	return Default.Instance.ResultName;
}

function SetString(string str) 
{
	local int length, i, code;
	local string char, rstring;
	
	length = Len(str);
	rstring = "";

	for ( i = 0; i < length; i += 1 )
	{
		char = Mid(str, i, 1);
		code = Asc(char);
		if ( 65 <= code && code <= 90 || 97 <= code && code <= 122 || 48 <= code && code <= 57 )
		{
			rstring = rstring$char;
		}
	}

	Self.SetPropertyText("ResultName", rstring);
}

function name GetName() 
{
	return ResultName;
}

function name Convert(string input) 
{
	SetString(input);
	return ResultName;
}
