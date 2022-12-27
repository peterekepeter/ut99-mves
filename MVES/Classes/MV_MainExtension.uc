//================================================================================
// MV_MainExtension.
//================================================================================
class MV_MainExtension expands Object;

function WelcomeWindowTo( PlayerPawn Victim)
{
	local info I;

	if ( Victim.IsA('Spectator') )
		return;
	ForEach Victim.ChildActors( class'Info', I)
		if ( I.IsA('MVWelcomeWRI') )
			return;
	I = Victim.Spawn(class<Info>( DynamicLoadObject( MapVote(Outer).ClientPackage$".MVWelcomeWRI",class'class')), Victim,,vect(0,0,0) );
	I.SetPropertyText("ServerInfoURL", MapVote(Outer).ServerInfoURL);
	I.SetPropertyText("MapInfoURL", MapVote(Outer).MapInfoURL);
}

function Info SpawnVoteWRIActor( PlayerPawn Victim)
{
	return Victim.Spawn( class<Info>(DynamicLoadObject( MapVote(Outer).ClientPackage$".MapVoteWRI",class'class')), Victim,,vect(0,0,0));
}

function RemoveMapVotes( MVPlayerWatcher W)
{
	MapVote(Outer).iMapVotes = 0;
	While ( W != none )
	{
		W.PlayerVote = "";
		W = W.nextWatcher;
	}
}

function UpdateMapVotes( MVPlayerWatcher W)
{
	local MapVote Mutator;
	local int i;

	Mutator = MapVote(Outer);
	While ( W != none )
	{
		if ( W.MapVoteWRIActor != none )
		{
			class'WRI_Statics'.static.UpdateMapVoteResults( W.MapVoteWRIActor, "Clear", 0);
			For ( i=0 ; i<Mutator.iMapVotes ; i++ )
				class'WRI_Statics'.static.UpdateMapVoteResults( W.MapVoteWRIActor, Mutator.StrMapVotes[i], Mutator.RankMapVotes[i]);
		}
		W = W.nextWatcher;
	}
}

function UpdateKickVotes( MVPlayerWatcher W)
{
	local MapVote Mutator;
	local int i;

	Mutator = MapVote(Outer);
	While ( W != none )
	{
		if ( W.MapVoteWRIActor != none )
		{
			class'WRI_Statics'.static.UpdateKickVoteResults( W.MapVoteWRIActor, "Clear", 0);
			For ( i=0 ; i<Mutator.iKickVotes ; i++ )
				class'WRI_Statics'.static.UpdateKickVoteResults( W.MapVoteWRIActor, Mutator.StrKickVotes[i], Mutator.KickVoteCount[i]);
		}
		W = W.nextWatcher;
	}
}

static function CloseVoteWindows( MVPlayerWatcher W)
{
	While ( W != none )
	{
		if ( W.MapVoteWRIActor != none )
		{
			class'WRI_Statics'.static.CloseWindow( W.MapVoteWRIActor);
			W.MapVoteWRIActor.LifeSpan = 0.1;
		}
		W = W.nextWatcher;
	}
}

function AddPlayerToWindows( MVPlayerWatcher Watcher)
{
	local MVPlayerWatcher W;
	local string aStr;
	
	aStr = WTeamCode(Watcher.Watched) $ Watcher.PlayerID $ Watcher.Watched.PlayerReplicationInfo.PlayerName;
	
	For ( W=Watcher.Mutator.WatcherList ; W!=none ; W=W.nextWatcher )
		if ( W.MapVoteWRIActor != none )
		{
			class'WRI_Statics'.static.AddNewPlayer( W.MapVoteWRIActor, aStr, false);
			Log("Adding "$aStr$" to "$W.MapVoteWRIActor);
		}
}

function RemovePlayerFromWindows( MVPlayerWatcher Watcher)
{
	local MVPlayerWatcher W;
	
	For ( W=Watcher.Mutator.WatcherList ; W!=none ; W=W.nextWatcher )
		if ( W.MapVoteWRIActor != none )
			class'WRI_Statics'.static.RemovePlayerName( W.MapVoteWRIActor, Watcher.PlayerID);
}

function PlayersToWindow( Info MapVoteWRI)
{
	local MVPlayerWatcher W;
	local string aStr;
	
	For ( W=MapVote(Outer).WatcherList ; W!=none ; W=W.nextWatcher )
		if ( W.PlayerID != "" )
		{
			aStr = WTeamCode(W.Watched) $ W.PlayerID $ W.Watched.PlayerReplicationInfo.PlayerName;
			class'WRI_Statics'.static.AddNewPlayer( MapVoteWRI, aStr, W.PlayerVote != "");
			Log("Adding "$aStr$" to "$MapVoteWRI);
		}
}

function UpdatePlayerVotedInWindows(MVPlayerWatcher Voter)
{
	local MVPlayerWatcher W;
	
	for ( W = MapVote(Outer).WatcherList ; W != None ; W = W.nextWatcher )
	{
		if (W.MapVoteWRIActor == None)
		{
			continue;
		}
		class'WRI_Statics'.static.UpdatePlayerVoted(
			W.MapVoteWRIActor, Voter.PlayerID);
	}
}

function string WTeamCode( Pawn Other)
{
	if ( Other.IsA('Spectator') )		return "9";
	else if ( Other.PlayerReplicationInfo.Team > 9 )		return "0";
	return string(Other.PlayerReplicationInfo.Team);
}

