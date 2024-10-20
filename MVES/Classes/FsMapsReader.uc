class FsMapsReader extends Info;

var int iSeek;
var String FirstMap;
var String CurMap;

function Reset() 
{
	iSeek = 1;
	FirstMap = GetMapName("","",0);
	CurMap = FirstMap;
}

function string GetMap() 
{
	return CurMap;
}

function bool MoveNext()
{
	CurMap = GetMapName("", FirstMap, iSeek++);
	return CurMap == FirstMap || CurMap == "" ;
}

function int GetMapCount()
{
	return iSeek - 1;
}