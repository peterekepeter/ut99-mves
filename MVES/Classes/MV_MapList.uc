//================================================================================
// MV_MapList.
//================================================================================
class MV_MapList expands MV_Util config(MVE_MapList);

var MapVote Mutator; // required input var
const MAX_MAPS = 4096;

var() config string LastUpdate;

var() config int iMapList;
var() config string MapList[4096];
//var() config int LastPlayed[4096]; //Does not affect the string, said properties must be replicated differently to avoid caching
var() config int GameCount;
var() config int iGameC;
var() config string GameNames[100];
var() config string RuleNames[ArrayCount(GameNames)];
var() config float VotePriority[ArrayCount(GameNames)];

var string TmpGameName[ArrayCount(GameNames)];
var() config string RuleList[ArrayCount(GameNames)];
var() config int iRules;

var(Debug) string TmpCodes[ArrayCount(GameNames)];
var(Debug) string GameTags[ArrayCount(GameNames)];
var(Debug) int IsPremade[ArrayCount(GameNames)];
var(Debug) int FStart[ArrayCount(GameNames)], FEnd[ArrayCount(GameNames)];
var(Debug) int EStart[ArrayCount(GameNames)], EEnd[ArrayCount(GameNames)];
var(Debug) int iTmpC;

var config int iNewMaps[32], iM;
var config string sNewMaps[32];
var config string M[16384];

var string MapListString; //Send this over the net!
var MapHistory History;
var FsMapsReader Reader;

event PostBeginPlay()
{
	History = new(Self) class'MapHistory';	
	History.MapList = Self;
}

