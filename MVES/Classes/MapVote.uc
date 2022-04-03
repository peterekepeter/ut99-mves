//================================================================================
// MapVote.
//================================================================================
class MapVote expands Mutator config(MVE_Config);

var() config string ClientPackage;		//Load this package
var() config string ServerInfoURL;
var() config string MapInfoURL;
var() config string HTTPMapListLocation; //HTTPMapListPort is needs to be attached here as well
var() config string TravelString; //Used for next map!
var string CurrentMode; //Clear on restart, if "", take gametype's default game mode

var() config int TravelIdx; //Load this rule set
var() config int VoteTimeLimit;
var() config int HTTPMapListPort;
var() config int DefaultGameTypeIdx; //For crashes
var() config name ServerCodeName; //Necessary for our ServerCode

var() config int MidGameVotePercent, KickPercent;
var() config int MapCostAddPerLoad, MapCostMaxAllow;

enum EIDType
{
	PID_Default,
	PID_NexGen
}
;

var() config EIDType PlayerIDType;

var() config bool bFirstRun;
var() config bool bShutdownServerOnTravel;
var() config bool bWelcomeWindow;
var() config bool bSpecsAllowed;
var() config bool bAutoOpen;
var int ScoreBoardTime;
var() config int ScoreBoardDelay;
var float EndGameTime;
var() config bool bKickVote;
var() config bool bEnableHTTPMapList;
var() config bool bEnableMapOverrides;
var bool bLevelSwitchPending;
var bool bVotingStage;
var bool bMapChangeIssued;
var bool bXCGE_DynLoader; //FUCK YEAH

var() config bool bOverrideServerPackages;
var() config bool bResetServerPackages;
var() config string MainServerPackages;
struct GameType
{
	var() config bool bEnabled;
	var() config string GameName; //For displayable rule
	var() config string RuleName;
	var() config string GameClass;
	var() config string FilterCode;
	var() config bool bHasRandom;
	var() config float VotePriority;
	var() config string MutatorList;
	var() config string Settings;
	var() config string Packages;
	var() config int TickRate;
	var() config string ServerActors;
	var() config bool bAvoidRandom;
}
;
var() config string DefaultSettings;
var() config int DefaultTickRate;
var int pos;
const CustomGameCount = 512;
var() config GameType CustomGame[CustomGameCount];
var GameType EmptyGame;
var int iGames;


var() config string Aliases[32];
var string PreAlias[32], PostAlias[32];
var int iAlias;
var() config string MapFilters[1024], ExcludeFilters[32];
var int iFilter, iExclF;


var MV_PlayerWatcher WatcherList, InactiveList;

var MV_MapList MapList;
var MV_MainExtension Extension;
var string ExtensionClass;


var(Debug) bool bSaveConfig, bGenerateMapList;
var string LastMsg;

var string StrMapVotes[32];
var float FMapVotes[32];
var int RankMapVotes[32];
var int iMapVotes;

var string StrKickVotes[32];
var int KickVoteCount[32];
var int iKickVotes;

var string BanList[32];

var MV_PlayerDetector PlayerDetector;
var int CurrentID;

var MV_MapResult CurrentMap;
var Music SongOverride;

//XC_GameEngine and Unreal 227 interface
//native(1718) final function bool AddToPackageMap( optional string PkgName);

state Voting
{
	event BeginState()
	{
		bVotingStage = True;
		CountMapVotes(); //Call again if mid game, now we do check the maps
	}
	PreBegin:
	Sleep( 5);
	Begin:
	if ( VoteTimeLimit < 5 )
		goto('Vote_5');
	if ( VoteTimeLimit < 10 )
	{
		Sleep(VoteTimeLimit - 5);
		goto('Vote_5');
	}
	if ( VoteTimeLimit < 30 )
	{
		Sleep(VoteTimeLimit - 10);
		goto('Vote_10');
	}
	if ( VoteTimeLimit < 60 )
	{
		Sleep(VoteTimeLimit - 30);
		goto('Vote_30');
	}
	Sleep( VoteTimeLimit - 60);
	Vote_60:
	Extension.TimedMessage( 12);
	Sleep(30 * Level.TimeDilation);
	Vote_30:
	Extension.TimedMessage( 11);
	Sleep(20 * Level.TimeDilation);
	Vote_10:
	Extension.TimedMessage( 10);
	Sleep(1 * Level.TimeDilation);
	Extension.TimedMessage( 9);
	Sleep(1 * Level.TimeDilation);
	Extension.TimedMessage( 8);
	Sleep(1 * Level.TimeDilation);
	Extension.TimedMessage( 7);
	Sleep(1 * Level.TimeDilation);
	Extension.TimedMessage( 6);
	Sleep(1 * Level.TimeDilation);
	Vote_5:
	Extension.TimedMessage( 5);
	Sleep(1 * Level.TimeDilation);
	Extension.TimedMessage( 4);
	Sleep(1 * Level.TimeDilation);
	Extension.TimedMessage( 3);
	Sleep(1 * Level.TimeDilation);
	Extension.TimedMessage( 2);
	Sleep(1 * Level.TimeDilation);
	Extension.TimedMessage( 1);
	Sleep(1 * Level.TimeDilation);
	Vote_End:
	Sleep(0.0);
	CountMapVotes( True);
}

state DelayedTravel
{
	event BeginState()
	{
		bLevelSwitchPending = True;
	}
	Begin:
	Sleep(4);
	bMapChangeIssued = True;
	ExecuteTravel();
}

function ExecuteSetting (string Setting, bool bIsDefaultSetting)
{
	local string Property;
	local string Value;
	local string Prev;
	local string Next;

	Property=Left(Setting,InStr(Setting,"="));
	Value=Mid(Setting,InStr(Setting,"=") + 1);
	/* 	if ( bIsDefaultSetting )
	{
		Log("[MVE] Execute default Setting:" @ Setting);
	} 
	else 
	{
		Log("[MVE] Execute Setting:" @ Setting);
	} 
	*/
	Prev=Level.Game.GetPropertyText(Property);
	Level.Game.SetPropertyText(Property,Value);
	Next=Level.Game.GetPropertyText(Property);
}

