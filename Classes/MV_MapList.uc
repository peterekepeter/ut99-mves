//================================================================================
// MV_MainExtension.
//================================================================================
class MV_MapList expands Info
	config(MVE_MapList);

var MapVote Mutator;
var() config string LastUpdate;

var() config int MapCount;
var() config int iMapList;
var() config string MapList[4096];
var(Debug) string ClientMapList[4096]; //This is what we send
var int iClientMapList; //Current loop position during initial generation
//var() config int LastPlayed[4096]; //Does not affect the string, said properties must be replicated differently to avoid caching
var() config int GameCount;
var() config int iGameC;
var() config string GameNames[63];
var() config string RuleNames[63];
var() config float VotePriority[63];

var string TmpGameName[63];
var() config string RuleList[63];
var() config int iRules;

var(Debug) string TmpCodes[63];
var(Debug) string GameTags[63];
var(Debug) int IsPremade[63];
var(Debug) int FStart[63], FEnd[63];
var(Debug) int EStart[63], EEnd[63];
var(Debug) int iTmpC;

var string MapListString; //Send this over the net!
var MapHistory History;

event PostBeginPlay()
{
	History = new(self) class'MapHistory';	
	History.MapList = self;
}

function SetupClientList()
{
	local int iMapIdx, hMapIdx;
	local int i, j, iOrgIdx;
	local string aStr, eStr;

	iClientMapList = iMapList;

	SELECT_COPY_TARGET:
	While ( i < History.iMe )
	{
		if ( History.IsExcluded(i) )
			Goto FOUND_EXCLUSION;
		i++;
	}

	While ( iMapIdx < iClientMapList )
		ClientMapList[iMapIdx++] = MapList[iOrgIdx++];
	Assert(iOrgIdx == iMapList);
	return;

	FOUND_EXCLUSION:
	hMapIdx = History.MapIdx(i);
//	Log("Processing exclusion at "$i @ hMapIdx);
	While ( iOrgIdx < hMapIdx )
		ClientMapList[iMapIdx++] = MapList[iOrgIdx++];
	aStr = "";
	eStr = ":" $ MapGames( hMapIdx );
	LOOP_EXCLUSION:
	j = InStr( eStr, TwoDigits( History.GameIdx(i)) );
	if ( j > 0 )
	{	
		aStr = aStr $ ":" $ TwoDigits( History.GameIdx(i) );
		eStr = Left( eStr, j-1) $ Mid( eStr, j+2);
	}
	while ( hMapIdx == History.MapIdx(i+1) )
	{
		i++;
		if ( History.IsExcluded(i) )
			Goto LOOP_EXCLUSION;
	}
	if ( eStr == ";" ) //All maps blanked
		ClientMapList[iMapIdx++] = "[X]" $ MapList[ hMapIdx ];
	else if ( aStr == "" )
		ClientMapList[iMapIdx++] = MapList[ hMapIdx ];
	else
	{
		ClientMapList[iMapIdx++] = MapName( hMapIdx) $ eStr;
		ClientMapList[iMapIdx++] = "[X]" $ MapName( hMapIdx) $ aStr $ ";";
		iClientMapList++; //As we split an entry in two, we have to add an entry slot
	}
	iOrgIdx++;
	i++;
	Goto SELECT_COPY_TARGET;
}

