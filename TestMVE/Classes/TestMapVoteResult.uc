class TestMapVoteResult extends TestClass;

var MV_Result s;
var MV_Aliases a;

function TestMain()
{
	TestPackages();
	TestMapLoading();
	TestMutators();
	TestStringProperties();
	TestIntProperties();
	TestActors();
	TestSettings();
	TestWrappedPackages();
	TestUrlParameters();
	TestRemove();
	TestAliases();
}

function TestPackages()
{
	Describe("MV_Result packages");
	s.AddPackages("Package1,Package2");
	AssertEquals(s.ServerPackageCount, 2, "has 2 packages");
	s.AddPackages("Package1");
	AssertEquals(s.ServerPackageCount, 2, "cannot add same package mutiple times");
	s.AddPackages("Package3");
	AssertEquals(s.GetPackagesStringList(), "Package1,Package2,Package3", "can get string list");
}

function TestWrappedPackages() 
{
	Describe("MV_Result accepts packages wrapped in paren");
	s.AddPackages("(\"SoldierSkins\",\"CommandoSkins\")");
	AssertEquals(s.GetPackagesStringList(), "SoldierSkins,CommandoSkins", "can get string list");
	s.AddPackages("(\"MVE2dev\",\"CommandoSkins\")");
	AssertEquals(s.GetPackagesStringList(), "SoldierSkins,CommandoSkins,MVE2dev", "appends additional");
	AssertEquals(s.GetWrappedPackages(), "(\"SoldierSkins\",\"CommandoSkins\",\"MVE2dev\")", "can wrap packages");
}

function TestMapLoading()
{

	Describe("DM-Fractal map");
	s.Map = "DM-Fractal";
	AssertEquals(s.CanMapBeLoaded(), True, "can be loaded");
	AssertEquals(s.GetSongString(), "Mech8.Mech8", "song is mech8");
	AssertEquals(s.GetIdealPlayerCountString(), "2-4", "ideal player count string is 2-4");
	AssertEquals(s.GetAvgIdealPlayerCount(), 3, "parsed ideal player count is 3");

	Describe("randomgarbage map");
	s.Map = "randomgarbage";
	AssertEquals(s.CanMapBeLoaded(), False, "randomgarbage cannot be loaded");
	AssertEquals(s.GetSongString(), "None", "song is `None`");

}

function TestMutators()
{
	Describe("mutators");
	s.AddMutators("MVES.MapVote");
	AssertEquals(s.MutatorCount, 1, "has 1 mutator");
	s.AddMutators("PackA.MutA,PackB.MutB");
	AssertEquals(s.MutatorCount, 3, "has 3 mutators");
	s.AddMutators("MVES.MapVote");
	AssertEquals(s.MutatorCount, 3, "cannot add the same mutator twice");
}

function TestActors()
{
	Describe("mutators");
	s.AddActors("MVES.MapVote");
	AssertEquals(s.ActorCount, 1, "has 1 actors");
	s.AddActors("PackA.A,PackB.B");
	AssertEquals(s.ActorCount, 3, "has 3 actors");
	s.AddActors("MVES.MapVote");
	AssertEquals(s.ActorCount, 3, "cannot add the same actor twice");
}


function TestStringProperties()
{
	Describe("string properties");
	s.SetGameName("DeathMatch");
	s.SetRuleName("InstaGib");
	s.SetGameClass("Botpack.DeathMatchPlus");
	s.SetFilterCode("dmlist");
	AssertEquals(s.GameName, "DeathMatch", "can set GameName");
	AssertEquals(s.RuleName, "InstaGib", "can set RuleName");
	AssertEquals(s.GameClass, "Botpack.DeathMatchPlus", "can set GameClass");
	AssertEquals(s.FilterCode, "dmlist", "can set FilterCode");
	s.SetGameName("");
	s.SetRuleName("");
	s.SetGameClass("");
	s.SetFilterCode("");
	AssertEquals(s.GameName, "DeathMatch", "empty string does not change GameName");
	AssertEquals(s.RuleName, "InstaGib", "empty string does not change RuleName");
	AssertEquals(s.GameClass, "Botpack.DeathMatchPlus", "empty string does not change GameClass");
	AssertEquals(s.FilterCode, "dmlist", "empty string does not change FilterCode");
}

function TestIntProperties()
{
	Describe("int properties");
	s.SetTickRate(75);
	AssertEquals(s.TickRate, 75, "sets tickrate");
	s.SetTickRate(0);
	AssertEquals(s.TickRate, 75, "previous tickrate is kept when settikng to 0");
}

