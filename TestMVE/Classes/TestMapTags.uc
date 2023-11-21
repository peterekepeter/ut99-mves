class TestMapTags extends TestClass;

var MapTagsConfig c;
var MV_MapTags m;

function TestMain()
{
	Describe("Basic map tag feature");
	c.MapTags[0] = "DM-Test:small:duel";
	c.MapTags[1] = "DM-Test2:small";

	m = c.GetConfiguredMapTags();

	AssertTagged("DM-Test", "small");
	AssertTagged("DM-Test2", "small");
	AssertTagged("DM-Test", "duel");
	AssertNotTagged("DM-Test2", "duel");
	AssertNotTagged("DM-X", "duel");
	AssertTagged("DM-X", "");
	AssertTagged("DM-Test", "small:duel");
	AssertTagged("DM-Test", "duel:small");


	Describe("When map is configured twice, configuration is merged");
	c.MapTags[0] = "DM-Test:duel";
	c.MapTags[1] = "DM-Test:small";

	m = c.GetConfiguredMapTags();
	AssertTagged("DM-Test", "small");
	AssertTagged("DM-Test", "duel");
}

function AssertTagged(string map, string tags) 
{
	AssertEquals(
		m.TestTagMatch(map, tags), True, map$" is tagged with "$tags
	);
}

function AssertNotTagged(string map, string tags) 
{
	AssertEquals(
		m.TestTagMatch(map, tags), False, map$" is not tagged with "$tags
	);
}

function Describe(string subject)
{
	Super.Describe(subject);
	c = new class'MapTagsConfig';
	c.MapTagsVersion = c.CurrentVersion;
	m = None;
}