class MV_MapFilter extends MV_Util config(MVE_MapList);

var bool bEnableMapTags;


var int M_iGames;
var string M_MapFilters[1024], M_ExcludeFilters[32];
var int M_iFilter, M_iExclF;
var string M_GameCode[100];
var byte M_GameHasRandom[100];
var string TmpCodes[ArrayCount(M_GameCode)];
var string GameTags[ArrayCount(M_GameCode)];
var int IsPremade[ArrayCount(M_GameCode)];
var int FStart[ArrayCount(M_GameCode)], FEnd[ArrayCount(M_GameCode)];
var int EStart[ArrayCount(M_GameCode)], EEnd[ArrayCount(M_GameCode)];
var int iTmpC;

// output
var int iMapList;
var string MapList[4096];

function ApplyFilterLists(MV_Sort sorter) 
{
	local string CurMap, CurMapWithoutExtension, ClearMap;
	local string CurRules, PrevRules;
	local int i, j, k, iLen;
	local string sTest;
	local bool bAddTag;
	local MV_MapTags MapTags;

	iMapList = 0;
	CacheCodes();

	// collect game names that have random enabled into CurRules string
	for ( i = 0 ; i < ArrayCount(M_GameCode) ; i++ )
	{
		if ( M_GameCode[i] == "" )
			continue;
		if ( M_GameHasRandom[i] == 1 ) 
			CurRules = CurRules$":"$TwoDigits(i);
	}

	// add random at the top of list
	if ( CurRules != "" )
	{
		MapList[iMapList] = "Random"$CurRules$";";
		iMapList++;
		PrevRules = CurRules;
	}

	if ( bEnableMapTags )
	{
		MapTags = GetMapTagsObject();
	}

	for ( k = 0; k < sorter.ItemCount; k += 1 )
	{
		CurMap = sorter.Items[k];
		CurMapWithoutExtension = RemoveExtension(CurMap);
		CurRules = "";
		for ( i = 0 ; i < iTmpC ; i++ ) //Scan what gametypes this map is defined for
		{
			if ( IsPremade[i] > 0 ) // Do not add premade tags to preserve premade order
				continue;
			bAddTag = False;
			iLen = Len( TmpCodes[i]);
			for ( j = FStart[i] ; j < FEnd[i] ; j++ )
			{
				if ( !(Left( M_MapFilters[j], iLen) ~= TmpCodes[i]) ) //Check that this IS a filter for this gamemode
					continue;
				sTest = Mid( M_MapFilters[j], iLen);
				if ( bEnableMapTags && InStr(sTest, ":") == 0 ) //Tag match
					bAddTag = MapTags.TestTagMatch(CurMapWithoutExtension, sTest);
				else if ( InStr(sTest,"*") < 0 ) //Exact match for map name
					bAddTag = (sTest ~= CurMapWithoutExtension);
				else
				{
					sTest = Left( sTest, Len(sTest) - 1);
					bAddTag = (sTest ~= Left(CurMap, Len(sTest)));
				}
				if ( bAddTag )
					break;
			}
			if ( bAddTag && (EEnd[i] > 0) ) //Apply exclude filter now
			{
				for ( j = EStart[i] ; j < EEnd[i] ; j++ )
				{
					sTest = Mid( M_ExcludeFilters[j], iLen);
					if ( bEnableMapTags && InStr(sTest, ":") == 0 ) //Tag match
						bAddTag = !MapTags.TestTagMatch(CurMapWithoutExtension, sTest);
					else if ( InStr(sTest,"*") < 0 ) //Exact match for map name
						bAddTag = !(sTest ~= CurMapWithoutExtension);
					else
					{
						sTest = Left( sTest, Len(sTest) - 1);
						bAddTag = !(sTest ~= Left(CurMap, Len(sTest)));
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
			if ( CurRules == PrevRules )
			{
				MapList[ iMapList ] = ClearMap$";";
			}
			else 
			{
				MapList[ iMapList ] = ClearMap$CurRules$";";
			}
			iMapList++;
			PrevRules = CurRules;
		}
	}

	Log("[MVE] Checking premade lists...");
	for ( i = 0 ; i < iTmpC ; i++ )
	{
		iLen = Len( TmpCodes[i]);
		if ( IsPremade[i] > 0 )
		{
			for ( j = FStart[i] ; j < FEnd[i] ; j++ )
			{
				//Check that this IS a filter for this gamemode
				if ( !(Left( M_MapFilters[j], iLen) ~= TmpCodes[i]) ) 
				{
					continue;
				}
				MapList[iMapList] = Mid( M_MapFilters[j], iLen)$GameTags[i]$";";
				iMapList++;
			}
		}
	}

	// clear the rest
	for ( i = iMapList ; i < ArrayCount(MapList) ; i++ )
	{
		MapList[i] = "";
	}
}

//Returns a chunk of the fingerprint
function CacheCodes()
{
	local int i, j, k;
	local string tmpCode;
	local int iMin, iMax, iLen;

	for ( i = 0 ; i < M_iGames ; i++ )
	{
		tmpCode = M_GameCode[i]$" ";
		if ( tmpCode != " " )
		{
			for ( j = 0 ; j < k ; j++ )
				if ( TmpCodes[j] == tmpCode )
				{
					GameTags[j] = GameTags[j]$":"$TwoDigits(i);
					goto END_LOOP;
				}
			if ( Left(tmpCode,7) ~= "premade" )
				IsPremade[k] = 1;
			GameTags[k] = ":"$TwoDigits(i);
			TmpCodes[k++] = tmpCode;
		}
	END_LOOP:
	}

	iTmpC = k;

	for ( i = 0 ; i < iTmpC ; i++ )
	{
		iLen = Len( TmpCodes[i]);
		k += iLen; //For the fingerprint
		j = 0;
		iMin = 0;
		iMax = 0;
		while ( j < M_iFilter )
		{
			if ( Left(M_MapFilters[j], iLen) == TmpCodes[i] )
			{
				iMin = j;
				break;
			}
			j++;
		}
		while ( j < M_iFilter ) //First loop of this kind always matches last of previous one
			if ( Left(M_MapFilters[j++], iLen) == TmpCodes[i] )
				iMax = j;
		FStart[i] = iMin;
		FEnd[i] = iMax;

		iMin = 0;
		iMax = 0;
		j = 0;
		while ( j < M_iExclF )
		{
			if ( Left(M_ExcludeFilters[j], iLen) == TmpCodes[i] )
			{
				iMin = j;
				break;
			}
			j++;
		}
		while ( j < M_iExclF ) //First loop of this kind always matches last of previous one
			if ( Left(M_ExcludeFilters[j++], iLen) == TmpCodes[i] )
				iMax = j;
		EStart[i] = iMin;
		EEnd[i] = iMax;
	}
}

function string TwoDigits( int i)
{
	if ( i < 10 )
		return "0"$string(i);
	return string(i);
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

function MV_MapTags GetMapTagsObject()
{
	return (new class'MapTagsConfig').GetConfiguredMapTags();
}