event PostBeginPlay()
{
	local class<MV_MainExtension> ExtensionC;
	local string Cmd, NextParm, aStr, Settings;
	local Actor A;
	local class<Actor> ActorClass;
	local int MapIdx;

	log(" !MVE: PostBeginPlay!");
	if ( bFirstRun )
	{
		bFirstRun = False;
		SaveConfig();
	}
	LoadAliases();

	//if ( int(ConsoleCommand("get ini:Engine.Engine.GameEngine XC_Version")) >= 11 ) //Only XC_GameEngine contains this variable
	//{
	bXCGE_DynLoader = False;
	//default.bXCGE_DynLoader = true; //So we get to see if it worked from clients!
	//AddToPackageMap( ClientPackage);
	//}
	if ( ExtensionClass != "" )
	{
		ExtensionC = class<MV_MainExtension>( DynamicLoadObject(ExtensionClass,class'class') );
	}
	if ( ExtensionC == None )
	{
		ExtensionC = class'MV_MainExtension';
	}
	Extension = new ExtensionC;
	if ( bEnableHTTPMapList && (Level.NetMode != NM_Standalone) )
	{
		Extension.SetupWebApp();
	}
	MapList = Spawn(class'MV_MapList');
	MapList.Mutator = self;
	RegisterMessageMutator();
	
	if ( DefaultSettings != "" )
	{
		Settings=DefaultSettings;
	
		while ( Len(Settings) > 0 )
		{
			pos=InStr(Settings,";");
			if ( pos < 0 )
			{
				pos=InStr(Settings,",");
			}
			if ( pos < 0 )
			{
				ExecuteSetting(Settings,True);
				Settings="";
			} 
			else 
			{
				ExecuteSetting(Left(Settings,pos),True);
				Settings=Mid(Settings,pos + 1);
			}
		}
	}
	Cmd = Extension.ByDelimiter( string(self), ".");
	Log("[MVE] Command: "$Cmd);
	
	CurrentMap = new class'MV_MapResult';
	CurrentMap.Map = Cmd;
	CurrentMap.OriginalSong = ""$Level.Song;
	CurrentMap.GameIndex = TravelIdx;
	
	if (bEnableMapOverrides)
	{
		ProcessMapOverrides(CurrentMap);
		SongOverride = None;
		if (CurrentMap.Song != "")
		{
			SongOverride = Music(DynamicLoadObject(CurrentMap.Song, class'Music'));
			Log("[MVE] SongOverride configured to: `"$SongOverride$"`");
		}
	}

	if ( Cmd ~= Left(TravelString, Len(Cmd) ) )  //CRASH DIDN'T HAPPEN, SETUP GAME
	{
		MapIdx = MapList.FindMapWithGame( Cmd, TravelIdx);
		if ( MapIdx >= 0 )
		{
			MapList.History.NewMapPlayed( MapIdx, TravelIdx, MapCostAddPerLoad);
		}
		CurrentMode = CustomGame[TravelIdx].GameName @ "-" @ CustomGame[TravelIdx].RuleName;
		DEFAULT_MODE:
		Cmd = CustomGame[TravelIdx].Settings;
		//Log("[MVE] Loading settings:",'MapVote');
		while ( Cmd != "" )
		{
			NextParm = Extension.NextParameter( Cmd, ",");
			Log("[MVE] Execute Setting: "$NextParm,'MapVote');
			if ( InStr(NextParm,"=") > 0 )
			{
				Level.Game.SetPropertyText( Extension.NextParameter(NextParm,"=") , NextParm );
			}
		}
		
		Cmd = ParseAliases(CustomGame[TravelIdx].ServerActors);
		if ( Cmd != "" )
			Log("[MVE] Spawning ServerActors",'MapVote');
		While ( Cmd != "" )
		{
			NextParm = Extension.NextParameter( Cmd, ",");
			if ( InStr(NextParm,".") < 0 )
				NextParm = "Botpack."$NextParm;
			ActorClass = class<Actor>(DynamicLoadObject(NextParm, class'Class'));	
			A=Spawn(ActorClass);
			Log("[MVE] ===> "$string(ActorClass));
		}

		Cmd = ParseAliases(CustomGame[TravelIdx].MutatorList);
		if ( Cmd != "" )
		{
			Log("[MVE] Spawning Mutators",'MapVote');
		}
		while ( Cmd != "" )
		{
			NextParm = Extension.NextParameter( Cmd, ",");
			if ( InStr(NextParm,".") < 0 )
			{
				NextParm = "Botpack."$NextParm;
			}
			ActorClass = class<Actor>(DynamicLoadObject(NextParm, class'Class'));	
			A=Spawn(ActorClass);
			Level.Game.BaseMutator.AddMutator(Mutator(A));
			Log("[MVE] ===> "$string(ActorClass));
		}
		if ( bXCGE_DynLoader )
		{
			Cmd = CustomGame[TravelIdx].Packages;
			if ( InStr( Cmd, "<") >= 0 )
			{
				Cmd = ParseAliases( Cmd);
			}
			while ( Cmd != "" )
			{
				NextParm = Extension.NextParameter( Cmd, ",");
				if ( NextParm != "" )
				{
					AddToPackageMap( NextParm);
				}
			}
		}
	}
	else
	{
		MapIdx = MapList.FindMap( Cmd);
		NEXT_MATCHING_MAP:
		if ( MapIdx >= 0 )
			NextParm = MapList.MapGames( MapIdx);
		if ( (string(Level.Game.class) ~= ParseAliases(CustomGame[DefaultGameTypeIdx].GameClass)) && (InStr(NextParm, MapList.TwoDigits(DefaultGameTypeIdx)) >= 0) ) //Map is in default game mode list and matches gametype
		{
			TravelIdx = DefaultGameTypeIdx;
			goto DEFAULT_MODE;
		}
		//		Log( Level.Game.Class @ CustomGame[DefaultGameTypeIdx].GameClass @ MapIdx @ NextParm @ MapList.TwoDigits(DefaultGameTypeIdx));
		if ( MapIdx >= 0 )
		{
			MapIdx = MapList.FindMap( Cmd, MapIdx+1);
			if ( MapIdx > 0 )
				goto NEXT_MATCHING_MAP;
		}
		CurrentMode = Level.Game.GameName @ "- Crashed";
		TravelIdx = -1;
		TravelString = "";
	}
	MapList.SetupClientList();
	if ( MapList.MapListString == "" && MapList.MapCount > 0 )
		MapList.GenerateString();
	if ( bResetServerPackages && bOverrideServerPackages )
	{
		MainServerPackages = ConsoleCommand("Get ini:Engine.Engine.GameEngine ServerPackages");
		bResetServerPackages = False;
		SaveConfig();
	}
	// init player detector
	PlayerDetector = Spawn(class'MV_PlayerDetector');
	PlayerDetector.Initialize(self);
	// self testing
	// SetupTravelString("DM-Deck16][:1");
}