//We scan all maps, check if they match our filters
//If no filter exist, go ahead
//Else add to list and find rules that use it
function GlobalLoad()
{
	local string FirstMap, CurMap;
	local int iSeek;
	local string CurFP, CurRules;
	local int i, j, k, iLen;
	local string sTest;
	local bool bAddTag;

	Mutator.CleanRules();
	Mutator.CountFilters();
	if ( Mutator.ServerCodeName == '' )
		Mutator.SetPropertyText("ServerCodeName",string(rand(MaxInt)) $ string(rand(MaxInt))  );
	FirstMap = GetMapName("","",0);
	CurMap = FirstMap;
	CacheCodes();
	MapCount = 0;
	iMapList = 0;
	iSeek = 1;

	//Random!!!
	For ( i=0 ; i<63 ; i++ )
	{
		if ( Mutator.MutatorCode( i) == "" )
			continue;
		if ( Mutator.HasRandom(i) )
			CurRules = CurRules $ ":" $ TwoDigits(i);
	}
	if ( CurRules != "" )
	{
		MapList[iMapList] = "Random" $ CurRules $ ";";
		ClientMapList[ iMapList ] = MapList[ iMapList ];
		iMapList++;
		MapCount += Len(CurRules) / 3;
	}
	Goto START_LOOP;

	CHECK_FINISH:
	if ( CurMap == FirstMap || CurMap == "" )
	{
		Log("CHECKING PREMADE LISTS...");
		For ( i=0 ; i<iTmpC ; i++ )
		{
			iLen = Len( TmpCodes[i]);
			if ( IsPremade[i] > 0 )
				For ( j=FStart[i] ; j<FEnd[i] ; j++ )
				{
					if ( !(Left( Mutator.GetMapFilter(j), iLen) ~= TmpCodes[i]) ) //Check that this IS a filter for this gamemode
						continue;
					MapList[iMapList] = Mid( Mutator.GetMapFilter(j), iLen) $ GameTags[i] $ ";";
					ClientMapList[ iMapList ] = MapList[ iMapList ];
					iMapList++;
					MapCount += Len(GameTags[i]) / 3;
				}
		}
		iClientMapList = iMapList;
		For ( i=iMapList ; i<4096 ; i++ )
			MapList[iMapList] = "";
		Log("MAP LIST GENERATION ENDED, CHECK THE MV_MapList ACTOR");
		EnumerateGames();
		GenerateString();
		//Mutator.Extension.CloseVoteWindows( Mutator.WatcherList);
		Mutator.UpdateMapListCaches();
		SaveConfig();
		History.iMe = 0;
		History.SaveConfig();
		Mutator.BroadcastMessage("Map list has been reloaded, wait 5 seconds to reopen the vote window.",true);
		return;
	}
	START_LOOP:
	CurRules = "";
	For ( i=0 ; i<iTmpC ; i++ ) //Scan what gametypes this map is defined for
	{
		if ( IsPremade[i] > 0 ) //Do not add premade tags
			continue;
		bAddTag = false;
		iLen = Len( TmpCodes[i]);
		For ( j=FStart[i] ; j<FEnd[i] ; j++ )
		{
			if ( !(Left( Mutator.GetMapFilter(j), iLen) ~= TmpCodes[i]) ) //Check that this IS a filter for this gamemode
				continue;
			sTest = Mid( Mutator.GetMapFilter(j), iLen);
			if ( InStr(sTest,"*") < 0 ) //Exact match for map name
				bAddTag = (sTest ~= RemoveExtension(CurMap));
			else
			{
				sTest = Left( sTest, Len(sTest)-1);
				bAddTag = (sTest ~= Left(CurMap, Len(sTest)));
			}
			if ( bAddTag )
				break;
		}
		if ( bAddTag && (EEnd[i] > 0) ) //Apply exclude filter now
		{
			For ( j=EStart[i] ; j<EEnd[i] ; j++ )
			{
				sTest = Mid( Mutator.ExcludeFilters[j], iLen);
				if ( InStr(sTest,"*") < 0 ) //Exact match for map name
					bAddTag = !(sTest ~= RemoveExtension(CurMap));
				else
				{
					sTest = Left( sTest, Len(sTest)-1);
					bAddTag = !(sTest ~= Left(CurMap, Len(sTest)));
				}
				if ( !bAddTag )
					break;
			}
		}
		
		if ( bAddTag )
			CurRules = CurRules $ GameTags[i];
	}
	if ( CurRules != "" )
	{
		MapList[ iMapList ] = RemoveExtension(CurMap) $ CurRules $ ";";
		ClientMapList[ iMapList ] = MapList[ iMapList ];
		iMapList++;
		MapCount += Len(CurRules) / 3;
	}
	CurMap = GetMapName("",FirstMap,iSeek++);
	Goto CHECK_FINISH;
}

