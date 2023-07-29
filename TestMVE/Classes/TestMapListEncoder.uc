class TestMapListEncoder extends TestClass;

var string L[1024];
var int P;
var int RangeStart;
var int PrevIndex;
var int CharsPerLine;
var int PredictedCode;
const MaxCharsPerLine = 1000;
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
}

function TestGameCodeEncode() 
{
	Describe("MapList GameCode Encode");

	Reset();
	AddMap("Random");
	AddToGame(4);
	AssertLine(0, "Random:3", "gametypes are encoded with -1");

	Reset();
	AddMap("Random");
	AddToGame(1);
	AssertLine(0, "Random:0", "yes, gametype 1 is encoded as 0");

	Reset();
	AddMap("Random");
	AddToGame(0);
	AssertLine(0, "Random:", "gametype 0 is predicted");

	Reset();
	AddMap("Random");
	AddToGame(9);
	AddToGame(18);
	AssertLine(0, "Random:8:6", "numbers are delta coded, with predicted +1");

	Reset();
	AddMap("Random");
	AddToGame(4);
	AddToGame(5);
	AssertLine(0, "Random:3>", "in a range of size 2 the second number is predicted");

	Reset();
	AddMap("Random");
	AddToGame(0);
	AddToGame(1);
	AssertLine(0, "Random:>", "gametype 0-1 completely predicted");

	Reset();
	AddMap("Random");
	AddToGameRange(3,4);
	AddToGameRange(6,7);
	AddToGameRange(9,14);
	AssertLine(0, "Random:2>:>:>3", "ranges that skip 1 and have length of 1 are predicted");


	Reset();
	AddMap("Random");
	AddToGame(0);
	AddToGame(2);
	AddToGame(4);
	AddToGame(6);
	AddToGame(8);
	AssertLine(0, "Random:::::", "every second gametype is predicted");
	
	Reset();
	AddMap("DM-Deck16][");
	AddToGameRange(1,3);
	AddToGameRange(6,8);
	AssertLine(0, "DM-Deck16][:0>0:0>0", "range encoding works");

	Reset();
	AddMap("Random");
	AddToGame(4);
	AddToGame(7);
	AddMap("CTF-Face");
	AddToGame(4);
	AddToGame(7);
	AssertLine(0, "Random:3:0|CTF-Face", "games are ommited when repeated");

	Reset();
	AddMap("Random");
	AddToGame(1);
	AddMap("CTF-Face");
	AssertLine(0, "Random:0", "map discarded for having no gametpye");

	Reset();
	AddMap("DM-Deck16][");
	AddToGame(0);
	AddToGame(1);
	AddToGame(2);
	AssertLine(0, "DM-Deck16][:>0", "implicitly starts with 0");

	Reset();
	AddMap("DM-1on1-CrossCon");
	AddToGameRange(0,1);
	AddToGameRange(3,5);
	AddToGameRange(7,12);
	AddToGameRange(30,34);
	AddToGame(56);
	AddToGame(59);
	AssertLine(0, 
		"DM-1on1-CrossCon:>:>0:>3:15>2:19:0", 
		"real world scenario encoded as expected"
	);
}

function TestGameCodesBackreference() 
{
	Describe("MapList GameCode Backreference");

	Reset();
	AddMap("A");
	AddToGameRange(0,16);
	AddMap("B");
	AddToGame(17);
	AddMap("C");
	AddToGameRange(0,16);
	AssertLine(0, "A:>14|B:16|C:-", "backreference skip 1 is used");

	Reset();
	AddMap("A");
	AddToGame(0);
	AddMap("B");
	AddToGame(17);
	AddMap("C");
	AddToGame(0);
	AssertLine(0, "A:|B:16|C:", "backreference not used for implicit 0");

	Reset();
	AddMap("A");
	AddToGameRange(0,1);
	AddMap("B");
	AddToGame(17);
	AddMap("C");
	AddToGameRange(0,1);
	AssertLine(0, "A:>|B:16|C:>", "backreference not used when codes are short");

	Reset();
	AddMap("A"); AddToGame(16); AddToGame(18);
	AddMap("B"); AddToGame(17);
	AddMap("C"); AddToGame(18);
	AddMap("D"); AddToGame(16); AddToGame(18);
	AssertLine(0, "A:15:|B:16|C:17|D:-1", "backreference skip 2");

	Reset();
	AddMap("A"); AddToGameRange(14,16);
	AddMap("B"); AddToGame(17);
	AddMap("C"); AddToGame(17);
	AddMap("D"); AddToGameRange(14,16);
	AssertLine(0, "A:13>0|B:16|C|D:-", 
		"using backreference does not create new history entries");
		
	Reset();
	AddMap("A"); AddToGameRange(0,16);
	AddMap("B"); AddToGameRange(0,17);
	AddMap("C"); AddToGameRange(0,18);
	AddMap("D"); AddToGameRange(0,19);
	AddMap("E"); AddToGameRange(0,16);
	AddMap("F"); AddToGameRange(0,17);
	AddMap("G"); AddToGameRange(0,18);
	AddMap("H"); AddToGameRange(0,19);
	AddMap("I"); AddToGameRange(0,18);
	AddMap("J"); AddToGameRange(0,19);
	AssertLine(0, "A:>14|B:>15|C:>16|D:>17|E:-2|F:-1|G:-|H|I:-|J", 
		"extensive backreference");
}

function TestMapNameReuse()
{
	Describe("MapList Map name reuse");

	Reset();
	AddMap("DM-Deck16]["); AddToGame(0);
	AddMap("DM-Decimator"); AddToGame(0);
	AssertLine(0, "DM-Deck16][:|4>imator", "name reuse encoded with -2");
	
	Reset();
	AddMap("DM-Deck16]["); AddToGame(0);
	AddMap("Destroy"); AddToGame(0);
	AssertLine(0, "DM-Deck16][:|Destroy", "not reused when 1 char is common");

	Reset();
	AddMap("DM-Deck16]["); AddToGame(0);
	AddMap("DMtest"); AddToGame(0);
	AssertLine(0, "DM-Deck16][:|>test", "short reuse when 2 char is common");

	Reset();
	AddMap("DM-Deck16]["); AddToGame(0);
	AddMap("DM-Test"); AddToGame(0);
	AssertLine(0, "DM-Deck16][:|1>Test", "numeric reuse when 3 char is common");

	Reset();
	AddMap("DM-1on1-Rose-v2"); AddToGame(0);
	AddMap("DM-1on1-Rose"); AddToGame(0);
	AssertLine(0, "DM-1on1-Rose-v2:|10>", "full name 12 char resuse");
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

function AddMap(string map)
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

function AddToGameRange(int from, int to)
{
	local int i;
	for (i = from; i <= to; i+=1) 
	{
		AddToGame(i);
	}
}

function AddToGame(int idx)
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
			L[P] = L[P]$"|"$s;
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
	CharsPerLine = MaxCharsPerLine;
}