function TestSettings()
{
	Describe("game settings");
	s.AddGameSettings("FragLimit=30,TimeLimit=0,GameSpeed=1.00,MinPlayers=2,bUseTranslocator=False,GameName=Instagib Deathmatch");
	AssertEquals(s.SettingsCount, 6, "parses settings correctly");
	AssertEquals(s.GetGameSettingByKey("FragLimit"), "30", "frag limit correctly set");
	AssertEquals(s.GetGameSettingByKey("TimeLimit"), "0", "time limit correctly set");
	AssertEquals(s.GetGameSettingByKey("GameSpeed"), "1.00", "game speed correctly set");
	AssertEquals(s.GetGameSettingByKey("MinPlayers"), "2", "min players correctly set");
	AssertEquals(s.GetGameSettingByKey("bUseTranslocator"), "False", "bool correctly set");
	AssertEquals(s.GetGameSettingByKey("GameName"), "Instagib Deathmatch", "game name correctly set");
	AssertEquals(s.GetGameSettingByKey("Uknown"), "", "undefined property has empty value");
	s.AddGameSettings("FragLimit=50");
	AssertEquals(s.SettingsCount, 6, "adding same properties does not increase count");
	AssertEquals(s.GetGameSettingByKey("FragLimit"), "50", "same properties override each other");
	AssertEquals(s.GetGameSettingByKey("TimeLimit"), "0", "other property value is kept");
	s.AddGameSettings("MaxTeamSize=16");
	AssertEquals(s.SettingsCount, 7, "new property can be added");
}

function TestUrlParameters()
{
	Describe("url parameters are appended and concatenated");
	AssertEquals(s.UrlParametersCount, 0, "starts with 0 params");
	AssertEquals(s.GetUrlParametersString(), "", "returns empty string");
	s.AddUrlParameters("?Key=Value");
	AssertEquals(s.UrlParametersCount, 1, "added one param");
	s.AddUrlParameters("?ProfileX=1?ProfileY=2");
	AssertEquals(s.UrlParametersCount, 3, "added more params");
	AssertEquals(s.GetUrlParametersString(), "?Key=Value?ProfileX=1?ProfileY=2", "returns merged params");
	
	Describe("adding same url parameters overwrite each other");
	s.AddUrlParameters("?Key=Value");
	s.AddUrlParameters("?Key=AnotherValue");
	s.AddUrlParameters("?Key=LastValue");
	AssertEquals(s.GetUrlParametersString(), "?Key=LastValue", "returns merged params");

	Describe("adding same url parameter without value overwrite each other");
	s.AddUrlParameters("?Dummy=0");
	s.AddUrlParameters("?Dummy?Dummy??");
	AssertEquals(s.GetUrlParametersString(), "?Dummy=", "returns single param");
}

function TestRemove()
{
	Describe("mutators can be removed");
	s.AddMutators("A,B,C");
	AssertEquals(s.RemoveMutator("B"), True, "remove single mutator");
	AssertEquals(s.RemoveMutator("B"), False, "cannot remove twice");
	AssertEquals(s.MutatorCount, 2, "has 2 mutators");
	AssertEquals(s.RemoveMutators("A,C"), True, "remove multiple");
	AssertEquals(s.MutatorCount, 0, "has 0 mutators");

	Describe("actors can be removed");
	s.AddActors("A,B,C");
	AssertEquals(s.RemoveActor("B"), True, "remove single actor");
	AssertEquals(s.RemoveActor("B"), False, "cannot remove twice");
	AssertEquals(s.ActorCount, 2, "has 2 actors");
	AssertEquals(s.RemoveActors("A,C"), True, "remove multiple");
	AssertEquals(s.ActorCount, 0, "has 0 actors");
}


function TestAliases()
{
	Describe("map result will expand aliases");
	Alias("<X>=B,<Y>");
	Alias("<Y>=C,D");

	s.AddActors("A,<X>,E");
	AssertEquals(s.ActorCount, 5, "add aliased actors");

	s.RemoveActors("A,<X>,E");
	AssertEquals(s.ActorCount, 0, "remov aliased actors");

	s.AddMutators("A,<X>,E");
	AssertEquals(s.MutatorCount, 5, "add aliased mutators");

	s.RemoveMutators("A,<X>,E");
	AssertEquals(s.MutatorCount, 0, "remove aliased mutators");

	s.AddPackages("A,<X>,E");
	AssertEquals(s.ServerPackageCount, 5, "add aliased packages");

	Alias("<DMSET>=FragLimit=30,TimeLimit=0");
	s.AddGameSettings("MinPlayers=2,<DMSET>");
	AssertEquals(s.SettingsCount, 3, "add aliased settings");
	AssertEquals(s.GetGameSettingByKey("FragLimit"), "30", "aliased FragLimit is 30");

	Alias("<URLP>=?ProfileX=1?ProfileY=2?ProfileZ=3");
	s.AddUrlParameters("<URLP>");
	AssertEquals(s.UrlParametersCount, 3, "add aliased url paramater");

	Alias("<DMP> Botpack.DeathMatchPlus");
	s.SetGameClass("<DMP>");
	AssertEquals(s.GameClass, "Botpack.DeathMatchPlus", "set aliased game class"); 
}

function Alias(string input) 
{ 
	a.AddAliasLine(input);
}

function Describe(string subject)
{
	Super.Describe(subject);
	a = new class'MV_Aliases';
	s = class'MV_Result'.Static.Create("DM-Fractal", 0, a);
	s.bQuiet = True;
}