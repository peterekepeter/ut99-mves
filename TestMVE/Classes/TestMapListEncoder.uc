class TestMapListEncoder extends TestClass;

var string L[1024];
var int P;
var int RangeStart;
var int PrevIndex;
var string PrevCodes;
var string Codes;
var string NextMap;
var string NextMapEnc;
var string PrevMap;
const NA = -65536;

function TestMain()
{
	Describe("Basic GameCode Encode");
	AddMap("Random");
	AddToGame(4);
	AddToGame(7);
	AssertLine(0, "Random:4:7");
	
	Describe("Game codes are range encoded");
	AddMap("DM-Deck16][");
	AddToGame(1);
	AddToGame(2);
	AddToGame(3);
	AddToGame(6);
	AddToGame(7);
	AddToGame(8);
	AssertLine(0, "DM-Deck16][:1>3:6>8");

	Describe("Game codes are ommited when identical");
	AddMap("Random");
	AddToGame(4);
	AddToGame(7);
	AddMap("CTF-Face");
	AddToGame(4);
	AddToGame(7);
	AssertLine(0, "Random:4:7|CTF-Face");

	Describe("Maps without games are discarded");
	AddMap("Random");
	AddToGame(1);
	AddMap("CTF-Face");
	AssertLine(0, "Random:1");

	Describe("Map name start is reused");
	AddMap("DM-Deck16][");
	AddToGame(1);
	AddMap("DM-Decimator");
	AddToGame(1);
	AssertLine(0, "DM-Deck16][:1|6>imator");

	// Describe("Range start is implicitly 0");
	// AddMap("DM-Deck16][");
	// AddToGame(0);
	// AddToGame(1);
	// AddToGame(2);
	// AddToGame(3);
	// AssertLine(0, "DM-Deck16][:>3");
}

function AssertLine(int line, string expected)
{
	Finalize();
	AssertEquals(L[line], expected, "line "$line$" is correct");
}

function Describe(string str) 
{
	Reset();
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
		NextMapEnc = i$">"$Mid(map, i);
	}
	else 
	{
		NextMapEnc = map;
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
	Codes = Codes$":"$idx;
	PrevIndex = idx;
	RangeStart = idx;
}

function FinalizeCodesRange()
{
	if (PrevIndex >= 0)
	{
		if (RangeStart != PrevIndex)
		{
			Codes = Codes$">"$PrevIndex;
		}
		PrevIndex = NA;
		RangeStart = NA;
	}
}

function FinalizeMapEntry()
{
	local string s;
	FinalizeCodesRange();
	if (Codes != "")
	{
		s = NextMapEnc;
		if (Codes != PrevCodes)
		{
			s = s$Codes;
		}
		if (L[P] != "") 
		{
			L[P] = L[P]$"|"$s;
		}
		else 
		{
			L[P] = L[P]$s;
		}
		PrevCodes = Codes;
		Codes = "";
		PrevMap = NextMap;
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
	PrevIndex = NA;
	RangeStart = NA;
	PrevCodes = "";
	Codes = "";
	PrevMap = "";
}