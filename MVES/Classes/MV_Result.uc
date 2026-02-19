class MV_Result expands MV_Util;

var MV_Aliases Aliases;

var string OriginalSong;
var string Map;
var string Song;
var int GameIndex;

var int DerivedCount;
var int DerivedFrom[32];

var string GameName;
var string RuleName;
var string GameClass;
var string FilterCode;
var int TickRate;

const ServerPackageMaxCount = 1024;
var int ServerPackageCount;
var string ServerPackages[1024];

const MaxMutatorCount = 1024;
var int MutatorCount;
var string Mutators[1024];

const MaxActors = 1024;
var int ActorCount;
var string Actors[1024];

const MaxSettings = 256;
var int SettingsCount;
var string SettingsKey[256];
var string SettingsValue[256];

const MaxUrlParameters = 256;
var int UrlParametersCount;
var string UrlParametersKey[256], UrlParametersValue[256];

var LevelInfo LevelInfo;
var bool LevelInfoCached;

var LevelSummary LevelSummary;
var bool LevelSummaryCached;

var bool bQuiet;

static function MV_Result Create(optional string map, optional int gameIdx, optional MV_Aliases aliases)
{
	local MV_Result object;
	object = new class'MV_Result';
	object.Map = map;
	object.GameIndex = gameIdx;
	object.bQuiet = False;
	object.Aliases = aliases;
	return object;
}

function AddPackages(string packageNameList)
{
	local string packageName;

	packageNameList = Aliases.Resolve(packageNameList);

	// unwrap decorations
	if ( InStr(packageNameList, "(") == 0 ) 
	{
		packageNameList = Mid(packageNameList, 1, Len(packageNameList) - 2);
	}

	while ( class'MV_Parser'.static.TrySplit(packageNameList, ",", packageName, packageNameList) )
	{
		AddPackage(packageName);
	}
}

