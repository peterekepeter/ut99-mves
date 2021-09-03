//
// Player watcher for players
//

class MVPlayerWatcher expands Info;

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
			Mutator.WatcherList = self;
			bHooked = true;
		}
		bHTTPLoading = false;
	}
	event Tick( float DeltaTime)
	{
		if ( MapVoteWRIActor != none && MapVoteWRIActor.bDeleteMe )
			MapVoteWRIActor = none;
		if ( Watched == none || Watched.bDeleteMe )
			GotoState('Inactive');
		bOverflow = false;
	}
Begin:
	if ( Mutator.PlayerIDType == PID_Default ) //15 ticks to retrieve ip
	{
		While( TicksLeft-- > 0 )
			Sleep(0.0);
		if ( Watched == none || Watched.bDeleteMe )
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
		While ( TicksLeft-- > 0 )
		{
			if ( Watched == none || Watched.bDeleteMe )
				Stop;
			if ( NexGenClient == none )
			{
				NexGenClient = Mutator.Extension.FindNexgenClient( Watched);
				if ( NexGenClient != none ) //Found! let's give more time
					TicksLeft += 6;
			}
			if ( (NexGenClient != none) && (NexGenClient.GetPropertyText("bInitialized") == GetPropertyText("bHooked")) && (NexGenClient.GetPropertyText("loginComplete") == GetPropertyText("bHooked")) )
			{
				PlayerCode = NexGenClient.GetPropertyText("playerID");
				if ( (PlayerCode == "") || Mutator.IpBanned(PlayerCode) )
				{
					//Broadcast a message later
					Watched.Destroy();
					Stop;
				}
				TicksLeft = 0;
				Goto('PostID');
			}
			Sleep(0.80 * Level.TimeDilation);
		}
		if ( NexGenClient == none )
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
	bInitialized = true;
	if ( Mutator.bWelcomeWindow )
		Mutator.Extension.WelcomeWindowTo( Watched);
	PlayerID = class'MV_MainExtension'.static.NumberToByte( Watched.PlayerReplicationInfo.PlayerID);
	PlayerID = class'MV_MainExtension'.static.PreFill( PlayerID, "0", 3);
	Mutator.Extension.AddPlayerToWindows( self);
GetCache:
	Sleep( 1.5 + FRand() * 5 );
	if ( !GetCacheActor() )
		Stop;
	TicksLeft = 15;
	if ( ViewPort(Watched.Player) != none ) //Local player, proceed to hack the MLC
	{
		MapListCacheActor.SetPropertyText("bNeedServerMapList","1");
		MapListCacheActor.SetPropertyText("bClientLoadEnd","1");
		MapListCacheActor.SetPropertyText("HTTPMapListLocation","None");
		MapListCacheActor.SetPropertyText("bChaceCheck","1");
		MapListCacheActor.SetPropertyText("LoadMapCount", string(Mutator.MapList.MapCount) );
		MapListCacheActor.SetPropertyText("LoadRuleCount", string(Mutator.MapList.GameCount) );
		MapListCacheActor.SetPropertyText("LoadPercentage", "100" );
	}
	While ( TicksLeft-- > 0 )
	{
		if ( NeedsFullCache() )
		{
			FullCache:
			MapListCacheActor.SetPropertyText("bNeedServerMapList","1");
			MapListCacheActor.SetPropertyText("HTTPMapListLocation","None");
			Mutator.Extension.MLC_Rules( MapListCacheActor);	Sleep(0.2 * Level.TimeDilation);
			Mutator.Extension.MLC_MapList_1( MapListCacheActor);	Sleep(0.2 * Level.TimeDilation);
			Mutator.Extension.MLC_MapList_2( MapListCacheActor);	Sleep(0.2 * Level.TimeDilation);
			Mutator.Extension.MLC_MapList_3( MapListCacheActor);	Sleep(0.2 * Level.TimeDilation);
			Mutator.Extension.MLC_MapList_4( MapListCacheActor);	Sleep(0.2 * Level.TimeDilation);
			Mutator.Extension.MLC_MapList_5( MapListCacheActor);	Sleep(0.2 * Level.TimeDilation);
			Mutator.Extension.MLC_MapList_6( MapListCacheActor);	Sleep(0.2 * Level.TimeDilation);
			Mutator.Extension.MLC_MapList_7( MapListCacheActor);	Sleep(0.2 * Level.TimeDilation);
			Mutator.Extension.MLC_MapList_8( MapListCacheActor);	Sleep(0.2 * Level.TimeDilation);
			Mutator.Extension.MLC_MapList_9( MapListCacheActor);	Sleep(0.2 * Level.TimeDilation);
			Mutator.Extension.MLC_MapList_10( MapListCacheActor);	Sleep(0.2 * Level.TimeDilation);
			Mutator.Extension.MLC_MapList_11( MapListCacheActor);	Sleep(0.2 * Level.TimeDilation);
			Mutator.Extension.MLC_MapList_12( MapListCacheActor);	Sleep(0.2 * Level.TimeDilation);
			Mutator.Extension.MLC_MapList_13( MapListCacheActor);	Sleep(0.2 * Level.TimeDilation);
			Mutator.Extension.MLC_MapList_14( MapListCacheActor);	Sleep(0.2 * Level.TimeDilation);
			Mutator.Extension.MLC_MapList_15( MapListCacheActor);	Sleep(0.2 * Level.TimeDilation);
			Mutator.Extension.MLC_MapList_16( MapListCacheActor);
			Stop;
		}
		Sleep(0.33 * Level.TimeDilation); //Total: 5 secs
	}
	if ( bHTTPLoading ) //Started but not ended
		Goto('FullCache');
}

