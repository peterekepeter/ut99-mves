//=============================================================================
// MV_SubExtension.
//=============================================================================
class MV_SubExtension expands MV_MainExtension;

function PlayersToWindow( Info MapVoteWRI)
{
	local MVPlayerWatcher W;
	local string aStr;
	local MapVoteWRI MV;
	local int i;

	MV = MapVoteWRI( MapVoteWRI);
	
	for ( W = MapVote(Outer).WatcherList ; W != None ; W = W.nextWatcher )
		if ( W.PlayerID != "" )
		{
			aStr = WTeamCode(W.Watched)$W.PlayerID$W.Watched.PlayerReplicationInfo.PlayerName;
			if ( W.PlayerVote != "" )
				aStr = aStr$"&?&!&";
			MV.PlayerName[i ++ ] = aStr;
		}
}

function Info SpawnVoteWRIActor( PlayerPawn Victim)
{
	local MapVoteWRI MVWRI;
	local MapVote Mutator;
	local int i;

	Mutator = MapVote(Outer);
	MVWRI = Victim.Spawn( class'MapVoteWRI', Victim,,vect(0,0,0));
	MVWRI.bFixNetNews = Mutator.bFixNetNewsForPlayers;

	for ( i = 0 ; i < Mutator.iMapVotes ; i ++ )
		MVWRI.MapVoteResults[i] = Mutator.StrMapVotes[i];
	for ( i = 0 ; i < Mutator.iKickVotes ; i ++ )
		MVWRI.KickVoteResults[i] = Mutator.StrKickVotes[i];
	return MVWRI;
}

function MLC_Rules( Info MapListCacheActor)
{
	local MV_MapList MapList;
	local MapListCache MLC;
	local int i;

	MapList = MapVote(Outer).MapList;
	MLC = MapListCache(MapListCacheActor);

	MLC.RuleCount = MapList.GameCount;
	MLC.MapCount = MapList.iMapList;
	MLC.RuleListCount = MapList.iRules;
	for ( i = 0 ; i < MapList.iGameC ; i ++ )
	{
		MLC.GameModeName[i] = MapList.GameNames[i];
		MLC.RuleName[i] = MapList.RuleNames[i];
		MLC.SetVotePriority(i, MapList.GetVotePriority(i));
		// Log("copy MapList.GameNames["$i$"] "$MapList.GameNames[i]);
		// Log("copy MapList.RuleNames["$i$"] "$MapList.RuleNames[i]);
		// Log("copy MapList.GetVotePriority("$i$") "$MapList.GetVotePriority(i));
	}
	for ( i = 0 ; i < MapList.iRules ; i ++ )
	{
		MLC.RuleList[i] = MapList.RuleList[i];
		// Log("copy MapList.RuleList[i"$i$"] "$MapList.RuleList[i]);
	}

	for ( i = 0; i < ArrayCount(MLC.iNewMaps); i++ )
	{
		// FEATURE IS DISABLED
		MLC.iNewMaps[i] = 0;
		// Log("copy MapList.iNewMaps["$i$"] "$MapList.iNewMaps[i]);
	}
}


function MLC_MapList_1( Info MapListCacheActor)
{
	local MV_MapList MapList;	local MapListCache MLC;	local int i, k, l;
	MapList = MapVote(Outer).MapList;
	MLC = MapListCache(MapListCacheActor);
	l = 0;
	k = MapList.GetMapListCount() -l;
	if ( k > 256 ) k = 256;
	for ( i = 0 ; i < k ; i ++ )		MLC.MapList1[ i ] = MapList.GetMapList( i + l );
	// For ( i=0 ; i<k ; i++ )		Log("copy MLC.MapList1["$i$"] "$MLC.MapList1[ i ]);
}

function MLC_MapList_2( Info MapListCacheActor)
{
	local MV_MapList MapList;	local MapListCache MLC;	local int i, k, l;
	MapList = MapVote(Outer).MapList;
	MLC = MapListCache(MapListCacheActor);
	l = 256;
	k = MapList.GetMapListCount() -l;
	if ( k > 256 ) k = 256;
	for ( i = 0 ; i < k ; i ++ )		MLC.MapList2[ i ] = MapList.GetMapList( i + l );
	// For ( i=0 ; i<k ; i++ )		Log("copy MLC.MapList2["$i$"] "$MLC.MapList2[ i ]);
}