//Returns a chunk of the fingerprint
function CacheCodes()
{
	local int i, j, k;
	local string tmpCode;
	local int iMin, iMax, iLen;

	For ( i=0 ; i<Mutator.iGames ; i++ )
	{
		tmpCode = Mutator.MutatorCode(i) $ " ";
		if ( tmpCode != " " )
		{
			For ( j=0 ; j<k ; j++ )
				if ( TmpCodes[j] == tmpCode )
				{
					GameTags[j] = GameTags[j] $ ":" $ TwoDigits(i);
					Goto END_LOOP;
				}
			if ( Left(tmpCode,7) ~= "premade" )
				IsPremade[k] = 1;
			GameTags[k] = ":" $ TwoDigits(i);
			TmpCodes[k++] = tmpCode;
		}
		END_LOOP:
	}

	iTmpC = k;
	if ( Mutator.iFilter == 0 )
		Mutator.CountFilters();

	For ( i=0 ; i<iTmpC ; i++ )
	{
		iLen = Len( TmpCodes[i]);
		k += iLen; //For the fingerprint
		j=0;
		iMin = 0;
		iMax = 0;
		While ( j < Mutator.iFilter )
		{
			if ( Left(Mutator.GetMapFilter(j), iLen) == TmpCodes[i] )
			{
				iMin = j;
				break;
			}
			j++;
		}
		While ( j < Mutator.iFilter ) //First loop of this kind always matches last of previous one
			if ( Left(Mutator.GetMapFilter(j++), iLen) == TmpCodes[i] )
				iMax = j;
		FStart[i] = iMin;
		FEnd[i] = iMax;

		iMin = 0;
		iMax = 0;
		j = 0;
		While ( j < Mutator.iExclF )
		{
			if ( Left(Mutator.ExcludeFilters[j], iLen) == TmpCodes[i] )
			{
				iMin = j;
				break;
			}
			j++;
		}
		While ( j < Mutator.iExclF ) //First loop of this kind always matches last of previous one
			if ( Left(Mutator.ExcludeFilters[j++], iLen) == TmpCodes[i] )
				iMax = j;
		EStart[i] = iMin;
		EEnd[i] = iMax;
	}
}

function EnumerateGames()
{
	local int i, j, k;
	local string TC;
	local float fPri;
	
	iRules = 0;
	GameCount = 0;
	For ( i=0 ; i<Mutator.iGames ; i++ )
	{
		if ( Mutator.MutatorCode(i) != "" )
		{
			TC = Mutator.GameName(i);
			GameNames[i] = TC;
			RuleNames[i] = Mutator.RuleName(i);
			VotePriority[i] = Mutator.VotePriority(i);
			GameCount++;
			iGameC = i+1;
			k += len(TC);
			For ( j=0 ; j<iRules ; j++ )
			{
				if ( TmpGameName[j] ~= TC )
				{
					RuleList[j] = RuleList[j] $ ":" $ TwoDigits(i);
					Goto END_LOOP;
				}
			}
			TmpGameName[iRules] = TC;
			RuleList[iRules++] = ":" $ TwoDigits(i);
		}
		END_LOOP:
	}
	k += iRules;
}

function bool ValidMap( out string MapString)
{
	local string MapName, GameIdx;
	local int i, iLen;
	
	iLen = InStr( MapString, ":");
	if ( iLen <= 0 )
		return false;
	GameIdx = Mid( MapString, iLen+1);
	if ( (GameIdx == "") || (Len(GameIdx) > 2) || (String(int(GameIdx)) != GameIdx) )
		return false; //Make sure it's a valid number
	if ( Len(GameIdx) == 1 )
		GameIdx = "0"$GameIdx;
	MapName = Left( MapString, iLen);
	For ( i=0 ; i<iMapList ; i++ )
		if ( Left(MapList[i], iLen) ~= MapName )
		{
			if ( InStr( Mid(MapList[i],iLen), GameIdx) > 0 )
			{
				MapString = Left(MapList[i], iLen) $ ":" $ GameIdx; //Normalize string for voting stage
				return true;
			}
		}   //REMOVED BREAK, NOW SAME MAP CAN BE IN LIST MULTIPLE TIMES
}

function int FindMap( string MapString, optional int StartingIdx)
{
	local int i, iLen;
	
	iLen = InStr( MapString, ":");
	if ( iLen > 0 )
		MapString = Left( MapString, iLen);
	else
		iLen = Len(MapString);
	For ( i=StartingIdx ; i<iMapList ; i++ )
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
		GameStr = Mid( MapString, iLen+1, 2);
	}
	else
		iLen = Len(MapString);
	For ( i=0 ; i<iMapList ; i++ )
		if ( (Mid(MapList[i], iLen, 1) == ":") && (Left(MapList[i], iLen) ~= MapString) && (InStr(Mid(MapList[i], iLen),GameStr) > 0)  )
			return i;
	return -1;
}


