class MapListDecoder extends MV_Parser;

var string L[4096];

// reader props
var int R;
var string ReadLine;
var string ReadMapEntry;
var string ReadMapName;
var string PrevReadCodes[8];
var int PrevReadCodesAt;

// writer props
var int P;
var int RangeStart;
var int PrevIndex;
var int CharsPerLine;
var int PredictedCode;
const InitialCharsPerLine = 500;
var string PrevCodes[8];
var int PrevCodesIndex;
var string Codes;
var string NextMap;
var string NextMapEnc;
var string PrevMap;
const NA = -65536;

function ResetReader() 
{
	local int i;
	R = 0;
	ReadLine = EMPTY_STRING;
	ReadMapEntry = EMPTY_STRING;
	PrevReadCodesAt = 0;
	for ( i = 0; i < ArrayCount(PrevCodes); i+=1 )
	{
		PrevCodes[i] = EMPTY_STRING;
	}
}

function bool ReadEntry(out string resultMap) 
{
	local bool trimLegacySemicolon; 

	if ( ReadLine == "" )
	{
		if ( L[R] != "" )
		{
			ReadLine = L[R];
			R += 1;
		}
		else 
		{
			return False;
		}
	}

	// detect legacy semicolon mode
	// workaround implemented on 2023-08-23
	trimLegacySemicolon = InStr(ReadMapEntry, "|") == -1;
	
	if ( Parse(ReadMapEntry, "|", ReadLine) )
	{
		if ( Parse(ReadMapName, ":", ReadMapEntry) )
		{
			resultMap = ReadMapName;
			if ( ReadMapEntry == EMPTY_STRING ) 
			{
				if ( trimLegacySemicolon ) 
				{
					// map list is from  version of mve which has suffixed semicolons
					if ( Right(resultMap, 1) == ";" ) 
					{
						resultMap = Left(resultMap, Len(resultMap) -1);
					}
				}
				// backreference to previous codes
				ReadMapEntry = PrevReadCodes[(PrevReadCodesAt - 1) & 7];
			}
			else if (Mid(ReadMapEntry, 0, 1) == "-") 
			{
				// handle long backreference
				ReadMapEntry = PrevReadCodes[(int(ReadMapEntry) -2) & 7];
			}
			else 
			{
				// new code definition
				PrevReadCodes[PrevReadCodesAt] = ReadMapEntry;
				PrevReadCodesAt = (PrevReadCodesAt + 1) & 7;
			}
			return True;
		}
		else 
		{
			// ignore empty entry, reproduce with |||| or emtpy config lines
		}
	}
	else 
	{
		ReadEntry(resultMap);
	}
}

function bool ReadCode(out int code)
{
	local string str;
	if ( Parse(str, ":", ReadMapEntry) ) 
	{
		code = int(str);
		return True;
	}
	else 
	{
		return False;
	}
}

static function bool Parse(out string resultItem, string separator, out string mutableInput)
{
	return TrySplit(mutableInput, separator, resultItem, mutableInput);
}
