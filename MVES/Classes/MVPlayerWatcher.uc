//
// Player watcher for players
//

class MVPlayerWatcher expands MV_Callbacks;

var MapVote Mutator;
var PlayerPawn Watched;
var string PlayerIP;
var string PlayerCode;
var string PlayerID;
var string PlayerVote;
var int KickVoteID;
var string KickVoteCode;
var MVPlayerWatcher nextWatcher;
var int TicksLeft;
var bool bInitialized;
var bool bHooked;
var bool bHTTPLoading;
var bool bOverflow;
var Info MapListCacheActor;
var Info MapVoteWRIActor;
var Info NexGenClient;

//Map list cache note:
//if bNeedServerMapList=True and HTTPMapListLocation=="None"
//then we're doing some full old fashioned replication
//client can't alter bNeedServerMapList so we don't know if the HTTP linker
//is being setup, 5 seconds after the map list spawn is a good wait

state Initializing
{
	event BeginState()
	{
		TicksLeft = 15;
		if ( !bHooked )
		{
			nextWatcher = Mutator.WatcherList;
			Mutator.WatcherList = Self;
			bHooked = True;
		}
		bHTTPLoading = False;
	}
	event Tick( float DeltaTime)
	{
		if ( MapVoteWRIActor != None && MapVoteWRIActor.bDeleteMe )
			MapVoteWRIActor = None;
		if ( Watched == None || Watched.bDeleteMe )
			GotoState('Inactive');
		bOverflow = False;
	}
	Begin:
	if ( Mutator.PlayerIDType == PID_Default ) //15 ticks to retrieve ip
	{
		while( TicksLeft -- > 0 )
			Sleep(0.0);
		if ( Watched == None || Watched.bDeleteMe )
			Stop;
		PlayerCode = class'MV_MainExtension'.static.ByDelimiter( Watched.GetPlayerNetworkAddress(), ":"); //Remove port
		if ( (PlayerCode != "") && Mutator.IpBanned(PlayerCode) )
		{
			//Broadcast a message later
			Watched.Destroy();
			Stop;
		}
	}
	else if ( Mutator.PlayerIDType == PID_NexGen ) //6 seconds to retrieve NexGen ID
	{
		while ( TicksLeft -- > 0 )
		{
			if ( Watched == None || Watched.bDeleteMe )
				Stop;
			if ( NexGenClient == None )
			{
				NexGenClient = Mutator.Extension.FindNexgenClient( Watched);
				if ( NexGenClient != None ) //Found! let's give more time
					TicksLeft += 6;
			}
			if ( (NexGenClient != None) && (NexGenClient.GetPropertyText("bInitialized") == GetPropertyText("bHooked")) && (NexGenClient.GetPropertyText("loginComplete") == GetPropertyText("bHooked")) )
			{
				PlayerCode = NexGenClient.GetPropertyText("playerID");
				if ( (PlayerCode == "") || Mutator.IpBanned(PlayerCode) )
				{
					//Broadcast a message later
					Watched.Destroy();
					Stop;
				}
				TicksLeft = 0;
				goto('PostID');
			}
			Sleep(0.80 * Level.TimeDilation);
		}
		if ( NexGenClient == None )
			Watched.ClientMessage("MVE: NexgenClient detection timeout");
		else if (NexGenClient.GetPropertyText("bInitialized") != GetPropertyText("bHooked"))
			Watched.ClientMessage("MVE: Unable to find initialization var on NexgenClient");
		else
			Watched.ClientMessage("MVE: Unable to find login var on NexgenClient");
		Watched.Destroy();
		Stop;
	}
	PostID:
	PlayerIP = class'MV_MainExtension'.static.ByDelimiter( Watched.GetPlayerNetworkAddress(), ":"); //Remove port
	bInitialized = True;
	if ( Mutator.bWelcomeWindow && Mutator.ServerInfoURL != "")
	{
		Mutator.Extension.WelcomeWindowTo( Watched);
	}
	PlayerID = class'MV_MainExtension'.static.NumberToByte( Watched.PlayerReplicationInfo.PlayerID);
	PlayerID = class'MV_MainExtension'.static.PreFill( PlayerID, "0", 3);
	Mutator.Extension.AddPlayerToWindows( Self);
	GetCache:
	Sleep( 1.0 + FRand() * 1.0 );
	if ( !GetCacheActor() )
		Stop;
	TicksLeft = 15;
	if ( ViewPort(Watched.Player) != None ) //Local player, proceed to hack the MLC
	{
		// MapListCacheActor.SetPropertyText("bNeedServerMapList","1");
		MapListCacheActor.SetPropertyText("bClientLoadEnd","1");
		// MapListCacheActor.SetPropertyText("HTTPMapListLocation","None");
		MapListCacheActor.SetPropertyText("bChaceCheck","1");
		MapListCacheActor.SetPropertyText("LoadMapCount", string(Mutator.MapList.iMapList) );
		MapListCacheActor.SetPropertyText("LoadRuleCount", string(Mutator.MapList.GameCount) );
		MapListCacheActor.SetPropertyText("LoadPercentage", "100" );
	}
	while ( TicksLeft -- > 0 )
	{
		if ( NeedsFullCache() )
		{
			FullCache:
			// MapListCacheActor.SetPropertyText("bNeedServerMapList","1");
			// MapListCacheActor.SetPropertyText("HTTPMapListLocation","None");
			// MapListCacheActor.SetPropertyText("ClientScreenshotPackage", Mutator.ClientScreenshotPackage );
			// MapListCacheActor.SetPropertyText("ClientLogoTexture", Mutator.ClientLogoTexture );
			// MapListCacheActor.SetPropertyText("ServerInfoURL", Mutator.ServerInfoURL );
			// MapListCacheActor.SetPropertyText("MapInfoURL", Mutator.MapInfoURL );
			// Mutator.Extension.MLC_Rules( MapListCacheActor); 	Sleep(0.5);
			// Mutator.Extension.MLC_MapList_1( MapListCacheActor); 	Sleep(0.5);
			// Mutator.Extension.MLC_MapList_2( MapListCacheActor);	Sleep(0.5);
			// Mutator.Extension.MLC_MapList_3( MapListCacheActor);	Sleep(0.5);
			// Mutator.Extension.MLC_MapList_4( MapListCacheActor);	Sleep(0.5);
			// Mutator.Extension.MLC_MapList_5( MapListCacheActor);	Sleep(0.5);
			// Mutator.Extension.MLC_MapList_6( MapListCacheActor);	Sleep(0.5);
			// Mutator.Extension.MLC_MapList_7( MapListCacheActor);	Sleep(0.5);
			// Mutator.Extension.MLC_MapList_8( MapListCacheActor);	Sleep(0.5);
			// Mutator.Extension.MLC_MapList_9( MapListCacheActor);	Sleep(0.5);
			// Mutator.Extension.MLC_MapList_10( MapListCacheActor);	Sleep(0.5);
			// Mutator.Extension.MLC_MapList_11( MapListCacheActor);	Sleep(0.5);
			// Mutator.Extension.MLC_MapList_12( MapListCacheActor);	Sleep(0.5);
			// Mutator.Extension.MLC_MapList_13( MapListCacheActor);	Sleep(0.5);
			// Mutator.Extension.MLC_MapList_14( MapListCacheActor);	Sleep(0.5);
			// Mutator.Extension.MLC_MapList_15( MapListCacheActor);	Sleep(0.5);
			// Mutator.Extension.MLC_MapList_16( MapListCacheActor);
			Stop;
		}
		Sleep(0.5); // Total: 8-10 seconds
	}
	if ( bHTTPLoading ) // Started but not ended
		goto('FullCache');
}