function Mutate( string MutateString, PlayerPawn Sender)
{
	if ( Left(MutateString,10) ~= "BDBMAPVOTE" )
	{
		if ( Mid(MutateString,11,6) ~= "RELOAD" )
		{
			if ( Sender.bAdmin )				MapList.GlobalLoad();
			else				Sender.ClientMessage("You cannot reload the map list");
		}
		else if ( Mid(MutateString,11,8) ~= "VOTEMENU" )
		{
			if ( (Level.TimeSeconds > 15) || (Level.NetMode == 0) || Sender.bAdmin )
				OpenWindowFor( Sender);
			else
				Sender.ClientMessage("Please wait a few seconds to vote");
		}
		else if ( Mid(MutateString,11,3) ~= "MAP" )
			PlayerVoted( Sender, Mid(MutateString,15) );
		else if ( Mid(MutateString,11,5) ~= "KICK " )
			PlayerKickVote( Sender, Mid(MutateString, 17, 3));
		else
			return;
	}
	if ( NextMutator != None )
		NextMutator.Mutate( MutateString, Sender);
}

function bool HandleEndGame ()
{
	// notify next mutator of end game
	super.HandleEndGame();

	if (ShouldHandleEndgame())
	{
		HandleAssaultReset();
		DeathMatchPlus(Level.Game).bDontRestart = True;
		if ( !bVotingStage )
			GotoState('Voting','PreBegin');
		ScoreBoardTime=ScoreBoardDelay;
		SetTimer(Level.TimeDilation,True);
	}
	return False; // return value isn't properly used
}

function bool ShouldHandleEndgame()
{
	return IsMonsterHunt() || // always show mapvote for monsterhunt
	(!CheckForTie() && !IsAssaultAndNeedsToSwitchTeams());
}

function bool IsMonsterHunt()
{
	local string name;
	name = Caps(Level.Game$"");
	if (InStr(name, "MONSTER") != -1 && InStr(name, "HUNT") != -1)
	{
		return True;
	}
	return False;
}

function bool IsAssaultAndNeedsToSwitchTeams()
{
	local Assault a;
	a = Assault(Level.Game);
	if (a == None)
	{
		return False;
	}
	if (a.bDefenseSet)
	{
		return False;
	}
	return True;
}

function HandleAssaultReset()
{
	local Assault a;
	a = Assault(Level.Game);
	if (a != None) 
	{
		Log("[MVE] Resetting assault game!");
		a.bDefenseSet = False;
		a.NumDefenses = 0;
		a.CurrentDefender = 0;
		a.SavedTime = 0;
		a.GameCode = "";
		a.Part = 1;
		a.bTiePartOne = False;
		a.SaveConfig();
	}
}

function bool CheckForTie ()
{
	local TeamInfo Best;
	local int i;
	local Pawn P;
	local Pawn BestP;
	local PlayerPawn Player;

	if ( Level.Game.IsA('Assault') || Level.Game.IsA('Domination') )
		return False;
	if ( Level.Game.IsA('TeamGamePlus') )
	{
		for ( i=0 ; i<TeamGamePlus(Level.Game).MaxTeams ; i++ )
		if ( (Best == None) || (Best.Score < TeamGamePlus(Level.Game).Teams[i].Score) )
			Best = TeamGamePlus(Level.Game).Teams[i];
		for ( i=0 ; i<TeamGamePlus(Level.Game).MaxTeams ; i++ )
		if ( (Best.TeamIndex != i) && (Best.Score == TeamGamePlus(Level.Game).Teams[i].Score) )
			return True;
	}
	else
	{

	for ( P=Level.PawnList ; P!= None ; P=P.NextPawn )
		if ( P.bIsPlayer && ((BestP == None) || (P.PlayerReplicationInfo.Score > BestP.PlayerReplicationInfo.Score)) )
			BestP = P;
		for ( P=Level.PawnList ; P!= None ; P=P.NextPawn )
			if ( P.bIsPlayer && (BestP != P) && (P.PlayerReplicationInfo.Score == BestP.PlayerReplicationInfo.Score) )
				return True;
	}
}

event Timer()
{
	if ( ScoreBoardTime > 0 )
	{
		ScoreBoardTime--;
		if ( ScoreBoardTime == 0 )
		{
			EndGameTime=Level.TimeSeconds;
			if ( bAutoOpen )
				OpenAllWindows();
		}
		return;
	}
}

event Tick( float DeltaTime)
{
	if ( Level.Game.CurrentID != CurrentID )
	{
		PlayerDetector.DetectPlayers();
		CurrentID = Level.Game.CurrentID;
	}
	if ( Level.NextURL != "" && !bMapChangeIssued )
	{
		MapChangeIssued();
	}
	if ( bMapChangeIssued && (Level.NextSwitchCountdown < 0) && (Level.NextURL == "") ) //Handle switch failure
	{
		bLevelSwitchPending = False;
		bMapChangeIssued = False;
		Level.NextSwitchCountDown = 4;
		Extension.RemoveMapVotes( WatcherList);
		if ( bVotingStage )
			GotoState('Voting','Begin');
		if ( bAutoOpen )
			OpenAllWindows();
	}
	if ( bSaveConfig )
	{
		SaveConfig();
		bSaveConfig = False;
	}
	if ( bGenerateMapList )
	{
		GenerateMapList();
		bGenerateMapList = False;
	}
	LastMsg = "";
}

