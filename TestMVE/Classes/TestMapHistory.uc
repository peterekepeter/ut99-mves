class TestMapHistory extends TestClass;

var MapHistory History;
var MV_Result Result;
var int MaxCost, CostAdd;

function TestMain()
{
	Describe("MapHistory basic exclusion");

	CostAdd = 4;
	MaxCost = 1;

	MapPlayed("DM-Deck16][");
	AssertExcluded("DM-Deck16][", "because just played");

	MapPlayed("CTF-Face");
	AssertExcluded("CTF-Face", "because just played");
	AssertExcluded("DM-Deck16][", "still on cooldown");

	MapPlayed("DM-Agony");
	AssertExcluded("DM-Agony", "because just played");
	AssertExcluded("CTF-Face", "still on just played");
	AssertExcluded("DM-Deck16][", "almost off cooldown");

	MapPlayed("DM-Fractal");

	AssertNotExcluded("DM-Deck16][", "just got off cooldown");
	AssertExcluded("DM-Fractal", "because just played");
	AssertExcluded("DM-Agony", "still on cooldown");
	AssertExcluded("CTF-Face", "still on cooldown");


	Describe("MapHistory playing same map adds to cost");
	CostAdd = 3;
	MaxCost = 3; 
	MapPlayed("DM-Deck16][");
	AssertNotExcluded("DM-Deck16][", "can still be played");
	MapPlayed("DM-Deck16][");
	AssertExcluded("DM-Deck16][", "cannot be played anymore");

	Describe("Does not fail when CostAdd is 0");
	CostAdd = 0;
	MaxCost = 3; 
	MapPlayed("DM-Deck16][");
	MapPlayed("DM-Fractal");
	AssertNotExcluded("DM-Deck16][", "both maps can still be played");
	AssertNotExcluded("DM-Fractal", "both maps can still be played");

}

function MapPlayed(optional string map, optional string game, optional string rule) 
{
	if ( map == "" ) 
		map = "DM-Deck16][";
	if ( game == "" ) 
		game = "DeathMatch";
	if ( rule == "" ) 
		rule = "InstaGib";
	result.Map = map;
	result.GameName = game;
	result.RuleName = rule;
	History.NewMapPlayed(result, CostAdd);
}

function AssertExcluded(string map, string reason) 
{
	AssertEquals(History.IsExcluded(map, MaxCost), True, map@reason);
}

function AssertNotExcluded(string map, string reason) 
{
	AssertEquals(History.IsExcluded(map, MaxCost), False, map@reason);
}

function Describe(string name) 
{
	Super.Describe(name);
	if ( History == None ) 
		History = new class'MapHistory';
	if ( Result == None ) 
		Result = new class'MV_Result';
	History.ElementCount = 0;
	MaxCost = 0;
	CostAdd = 0;
}