function bool AddPackage(string packageName)
{
	local int i;

	// unwrap decorations
	if ( InStr(packageName, "\"") == 0 ) 
	{
		packageName = Mid(packageName, 1, Len(packageName) - 2);
	}

	if ( i >= ServerPackageMaxCount )
	{
		Err("Cannot add `"$packageName$"`, max server package count reached!");
		return False;
	}
	for ( i = 0; i < ServerPackageCount; i++ )
	{
		if ( ServerPackages[i] == packageName )
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
	for ( i = 0; i < ServerPackageCount; i++ )
	{
		result = result$separator$ServerPackages[i];
		separator = ",";
	}
	return result;
}

function string GetWrappedPackages()
{
	local string separator, result;
	local int i;
	separator = "(\"";
	for ( i = 0; i < ServerPackageCount; i++ )
	{
		result = result$separator$ServerPackages[i];
		separator = "\",\"";
	}
	return result$"\")";
}


function bool AddMutators(string list)
{
	local string mutator;
	local bool success;
	success = True;
	list = Aliases.Resolve(list);
	
	while ( class'MV_Parser'.static.TrySplit(list, ",", mutator, list) )
		if ( !AddMutator(mutator) ) 
			success = False;
	
	return success;
}

function bool AddMutator(string mutator)
{
	local int i;
	if ( MutatorCount >= MaxMutatorCount )
	{
		Err("Cannot add `"$mutator$"`, max mutator count reached!");
		return False;
	}
	for ( i = 0; i < MutatorCount; i++ )
	{
		if ( Mutators[i] == mutator )
		{
			return False;
		}
	}
	Mutators[MutatorCount] = mutator;
	MutatorCount++;
	return True;
}

function bool RemoveMutators(string list)
{
	local string mutator;
	local bool success;
	success = True;
	list = Aliases.Resolve(list);
	
	while ( class'MV_Parser'.static.TrySplit(list, ",", mutator, list) )
		if ( !RemoveMutator(mutator) ) 
			success = False;
	
	return success;
}

function bool RemoveMutator(string mutator)
{
	local int i,j;
	for ( i = MutatorCount - 1; i >= 0; i-=1 )
	{
		if ( Mutators[i] ~= mutator )
		{
			for ( j = i; j < MutatorCount && j < MaxMutatorCount - 1; j = j + 1 )
				Mutators[j] = Mutators[j + 1];
			if ( MutatorCount == MaxMutatorCount ) 
				Mutators[MaxMutatorCount - 1] = "";
			if ( MutatorCount > 0 )
				MutatorCount -= 1;
			return True;
		}
	}
	if ( !bQuiet ) 
	{
		Err("Failed to remove mutator `"$mutator$"`");
	}
	return False;
}

function bool AddActors(string list)
{
	local string actor;
	local bool success;
	success = True;
	list = Aliases.Resolve(list);
	
	while ( class'MV_Parser'.static.TrySplit(list, ",", actor, list) )
		if ( !AddActor(actor) ) 
			success = False;

	return success;
}

function bool AddActor(string actor)
{
	local int i;
	if ( ActorCount >= MaxActors )
	{
		Err("Cannot add `"$actor$"`, max server actor count reached!");
		return False;
	}
	for ( i = 0; i < ActorCount; i++ )
	{
		if ( Actors[i] == actor )
		{
			return False;
		}
	}
	Actors[ActorCount] = actor;
	ActorCount++;
	return True;
}

function bool RemoveActors(string list) 
{
	local string actorstr;
	local bool success;
	success = True;
	list = Aliases.Resolve(list);
	
	while ( class'MV_Parser'.static.TrySplit(list, ",", actorstr, list) )
		if ( !RemoveActor(actorstr) ) 
			success = False;
	
	return success;
}

function bool RemoveActor(string actor) 
{
	local int i,j;
	for ( i = ActorCount - 1; i >= 0; i-=1 )
	{
		if ( Actors[i] ~= actor )
		{
			for ( j = i; j < ActorCount && j < MaxActors - 1; j = j + 1 )
				Actors[j] = Actors[j + 1];
			if ( ActorCount == MaxActors ) 
				Actors[MaxActors - 1] = "";
			if ( ActorCount > 0 )
				ActorCount -= 1;
			return True;
		}
	}
	if ( !bQuiet ) 
	{
		Err("Failed to remove actor `"$actor$"`");
	}
	return False;
}

function bool AddGameSettings(string settingsList)
{
	local string keyvalue;
	local string key;
	local string value;
	local bool success;
	success = True;
	settingsList = Aliases.Resolve(settingsList);
	
	while ( class'MV_Parser'.static.TrySplit(settingsList, ",", keyvalue, settingsList) )
	{
		if ( class'MV_Parser'.static.TrySplit(keyvalue, "=", key, value) )
		{
			if ( !UpdateSingleGameSetting(key, value) ) 
			{
				success = False;
			}
		}
		else 
		{
			Err("Ignoring invalid setting `"$keyvalue$"` from `"$settingsList$"`");
			success = False;
		}
	}

	return success;
}

function bool AddUrlParameters(string params) 
{
	local string param, key, value;
	local int i;
	local bool success;
	success = False;
	params = Aliases.Resolve(params);

	while ( class'MV_Parser'.static.TrySplit(params, "?", param, params) )
	{
		if ( class'MV_Parser'.static.TrySplit(param, "=", key, value) ) 
		{
			for ( i = 0;i < UrlParametersCount;i+=1 ) 
			{
				if ( UrlParametersKey[i] ~= key )
				{
					UrlParametersValue[i] = value;
					goto NEXT_PARAM;
				}
			}
			if ( UrlParametersCount < MaxUrlParameters )
			{
				UrlParametersKey[UrlParametersCount] = key;
				UrlParametersValue[UrlParametersCount] = value;
				UrlParametersCount += 1;
			}
			else 
			{
				Err("Cannot add `"$param$"`, max server actor count reached!");
				return False;
			}
		}
	NEXT_PARAM:
	}
	return success;
}

function string GetUrlParametersString() 
{
	local string result;
	local int i;

	for ( i = 0; i < UrlParametersCount; i+=1 )
	{
		result = result$"?"$UrlParametersKey[i]$"="$UrlParametersValue[i];
	}
	return result;
}

function bool UpdateSingleGameSetting(string key, string value)
{
	local int i;
	for ( i = 0; i < SettingsCount; i += 1 )
	{
		if ( SettingsKey[i] == key ) 
		{
			SettingsValue[i] = value;
			return True;
		}
	}
	if ( SettingsCount > MaxSettings )
	{
		Err("Cannot set `"$key$"` to `"$value$"`, max settings count reached!");
		return False;
	}
	SettingsKey[SettingsCount] = key;
	SettingsValue[SettingsCount] = value;
	SettingsCount++;
	return True;
}

function string GetGameSettingByKey(string key)
{
	local int i;
	for ( i = 0; i < SettingsCount; i += 1 )
	{
		if ( SettingsKey[i] == key )
		{
			return SettingsValue[i];
		}
	}
	return "";
}

function SetGameName(string s)
{
	if ( s == "" ) return;
	GameName = s;
}

function SetRuleName(string s)
{
	if ( s == "" ) return;
	RuleName = s;
}

function SetGameClass(string s)
{
	if ( s == "" ) return;
	GameClass = Aliases.Resolve(s);
}

function SetFilterCode(string s)
{
	if ( s == "" ) return;
	FilterCode = s;
}

function SetTickRate(int t)
{
	if ( t <= 0 ) return;
	TickRate = t;
}

function string GetSongString()
{
	LoadSongInformation();
	return OriginalSong;
}

function string GetIdealPlayerCountString()
{
	local string result;
	result = GetLevelSummaryObject().IdealPlayerCount;
	if ( result == "" ) result = GetLevelInfoObject().IdealPlayerCount;
	return result;
}

function int GetAvgIdealPlayerCount() 
{
	local int dashAt, temp, value, weight;
	local string str;
	str = GetIdealPlayerCountString();
	dashAt = InStr(str, "-");
	value = 0;
	weight = 0;
	if ( dashAt >= 0 ) 
	{
		temp = int(Left(str, dashAt));
		if ( temp > 0 ) 
		{
			value += temp;
			weight += 1;
		}
		temp = int(Mid(str, dashAt + 1));
		if ( temp > 0 ) 
		{
			value += temp;
			weight += 1;
		}
	}
	else 
	{
		temp = int(str);
		if ( temp > 0 ) 
		{
			value += temp;
			weight += 1;
		}
	}
	if ( value > 0 && weight > 0 ) 
	{
		return value / weight;
	}
	else 
	{
		// value not known
		return -1; 
	}
}

function LoadSongInformation()
{
	if ( OriginalSong == "" )
	{
		OriginalSong = ""$GetLevelInfoObject().Song;
	}
}

function bool CanMapBeLoaded()
{
	if ( GetLevelSummaryObject() != None ) 
	{
		return True;
	}
	if ( GetLevelInfoObject() != None ) 
	{
		return True;
	}
	// last resort, probably won't help but hey, we tried
	if ( DynamicLoadObject(Self.Map$".PlayerStart0", class'PlayerStart') != None ) 
	{
		return True;
	}
	return False;
}	

function LevelInfo GetLevelInfoObject()
{
	if ( LevelInfoCached )
	{
		return LevelInfo; 
	}
	LevelInfoCached = True;
	// 1st try
	LevelInfo = LevelInfo(DynamicLoadObject(Self.Map$".LevelInfo0", class'LevelInfo'));
	if ( LevelInfo == None ) 
	{
		// 2nd try
		LevelInfo = LevelInfo(DynamicLoadObject(Self.Map$".LevelInfo1", class'LevelInfo'));
	}
	return LevelInfo;
}

function LevelSummary GetLevelSummaryObject()
{
	if ( LevelSummaryCached )
	{
		return LevelSummary;
	}
	LevelSummaryCached = True;
	LevelSummary = LevelSummary(DynamicLoadObject(Self.Map$".LevelSummary", class'LevelSummary'));
	return LevelSummary;
}

function bool IsDerivedFrom(int idx)
{
	local int i;

	for ( i = 0; i < DerivedCount; i += 1 )
	{
		if ( DerivedFrom[i] == idx )
		{
			return True;
		}
	}
	return False;
}

function AddDerivedFrom(int idx)
{
	DerivedFrom[DerivedCount] = idx;
	DerivedCount += 1;
}