function TimedMessage( int ID)
{
	local int Seconds;
	local PlayerPawn ThisPawn;
	
	if ( ID > 5 )		Seconds = 16 - ID;
	else if ( ID == 5 )	Seconds = 30;
	else if ( ID == 4 )	Seconds = 60;

	ForEach Actor(Outer).AllActors (class'PlayerPawn', ThisPawn)
	{
		ThisPawn.ClearProgressMessages();
		if ( ThisPawn.IsA('TournamentPlayer') )
			TournamentPlayer(ThisPawn).TimeMessage(ID);
		else
			ThisPawn.SetProgressMessage(Seconds$" seconds remaining to vote", 0);
	}
}

function string GenerateSPList( string NewPacks)
{
	local string Result;
	local int i;

	if ( (MapVote(Outer) == none) || (MapVote(Outer).MainServerPackages == "") )
		return "";

	Result = MapVote(Outer).MainServerPackages;
	Result = Left( Result, Len(Result)-1 );
	While ( NewPacks != "" )
		Result = Result $ "," $ chr(34) $ static.NextParameter(NewPacks,",") $ chr(34);
	return Result $ ")";
}

function MLC_Rules( Info MapListCacheActor)
{
	local MV_MapList MapList;
	MapList = MapVote(Outer).MapList;

	MapListCacheActor.SetPropertyText("RuleCount", string(MapList.GameCount));
	MapListCacheActor.SetPropertyText("MapCount", string(MapList.iMapList));
	MapListCacheActor.SetPropertyText("RuleListCount", string(MapList.iRules));
}

function MLC_MapList_1( Info MapListCacheActor);
function MLC_MapList_2( Info MapListCacheActor);
function MLC_MapList_3( Info MapListCacheActor);
function MLC_MapList_4( Info MapListCacheActor);
function MLC_MapList_5( Info MapListCacheActor);
function MLC_MapList_6( Info MapListCacheActor);
function MLC_MapList_7( Info MapListCacheActor);
function MLC_MapList_8( Info MapListCacheActor);
function MLC_MapList_9( Info MapListCacheActor);
function MLC_MapList_10( Info MapListCacheActor);
function MLC_MapList_11( Info MapListCacheActor);
function MLC_MapList_12( Info MapListCacheActor);
function MLC_MapList_13( Info MapListCacheActor);
function MLC_MapList_14( Info MapListCacheActor);
function MLC_MapList_15( Info MapListCacheActor);
function MLC_MapList_16( Info MapListCacheActor);

function SetupWebApp()
{
	local WebServer WS;
	local int i, aPort;
	local string DefStr;

	i = int( class'WebServer'.default.bEnabled);
	DefStr = class'WebServer'.default.Applications[0];
	aPort = class'WebServer'.default.ListenPort;
	class'WebServer'.default.Applications[0] = "";
	class'WebServer'.default.bEnabled = true;
	class'WebServer'.default.ListenPort = MapVote(Outer).HTTPMapListPort;

	WS = MapVote(Outer).Spawn( class'WebServer');
	
	class'WebServer'.default.Applications[0] = DefStr;
	class'WebServer'.default.bEnabled = bool(i);
	class'WebServer'.default.ListenPort = aPort;

	WS.ApplicationPaths[0] = "/MapList";
	WS.ApplicationObjects[0] = New(None) class'MapListServer';
	WS.ApplicationObjects[0].Level = WS.Level;
	WS.ApplicationObjects[0].WebServer = WS;
	WS.ApplicationObjects[0].Path = "/MapList";
	WS.ApplicationObjects[0].Init();
}

static function Info FindNexgenClient( PlayerPawn Player)
{
	local Info aInfo;
	ForEach Player.ChildActors (class'Info', aInfo)
		if ( aInfo.IsA('NexgenClient') )
			return aInfo;
}

//*****************************************************************************************************
//Parse next parameter from this command string using a custom delimiter, prepare string for next parse
//*****************************************************************************************************
static function string NextParameter( out string Commands, string Delimiter)
{
	local string result;
	local int i;
	
	if ( Delimiter == "" )
	{	result = Commands;
		Commands = "";
		return result;
	}

	i = InStr(Commands, Delimiter);
	if ( i < 0 )
	{
		result = Commands;
		Commands = "";
		return result;
	}
	if ( i == 0 ) //Idiot parse
	{
		Commands = Mid( Commands, Len(Delimiter));
		return NextParameter( Commands, Delimiter);
	}
	result = Left( Commands, i);
	Commands = Mid( Commands, i + Len(Delimiter) );
	return result;
}

//**************************************************************************************************
//Parses a parameter from this command using a delimiter, can seek and doesn't modify initial string
//**************************************************************************************************
static function string ByDelimiter( string Str, string Delimiter, optional int Skip)
{
	local int i;

	AGAIN:
	i = InStr( Str, Delimiter);
	if ( i < 0 )
	{
		if ( Skip == 0 )
			return Str;
		return "";
	}
	else
	{
		if ( Skip == 0 )
			return Left( Str, i);
		Str = Mid( Str, i + Len(Delimiter) );
		Skip--;
		Goto AGAIN;
	}
}

//***************************************************
//Fills a string with additional characters if needed
//***************************************************
static function string PreFill( string Base, string Fill, int Req)
{
	While ( Len(Base) < Req )
		Base = Fill $ Base;
	return Base;
}

//**********************************************************************
//Turns a single number into it's string HEX representation (without 0x)
//**********************************************************************
static function string NumberToByte( int N, optional bool bStart)
{
	local int d, i, test;
	local string Result;

	For ( i=7 ; i>=0 ; i-- )
	{
		test = (N >>> (i*4) ) & 0x0F;
		if ( test != 0 )
			bStart = true;
		if ( bStart )
			Result = Result $ SingleHEX(test);
	}
	return Result;
}

static function string SingleHEX( int N)
{
	if ( N < 10 )
		return string(N);
	return chr( 55 + N);
}

defaultproperties
{
}