//We scan all maps, check if they match our filters
//If no filter exist, go ahead
//Else add to list and find rules that use it
function GlobalLoad(bool bFullscan)
{
	local string CurMap, CurMapWithoutExtension, ClearMap, NewMaps, Maps[16384];
	local string CurFP, CurRules, PrevRules;
	local int i, j, k, iLen, iMaps, firstHas, prevAdded;
	local string sTest;
	local bool bAddTag;
	local MV_MapTags MapTags;
	local MV_Sort sorter;

	if ( Mutator.bEnableMapTags )
	{
		MapTags = GetMapTagsObject();
	}

	Mutator.CleanRules();
	Mutator.CountFilters();
	if ( Mutator.ServerCodeName == '' )
		Mutator.SetPropertyText("ServerCodeName",string(rand(MaxInt))$string(rand(MaxInt))  );
	CacheCodes();
	iMapList = 0;

	// collect game names that have random enabled into CurRules string
      
	for ( i = 0 ; i < ArrayCount(GameNames) ; i ++ )
	{
		if ( Mutator.MutatorCode( i) == "" )
		{
			continue;
		}
		if ( Mutator.HasRandom(i) ) 
		{
			CurRules = CurRules$":"$TwoDigits(i);
		}
	}

	if ( CurRules != "" )
	{
		MapList[iMapList] = "Random"$CurRules$";";
		iMapList ++ ;
		PrevRules = CurRules;
	}

	DetectAliasErrors();
	
	Log("[MVE] Reloading map list, this may take a while!");
	Reader.Reset();
	sorter = new class'MV_Sort';

	do
	{
		CurMap = Reader.GetMap();
		
		if ( bFullscan )
		{
			if ( TestIfMapCanBeLoaded(CurMap) == False )
			{
				Log("[MVE] Scan `"$CurMap$"`: FAILED TO LOAD!!!!!! < check map/packages for errors");
			}
			else 
			{
				Log("[MVE] Scan `"$CurMap$"`: OK!");
			}
		}

		sorter.AddItem(CurMap);
            
		if ( sorter.ItemCount >= 4095 )
		{
			Log("[MVE] Map limit reached with `"$CurMap$"`");
			break;
		}
	}
	until (Reader.MoveNext());
      
	if ( Mutator.bSortAndDeduplicateMaps )
	{
		Log("[MVE] Sorting and removing duplicate maps");

		sorter.SortAndDeduplicate();

		if ( sorter.DuplicatesRemoved > 0 )
		{
			Log("[MVE] "$sorter.DuplicatesRemoved$" duplicates found and removed");
		}
	}
	

	Log("[MVE] Matching maps with filters");
	for ( k = 0; k < sorter.ItemCount; k += 1 )
	{
		CurMap = sorter.Items[k];
            // Log("[MVE] processing map "$CurMap);
		CurMapWithoutExtension = RemoveExtension(CurMap);
		CurRules = "";
		for ( i = 0 ; i < iTmpC ; i ++ ) //Scan what gametypes this map is defined for
		{
			if ( IsPremade[i] > 0 ) //Do not add premade tags
				continue;
			bAddTag = False;
			iLen = Len( TmpCodes[i]);
			for ( j = FStart[i] ; j < FEnd[i] ; j ++ )
			{
				if ( ! (Left( Mutator.GetMapFilter(j), iLen) ~= TmpCodes[i]) ) //Check that this IS a filter for this gamemode
					continue;
				sTest = Mid( Mutator.GetMapFilter(j), iLen);
				if ( Mutator.bEnableMapTags && InStr(sTest, ":") == 0 ) //Tag match
					bAddTag = MapTags.TestTagMatch(CurMapWithoutExtension, sTest);
				else if ( InStr(sTest,"*") < 0 ) //Exact match for map name
					bAddTag = (sTest ~= CurMapWithoutExtension);
				else
				{
					sTest = Left( sTest, Len(sTest) -1);
					bAddTag = (sTest ~= Left(CurMap, Len(sTest)));
				}
				if ( bAddTag )
					break;
			}
			if ( bAddTag && (EEnd[i] > 0) ) //Apply exclude filter now
			{
				for ( j = EStart[i] ; j < EEnd[i] ; j ++ )
				{
					sTest = Mid( Mutator.ExcludeFilters[j], iLen);
					if ( Mutator.bEnableMapTags && InStr(sTest, ":") == 0 ) //Tag match
						bAddTag = !MapTags.TestTagMatch(CurMapWithoutExtension, sTest);
					else if ( InStr(sTest,"*") < 0 ) //Exact match for map name
						bAddTag = ! (sTest ~= CurMapWithoutExtension);
					else
					{
						sTest = Left( sTest, Len(sTest) -1);
						bAddTag = ! (sTest ~= Left(CurMap, Len(sTest)));
					}
					if ( !bAddTag )
						break;
				}
			}
			
			if ( bAddTag )
				CurRules = CurRules$GameTags[i];
		}
		if ( CurRules != "" )
		{
			// add map to maplist
			ClearMap = CurMapWithoutExtension;
			Maps[ iMaps ++ ] = ClearMap;
			if ( CurRules == PrevRules )
			{
				MapList[ iMapList ] = ClearMap$";";
			}
			else 
			{
				MapList[ iMapList ] = ClearMap$CurRules$";";
			}
			iMapList ++ ;
			PrevRules = CurRules;
		}
	}
		
	Log("[MVE] Remove old + add new maps...");
	NewMaps = ":";
	for ( i = 0; i < iMaps; i ++ )
		NewMaps = NewMaps$Maps[i]$":";	

	ClearMap = ":";
	j = 0;
	for ( i = 0; i < iM; i ++ ) 
	{
		if ( InStr(NewMaps, ":"$M[i]$":") != -1 ) 
		{
			ClearMap = ClearMap$M[i]$":";
			if ( i != j )
				M[j] = M[i];
			j ++ ;
		}			
	}
	NewMaps = "";
	
	for ( i = 0; i < iMaps; i ++ ) 
	{
		if ( InStr(ClearMap, ":"$Maps[i]$":") == -1 )
			M[j ++ ] = Maps[i];
	}
	iM = j;
	for ( i = j ; i < ArrayCount(M) ; i ++ )
		M[i] = "";
		
	ClearMap = ":";
	for ( i = 0; i < iMapList; i ++ )
		ClearMap = ClearMap$Left(MapList[i], InStr(MapList[i], ":"))$":"$i$":";	
	
	for ( j = 0; j < ArrayCount(iNewMaps) && iM - j > 0; j ++ ) 
	{
		NewMaps = M[iM - j - 1];
		k = InStr(ClearMap, ":"$NewMaps$":");
		if ( k == -1 ) 
		{
			iNewMaps[j] = 0;
			sNewMaps[j] = "";
		} 
		else 
		{
			iNewMaps[j] = int(Mid(ClearMap, k + 2 + Len(NewMaps), 4));
			sNewMaps[j] = NewMaps;
		}
	}
	
	Log("[MVE] Checking premade lists...");
	for ( i = 0 ; i < iTmpC ; i ++ )
	{
		iLen = Len( TmpCodes[i]);
		if ( IsPremade[i] > 0 )
		{
			for ( j = FStart[i] ; j < FEnd[i] ; j ++ )
			{
				//Check that this IS a filter for this gamemode
				if ( ! (Left( Mutator.GetMapFilter(j), iLen) ~= TmpCodes[i]) ) 
				{
					continue;
				}
				MapList[iMapList] = Mid( Mutator.GetMapFilter(j), iLen)$GameTags[i]$";";
				iMapList ++ ;
			}
		}
	}

      // clear the rest
	for ( i = iMapList ; i < MAX_MAPS ; i ++ )
	{
		MapList[i] = "";
	}

	// reload report 
	Log("[MVE] Reloaded "$iMaps$" maps matched to "$iTmpC$" gametypes from "$(Reader.GetMapCount())$" scanned maps.");
	if ( iMaps == 0 ) 
	{
		Log("[MVE]");
		Log("[MVE] [ERROR] No maps were loaded!");
		Log("[MVE]");
		if ( iTmpC <= 0 )
		{
			Log("[MVE] [ERROR] No gametypes were detected!");
			Log("[MVE]");
			Log("[MVE] -> enable gametypes with `bEnabled=True`");
			Log("[MVE] -> make sure the gametype's VotePriority > 0");
			Log("[MVE] -> the gametype's GameClass, GameName, RuleName must not be empty");
			Log("[MVE]");
		}
		else if (iMaps <= 0) 
		{
			Log("[MVE] [ERROR] No maps were matched by filters!");
			Log("[MVE]");
			Log("[MVE] -> each gametype should have a FilterCode");
			Log("[MVE] -> FilterCode should have at least 1 MapFilters rule (can have multiple)");
			Log("[MVE] -> if you use ExcludeFilters make sure it doesn't exclude all maps");
			Log("[MVE] -> if you're using MapTags you will need 1 MapTags entry for each map");
			Log("[MVE] -> if you're using premade lists you need 1 MapFilters entry for each map");
			Log("[MVE]");
		}
		// CustomGame[i].bEnabled && (CustomGame[i].GameClass != "") && (CustomGame[i].GameName != "") && (CustomGame[i].RuleName != "") && (CustomGame[i].VotePriority > 0) 
	}
	if ( Reader.GetMapCount() <= 10 )
	{
		Log("[MVE]");
		Log("[MVE] [WARNING] Unusually low number of maps were found on filesystem!");
		Log("[MVE]");
		Log("[MVE] -> make sure you have maps in your map folders");
		Log("[MVE] -> verify map folders is are added to Paths `Paths=../Maps/*.unr`");
		Log("[MVE]");
	}

	EnumerateGames();
	GenerateString();
	//Mutator.Extension.CloseVoteWindows( Mutator.WatcherList);
	Mutator.UpdateMapListCaches();
	SaveConfig();
	Mutator.BroadcastMessage("[MVE] Map list has been reloaded, wait 5 seconds to reopen the vote window.",True);
}

