class MapVoteResult expands MV_Util;

var string OriginalSong;
var string Map;
var string Song;
var int GameIndex;

// private 

const ServerPackageMaxCount = 1024;
var int ServerPackageCount;
var string ServerPackages[1024];

const MaxMutatorCount = 1024;
var int MutatorCount;
var string Mutators[1024];

var LevelInfo LevelInfo;
var bool LevelInfoCached;

var LevelSummary LevelSummary;
var bool LevelSummaryCached;

static function MapVoteResult Create(optional string map, optional int gameIdx){
	local MapVoteResult object;
	object = new class'MapVoteResult';
	object.Map = map;
	object.GameIndex = gameIdx;
	return object;
}

function bool AddPackages(string packageNameList)
{
	local string packageName;
	while (class'MV_Parser'.static.TrySplit(packageNameList, ",", packageName, packageNameList))
	{
		AddPackage(packageName);
	}
}

function bool AddPackage(string packageName)
{
	local int i;
	if (i >= ServerPackageMaxCount)
	{
		Err("Cannot add `"$packageName$"`, max server package count reached!");
		return False;
	}
	for (i=0; i<ServerPackageCount; i++)
	{
		if (ServerPackages[i] == packageName)
		{
			return False;
		}
	}
	ServerPackages[ServerPackageCount] = packageName;
	ServerPackageCount++;
	return True;
}

function string GetPackagesStringList()
{
	local string separator, result;
	local int i;
	separator = "";
	for (i=0; i<ServerPackageCount; i++)
	{
		result = result $ separator $ ServerPackages[i];
		separator = ",";
	}
	return result;
}

function bool AddMutators(string list)
{
	local string mutator;
	
	while (class'MV_Parser'.static.TrySplit(list, ",", mutator, list))
	{
		AddMutator(mutator);
	}
}

function bool AddMutator(string mutator)
{
	local int i;
	if (MutatorCount >= MaxMutatorCount)
	{
		Err("Cannot add `"$mutator$"`, max mutator count reached!");
		return False;
	}
	for (i=0; i<MutatorCount; i++)
	{
		if (Mutators[i] == mutator)
		{
			return False;
		}
	}
	Mutators[MutatorCount] = mutator;
	MutatorCount++;
	return True;
}

function string GetSongString()
{
	LoadSongInformation();
	return OriginalSong;
}

function LoadSongInformation(){
	if (OriginalSong == "")
	{
		OriginalSong = ""$GetLevelInfoObject().Song;
	}
}

function bool CanMapBeLoaded()
{
	if (GetLevelSummaryObject() != None) 
	{
		return true;
	}
	if (GetLevelInfoObject() != None) 
	{
		return true;
	}
	// last resort, probably won't help but hey, we tried
	if (DynamicLoadObject(self.Map$".PlayerStart0", class'PlayerStart') != None) 
	{
		return true;
	}
	return false;
}	

function LevelInfo GetLevelInfoObject()
{
	if (LevelInfoCached)
	{
		return LevelInfo; 
	}
	LevelInfoCached = true;
	// 1st try
	LevelInfo = LevelInfo(DynamicLoadObject(self.Map$".LevelInfo0", class'LevelInfo'));
	if (LevelInfo == None) 
	{
		// 2nd try
		LevelInfo = LevelInfo(DynamicLoadObject(self.Map$".LevelInfo1", class'LevelInfo'));
	}
	return LevelInfo;
}

function LevelSummary GetLevelSummaryObject()
{
	if (LevelSummaryCached)
	{
		return LevelSummary;
	}
	LevelSummaryCached = true;
	LevelSummary = LevelSummary(DynamicLoadObject(self.Map$".LevelSummary", class'LevelSummary'));
	return LevelSummary;
}