function GenerateMapList()
{
	if ( MapList == None )
	{
		MapList = Spawn(class'MV_MapList');
		MapList.Mutator = self;
	}
	MapList.GlobalLoad();
}


//Never happens in local games
function MapChangeIssued()
{
	local string aStr;

	bMapChangeIssued = True;
	Log("Map change issued with URL: "$ Level.NextURL,'MapVote');
	aStr = Extension.ByDelimiter( Level.NextURL, "?");
	aStr = Extension.ByDelimiter( aStr, "#" )  $ ":" $ string(TravelIdx) ; //Map name plus current IDX
	while ( InStr( aStr, " ") == 0 )
		aStr = Mid( aStr, 1);
	if ( MapList.ValidMap( aStr) )
	{
		if ( Level.bNextItems )			BroadcastMessage( Extension.ByDelimiter( aStr, ":") $ GameRuleCombo(TravelIdx) @ "has been selected as next map.", True);
		else			BroadcastMessage( Extension.ByDelimiter( aStr, ":") $ GameRuleCombo(TravelIdx) @ "has been forced.", True);
		TravelString = Level.NextURL;
	}
	else
		Log("Map code "$aStr$" not found in map list",'MapVote');
	SaveConfig();
}

function PlayerJoined( PlayerPawn P)
{
	local MV_PlayerWatcher MVEPV;
	log("[MVE] PlayerJoined:"@P.PlayerReplicationInfo.PlayerName@"("$P$") with id"@P.PlayerReplicationInfo.PlayerID);

	if (bEnableMapOverrides && SongOverride != None)
	{
		P.ClientSetMusic(SongOverride, 0, 0, MTRAN_Instant );
	}

	//Give this player a watcher
	if ( InactiveList == None )
	{
		MVEPV = Spawn(class'MV_PlayerWatcher');
		MVEPV.Mutator = self;
	}
	else
		MVEPV = InactiveList;
	MVEPV.Watched = P;
	MVEPV.GotoState('Initializing');
}

function PlayerKickVote( PlayerPawn Sender, string KickId)
{
	local MV_PlayerWatcher W, ToKick;
	local string Error;
	for ( W=WatcherList ; W!=None ; W=W.nextWatcher )
		if ( W.PlayerId == KickId )
		{
			ToKick = W;
		break;
	}
	W = GetWatcherFor( Sender);
	if ( (ToKick == None) || (W == None) )
		return;
	if ( !W.Watched.bAdmin )
	{
		if ( ToKick.IsModerator() )
			Error = "You cannot kick a server moderator";
		else if ( ToKick.Watched.bAdmin )
			Error = "You cannot kick a server admin";
		else if ( ToKick == W )
			Error = "You cannot kick yourself";
	}
	else
	{
		BroadcastMessage( ToKick.Watched.PlayerReplicationInfo.PlayerName @ "has been removed from the game by" @ W.Watched.PlayerReplicationInfo.PlayerName, True);
		Log("[MVE]" @ ToKick.Watched.PlayerReplicationInfo.PlayerName @ "has been removed from the game by" @ W.Watched.PlayerReplicationInfo.PlayerName,'MapVote');
		PlayerKickVoted( ToKick);
		CountKickVotes( True);
		return;
	}
	if ( Error != "" )
	{
		if ( W.KickVoteCode != "" )
		{
			W.KickVoteCode = "";
			CountKickVotes( True);
		}
		Sender.ClientMessage( Error);
		return;
	}
	W.KickVoteCode = ToKick.PlayerCode;
	BroadcastMessage( W.Watched.PlayerReplicationInfo.PlayerName @ "has placed a kick vote on" @ ToKick.Watched.PlayerReplicationInfo.PlayerName, True);
	CountKickVotes();
}

function CountKickVotes( optional bool bNoKick)
{
	local MV_PlayerWatcher W;
	local int i, pCount;
	local float Pct;

	iKickVotes = 0;
	for ( W=WatcherList ; W!=None ; W=W.NextWatcher )
	{
		if ( Spectator(W.Watched) == None )
			pCount++;
		if ( W.KickVoteCode != "" )
		{
			for ( i=0 ; i<iKickVotes ; i++ )
				if ( StrKickVotes[i] == W.KickVoteCode )
				{
					KickVoteCount[i]++;
				goto DO_CONTINUE;
			}
			StrKickVotes[iKickVotes] = W.KickVoteCode;
			KickVoteCount[iKickVotes++] = 1;
		}
		DO_CONTINUE:
	}
	i = 0;
	while ( i < iKickVotes )
	{
		W = WatcherList;
		while ( W!=None )
		{
			if ( W.PlayerCode == StrKickVotes[i] )
				break;
			W = W.NextWatcher;
		}
		if ( (W != None) && !bNoKick && (pCount > 4) )
		{
			Pct = (float( KickVoteCount[i]) / float( pCount)) * 100.0;
			if ( Pct >= KickPercent )
			{
				BroadcastMessage( W.Watched.PlayerReplicationInfo.PlayerName @ "has been removed from the game.", True);
				PlayerKickVoted( W);
				W = None;
			}
		}
		if ( W == None )
		{
			StrKickVotes[i] = StrKickVotes[--iKickVotes];
			KickVoteCount[i] = KickVoteCount[iKickVotes];
			continue;
		}
		StrKickVotes[i] = W.PlayerID $ W.Watched.PlayerReplicationInfo.PlayerName $ "," $ KickVoteCount[i];
		i++;
	}
	Extension.UpdateKickVotes( WatcherList);
}