function DetectAliasErrors()
{
	local string errorMessage;

	Mutator.LoadAliases();
	while ( Mutator.AliasesLogic.DetectConfigurationError(errorMessage) ) 
	{
		Err(errorMessage);
	}
}

//Returns a chunk of the fingerprint
function CacheCodes()
{
	local int i, j, k;
	local string tmpCode;
	local int iMin, iMax, iLen;

	for ( i = 0 ; i < Mutator.iGames ; i ++ )
	{
		tmpCode = Mutator.MutatorCode(i)$" ";
		if ( tmpCode != " " )
		{
			for ( j = 0 ; j < k ; j ++ )
				if ( TmpCodes[j] == tmpCode )
				{
					GameTags[j] = GameTags[j]$":"$TwoDigits(i);
					goto END_LOOP;
				}
			if ( Left(tmpCode,7) ~= "premade" )
				IsPremade[k] = 1;
			GameTags[k] = ":"$TwoDigits(i);
			TmpCodes[k ++ ] = tmpCode;
		}
		END_LOOP:
	}

	iTmpC = k;
	if ( Mutator.iFilter == 0 )
		Mutator.CountFilters();

	for ( i = 0 ; i < iTmpC ; i ++ )
	{
		iLen = Len( TmpCodes[i]);
		k += iLen; //For the fingerprint
		j = 0;
		iMin = 0;
		iMax = 0;
		while ( j < Mutator.iFilter )
		{
			if ( Left(Mutator.GetMapFilter(j), iLen) == TmpCodes[i] )
			{
				iMin = j;
				break;
			}
			j ++ ;
		}
		while ( j < Mutator.iFilter ) //First loop of this kind always matches last of previous one
			if ( Left(Mutator.GetMapFilter(j ++ ), iLen) == TmpCodes[i] )
				iMax = j;
		FStart[i] = iMin;
		FEnd[i] = iMax;

		iMin = 0;
		iMax = 0;
		j = 0;
		while ( j < Mutator.iExclF )
		{
			if ( Left(Mutator.ExcludeFilters[j], iLen) == TmpCodes[i] )
			{
				iMin = j;
				break;
			}
			j ++ ;
		}
		while ( j < Mutator.iExclF ) //First loop of this kind always matches last of previous one
			if ( Left(Mutator.ExcludeFilters[j ++ ], iLen) == TmpCodes[i] )
				iMax = j;
		EStart[i] = iMin;
		EEnd[i] = iMax;
	}
}