state Inactive
{
	event BeginState()
	{
		RemoveFromActive();
		Watched = None;		
		nextWatcher = Mutator.InactiveList;
		Mutator.InactiveList = Self;
		bInitialized = False;
		bOverflow = False;
		if ( PlayerVote != "" )
		{
			PlayerVote = "";
			Mutator.CountMapVotes();
			//SEND "Clear" TO OPEN WINDOWS, AND RESEND LIST!
		}
		PlayerIP = "";
		PlayerID = "";
		PlayerCode = "";
		KickVoteID = -1;
		KickVoteCode = "";
		NexGenClient = None;
		if ( MapListCacheActor != None )
		{
			MapListCacheActor.Destroy();
			MapListCacheActor = None;
		}
		if ( MapVoteWRIActor != None )
		{
			MapVoteWRIActor.Destroy();
			MapVoteWRIActor = None;
		}
	}
	event EndState() //NEVER, EVER PULL THIS THING OUT OF THIS STATE IF IT ISN'T MUTATOR.INACTIVELIST
	{
		Mutator.InactiveList = nextWatcher;
	}
}

function RemoveFromActive()
{
	local MVPlayerWatcher PW;

	if ( Mutator.WatcherList == Self )
		Mutator.WatcherList = nextWatcher;
	else
	{
		for ( PW = Mutator.WatcherList ; PW != None ; PW = PW.nextWatcher )
			if ( PW.nextWatcher == Self )
			{
				PW.nextWatcher = nextWatcher;
				break;
			}
	}
	nextWatcher = None;
	bHooked = False;
}