//This player was removed from the game
function PlayerKickVoted( MV_PlayerWatcher Kicked, optional string OverrideReason)
{
	local MV_PlayerWatcher W;
	local int i;
	local Info NexgenRPCI;
	local string Reason, LastPlayer;

	if ( Kicked.Watched == None || Kicked.Watched.bDeleteMe )
		return;

	for ( W=WatcherList ; W!=None ; W=W.nextWatcher )
		if ( W.KickVoteCode == Kicked.PlayerCode )
			W.KickVoteCode = ""; //Clear
	
	if ( OverrideReason != "" ) Reason = OverrideReason;
	
	if ( Kicked.NexGenClient != None )
	{
		foreach Kicked.Watched.ChildActors (class'Info', NexgenRPCI) //Issue a NexGen ban if possible
		if ( NexgenRPCI.IsA('NexgenClientCore') )
		{
			// class'MV_NexgenUtil'.static.banPlayer( Kicked.NexGenClient, NexgenRPCI, Reason);
			// Log("[MVE] Nexgen Ban issued: "$ Kicked.NexGenClient @ NexgenRPCI, 'MapVote');
			return;
		}
	}

	while ( (i<32) && (BanList[i] != "") )
	{
		i++;
	}		
	if ( i==32 )	i = Rand(32);
	BanList[i] = Kicked.PlayerCode;
	Log("[MVE] Added "$Kicked.PlayerCode @ "to banlist ID" @i,'MapVote');
	Kicked.Watched.Destroy();
}

function bool IpBanned( string Address)
{
	local int i;
	for ( i=0 ; i<32 ; i++ )
	{
		if ( BanList[i] == "" )
			return False;
		if ( BanList[i] == Address )
			return True;
	}
}

//Compacts arrays, because we want faster loops
function CleanRules()
{
	local int i, j;
	local bool bSave;
	
	For ( j=0 ; j<ArrayCount(CustomGame) ; j++ )
	{
		if ( j != i )
		{
			if ( CustomGame[j].GameClass != "" && CustomGame[j].RuleName != "" )
			{
				CustomGame[i++] = CustomGame[j];
				CustomGame[j] = EmptyGame;
				bSave = True;
			}
		}
		else if ( CustomGame[j].GameClass != "" && CustomGame[j].RuleName != "" )
			i++;
	}
	iGames = i;

	if ( bSave )
		SaveConfig();
}

function CountFilters()
{
	local int i, lastE;
	
	if ( MapFilters[512] != "" ) //Optimization
		lastE = 513;
	for ( i=lastE ; i<1024 ; i++ )
	{
		if ( MapFilters[i] != "" )
			lastE = i+1;
	}
	iFilter = lastE;
	
	lastE = 0;
	for ( i=0 ; i<32 ; i++ )
		if ( ExcludeFilters[i] != "" )
			lastE = i+1;
	iExclF = lastE;
}

function UpdateMapListCaches()
{
	local MV_PlayerWatcher aList;
	
	for ( aList=WatcherList ; aList!=None ; aList=aList.nextWatcher )
	{
		if ( aList.bInitialized )
		{
			if ( aList.MapListCacheActor != None )
			{
				aList.MapListCacheActor.Destroy();
				aList.MapListCacheActor = None;
			}
			aList.GotoState('Initializing','GetCache');
		}
	}
}

function OpenWindowFor( PlayerPawn Sender, optional MV_PlayerWatcher W)
{
	//local MapVoteWRI MVWRI;
	
	if ( bLevelSwitchPending )
		return;
	if ( ServerCodeName == '' )	
	{
		Sender.ClientMessage("Map Vote not setup, load map list using MUTATE BDBMAPVOTE RELOAD");
		return;
	}
	if ( W == None )
		W = GetWatcherFor( Sender);
	if ( W != None )
	{
		if ( W.MapListCacheActor == None )
			Sender.ClientMessage("Please wait, Map List Cache not retrieved");
		else if ( W.MapVoteWRIActor != None )
		{
		}
		else
		{
			W.MapVoteWRIActor = Extension.SpawnVoteWRIActor( Sender);
			Extension.PlayersToWindow( W.MapVoteWRIActor);
			W.MapVoteWRIActor.SetPropertyText("bKickVote", string(bKickVote) );
			W.MapVoteWRIActor.SetPropertyText("Mode", CurrentMode);
		}
	}
	//MVWRI.GetServerConfig();
}

function OpenAllWindows()
{
	local MV_PlayerWatcher W;
	if ( bLevelSwitchPending )		return;
	for ( W=WatcherList ; W!=None ; W=W.nextWatcher )
		if ( CanVote(W.Watched) && (W.MapVoteWRIActor == None) )
			OpenWindowFor( W.Watched, W);
}

function PlayerVoted( PlayerPawn Sender, string MapString)
{
	local MV_PlayerWatcher W;
	local int iU;

	if ( bLevelSwitchPending )
	{
		Sender.ClientMessage("Server is about to change map, voting isn't allwoed");
		return;
	}
	if ( !Sender.bAdmin && !CanVote(Sender) )
	{
		Sender.ClientMessage("You're not allowed to vote");
		return;
	}
	W = GetWatcherFor( Sender);
	if ( W == None || W.bOverflow )
		return;
	if ( Left( MapString, 3) == "[X]" )
	{
		if ( Sender.bAdmin )
			MapString = Mid( MapString, 3);
		else
		{
			Sender.ClientMessage("This map is not available");
			return;
		}
	}
	W.bOverflow = True;
	if ( !MapList.ValidMap(MapString) ) //String is normalized, safe to cast equals
	{
		Sender.ClientMessage("Cannot vote, bad map code: "$MapString);
		return;
	}

	if (W.PlayerVote == MapString && !Sender.bAdmin)
	{
		Sender.ClientMessage("Already voted: "$MapString);
		return;
	}
	
	W.PlayerVote = MapString;
	iU = int(Extension.ByDelimiter( W.PlayerVote,":",1));

	if ( Sender.bAdmin )
	{
		GotoMap(MapString,True);
		SaveConfig();
		BroadcastMessage("Server Admin has force a map switch to " $ Extension.ByDelimiter(MapString,":") @ GameRuleCombo(iU),True);
		return;
	}
	W.PlayerVote = MapString;
	BroadcastMessage( Sender.PlayerReplicationInfo.PlayerName $ " voted for " $ Extension.ByDelimiter(MapString,":") @ GameRuleCombo(iU),True);
	CountMapVotes();
}