function EnumerateGames()
{
	local int i, j;
	local string gameName;
	local float fPri;
	local bool found;
	
	iRules = 0;
	GameCount = 0;
	for ( i = 0 ; i < Mutator.iGames ; i ++ )
	{
		if ( Mutator.MutatorCode(i) != "" )
		{
			gameName = Mutator.GameName(i);
			GameNames[i] = gameName;
			RuleNames[i] = Mutator.RuleName(i);
			VotePriority[i] = Mutator.VotePriority(i);
			GameCount ++ ;
			iGameC = i + 1;
			found = False;
			for ( j = 0 ; j < iRules ; j ++ )
			{
				if ( TmpGameName[j] ~= gameName )
				{
					// add to existing rule from RuleList
					RuleList[j] = RuleList[j]$":"$TwoDigits(i);
					found = True;
				}
			}
			if ( !found )
			{
				// add new entry into RuleList
				TmpGameName[iRules] = gameName;
				RuleList[iRules] = ":"$TwoDigits(i);
				iRules ++ ;
			}
		}
	}
}

function bool IsValidMap( out string MapString, out string reason )
{
	local string MapName, GameIdx, targetIdxList;
	local int i, iLen, colonAt;
	local bool bMapFound;
	
	reason = "";
	iLen = InStr( MapString, ":");
	if ( iLen <= 0 )
	{
		reason = "missing gametype code";
		return False;
	}
	GameIdx = Mid( MapString, iLen + 1);
	if ( (GameIdx == "") || (Len(GameIdx) > 2) || (String(int(GameIdx)) != GameIdx) )
	{
		reason = "gametype code not a number";
		return False;
	}
	if ( Len(GameIdx) == 1 )
	{
		GameIdx = "0"$GameIdx;
	}
	MapName = Left( MapString, iLen);

	if ( History.IsExcluded(MapName) )
	{
		reason = "map is on cooldown";
		return False;
	}

	// find map in list 
	bMapFound = False;
	for ( i = 0 ; i < iMapList ; i ++ )
	{
		// use the gametype list of previous list item where it is defined
		colonAt = InStr(MapList[i], ":");
		if ( colonAt != -1 ) 
		{
			targetIdxList = Mid(MapList[i], colonAt);
		}
		
		// TODO ensure map name match is exact (map name that starts with another might match)
		if ( Left(MapList[i], iLen) ~= MapName )
		{
			bMapFound = True;
			if ( InStr( targetIdxList, GameIdx ) > 0 )
			{
				// found!
				// normalize string for voting stage
				MapString = Left(MapList[i], iLen)$":"$GameIdx; 
				// TODO check if map on coldown
				// TODO check if map in crashed state
				return True;
			}
			//REMOVED BREAK, NOW SAME MAP CAN BE IN LIST MULTIPLE TIMES
			// TODO code can be simplified if we can ensure that each map is only listed once
		}   
	}

	// map string not valid but return a relevant reason
	if ( bMapFound )
	{
		reason = "map found but it did not have the requested gametype";
		return False;
	}
	else 
	{
		reason = "map not found";
		return False;
	}
}

