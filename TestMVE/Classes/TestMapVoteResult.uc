class TestMapVoteResult extends TestClass;

var MapVoteResult s;

function TestMain()
{
	TestPackages();
	TestMapLoading();
	TestMutators();
	TestStringProperties();
	TestIntProperties();
	TestActors();
	TestSettings();
}

function TestPackages()
{
	Describe("MapVoteResult packages");
	s.AddPackages("Package1,Package2");
	AssertEquals(s.ServerPackageCount, 2, "has 2 packages");
	s.AddPackages("Package1");
	AssertEquals(s.ServerPackageCount, 2, "cannot add same package mutiple times");
	s.AddPackages("Package3");
	AssertEquals(s.GetPackagesStringList(), "Package1,Package2,Package3", "can get string list");
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

function TestIntProperties(){
	Describe("int properties");
	s.SetTickRate(75);
	AssertEquals(s.TickRate, 75, "sets tickrate");
	s.SetTickRate(0);
	AssertEquals(s.TickRate, 75, "previous tickrate is kept when settikng to 0");
}

function TestSettings(){
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

function Describe(string subject)
{
	super.Describe(subject);
	s = new class'MapVoteResult';
}