function CountMapVotes( optional bool bForceTravel)
{
	local MV_PlayerWatcher W, UniqueVotes[32];
	local float UniqueCount[32];
	local int i, iU, iBest, j;
	local float Total, Current;
	local bool bTie;
	
	if ( !bVotingStage )
	{
		for ( W=WatcherList ; W!=None ; W=W.nextWatcher )
		{
			if ( CanVote(W.Watched) )
			{
				Total += 1;
				if ( W.PlayerVote != "" )
					Current += 1;
			}
		}
		if ( (Current * 100 / Total) >= MidGameVotePercent )
		{
			BroadcastMessage("Mid game voting has initiated!!",True);
			GotoState('Voting','Begin');
			return;
		}
		Total = 0;
	}
	
	for ( W=WatcherList ; W!=None ; W=W.nextWatcher )
	{
		if ( CanVote(W.Watched) )
			Total += 1;
		if ( W.PlayerVote != "" )
		{
			for ( i=0 ; i<iU ; i++ )
			{
				if ( UniqueVotes[i].PlayerVote == W.PlayerVote )
				{
					UniqueCount[i] += VotePriority( int(Extension.ByDelimiter(W.PlayerVote,":",1)) );
					goto NEXT_PLAYER;
				}
			}
			UniqueVotes[iU] = W;
			UniqueCount[iU++] += VotePriority( int(Extension.ByDelimiter(W.PlayerVote,":",1)) );
			NEXT_PLAYER:
		}
	}

	iBest = 0;
	iMapVotes = iU;
	if ( iU > 0 )
	{
		j = int(Extension.ByDelimiter( UniqueVotes[0].PlayerVote,":",1));
		FMapVotes[0] = UniqueCount[0];
		StrMapVotes[0] = string(j) $ "," $ Extension.ByDelimiter( UniqueVotes[0].PlayerVote,":") $ "," $ GameName(j) $ "," $ RuleName(j) $ "," $ string(UniqueCount[0]);
	}
	for ( i=1 ; i<iU ; i++ )
	{
		j = int(Extension.ByDelimiter( UniqueVotes[i].PlayerVote,":",1));
		FMapVotes[i] = UniqueCount[i];
		StrMapVotes[i] = string(j) $ "," $ Extension.ByDelimiter( UniqueVotes[i].PlayerVote,":") $ "," $ GameName(j) $ "," $ RuleName(j) $ "," $ string(UniqueCount[i]);
		if ( UniqueCount[i] == UniqueCount[iBest] )
			bTie = True;
		else if ( UniqueCount[i] > UniqueCount[iBest] )
		{
			iBest = i;
			bTie = False;
		}
	}

	if ( bForceTravel && UniqueVotes[iBest] == None ) //Random map
	{
		// very dumb way
		for (i = 0; i < 1024; i++) {
			iU = Rand( MapList.iMapList);
			iBest = MapList.RandomGame(iU);
			if (!CustomGame[iBest].bAvoidRandom || i == 1023) {
				GotoMap( MapList.MapName(iU) $ ":" $ string(iBest), false );
				BroadcastMessage( "No votes sent, " $ MapList.MapName(iU) @ GameRuleCombo( iBest) @ "has been selected",True);
				break;
			}
		}
	}
	else if ( (UniqueCount[iBest] / Total) >= 0.51 ) //Absolute majority
	{
		GotoMap( UniqueVotes[iBest].PlayerVote, False);
		iU = int(Extension.ByDelimiter( UniqueVotes[iBest].PlayerVote,":",1));
		BroadcastMessage( Extension.ByDelimiter(UniqueVotes[iBest].PlayerVote,":") @ GameRuleCombo( iU) @ "has won by absolute majority.",True);
	}
	else if ( bForceTravel && bTie )
	{
		Current = 1;
		for ( i=iBest+1 ; i<iU ; i++ )
		{
			if ( UniqueCount[i] == UniqueCount[iBest] )
			{
				Current += 1;
				if ( 1 <= (FRand() * Current) )
					iBest = i;
			}
		}
		GotoMap( UniqueVotes[iBest].PlayerVote, False);
		iU = int(Extension.ByDelimiter( UniqueVotes[iBest].PlayerVote,":",1));
		BroadcastMessage( CapNumberWord(Current)$"map draw,"@Extension.ByDelimiter(UniqueVotes[iBest].PlayerVote,":") @ GameRuleCombo( iU) @ "selected.",True);
	}
	else if ( bForceTravel )
	{
		GotoMap( UniqueVotes[iBest].PlayerVote, False);
		iU = int(Extension.ByDelimiter( UniqueVotes[iBest].PlayerVote,":",1));
		BroadcastMessage( Extension.ByDelimiter(UniqueVotes[iBest].PlayerVote,":") @ GameRuleCombo( iU) @ "has won by simple majority.",True);
	}

	if ( !bForceTravel ) //Do not update rankings if we're leaving the map
	{
		i = 1;
		while ( i<iMapVotes )
		{
			if ( FMapVotes[i] > FMapVotes[i-1] )
			{
				FMapVotes[31] = FMapVotes[i-1];
				StrMapVotes[31] = StrMapVotes[i-1];
				FMapVotes[i-1] = FMapVotes[i];
				StrMapVotes[i-1] = StrMapVotes[i];
				FMapVotes[i] = FMapVotes[31];
				StrMapVotes[i] = StrMapVotes[31];
				if ( i == 1 )			i++;
				else					i--;
			}
			else
				i++;
		}
		RankMapVotes[0] = 0;
		for ( i=1 ; i<iMapVotes ; i++ )
		{
			if ( FMapVotes[i] == FMapVotes[i-1] )
				RankMapVotes[i] = RankMapVotes[i-1];
			else
				RankMapVotes[i] = i;
			//			Log("RANK="$string(RankMapVotes[i]) @ "COUNT="$string(FMapVotes[i]) @ "STR="$StrMapVotes[i]);
		}

		Extension.UpdateMapVotes( WatcherList);
	}

}

