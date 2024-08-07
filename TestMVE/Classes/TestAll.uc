class TestAll extends TestClass;

function TestMain()
{
	TestChild(class'TestSort');
	TestChild(class'TestMapTags');
	TestChild(class'TestMapListEncoder');
	TestChild(class'TestMvAliases');
	TestChild(class'TestMapHistory');
	TestChild(class'TestMapVoteResult');
}
