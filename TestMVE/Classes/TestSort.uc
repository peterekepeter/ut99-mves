class TestSort extends TestClass;

var MV_Sort s;

function TestMain()
{
	s = new class'MV_Sort';
	TestBasicSort();
	TestSortMaps();
	TestSortAndDeduplicate();
}

function TestBasicSort() 
{
	Describe("Basic swap");
	s.Clear();
	s.AddItem("B");
	s.AddItem("A");
	s.Sort();
	AssertEquals(s.Items[0], "A", "A is first");
	AssertEquals(s.Items[1], "B", "B is last");

	Describe("String comparison is not case sensitive");
	s.Clear();
	s.AddItem("B");
	s.AddItem("a");
	s.Sort();
	AssertEquals(s.Items[0], "a", "a is first");
	AssertEquals(s.Items[1], "B", "B is last");

	Describe("Sort 3 items case not sensitive");
	s.Clear();
	s.AddItem("c");
	s.AddItem("a");
	s.AddItem("B");
	s.Sort();
	AssertEquals(s.Items[0], "a", "a is first");
	AssertEquals(s.Items[1], "B", "B is mid");
	AssertEquals(s.Items[2], "c", "c is last");
}

function TestSortMaps()
{
	Describe("Sort 6 maps without duplicates");
	s.Clear();
	s.AddItem("DM-Deck16.unr");
	s.AddItem("DM-Deck17.unr");
	s.AddItem("AS-Frigate.unr");
	s.AddItem("DM-Fractal.unr");
	s.AddItem("CTF-Face.unr");
	s.AddItem("DM-Agony.unr");
	s.Sort();
	AssertEquals(s.Items[0], "AS-Frigate.unr", "AS-Frigate.unr is 1st");
	AssertEquals(s.Items[1], "CTF-Face.unr", "CTF-Face.unr is 2nd");
	AssertEquals(s.Items[2], "DM-Agony.unr", "DM-Agony.unr is 3rd");
	AssertEquals(s.Items[3], "DM-Deck16.unr", "DM-Deck16.unr is 4th");
	AssertEquals(s.Items[4], "DM-Deck17.unr", "DM-Deck17.unr is 5th");
	AssertEquals(s.Items[5], "DM-Fractal.unr", "DM-Fractal.unr is 6th");

	Describe("Sort 6 maps with duplicates");
	s.Clear();
	s.AddItem("DM-Deck17.unr");
	s.AddItem("DM-Deck17.unr");
	s.AddItem("AS-Frigate.unr");
	s.AddItem("AS-Frigate.unr");
	s.AddItem("AS-Frigate.unr");
	s.AddItem("DM-Deck17.unr");
	s.Sort();
	AssertEquals(s.Items[0], "AS-Frigate.unr", "AS-Frigate.unr is 1st");
	AssertEquals(s.Items[1], "AS-Frigate.unr", "AS-Frigate.unr is 2nd");
	AssertEquals(s.Items[2], "AS-Frigate.unr", "AS-Frigate.unr is 3rd");
	AssertEquals(s.Items[3], "DM-Deck17.unr", "DM-Deck17.unr is 4th");
	AssertEquals(s.Items[4], "DM-Deck17.unr", "DM-Deck17.unr is 5th");
	AssertEquals(s.Items[5], "DM-Deck17.unr", "DM-Deck17.unr is 6th");
}

function TestSortAndDeduplicate()
{
	Describe("Deduplicate list with duplicates");
	s.Clear();
	s.AddItem("DM-Deck17.unr");
	s.AddItem("DM-Deck17.unr");
	s.AddItem("AS-Frigate.unr");
	s.AddItem("AS-Frigate.unr");
	s.AddItem("AS-Frigate.unr");
	s.AddItem("DM-Deck17.unr");
	s.SortAndDeduplicate();
	AssertEquals(s.ItemCount, 2, "2 items are left after deduplicate");
	AssertEquals(s.Items[0], "AS-Frigate.unr", "AS-Frigate.unr is 1st");
	AssertEquals(s.Items[1], "DM-Deck17.unr", "DM-Deck17.unr is 2nd");
	AssertEquals(s.DuplicatesRemoved, 4, "4 duplicates were removed");

	Describe("Deduplicate list without duplicates");
	s.Clear();
	s.AddItem("DM-Deck16.unr");
	s.AddItem("AS-Frigate.unr");
	s.AddItem("DM-Deck17.unr");
	s.SortAndDeduplicate();
	AssertEquals(s.ItemCount, 3, "3 items remain");
	AssertEquals(s.DuplicatesRemoved, 0, "no items were removed");
}