//***********************************
//************** ACCESSORS *********
//***********************************

final function string GetMapFilter( int Idx)
{
	return MapFilters[Idx];
}

final function string MutatorCode( int i)
{
	if ( CustomGame[i].bEnabled && (CustomGame[i].GameClass != "") && (CustomGame[i].GameName != "") && (CustomGame[i].RuleName != "") && (CustomGame[i].VotePriority > 0) )
		return CustomGame[i].FilterCode;
}

final function bool HasRandom( int i)
{
	return CustomGame[i].bHasRandom;
}

final function string GameName( int i)
{
	return CustomGame[i].GameName;
}

final function string RuleName( int i)
{
	return CustomGame[i].RuleName;
}

final function string GameRuleCombo( int i)
{
	return "["$CustomGame[i].GameName@ "-" @CustomGame[i].RuleName$"]";
}

final function float VotePriority( int i)
{
	return CustomGame[i].VotePriority;
}

final function bool CanVote(PlayerPawn Sender)
{
	if (Sender.Player == None) 
	{
		return False; // is not a human player, thus cannot vote (sorry bots)
	}
	if (bLevelSwitchPending)
	{
		return False; // can't vote when mapvote is about to switch levels
	}
	if (!bSpecsAllowed && Sender.IsA('Spectator'))
	{
		return False;
	}
	return True;
}

//Validity assumed
final function SetupTravelString( string MapString )
{
	local string spk, GameClassName;
	local int idx, TickRate;
	local MV_MapOverrides MapOverrides;
	local MV_MapResult Result;
	
	if ( MapString == "" )
	{
		TravelString = "?restart";
	}
	Result = new class'MV_MapResult';
	Result.Map = Extension.NextParameter( MapString, ":");
	Result.GameIndex = int(MapString);
	Result.OriginalSong = GetOriginalSongName(Result);
	//RANDOM MAP CHOSEN!
	if ( Result.Map ~= "Random" )
	{
		Result.Map = MapList.RandomMap(Result.GameIndex);
	}

	GameClassName = CustomGame[Result.GameIndex].GameClass;

	if ( DynamicLoadObject(ParseAliases(GameClassName),class'Class') == None )
	{
		Log("Bad game class: "$GameClassName );
		return;
	}

	TravelString = Result.Map $ "?Game=" $ ParseAliases(GameClassName);
	TravelIdx = Result.GameIndex;
	Log("[MVE] -> TravelString: "$TravelString);
	Log("[MVE] -> GameIdx: "$TravelIdx);
		
	if (bEnableMapOverrides)
	{
		ProcessMapOverrides(Result);
	}

	if ( bOverrideServerPackages )
	{
		Result.AddPackages(CustomGame[Result.GameIndex].Packages);
		spk = Extension.GenerateSPList(Result.GetPackagesStringList());
		if ( spk == "" )			
		{	
			spk = MainServerPackages;
		}
		if ( InStr( spk, "<") >= 0 )
		{
			spk = ParseAliases( spk);
		}
		Log("[MVE] -> ServerPackages: "$spk);
		ConsoleCommand( "set ini:Engine.Engine.GameEngine ServerPackages "$spk);
	}
	TickRate = DefaultTickRate;
	if (CustomGame[idx].TickRate != 0)
		TickRate = CustomGame[idx].TickRate;
	ConsoleCommand( "set ini:Engine.Engine.NetworkDevice NetServerMaxTickRate "$CustomGame[idx].TickRate);
	ConsoleCommand( "set ini:Engine.Engine.NetworkDevice LanServerMaxTickRate "$CustomGame[idx].TickRate);
}

function string GetOriginalSongName(MV_MapResult map)
{
	local LevelInfo info;
	info = LevelInfo(DynamicLoadObject(map.Map $"."$"LevelInfo0", class'LevelInfo'));
	if (info == None)
	{
		Log("[MVE] GetOriginalSongName failed for "$map.Map);
		return "????"; // str should not match anyhing ? not valid in filename nor unreal names
	}
	return ""$info.Song;
}

function ProcessMapOverrides(MV_MapResult map)
{
	local MapOverridesConfig MapOverridesConfig;
	local MV_MapOverrides MapOverrides;
	local MV_MapOverridesParser MapOverridesParser;
	MapOverridesConfig = new class'MapOverridesConfig';
	MapOverridesConfig.RunMigration();
	MapOverrides = new class'MV_MapOverrides';
	MapOverridesParser = new class'MV_MapOverridesParser';
	MapOverridesParser.ParseConfiguration(MapOverrides, MapOverridesConfig);
	MapOverrides.ApplyOverrides(map);
}

final function GotoMap( string MapString, optional bool bImmediate)
{
	if ( Left(MapString,3) == "[X]" ) //Random sent me here
		MapString = Mid(MapString,3);
	SetupTravelString( MapString );
	SaveConfig();
	Extension.CloseVoteWindows( WatcherList);
	if ( bImmediate )
	{
		ExecuteTravel();
		bMapChangeIssued = True;
	}
	else
		GotoState('DelayedTravel');
}

final function RegisterMessageMutator()
{
	local mutator aMut;
	aMut = Level.Game.MessageMutator;
	Level.Game.MessageMutator = self;
	NextMessageMutator = aMut;
}

final function MV_PlayerWatcher GetWatcherFor( PlayerPawn Other)
{
	local MV_PlayerWatcher W;
	for ( W=WatcherList ; W!=None ; W=W.nextWatcher )
		if ( W.Watched == Other )
			return W;
}


final function string CapNumberWord( int Number)
{
	if ( Number == 2 )
		return "Two ";
	if ( Number == 3 )
		return "Three ";
	return "Multi-";
}