function bool GetCacheActor()
{
	local MapListCache transfer;
	if ( (Watched == None) || Watched.bDeleteMe || (Mutator.ServerCodeName == '') )
	{
		Log("[MVE] ERROR: GetCacheActor called with incorrect parameters");
		return False;
	}
	if ( MapListCacheActor != None )
	{
		MapListCacheActor.SetOwner( Watched);
		if ( Mutator.bEnableHTTPMapList )
			MapListCacheActor.SetPropertyText( "HTTPMapListLocation", Mutator.HTTPMapListLocation$"/MapList"$chr(47)$string(Mutator.ServerCodeName) ); //Reset just in case
		return True;
	}
	transfer = Spawn(class'MapListCache', Watched);
	transfer.ServerCallbacks = Self;
	MapListCacheActor = transfer;
	if ( MapListCacheActor == None )
	{
		Log("[MVE] !!! FATAL ERROR !!!");
		Log("[MVE] failed to spawn "$Mutator.ClientPackageInternal$".MapListCache");
		Log("[MVE] make sure you have the correct client package in MVE_Config");
		return False;
	}
	if ( Mutator.bEnableHTTPMapList  )
	{
		MapListCacheActor.SetPropertyText( "HTTPMapListLocation", Mutator.HTTPMapListLocation$"/MapList"$chr(47)$string(Mutator.ServerCodeName));
	}
	else 
	{
		MapListCacheActor.SetPropertyText("HTTPMapListLocation","None");
	}
	MapListCacheActor.SetPropertyText("ServerCode", string(Mutator.ServerCodeName) );
	MapListCacheActor.SetPropertyText("LastUpdate", Mutator.MapList.LastUpdate);
	MapListCacheActor.SetPropertyText("ClientScreenshotPackage", Mutator.ClientScreenshotPackage );
	MapListCacheActor.SetPropertyText("ClientLogoTexture", Mutator.ClientLogoTexture );
	MapListCacheActor.SetPropertyText("ServerInfoURL", Mutator.ServerInfoURL );
	MapListCacheActor.SetPropertyText("MapInfoURL", Mutator.MapInfoURL );
	return True;
}

function bool NeedsFullCache()
{
	local string test;
	if ( MapListCacheActor == None )
		return False;
	test = GetPropertyText("bInitialized"); //Always true here
	return (MapListCacheActor.GetPropertyText("HTTPMapListLocation") == "None" 
		&& MapListCacheActor.GetPropertyText("bNeedServerMapList") == test );
}


function RequestFullCache()
{
	MapListCacheActor.SetPropertyText("ClientScreenshotPackage", Mutator.ClientScreenshotPackage );
	MapListCacheActor.SetPropertyText("ClientLogoTexture", Mutator.ClientLogoTexture );
	MapListCacheActor.SetPropertyText("ServerInfoURL", Mutator.ServerInfoURL );
	MapListCacheActor.SetPropertyText("MapInfoURL", Mutator.MapInfoURL );
	Mutator.Extension.MLC_Rules( MapListCacheActor); 	
	Mutator.Extension.MLC_MapList_1( MapListCacheActor); 	
	Mutator.Extension.MLC_MapList_2( MapListCacheActor);
	Mutator.Extension.MLC_MapList_3( MapListCacheActor);	
	Mutator.Extension.MLC_MapList_4( MapListCacheActor);	
	Mutator.Extension.MLC_MapList_5( MapListCacheActor);	
	Mutator.Extension.MLC_MapList_6( MapListCacheActor);	
	Mutator.Extension.MLC_MapList_7( MapListCacheActor);	
	Mutator.Extension.MLC_MapList_8( MapListCacheActor);	
	Mutator.Extension.MLC_MapList_9( MapListCacheActor);	
	Mutator.Extension.MLC_MapList_10( MapListCacheActor);	
	Mutator.Extension.MLC_MapList_11( MapListCacheActor);	
	Mutator.Extension.MLC_MapList_12( MapListCacheActor);	
	Mutator.Extension.MLC_MapList_13( MapListCacheActor);	
	Mutator.Extension.MLC_MapList_14( MapListCacheActor);	
	Mutator.Extension.MLC_MapList_15( MapListCacheActor);	
	Mutator.Extension.MLC_MapList_16( MapListCacheActor);
}

function FullCacheLoaded()
{
	// finished loading full cache
}

function bool IsModerator()
{
	if ( (NexGenClient != None) && (InStr(NexGenClient.GetPropertyText("rights"),"G") >= 0) )
		return True;
}

defaultproperties
{
	KickVoteID=-1
	RemoteRole=ROLE_None
}