function int FindMap( string MapString, optional int StartingIdx)
{
	local int i, iLen;
	
	iLen = InStr( MapString, ":");
	if ( iLen > 0 )
		MapString = Left( MapString, iLen);
	else
		iLen = Len(MapString);
	for ( i = StartingIdx ; i < iMapList ; i ++ )
		if ( (Mid(MapList[i], iLen, 1) == ":") && (Left(MapList[i], iLen) ~= MapString) )
			return i;
	return -1;
}

function int FindMapWithGame( string MapString, optional int GameIdx)
{
	local int i, iLen;
	local string GameStr;
	
	GameStr = TwoDigits(GameIdx);
	iLen = InStr( MapString, ":");
	if ( iLen > 0 )
	{
		MapString = Left( MapString, iLen);
		GameStr = Mid( MapString, iLen + 1, 2);
	}
	else
		iLen = Len(MapString);
	for ( i = 0 ; i < iMapList ; i ++ )
		if ( (Mid(MapList[i], iLen, 1) == ":") && (Left(MapList[i], iLen) ~= MapString) && (InStr(Mid(MapList[i], iLen),GameStr) > 0)  )
			return i;
	return -1;
}


function GenerateString()
{
	local int i, j;
	local string S;

	for ( i = 0 ; i < iRules ; i ++ )
		MapListString = MapListString$"RuleList["$string(i)$"]="$RuleList[i]$chr(13);
	for ( i = 0 ; i < iGameC ; i ++ )
	{
		if ( GameNames[i] != "" )
		{
			j ++ ;
			MapListString = MapListString$"GameModeName["$string(i)$"]="$GameNames[i]$chr(13)
				$"RuleName["$string(i)$"]="$RuleNames[i]$chr(13)
				$"VotePriority["$string(i)$"]="$string(VotePriority[i])$chr(13);
		}
	}
	GameCount = j; //HACK FIX
	
	for ( i = 0 ; i < iMapList ; i ++ )
		MapListString = MapListString$"MapList["$string(i)$"]="$MapList[i]$chr(13);

	MapListString = MapListString 
		$"MapCount="$string(iMapList)$chr(13)
		$"RuleListCount="$string(iRules)$chr(13)
		$"RuleCount="$string(GameCount)$chr(13);

	GenerateCode();
}

function GenerateCode()
{
	local int i, iLen;
	local int j, k, n;
	
	iLen = Len(MapListString);
	while ( i < iLen )
	{
		n = Asc(Mid(MapListString,i,1)) * i;
		j += n;
		if ( j < 0 ) //Byte went over 31!
		{
			j = j & MaxInt;
			k ++ ;
		}
		i ++ ;
	}
	LastUpdate = class'MV_MainExtension'.static.NumberToByte(K)$class'MV_MainExtension'.static.NumberToByte(j);
}