final function ExecuteTravel()
{
	Level.ServerTravel( TravelString,False);
	if (bShutdownServerOnTravel)
	{
		ConsoleCommand("exit");
	}
}

final function LoadAliases()
{
	local int i, j;
	
	for ( i=0 ; i<32 ; i++ )
	{
		if ( Left(Aliases[i],1) == "<" )
		{
			j = InStr( Aliases[i], ">");
			if ( j < 0 )
				continue;
			if ( (Mid(Aliases[i],j,2) != ">=") || (Mid(Aliases[i], j+2) == "") )
				continue;
			PreAlias[iAlias] = Caps(Left( Aliases[i], j+1));
			PostAlias[iAlias++] = Mid( Aliases[i], j+2);
		}
	}
	//Single pass multi alias post processing
	for ( i=0 ; i<iAlias ; i++ )
		if ( InStr(PostAlias[i], "<") >= 0 )
			PostAlias[i] = ParseAliases( PostAlias[i]);
}

final function string ParseAliases( string Command)
{
	local string preStr, aStr;
	local int i;
	
	i = InStr( Command, "<");
	while ( i >= 0 )
	{
		preStr = Left( Command, i); //Split command in two
		Command = Mid( Command, i);
		i = InStr( Command, ">");
		if ( i < 0 ) //Badly written alias, remove all text for safety
			Command = preStr;
		else
		{
			aStr = Caps(Left( Command, i+1)); //Now remove the alias text from command
			Command = Mid( Command, i+1); //aStr is the alias, let's find it
			for ( i=0 ; i<iAlias ; i++ )
			{
				if ( PreAlias[i] == aStr )
				{
					aStr = PostAlias[i];
					goto SUCCESS;
				}
			}
			aStr = "";
			SUCCESS:
			Command = preStr $ aStr $ Command;
			i = InStr( Command, "<");
		}
	}
	return Command;
}

//***************************************
//*************** TRIGGERS *************
//***************************************

function bool MutatorTeamMessage( Actor Sender, Pawn Receiver, PlayerReplicationInfo PRI, coerce string S, name Type, optional bool bBeep )
{
	local int i;
	local playerpawn P;

	if ( S == LastMsg )
		goto END;
	LastMsg = S;
	CommonCommands( Sender, S);

	END:

	if ( DontPass( S) )
		return True;

	if ( NextMessageMutator != None )
		return NextMessageMutator.MutatorTeamMessage( Sender, Receiver, PRI, S, Type, bBeep );
	return True;
}

function bool MutatorBroadcastMessage( Actor Sender, Pawn Receiver, out coerce string Msg, optional bool bBeep, out optional name Type )
{
	local int i;
	local PlayerPawn P;
	local string orgMsg;

	if ( Msg != LastMsg )
	{
		LastMsg = Msg;
		orgMsg = Msg;
		while ( inStr( orgMsg, ":") > -1 )
		{
			orgMsg = Mid( orgMsg, inStr( orgMsg, ":")+1 );
		}

		CommonCommands( Sender, orgMsg);
	}


	if ( DontPass( orgMsg ) )
	{
		return True;
	}

	if ( NextMessageMutator != None )
	{
		return NextMessageMutator.MutatorBroadcastMessage( Sender, Receiver, Msg, bBeep, Type );
	}
	return True;
}

function bool DontPass( string Msg)
{
	if ( (Msg ~= "!v") || (Msg ~= "!vote") || (Msg ~= "!mapvote") || (Msg ~= "!kickvote") )
	{
		return True;
	}
}

function CommonCommands( Actor Sender, string S)
{
	if ( PlayerPawn(Sender) == None )
	{
		return;
	}

	if ( (S ~= "!v") || (S ~= "!vote") || (S ~= "!mapvote") || (S ~= "!kickvote") )
	{
		Mutate( "BDBMAPVOTE VOTEMENU", PlayerPawn(Sender) );
	}
}

defaultproperties
{
	ClientPackage="MVE2a";
	//HTTPMapListLocation="192.168.1.2:27011"
	//TravelString="CTF-Face?Game=BotPack.CTFGame"
	//TravelIdx=3
	ScoreBoardDelay=5;
	VoteTimeLimit=60;
	//HTTPMapListPort=27011
	//DefaultGameTypeIdx=3
	ServerCodeName=UT-Server;
	MidGameVotePercent=51;
	KickPercent=51;
	//MapCostAddPerLoad=5
	//MapCostMaxAllow=2
	bAutoOpen=True;
	bKickVote=True;
	bOverrideServerPackages=True;
	CustomGame(0)=(bEnabled=True,GameName="Assault",RuleName="Normal",GameClass="Botpack.Assault",FilterCode="as",VotePriority=1.000000);
	CustomGame(1)=(bEnabled=True,GameName="Capture the Flag",RuleName="Normal",GameClass="Botpack.CTFGame",FilterCode="ctf",VotePriority=1.000000);
	CustomGame(2)=(bEnabled=True,GameName="Deathmatch",RuleName="Normal",GameClass="Botpack.DeathMatchPlus",FilterCode="dm",VotePriority=1.000000);
	CustomGame(3)=(bEnabled=True,GameName="Domination",RuleName="Normal",GameClass="Botpack.Domination",FilterCode="dom",VotePriority=1.000000);
	CustomGame(4)=(bEnabled=True,GameName="Last Man Standing",RuleName="Normal",GameClass="Botpack.LastManStanding",FilterCode="lms",VotePriority=1.000000);
	CustomGame(5)=(bEnabled=True,GameName="Team Deathmatch",RuleName="Normal",GameClass="Botpack.TeamGamePlus",FilterCode="tdm",VotePriority=1.000000);
	MapFilters(0)="as AS-*";
	MapFilters(1)="ctf CTF-*";
	MapFilters(2)="dm DM-*";
	MapFilters(3)="dom DOM-*";
	MapFilters(4)="lms DM-*";
	MapFilters(5)="tdm DM-*";
	ExtensionClass="MVES.MV_SubExtension";
}