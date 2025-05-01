class TestMapOverrides extends TestClass;

var MV_MapOverrides overrides;
var MV_MapOverridesParser parser;
var MapOverridesConfig cfg;
var MV_Result result;

function TestMain()
{
	Describe("TestMapOverrides basic");
	cfg.MapOverrides[0] = "DM-X?Song=Organic.Organic";
	cfg.MapOverrides[1] = "DM-Deck16][?Song=Razor-ub.Razor-ub";
	parser.ParseConfiguration(overrides, cfg);

	AssertMapSongOverride("DM-X", "Organic.Organic", "song override applied");
	AssertMapSongOverride("DM-XYZ", "", "does not match");
	AssertMapSongOverride("DM-x", "Organic.Organic", "map match is not case sensitive");
	AssertMapSongOverride("DM-Deck16][", "Razor-ub.Razor-ub", "2nd map song override");
	Describe("Song overrides");

	cfg.MapOverrides[0] = "Song==Moroset.Moroset?Song=Mech8.Mech8";
	cfg.MapOverrides[1] = "SonG==A.a?Song=B.b";
	parser.ParseConfiguration(overrides, cfg);

	AssertSongSongOverride("Moroset.Moroset", "Mech8.Mech8", "song changed to another song");
	AssertSongSongOverride("Garbage.Value", "", "no override if does not match");
	AssertSongSongOverride("MoRoSet.MoRoSet", "Mech8.Mech8", "matching is not case sensitive");
	AssertSongSongOverride("A.a", "B.b", "key is not case sensitive");

	Describe("Mutator overrides");
	cfg.MapOverrides[0] = "DM-Deck16][?MutatorList=Botpack.RocketArena,Botpack.LowGrav";
	parser.ParseConfiguration(overrides, cfg);
	result.Map = "DM-Deck16][";
	overrides.ApplyOverrides(result);
	AssertEquals(result.MutatorCount, "2", "two mutators were added");
	AssertEquals(result.Mutators[0], "Botpack.RocketArena", "1st is rocket arena");
	AssertEquals(result.Mutators[1], "Botpack.LowGrav", "2nd is lowgrav");

}

function AssertSongSongOverride(string mapsong, string expectedsong, string message)
{
	result.Map = "DM-FractalSomething";
	result.GameIndex = 0;
	result.OriginalSong = mapsong;
	result.Song = "";
	result.bQuiet = True;
	overrides.ApplyOverrides(result);
	AssertEquals(result.Song, expectedsong, message);
}

function AssertMapSongOverride(string mapname, string expectedsong, string message) 
{
	ApplyOverridesToMap(mapname);
	AssertEquals(result.Song, expectedsong, message);
}

function ApplyOverridesToMap(string mapname)
{
	result.Map = mapname;
	result.GameIndex = 0;
	result.Song = "";
	result.bQuiet = True;
	overrides.ApplyOverrides(result);
}

function Describe(coerce string a)
{
	Super.Describe(a);
	overrides = new class'MV_MapOverrides';
	parser = new class'MV_MapOverridesParser';
	cfg = new class'MapOverridesConfig';
	result = new class'MV_Result';
}
