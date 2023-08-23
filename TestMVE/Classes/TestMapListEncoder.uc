class TestMapListEncoder extends TestClass;

var string L[1024];

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

function TestMain()
{
	TestGameCodeEncode();
	TestGameCodesBackreference();
	TestMapNameReuse();
	TestMultilineEncode();
	TestDecode();
}

function TestDecode() 
{
	local string m;
	local int c;

	Describe("Basic entry read");
	Reset();
	L[0] = "DM-Deck16][";
	AssertEquals(ReadEntry(m), "True", "advances to next map");
	AssertEquals(m, "DM-Deck16][", "map is Deck16");
	AssertEquals(ReadEntry(m), "False", "no next map");

	Describe("Multiple inline entries");
	Reset();
	L[0] = "DM-Deck16][:4|DM-Fractal:2|CTF-Face:5";
	ReadEntry(m); AssertEquals(m, "DM-Deck16][", "first is Deck16");
	ReadEntry(m); AssertEquals(m, "DM-Fractal", "second is Fractal");
	ReadEntry(m); AssertEquals(m, "CTF-Face", "third is Face");
	AssertEquals(ReadEntry(m), "False", "no more entries");

	Describe("Multiline entries");
	Reset();
	L[0] = "DM-Deck16][:1";
	L[1] = "DM-Fractal:2";
	L[2] = "CTF-Face:3";
	ReadEntry(m); AssertEquals(m, "DM-Deck16][", "first is Deck16");
	ReadEntry(m); AssertEquals(m, "DM-Fractal", "second is Fractal");
	ReadEntry(m); AssertEquals(m, "CTF-Face", "third is Face");
	AssertEquals(ReadEntry(m), "False", "no more entries");

	Describe("Read legacy codes");
	Reset();
	L[0] = "DM-Agony:00:01:03:59";
	ReadEntry(m); AssertEquals(m, "DM-Agony", "first is DM-Agony");
	ReadCode(c); AssertEquals(c, 0, "first code is 0");
	ReadCode(c); AssertEquals(c, 1, "second code is 1");
	ReadCode(c); AssertEquals(c, 3, "third code is 3");
	ReadCode(c); AssertEquals(c, 59, "4th code is 59");
	AssertEquals(ReadCode(c), False, "no more codes");

	Describe("Read legacy ommited codes are repeated");
	Reset();
	L[0] = "A:3:4:5|B";
	ReadEntry(m); AssertEquals(m, "A", "first entry is A");
	ReadCode(c); AssertEquals(c, 3, "1st code is 3");
	ReadCode(c); AssertEquals(c, 4, "2nd code is 4");
	ReadCode(c); AssertEquals(c, 5, "3rd code is 5");
	ReadEntry(m); AssertEquals(m, "B", "second entry is B");
	ReadCode(c); AssertEquals(c, 3, "1st code is 3");
	ReadCode(c); AssertEquals(c, 4, "2nd code is 4");
	ReadCode(c); AssertEquals(c, 5, "3rd code is 5");

	Describe("Read legacy entry with semicolon");
	Reset();
	L[0] = "DM-Agony;";
	ReadEntry(m); AssertEquals(m, "DM-Agony", "legacy semicolon is trimmed");
}

function ResetReader() 
{
	local int i;
	R = 0;
	ReadLine = EMPTY_STRING;
	ReadMapEntry = EMPTY_STRING;
	PrevReadCodesAt = 0;
	for (i = 0; i < ArrayCount(PrevCodes); i+=1)
	{
		PrevCodes[i] = EMPTY_STRING;
	}
}

