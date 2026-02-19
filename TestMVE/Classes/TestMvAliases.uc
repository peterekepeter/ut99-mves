class TestMvAliases extends TestClass;

var MV_Aliases a;

function TestMain()
{
	Describe("Basic alias functionality");
	Alias("<test>=something");
	AssertResolves("<test>abcd", "somethingabcd", "a basic alias resolve");
	AssertResolves("<tost>abcd", "<tost>abcd", "no change if no match");
	AssertPrefix("<test>", "detected while alias as prefix since its the only one");

	Describe("Allow space instead of equals");
	Alias("<test> something");
	AssertResolves("<test>abcd", "somethingabcd", "a basic alias resolve");

	Describe("Empty Alias does nothing");
	Alias("");
	AssertResolves("<test>abcd", "<test>abcd", "no change");

	Describe("Resolve does nothing when no aliases present");
	AssertResolves("<test>", "<test>", "does nothing");

	Describe("Resolves twice if repeated");
	Alias("<test>=x");
	AssertResolves("<test><test>", "xx", "resolves twice in series");

	Describe("Recursive resolve is supported");
	Alias("<a>=x");
	Alias("<b>=y");
	Alias("<test>=<a><b>");
	AssertResolves("<test>", "xy", "recursively resolves aliases");
	AssertPrefix("<", "detected while alias as prefix since its the only one");

	Describe("Missing operator configuration error");
	Alias("a");
	AssertConfigError("Invalid alias 'a' expected format '<name>=something'", "no operator error");

	Describe("Duplicate alias error");
	Alias("<a> x");
	AssertConfigError("", "no error so far");
	Alias("<a> y");
	AssertConfigError("Duplicate alias '<a>' not allowed...", "error as expected");

	Describe("Self expansion error");
	Alias("<a> <a><a><a>");
	AssertConfigError("Self referencing alias '<a>' not allowed...", "error as expected");

	Describe("Circular reference error");
	Alias("<a> <b>");
	Alias("<b> <c>");
	Alias("<c> <a>");
	AssertConfigError("Circular alias chain '<a>' -> '<b>' -> '<c>' not allowed...", "error as expected");

	Describe("Without equals for game settings");
	Alias("<lgsniperset> TimeLimit=11");
	AssertResolves("<lgsniperset>", "TimeLimit=11", "correctly parsed game settings");
}

function Alias(string input) 
{ 
	a.AddAliasLine(input);
}

function AssertResolves(string input, string expected, string casename) 
{
	AssertEquals(a.Resolve(input), expected, casename);
}

function AssertPrefix(string expected, string casename) 
{
	AssertEquals(a.Prefix, expected, casename);
}

function AssertConfigError(string expected, string casename)
{
	local string message;
	a.DetectConfigurationError(message);
	AssertEquals(message, expected, casename);
}

function Describe(string subject)
{
	Super.Describe(subject);
	a = new class'MV_Aliases';
}