function MLC_MapList_3( Info MapListCacheActor)
{
	local MV_MapList MapList;	local MapListCache MLC;	local int i, k, l;
	MapList = MapVote(Outer).MapList;
	MLC = MapListCache(MapListCacheActor);
	l = 512;
	k = MapList.GetMapListCount() -l;
	if ( k > 256 ) k = 256;
	for ( i = 0 ; i < k ; i ++ )		MLC.MapList3[ i ] = MapList.GetMapList( i + l );
	// For ( i=0 ; i<k ; i++ )		Log("copy MLC.MapList3["$i$"] "$MLC.MapList3[ i ]);
}

function MLC_MapList_4( Info MapListCacheActor)
{
	local MV_MapList MapList;	local MapListCache MLC;	local int i, k, l;
	MapList = MapVote(Outer).MapList;
	MLC = MapListCache(MapListCacheActor);
	l = 768;
	k = MapList.GetMapListCount() -l;
	if ( k > 256 ) k = 256;
	for ( i = 0 ; i < k ; i ++ )		MLC.MapList4[ i ] = MapList.GetMapList( i + l );
	// For ( i=0 ; i<k ; i++ )		Log("copy MLC.MapList4["$i$"] "$MLC.MapList4[ i ]);
}

function MLC_MapList_5( Info MapListCacheActor)
{
	local MV_MapList MapList;	local MapListCache MLC;	local int i, k, l;
	MapList = MapVote(Outer).MapList;
	MLC = MapListCache(MapListCacheActor);
	l = 1024;
	k = MapList.GetMapListCount() -l;
	if ( k > 256 ) k = 256;
	for ( i = 0 ; i < k ; i ++ )		MLC.MapList5[ i ] = MapList.GetMapList( i + l );
	// For ( i=0 ; i<k ; i++ )		Log("copy MLC.MapList5["$i$"] "$MLC.MapList5[ i ]);
}

function MLC_MapList_6( Info MapListCacheActor)
{
	local MV_MapList MapList;	local MapListCache MLC;	local int i, k, l;
	MapList = MapVote(Outer).MapList;
	MLC = MapListCache(MapListCacheActor);
	l = 1280;
	k = MapList.GetMapListCount() -l;
	if ( k > 256 ) k = 256;
	for ( i = 0 ; i < k ; i ++ )		MLC.MapList6[ i ] = MapList.GetMapList( i + l );
	// For ( i=0 ; i<k ; i++ )		Log("copy MLC.MapList6["$i$"] "$MLC.MapList6[ i ]);
}

function MLC_MapList_7( Info MapListCacheActor)
{
	local MV_MapList MapList;	local MapListCache MLC;	local int i, k, l;
	MapList = MapVote(Outer).MapList;
	MLC = MapListCache(MapListCacheActor);
	l = 1536;
	k = MapList.GetMapListCount() -l;
	if ( k > 256 ) k = 256;
	for ( i = 0 ; i < k ; i ++ )		MLC.MapList7[ i ] = MapList.GetMapList( i + l );
	// For ( i=0 ; i<k ; i++ )		Log("copy MLC.MapList7["$i$"] "$MLC.MapList7[ i ]);
}

function MLC_MapList_8( Info MapListCacheActor)
{
	local MV_MapList MapList;	local MapListCache MLC;	local int i, k, l;
	MapList = MapVote(Outer).MapList;
	MLC = MapListCache(MapListCacheActor);
	l = 1792;
	k = MapList.GetMapListCount() -l;
	if ( k > 256 ) k = 256;
	for ( i = 0 ; i < k ; i ++ )		MLC.MapList8[ i ] = MapList.GetMapList( i + l );
	// For ( i=0 ; i<k ; i++ )		Log("copy MLC.MapList8["$i$"] "$MLC.MapList8[ i ]);
}

function MLC_MapList_9( Info MapListCacheActor)
{
	local MV_MapList MapList;	local MapListCache MLC;	local int i, k, l;
	MapList = MapVote(Outer).MapList;
	MLC = MapListCache(MapListCacheActor);
	l = 2048;
	k = MapList.GetMapListCount() -l;
	if ( k > 256 ) k = 256;
	for ( i = 0 ; i < k ; i ++ )		MLC.MapList9[ i ] = MapList.GetMapList( i + l );
	// For ( i=0 ; i<k ; i++ )		Log("copy MLC.MapList9["$i$"] "$MLC.MapList9[ i ]);
}

