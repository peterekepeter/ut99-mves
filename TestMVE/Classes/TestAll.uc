class TestAll extends TestClass;

function TestMain()
{
	TestChild(class'TestSort');
	TestChild(class'TestMapVoteResult');
	TestChild(class'TestMapTags');
	TestChild(class'TestMapListEncoder');
	TestChild(class'TestMvAliases');
}