state Inactive
{
	event BeginState()
	{
		RemoveFromActive();
		Watched = none;		
		nextWatcher = Mutator.InactiveList;
		Mutator.InactiveList = self;
		bInitialized = false;
		bOverflow = false;
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
		NexGenClient = none;
		if ( MapListCacheActor != none )
		{
			MapListCacheActor.Destroy();
			MapListCacheActor = none;
		}
		if ( MapVoteWRIActor != none )
		{
			MapVoteWRIActor.Destroy();
			MapVoteWRIActor = none;
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

	if ( Mutator.WatcherList == self )
		Mutator.WatcherList = nextWatcher;
	else
	{
		For ( PW=Mutator.WatcherList ; PW!=none ; PW=PW.nextWatcher )
			if ( PW.nextWatcher == self )
			{
				PW.nextWatcher = nextWatcher;
				break;
			}
	}
	nextWatcher = none;
	bHooked = false;
}

function bool GetCacheActor()
{
	if ( (Watched == none) || Watched.bDeleteMe || (Mutator.ServerCodeName == '') )
	{
		Log("ERROR: GetCacheActor called with incorrect parameters");
		return false;
	}
	if ( MapListCacheActor != none )
	{
		MapListCacheActor.SetOwner( Watched);
		if ( Mutator.bEnableHTTPMapList )
			MapListCacheActor.SetPropertyText( "HTTPMapListLocation", Mutator.HTTPMapListLocation $ "/MapList" $ chr(47) $ string(Mutator.ServerCodeName) ); //Reset just in case
		return true;
	}
	MapListCacheActor = Spawn( class<Info>( DynamicLoadObject( Mutator.ClientPackage$".MapListCache",class'class')), Watched);
	if ( MapListCacheActor == none )
	{
		Log("ERROR SPAWNING "$Mutator.ClientPackage$".MapListCache");
		return false;
	}
	if ( Mutator.bEnableHTTPMapList  )
		MapListCacheActor.SetPropertyText( "HTTPMapListLocation", Mutator.HTTPMapListLocation $ "/MapList" $ chr(47) $ string(Mutator.ServerCodeName));
	MapListCacheActor.SetPropertyText( "ServerCode", string(Mutator.ServerCodeName) );
	MapListCacheActor.SetPropertyText( "LastUpdate", Mutator.MapList.LastUpdate);
	return true;
}

function bool NeedsFullCache()
{
	local string test;
	if ( MapListCacheActor == none )
		return false;
	if ( !Mutator.bEnableHTTPMapList )
		return true;
	test = GetPropertyText("bInitialized"); //Always true here
	return (MapListCacheActor.GetPropertyText("HTTPMapListLocation") == "None" && MapListCacheActor.GetPropertyText("bNeedServerMapList") == test );
}

function bool IsModerator()
{
	if ( (NexGenClient != none) && (InStr(NexGenClient.GetPropertyText("rights"),"G") >= 0) )
		return true;
}

defaultproperties
{
	KickVoteID=-1
	RemoteRole=ROLE_None
}