function bool ReadEntry(out string resultMap) 
{
	local bool trimLegacySemicolon; 

	if (ReadLine == "")
	{
		if (L[R] != "")
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
	
	if (Parse(ReadMapEntry, "|", ReadLine))
	{
		if (Parse(ReadMapName, ":", ReadMapEntry))
		{
			resultMap = ReadMapName;
			if (ReadMapEntry == EMPTY_STRING) 
			{
				if (trimLegacySemicolon) 
				{
					// map list is from  version of mve which has suffixed semicolons
					if (Right(resultMap, 1) == ";") 
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
	if (Parse(str, ":", ReadMapEntry)) 
	{
		code = int(str);
		return True;
	}
	else 
	{
		return False;
	}
}

function TestGameCodeEncode() 
{
	Describe("MapList GameCode Encode");

	Reset();
	WriteEntry("Random");
	WriteCode(4);
	AssertLine(0, "Random:3", "gametypes are encoded with -1");

	Reset();
	WriteEntry("Random");
	WriteCode(1);
	AssertLine(0, "Random:0", "yes, gametype 1 is encoded as 0");

	Reset();
	WriteEntry("Random");
	WriteCode(0);
	AssertLine(0, "Random:", "gametype 0 is predicted");

	Reset();
	WriteEntry("Random");
	WriteCode(9);
	WriteCode(18);
	AssertLine(0, "Random:8:6", "numbers are delta coded, with predicted +1");

	Reset();
	WriteEntry("Random");
	WriteCode(4);
	WriteCode(5);
	AssertLine(0, "Random:3>", "in a range of size 2 the second number is predicted");

	Reset();
	WriteEntry("Random");
	WriteCode(0);
	WriteCode(1);
	AssertLine(0, "Random:>", "gametype 0-1 completely predicted");

	Reset();
	WriteEntry("Random");
	WriteCodeRange(3,4);
	WriteCodeRange(6,7);
	WriteCodeRange(9,14);
	AssertLine(0, "Random:2>:>:>3", "ranges that skip 1 and have length of 1 are predicted");

	Reset();
	WriteEntry("Random");
	WriteCode(0);
	WriteCode(2);
	WriteCode(4);
	WriteCode(6);
	WriteCode(8);
	AssertLine(0, "Random:::::", "every second gametype is predicted");
	
	Reset();
	WriteEntry("DM-Deck16][");
	WriteCodeRange(1,3);
	WriteCodeRange(6,8);
	AssertLine(0, "DM-Deck16][:0>0:0>0", "range encoding works");

	Reset();
	WriteEntry("Random");
	WriteCode(4);
	WriteCode(7);
	WriteEntry("CTF-Face");
	WriteCode(4);
	WriteCode(7);
	AssertLine(0, "Random:3:0|CTF-Face", "games are ommited when repeated");

	Reset();
	WriteEntry("Random");
	WriteCode(1);
	WriteEntry("CTF-Face");
	AssertLine(0, "Random:0", "map discarded for having no gametpye");

	Reset();
	WriteEntry("DM-Deck16][");
	WriteCode(0);
	WriteCode(1);
	WriteCode(2);
	AssertLine(0, "DM-Deck16][:>0", "implicitly starts with 0");

	Reset();
	WriteEntry("DM-1on1-CrossCon");
	WriteCodeRange(0,1);
	WriteCodeRange(3,5);
	WriteCodeRange(7,12);
	WriteCodeRange(30,34);
	WriteCode(56);
	WriteCode(59);
	AssertLine(0, 
		"DM-1on1-CrossCon:>:>0:>3:15>2:19:0", 
		"real world scenario encoded as expected"
	);
}

function TestGameCodesBackreference() 
{
	Describe("MapList GameCode Backreference");

	Reset();
	WriteEntry("A");
	WriteCodeRange(0,16);
	WriteEntry("B");
	WriteCode(17);
	WriteEntry("C");
	WriteCodeRange(0,16);
	AssertLine(0, "A:>14|B:16|C:-", "backreference skip 1 is used");

	Reset();
	WriteEntry("A");
	WriteCode(0);
	WriteEntry("B");
	WriteCode(17);
	WriteEntry("C");
	WriteCode(0);
	AssertLine(0, "A:|B:16|C:", "backreference not used for implicit 0");

	Reset();
	WriteEntry("A");
	WriteCodeRange(0,1);
	WriteEntry("B");
	WriteCode(17);
	WriteEntry("C");
	WriteCodeRange(0,1);
	AssertLine(0, "A:>|B:16|C:>", "backreference not used when codes are short");

	Reset();
	WriteEntry("A"); WriteCode(16); WriteCode(18);
	WriteEntry("B"); WriteCode(17);
	WriteEntry("C"); WriteCode(18);
	WriteEntry("D"); WriteCode(16); WriteCode(18);
	AssertLine(0, "A:15:|B:16|C:17|D:-1", "backreference skip 2");

	Reset();
	WriteEntry("A"); WriteCodeRange(14,16);
	WriteEntry("B"); WriteCode(17);
	WriteEntry("C"); WriteCode(17);
	WriteEntry("D"); WriteCodeRange(14,16);
	AssertLine(0, "A:13>0|B:16|C|D:-", 
		"using backreference does not create new history entries");
		
	Reset();
	WriteEntry("A"); WriteCodeRange(0,16);
	WriteEntry("B"); WriteCodeRange(0,17);
	WriteEntry("C"); WriteCodeRange(0,18);
	WriteEntry("D"); WriteCodeRange(0,19);
	WriteEntry("E"); WriteCodeRange(0,16);
	WriteEntry("F"); WriteCodeRange(0,17);
	WriteEntry("G"); WriteCodeRange(0,18);
	WriteEntry("H"); WriteCodeRange(0,19);
	WriteEntry("I"); WriteCodeRange(0,18);
	WriteEntry("J"); WriteCodeRange(0,19);
	AssertLine(0, "A:>14|B:>15|C:>16|D:>17|E:-2|F:-1|G:-|H|I:-|J", 
		"extensive backreference");
}

function TestMapNameReuse()
{
	Describe("MapList Map name reuse");

	Reset();
	WriteEntry("DM-Deck16]["); WriteCode(0);
	WriteEntry("DM-Decimator"); WriteCode(0);
	AssertLine(0, "DM-Deck16][:|4>imator", "name reuse encoded with -2");
	
	Reset();
	WriteEntry("DM-Deck16]["); WriteCode(0);
	WriteEntry("Destroy"); WriteCode(0);
	AssertLine(0, "DM-Deck16][:|Destroy", "not reused when 1 char is common");

	Reset();
	WriteEntry("DM-Deck16]["); WriteCode(0);
	WriteEntry("DMtest"); WriteCode(0);
	AssertLine(0, "DM-Deck16][:|>test", "short reuse when 2 char is common");

	Reset();
	WriteEntry("DM-Deck16]["); WriteCode(0);
	WriteEntry("DM-Test"); WriteCode(0);
	AssertLine(0, "DM-Deck16][:|1>Test", "numeric reuse when 3 char is common");

	Reset();
	WriteEntry("DM-1on1-Rose-v2"); WriteCode(0);
	WriteEntry("DM-1on1-Rose"); WriteCode(0);
	WriteEntry("DM-1on1-R"); WriteCode(0);
	AssertLine(0, "DM-1on1-Rose-v2:|10>|7>", "full name resuse");
}

function TestMultilineEncode()
{
	Describe("List is written to new line when limit is exceeded");

	Reset();
	CharsPerLine = 30;
	WriteEntry("AS-Frigate"); WriteCode(0);
	WriteEntry("DM-Deck16]["); WriteCode(1);
	WriteEntry("CTF-Face"); WriteCode(2);
	AssertLine(0, "AS-Frigate:|DM-Deck16][:0", "first contains first 2 maps");
	AssertLine(1, "CTF-Face:1", "second line contains 3rd map");

	Describe("List items all written to newlines when limit is to low");

	Reset();
	CharsPerLine = 4;
	WriteEntry("AS-Frigate"); WriteCode(0);
	WriteEntry("DM-Deck16]["); WriteCode(1);
	WriteEntry("CTF-Face"); WriteCode(2);
	AssertLine(0, "AS-Frigate:", "first line contains first map");
	AssertLine(1, "DM-Deck16][:0", "second line second map");
	AssertLine(2, "CTF-Face:1", "third line third map");
}

function AssertLine(int line, string expected, string because)
{
	Finalize();
	AssertEquals(L[line], expected, because);
}

function Describe(string str) 
{
	Super.Describe(str);
}

function WriteEntry(string map)
{
	local int i, l;
	FinalizeMapEntry();
	l = Len(map);
	for (i = 0; i < l && Mid(PrevMap, i, 1) == Mid(map,i, 1); i+=1);
	NextMap = map;
	if (i > 2) 
	{
		NextMapEnc = (i-2)$">"$Mid(map, i);
	}
	else if (i == 2)
	{
		NextMapEnc = ">"$Mid(map, i);
	}
	else 
	{
		NextMapEnc = map;
	}
}

function WriteCodeRange(int from, int to)
{
	local int i;
	for (i = from; i <= to; i+=1) 
	{
		WriteCode(i);
	}
}

function WriteCode(int idx)
{
	if (PrevIndex >= 0)
	{
		if (idx - PrevIndex == 1)
		{
			PrevIndex = idx;
			return;
		}
		else 
		{
			FinalizeCodesRange();
		}
	}
	if (idx == PredictedCode) 
	{
		Codes = Codes$":"; // implicit range start
	} 
	else 
	{
		Codes = Codes$":"$(idx - PredictedCode - 1);
	}
	PredictedCode = idx + 1;
	PrevIndex = idx;
	RangeStart = idx;
}

function FinalizeCodesRange()
{
	if (PrevIndex >= 0)
	{
		if (RangeStart != PrevIndex)
		{
			if (PredictedCode == PrevIndex) 
			{
				Codes = Codes$">";
			}
			else 
			{
				Codes = Codes$">"$(PrevIndex - PredictedCode - 1);
			}
			PredictedCode = PrevIndex + 2;
		}
		else 
		{
			PredictedCode += 1;
		}
		PrevIndex = NA;
		RangeStart = NA;
	}
}

function FinalizeMapEntry()
{
	local string s;
	local int i,j;
	local bool didAppend;
	FinalizeCodesRange();
	if (Codes != "")
	{
		s = NextMapEnc;
		for (i = 0; i < ArrayCount(PrevCodes); i+=1)
		{
			j = (PrevCodesIndex + i) & 7;
			if (PrevCodes[j] == "") 
			{
				break;	
			}
			else if (Codes == PrevCodes[j])
			{
				if (i == 0) 
				{ 
					// predicted backreference to previous value
					didAppend = True;
				}
				else if (i == 1 && Len(Codes) > 2)
				{
					s = s$":-"; // skip 1
					didAppend = True;
				}
				else if (Len(Codes) > 3)
				{
					s = s$":-"$(i-1); // skip N+1
					didAppend = True;
				}
				break;
			}
		}

		if (!didAppend)
		{
			// full code append
			s = s$Codes;
			PrevCodesIndex = (PrevCodesIndex - 1) & 7;
			PrevCodes[PrevCodesIndex] = Codes;
		}

		if (L[P] != "") 
		{
			if (CharsPerLine < Len(L[P]) + Len(s) + 1)
			{
				P += 1;
				L[P] = L[P]$s;
			}
			else 
			{
				L[P] = L[P]$"|"$s;
			}
		}
		else 
		{
			L[P] = L[P]$s;
		}

		Codes = "";
		PrevMap = NextMap;
		PredictedCode = 0;
	}
}

function Finalize()
{
	FinalizeMapEntry();
}

function Reset() 
{
	ResetReader();
	ResetWriter();
}

function ResetWriter() 
{
	local int i;
	for (i = 0; i <= P; i+=1) 
	{
		L[i] = "";
	}
	P = 0;
	for (i = 0; i < ArrayCount(PrevCodes); i+=1)
	{
		PrevCodes[i] = "";
	}
	PrevCodesIndex = 0;
	PredictedCode = 0;
	PrevIndex = NA;
	RangeStart = NA;
	Codes = "";
	PrevMap = "";
	CharsPerLine = InitialCharsPerLine;
}

// TODO reuse from utils
static function bool Parse(out string resultItem, string separator, out string mutableInput)
{
	return TrySplit(mutableInput, separator, resultItem, mutableInput);
}

const EMPTY_STRING = "";

static function bool TrySplit(string input, string separator, out string first, out string rest)
{
	local int pos;

	if (input == EMPTY_STRING) 
	{
		first = EMPTY_STRING;
		rest = EMPTY_STRING;
		return False;
	}

	pos = InStr(input, separator);

	if (pos >= 0) 
	{
		first = Left(input, pos);
		rest = Mid(input, pos + Len(separator));
		return True;
	} 
	else if (pos == -1) 
	{
		first = input;
		rest = "";
		return True;
	}
}