function MLC_MapList_10( Info MapListCacheActor)
{
	local MV_MapList MapList;	local MapListCache MLC;	local int i, k, l;
	MapList = MapVote(Outer).MapList;
	MLC = MapListCache(MapListCacheActor);
	l = 2304;
	k = MapList.GetMapListCount() -l;
	if ( k > 256 ) k = 256;
	for ( i = 0 ; i < k ; i ++ )		MLC.MapList10[ i ] = MapList.GetMapList( i + l );
	// For ( i=0 ; i<k ; i++ )		Log("copy MLC.MapList10["$i$"] "$MLC.MapList10[ i ]);
}

function MLC_MapList_11( Info MapListCacheActor)
{
	local MV_MapList MapList;	local MapListCache MLC;	local int i, k, l;
	MapList = MapVote(Outer).MapList;
	MLC = MapListCache(MapListCacheActor);
	l = 2560;
	k = MapList.GetMapListCount() -l;
	if ( k > 256 ) k = 256;
	for ( i = 0 ; i < k ; i ++ )		MLC.MapList11[ i ] = MapList.GetMapList( i + l );
	// For ( i=0 ; i<k ; i++ )		Log("copy MLC.MapList11["$i$"] "$MLC.MapList11[ i ]);
}

function MLC_MapList_12( Info MapListCacheActor)
{
	local MV_MapList MapList;	local MapListCache MLC;	local int i, k, l;
	MapList = MapVote(Outer).MapList;
	MLC = MapListCache(MapListCacheActor);
	l = 2816;
	k = MapList.GetMapListCount() -l;
	if ( k > 256 ) k = 256;
	for ( i = 0 ; i < k ; i ++ )		MLC.MapList12[ i ] = MapList.GetMapList( i + l );
	// For ( i=0 ; i<k ; i++ )		Log("copy MLC.MapList12["$i$"] "$MLC.MapList12[ i ]);
}

function MLC_MapList_13( Info MapListCacheActor)
{
	local MV_MapList MapList;	local MapListCache MLC;	local int i, k, l;
	MapList = MapVote(Outer).MapList;
	MLC = MapListCache(MapListCacheActor);
	l = 3072;
	k = MapList.GetMapListCount() -l;
	if ( k > 256 ) k = 256;
	for ( i = 0 ; i < k ; i ++ )		MLC.MapList13[ i ] = MapList.GetMapList( i + l );
	// For ( i=0 ; i<k ; i++ )		Log("copy MLC.MapList13["$i$"] "$MLC.MapList13[ i ]);
}

function MLC_MapList_14( Info MapListCacheActor)
{
	local MV_MapList MapList;	local MapListCache MLC;	local int i, k, l;
	MapList = MapVote(Outer).MapList;
	MLC = MapListCache(MapListCacheActor);
	l = 3328;
	k = MapList.GetMapListCount() -l;
	if ( k > 256 ) k = 256;
	for ( i = 0 ; i < k ; i ++ )		MLC.MapList14[ i ] = MapList.GetMapList( i + l );
	// For ( i=0 ; i<k ; i++ )		Log("copy MLC.MapList14["$i$"] "$MLC.MapList14[ i ]);
}

function MLC_MapList_15( Info MapListCacheActor)
{
	local MV_MapList MapList;	local MapListCache MLC;	local int i, k, l;
	MapList = MapVote(Outer).MapList;
	MLC = MapListCache(MapListCacheActor);
	l = 3584;
	k = MapList.GetMapListCount() -l;
	if ( k > 256 ) k = 256;
	for ( i = 0 ; i < k ; i ++ )		MLC.MapList15[ i ] = MapList.GetMapList( i + l );
	// For ( i=0 ; i<k ; i++ )		Log("copy MLC.MapList15["$i$"] "$MLC.MapList15[ i ]);
}

function MLC_MapList_16( Info MapListCacheActor)
{
	local MV_MapList MapList;	local MapListCache MLC;	local int i, k, l;
	MapList = MapVote(Outer).MapList;
	MLC = MapListCache(MapListCacheActor);
	l = 3840;
	k = MapList.GetMapListCount() -l;
	if ( k > 256 ) k = 256;
	for ( i = 0 ; i < k ; i ++ )		MLC.MapList16[ i ] = MapList.GetMapList( i + l );
	// For ( i=0 ; i<k ; i++ )		Log("copy MLC.MapList16["$i$"] "$MLC.MapList16[ i ]);
}

defaultproperties
{
}