function string GetStringSection( string StartsFrom)
{
	local string Result;
	local int i;
	local bool bNext;

	if ( StartsFrom != "" )
		i = InStr( MapListString, StartsFrom);
	if ( i < 0 )
		return "";
	Result = Mid( MapListString, i, 1000 );
	if ( Len(Result) == 1000 )
		bNext = True;
	if ( i != 0 )
		Result = Mid( Result, InStr( Result, chr(13)) + 1); //Trim StartsFrom property, except on first call
	while ( (Len(Result) > 0) && (Right( Result,1) != chr(13)) )
		Result = Left( Result, Len(Result) -1);

	if ( !bNext )
		return "[START]"$chr(13)$Result$"[END]"$chr(13)$"[NEXT]"$chr(13);
	//Notify END of list, add the "[X]" on individual map entries!
	return "[START]"$chr(13)$Result$"[NEXT]"$chr(13)$"[END]"$chr(13);
}

function string RemoveExtension( string aStr)
{
	local string sBase;
	local int i;


	while ( True )
	{
		i = inStr( aStr,".");
		if ( i < 0 )
		{
			if ( sBase == "" )
				return aStr;
			return sBase;
		}
		sBase = Left(aStr,i);
		aStr = Mid( aStr, i + 1);
	}
}

function string TwoDigits( int i)
{
	if ( i < 10 )
		return "0"$string(i);
	return string(i);
}

final function string MapGames( int i)
{
	return Mid(MapList[i], InStr( MapList[i], ":") + 1);
}

final function string GetMapList( int i) //FOR PLUGIN USAGE
{
	return MapList[i];
}

final function int GetMapListCount()
{
	return iMapList;
}

final function string SetMapList( int i, string NewStr)
{
	MapList[i] = NewStr;
}

final function bool IsEdited( int i)
{
	return MapList[i] != default.MapList[i];
}

final function string RandomMap( int gameIdx, int forPlayerCount )
{
	local MapListDecoder decoder;
	local int i, j, code;
	local string result;
	local string options[4096];
	local string bestResult;
	local string levelString;
	local MV_Result map;
	local int bestScore, resultScore;
	local int count, idealPlayers, delta;

	decoder = new class'MapListDecoder';
	count = 0;

	for ( i = 0; i < iMapList; i+=1 )
	{
		decoder.L[i] = MapList[i];
		while ( decoder.ReadEntry(result) ) 
		{
			while ( decoder.ReadCode(code) ) 
			{
				if ( code == gameIdx ) 
				{
					options[count] = result;
					count += 1;
					continue;
				}
			}
		}
	}

	levelString = ""$decoder;
	decoder.Parse(levelString, ".", levelString);
	bestScore = -1000;
	for ( i = 0; i < 10; i += 1 ) 
	{
		result = options[(Rand(count) + gameIdx * 7 + count * 13) % count];
		resultScore = 0;
		map = class'MV_Result'.static.Create(result, gameIdx);
		if ( result ~= "Random" ) 
		{
			resultScore -= 100;
		}
		else if (!map.CanMapBeLoaded())
		{
			resultScore -= 100;
		}
		else if (forPlayerCount >= 0)
		{
			idealPlayers = map.GetAvgIdealPlayerCount();
			if ( idealPlayers >= 0 ) 
			{
				delta = forPlayerCount - idealPlayers;
				if ( delta < 0 )
				{
					delta = -delta;
				}
				resultScore += 32 - delta;
			}
		}
		if ( result ~= levelString ) resultScore -= 10;
		if ( bestScore <= resultScore ) 
		{
			bestResult = result;
			bestScore = resultScore;
		}
	}
	return bestResult;
}

final simulated function float GetVotePriority( int Idx)
{
	return VotePriority[Idx];
}

function MV_MapTags GetMapTagsObject()
{
	return (new class'MapTagsConfig').GetConfiguredMapTags();
}

function bool TestIfMapCanBeLoaded(string mapName) 
{
	return class'MV_Result'.static.Create(mapName).CanMapBeLoaded();
}

