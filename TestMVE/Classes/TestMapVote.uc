class TestMapVote extends TestClass;


function TestMain()
{
	Describe("MapVote.ParseMapFromURL");
	AssertMap("nyleve#leavevr?peer", "nyleve", "map with location");
	AssertMap("?Restart", "", "restart command");
	AssertMap("DM-Fractal?Mutator=MVES.MapVote", "DM-Fractal", "map with parameter");
	AssertMap("DM-Deck16][", "DM-Deck16][", "just map");
	AssertMap("   DM-Deck16][", "DM-Deck16][", "trim left whitespace");
}

function AssertMap(string url, string expected, string reason)
{
	AssertEquals(class'MapVote'.Static.ParseMapFromURL(url), expected, reason);
}
