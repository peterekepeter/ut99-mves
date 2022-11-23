// defines a common testing framework, all test classes should derive from here
class TestClass extends Commandlet;

var int FailCount;
var int PassCount;

function int Main(string Params)
{
	TestMain();
	Summary();
	return GetExitCode();
}

function TestMain()
{
	Fail("empty test class, please override TestMain");
}

function TestChild(class<TestClass> ChildTestClass)
{
	local TestClass instance;
	instance = new ChildTestClass;
	instance.TestMain();
	FailCount += instance.FailCount;
	PassCount += instance.PassCount;
}

function AssertEquals(coerce string a, coerce string b, string message)
{
	if (a != b) 
		FailEquals(a,b,message);
	else 
		Pass(message);
}

function FailEquals(coerce string a, coerce string b, string message)
{
	Fail(message$": expected \""$a$"\" to be \""$b$"\"");
}

function Fail(coerce string a)
{
	Err(a);
	FailCount += 1;
}

function Pass(coerce string a)
{
	Nfo("    Passed "$a);
	PassCount += 1;
}

function Summary()
{
	Nfo("-------------------");
	Nfo("Summary: failed:"@FailCount$", passed:"@PassCount);
}

function int GetExitCode()
{
	if (PassCount > 0 && FailCount <= 0)
	{
		return 0;
	}
	return 1;
}

function Describe(coerce string a)
{
	Nfo("-------------------");
	Nfo("Testing:"@a);
}

function Err(coerce string a)
{
	Log(" !! Failed "$a);
}

function Nfo(coerce string a)
{
	Log(a);
}