function GenerateString()
{
	local int i, j;
	local string S;

	For ( i=0 ; i<iRules ; i++ )
		MapListString = MapListString $ "RuleList[" $ string(i) $ "]=" $ RuleList[i] $ chr(13);
	For ( i=0 ; i<iGameC ; i++ )
	{
		if ( GameNames[i] != "" )
		{
			j++;
			MapListString = MapListString $ "GameModeName[" $ string(i) $ "]=" $ GameNames[i] $ chr(13)
				$ "RuleName[" $ string(i) $ "]=" $ RuleNames[i] $ chr(13)
				$ "VotePriority[" $ string(i) $ "]=" $ string(VotePriority[i]) $ chr(13);
		}
	}
	GameCount = j; //HACK FIX
	
	For ( i=0 ; i<iClientMapList ; i++ )
		MapListString = MapListString $ "MapList[" $ string(i) $ "]=" $ ClientMapList[i] $ chr(13);

	MapListString = MapListString 
			$ "MapCount=" $ string(MapCount) $ chr(13)
			$ "RuleListCount=" $ string(iRules) $ chr(13)
			$ "RuleCount=" $ string(GameCount) $ chr(13);

	GenerateCode();
}

function GenerateCode()
{
	local int i, iLen;
	local int j, k, n;
	
	iLen = Len(MapListString);
	While ( i < iLen )
	{
		n = Asc(Mid(MapListString,i,1)) * i;
		j += n;
		if ( j < 0 ) //Byte went over 31!
		{
			j = j & MaxInt;
			k++;
		}
		i++;
	}
	LastUpdate = class'MV_MainExtension'.static.NumberToByte(K) $ class'MV_MainExtension'.static.NumberToByte(j);
}

function string GetStringSection( string StartsFrom)
{
	local string Result;
	local int i;
	local bool bNext;

	if ( StartsFrom != "" )
		i = InStr( MapListString, StartsFrom);
	if ( i<0 )
		return "";
	Result = Mid( MapListString, i, 1000 );
	if ( Len(Result) == 1000 )
		bNext = true;
	if ( i != 0 )
		Result = Mid( Result, InStr( Result, chr(13)) + 1); //Trim StartsFrom property, except on first call
	While ( (Len(Result) > 0) && (Right( Result,1) != chr(13)) )
		Result = Left( Result, Len(Result)-1);

	if ( !bNext )
		return "[START]" $ chr(13) $ Result $ "[END]" $ chr(13) $ "[NEXT]" $ chr(13);
	//Notify END of list, add the "[X]" on individual map entries!
	return "[START]" $ chr(13) $ Result $ "[NEXT]" $ chr(13) $ "[END]" $ chr(13);
}

function string RemoveExtension( string aStr)
{
	local string sBase;
	local int i;


	While ( true )
	{
		i = inStr( aStr,".");
		if ( i < 0 )
		{
			if ( sBase == "" )
				return aStr;
			return sBase;
		}
		sBase = Left(aStr,i);
		aStr = Mid( aStr, i+1);
	}
}

function string TwoDigits( int i)
{
	if ( i < 10 )
		return "0"$ string(i);
	return string(i);
}

final function string MapName( int i)
{
	return class'MV_MainExtension'.static.ByDelimiter(MapList[i],":");
}

final function string MapGames( int i)
{
	return Mid(MapList[i], InStr( MapList[i], ":")+1);
}

final function string GetMapList( int i) //FOR PLUGIN USAGE
{
	return ClientMapList[i];
}

final function string SetMapList( int i, string NewStr)
{
	MapList[i] = NewStr;
}

final function bool IsEdited( int i)
{
	return MapList[i] != default.MapList[i];
}

final function int RandomGame( int i)
{
	local int j;
	local string s;
	s = Mid( MapList[i], InStr( MapList[i], ":") );
	j = Len(s) / 3;
	return int( Mid(s, Rand(j)*3 + 1, 2) );
}

final function string RandomMap( int Game)
{
	local int MaxRandom, i, iRandom;
	local string GameString, Result;
	
	GameString = ":" $ TwoDigits( Game);
	MaxRandom = 1;
	For ( i=1 ; i<iMapList ; i++ )
	{
		if ( (InStr( ClientMapList[i], GameString) > 0) && (Left(ClientMapList[i], 3) != "[X]") )
		{
			if ( Rand(MaxRandom++) == 0 )
				Result = ClientMapList[i];
		}
	}
	if ( Result != "" )
		return class'MV_MainExtension'.static.ByDelimiter(Result,":");
	//All maps red?
	MaxRandom = 1;
	For ( i=1 ; i<iMapList ; i++ )
	{
		if ( (InStr( ClientMapList[i], GameString) > 0)  )
		{
			if ( Rand(MaxRandom++) == 0 )
				Result = ClientMapList[i];
		}
	}
	return class'MV_MainExtension'.static.ByDelimiter(Result,":");
}