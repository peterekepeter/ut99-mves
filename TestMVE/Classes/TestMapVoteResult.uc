class TestMapVoteResult extends TestClass;

var MapVoteResult s;

function TestMain()
{
	Describe("MapVoteResult packages");
	s.AddPackages("Package1,Package2");
	AssertEquals(s.ServerPackageCount, 2, "has 2 packages");
	s.AddPackages("Package1");
	AssertEquals(s.ServerPackageCount, 2, "cannot add same package mutiple times");
	s.AddPackages("Package3");
	AssertEquals(s.GetPackagesStringList(), "Package1,Package2,Package3", "can get string list");


	Describe("DM-Fractal map");
	s.Map = "DM-Fractal";
	AssertEquals(s.CanMapBeLoaded(), True, "can be loaded");
	AssertEquals(s.GetSongString(), "Mech8.Mech8", "song is mech8");

	Describe("randomgarbage map");
	s.Map = "randomgarbage";
	AssertEquals(s.CanMapBeLoaded(), False, "randomgarbage cannot be loaded");
	AssertEquals(s.GetSongString(), "None", "song is `None`");


	Describe("mutators");
	s.AddMutators("MVES.MapVote");
	AssertEquals(s.MutatorCount, 1, "has 1 mutator");
	s.AddMutators("PackA.MutA,PackB.MutB");
	AssertEquals(s.MutatorCount, 3, "has 3 mutators");
	s.AddMutators("MVES.MapVote");
	AssertEquals(s.MutatorCount, 3, "cannot add the same mutator twice");
}

function Describe(string subject)
{
	super.Describe(subject);
	s = new class'MapVoteResult';
}