class MV_MapResult expands MV_Util;

var string OriginalSong;
var string Map;
var string Song;
var int GameIndex;

var int ServerPackageCount;
const ServerPackageMaxCount = 1024;
var string ServerPackages[1024];

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