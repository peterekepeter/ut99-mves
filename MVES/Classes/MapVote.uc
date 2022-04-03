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
};

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
};
var() config string DefaultSettings;
var() config int DefaultTickRate;
var int pos;
var() config GameType CustomGame[512];
var GameType EmptyGame;
var int iGames;


var() config string Aliases[32];
var string PreAlias[32], PostAlias[32];
var int iAlias;
var() config string MapFilters[1024], ExcludeFilters[32];
var int iFilter, iExclF;


var MVPlayerWatcher WatcherList, InactiveList;

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
	} else {
		Log("[MVE] Execute Setting:" @ Setting);
	} */
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

	if ( int(ConsoleCommand("get ini:Engine.Engine.GameEngine XC_Version")) >= 11 ) //Only XC_GameEngine contains this variable
	{
		bXCGE_DynLoader = true;
		default.bXCGE_DynLoader = true; //So we get to see if it worked from clients!
		AddToPackageMap( ClientPackage);
	}
	if ( ExtensionClass != "" )
		ExtensionC = class<MV_MainExtension>( DynamicLoadObject(ExtensionClass,class'class') );
	if ( ExtensionC == none )
		ExtensionC = class'MV_MainExtension';
	Extension = new ExtensionC;
	if ( bEnableHTTPMapList && (Level.NetMode != NM_Standalone) )
		Extension.SetupWebApp();
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
			} else {
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
			MapList.History.NewMapPlayed( MapIdx, TravelIdx, MapCostAddPerLoad);
		CurrentMode = CustomGame[TravelIdx].GameName @ "-" @ CustomGame[TravelIdx].RuleName;
		DEFAULT_MODE:
		Cmd = CustomGame[TravelIdx].Settings;
		//Log("[MVE] Loading settings:",'MapVote');
		while ( Cmd != "" )
		{
			NextParm = Extension.NextParameter( Cmd, ",");
			Log("[MVE] Execute Setting: "$NextParm,'MapVote');
			if ( InStr(NextParm,"=") > 0 )
				Level.Game.SetPropertyText( Extension.NextParameter(NextParm,"=") , NextParm );
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
			Log("[MVE] Spawning Mutators",'MapVote');
		while ( Cmd != "" )
		{
			NextParm = Extension.NextParameter( Cmd, ",");
			if ( InStr(NextParm,".") < 0 )
				NextParm = "Botpack."$NextParm;
			ActorClass = class<Actor>(DynamicLoadObject(NextParm, class'Class'));	
			A=Spawn(ActorClass);
			Level.Game.BaseMutator.AddMutator(Mutator(A));
			Log("[MVE] ===> "$string(ActorClass));
		}
		if ( bXCGE_DynLoader )
		{
			Cmd = CustomGame[TravelIdx].Packages;
			if ( InStr( Cmd, "<") >= 0 )
				Cmd = ParseAliases( Cmd);
			while ( Cmd != "" )
			{
				NextParm = Extension.NextParameter( Cmd, ",");
				if ( NextParm != "" )
					AddToPackageMap( NextParm);
			}
		}
	}
	else
	{
		MapIdx = MapList.FindMap( Cmd);
		NEXT_MATCHING_MAP:
		if ( MapIdx >= 0 )
			NextParm = MapList.MapGames( MapIdx);
		if ( (string(Level.Game.Class) ~= ParseAliases(CustomGame[DefaultGameTypeIdx].GameClass)) && (InStr(NextParm, MapList.TwoDigits(DefaultGameTypeIdx)) >= 0) ) //Map is in default game mode list and matches gametype
		{
			TravelIdx = DefaultGameTypeIdx;
			Goto DEFAULT_MODE;
		}
//		Log( Level.Game.Class @ CustomGame[DefaultGameTypeIdx].GameClass @ MapIdx @ NextParm @ MapList.TwoDigits(DefaultGameTypeIdx));
		if ( MapIdx >= 0 )
		{
			MapIdx = MapList.FindMap( Cmd, MapIdx+1);
			if ( MapIdx > 0 )
				Goto NEXT_MATCHING_MAP;
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
		bResetServerPackages = false;
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

	if ( NextMutator != none )
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
		For ( i=0 ; i<TeamGamePlus(Level.Game).MaxTeams ; i++ )
			if ( (Best == None) || (Best.Score < TeamGamePlus(Level.Game).Teams[i].Score) )
				Best = TeamGamePlus(Level.Game).Teams[i];
		For ( i=0 ; i<TeamGamePlus(Level.Game).MaxTeams ; i++ )
			if ( (Best.TeamIndex != i) && (Best.Score == TeamGamePlus(Level.Game).Teams[i].Score) )
				return True;
	}
	else
	{

		For ( P=Level.PawnList ; P!= none ; P=P.NextPawn )
			if ( P.bIsPlayer && ((BestP == None) || (P.PlayerReplicationInfo.Score > BestP.PlayerReplicationInfo.Score)) )
				BestP = P;
		For ( P=Level.PawnList ; P!= none ; P=P.NextPawn )
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
		MapChangeIssued();
	if ( bMapChangeIssued && (Level.NextSwitchCountdown < 0) && (Level.NextURL == "") ) //Handle switch failure
	{
		bLevelSwitchPending = false;
		bMapChangeIssued = false;
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
		bSaveConfig = false;
	}
	if ( bGenerateMapList )
	{
		GenerateMapList();
		bGenerateMapList = false;
	}
	LastMsg = "";
}

function GenerateMapList()
{
	if ( MapList == none )
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

	bMapChangeIssued = true;
	Log("Map change issued with URL: "$ Level.NextURL,'MapVote');
	aStr = Extension.ByDelimiter( Level.NextURL, "?");
	aStr = Extension.ByDelimiter( aStr, "#" )  $ ":" $ string(TravelIdx) ; //Map name plus current IDX
	while ( InStr( aStr, " ") == 0 )
		aStr = Mid( aStr, 1);
	if ( MapList.ValidMap( aStr) )
	{
		if ( Level.bNextItems )			BroadcastMessage( Extension.ByDelimiter( aStr, ":") $ GameRuleCombo(TravelIdx) @ "has been selected as next map.", true);
		else			BroadcastMessage( Extension.ByDelimiter( aStr, ":") $ GameRuleCombo(TravelIdx) @ "has been forced.", true);
		TravelString = Level.NextURL;
	}
	else
		Log("Map code "$aStr$" not found in map list",'MapVote');
	SaveConfig();
}

function PlayerJoined( PlayerPawn P)
{
	local MVPlayerWatcher MVEPV;
	log("[MVE] PlayerJoined:"@P.PlayerReplicationInfo.PlayerName@"("$P$") with id"@P.PlayerReplicationInfo.PlayerID);

	if (bEnableMapOverrides && SongOverride != None)
	{
		P.ClientSetMusic(SongOverride, 0, 0, MTRAN_Instant );
	}

	//Give this player a watcher
	if ( InactiveList == None )
	{
		MVEPV = Spawn(class'MVPlayerWatcher');
		MVEPV.Mutator = self;
	}
	else
		MVEPV = InactiveList;
	MVEPV.Watched = P;
	MVEPV.GotoState('Initializing');
}

function PlayerKickVote( PlayerPawn Sender, string KickId)
{
	local MVPlayerWatcher W, ToKick;
	local string Error;
	For ( W=WatcherList ; W!=none ; W=W.nextWatcher )
		if ( W.PlayerId == KickId )
		{
			ToKick = W;
			break;
		}
	W = GetWatcherFor( Sender);
	if ( (ToKick == none) || (W == none) )
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
		BroadcastMessage( ToKick.Watched.PlayerReplicationInfo.PlayerName @ "has been removed from the game by" @ W.Watched.PlayerReplicationInfo.PlayerName, true);
		Log("[MVE]" @ ToKick.Watched.PlayerReplicationInfo.PlayerName @ "has been removed from the game by" @ W.Watched.PlayerReplicationInfo.PlayerName,'MapVote');
		PlayerKickVoted( ToKick);
		CountKickVotes( true);
		return;
	}
	if ( Error != "" )
	{
		if ( W.KickVoteCode != "" )
		{
			W.KickVoteCode = "";
			CountKickVotes( true);
		}
		Sender.ClientMessage( Error);
		return;
	}
	W.KickVoteCode = ToKick.PlayerCode;
	BroadcastMessage( W.Watched.PlayerReplicationInfo.PlayerName @ "has placed a kick vote on" @ ToKick.Watched.PlayerReplicationInfo.PlayerName, true);
	CountKickVotes();
}

function CountKickVotes( optional bool bNoKick)
{
	local MVPlayerWatcher W;
	local int i, pCount;
	local float Pct;

	iKickVotes = 0;
	For ( W=WatcherList ; W!=none ; W=W.NextWatcher )
	{
		if ( Spectator(W.Watched) == none )
			pCount++;
		if ( W.KickVoteCode != "" )
		{
			For ( i=0 ; i<iKickVotes ; i++ )
				if ( StrKickVotes[i] == W.KickVoteCode )
				{
					KickVoteCount[i]++;
					Goto DO_CONTINUE;
				}
			StrKickVotes[iKickVotes] = W.KickVoteCode;
			KickVoteCount[iKickVotes++] = 1;
		}
		DO_CONTINUE:
	}
	i = 0;
	While ( i < iKickVotes )
	{
		W = WatcherList;
		While ( W!=none )
		{
			if ( W.PlayerCode == StrKickVotes[i] )
				break;
			W = W.NextWatcher;
		}
		if ( (W != none) && !bNoKick && (pCount > 4) )
		{
			Pct = (float( KickVoteCount[i]) / float( pCount)) * 100.0;
			if ( Pct >= KickPercent )
			{
				BroadcastMessage( W.Watched.PlayerReplicationInfo.PlayerName @ "has been removed from the game.", true);
				PlayerKickVoted( W);
				W = none;
			}
		}
		if ( W == none )
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
function PlayerKickVoted( MVPlayerWatcher Kicked, optional string OverrideReason)
{
	local MVPlayerWatcher W;
	local int i;
	local Info NexgenRPCI;
	local string Reason, LastPlayer;

	if ( Kicked.Watched == none || Kicked.Watched.bDeleteMe )
		return;

	For ( W=WatcherList ; W!=none ; W=W.nextWatcher )
		if ( W.KickVoteCode == Kicked.PlayerCode )
			W.KickVoteCode = ""; //Clear
	
	if ( OverrideReason != "" ) Reason = OverrideReason;
	
	if ( Kicked.NexGenClient != none )
	{
		ForEach Kicked.Watched.ChildActors (class'Info', NexgenRPCI) //Issue a NexGen ban if possible
			if ( NexgenRPCI.IsA('NexgenClientCore') )
			{
				class'MV_NexgenUtil'.static.banPlayer( Kicked.NexGenClient, NexgenRPCI, Reason);
				Log("[MVE] Nexgen Ban issued: "$ Kicked.NexGenClient @ NexgenRPCI, 'MapVote');
				return;
			}
	}

	While ( (i<32) && (BanList[i] != "") )
		i++;
	if ( i==32 )	i = Rand(32);
	BanList[i] = Kicked.PlayerCode;
	Log("[MVE] Added "$Kicked.PlayerCode @ "to banlist ID" @i,'MapVote');
	Kicked.Watched.Destroy();
}

function bool IpBanned( string Address)
{
	local int i;
	For ( i=0 ; i<32 ; i++ )
	{
		if ( BanList[i] == "" )
			return false;
		if ( BanList[i] == Address )
			return true;
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
				bSave = true;
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
	For ( i=lastE ; i<1024 ; i++ )
	{
		if ( MapFilters[i] != "" )
			lastE = i+1;
	}
	iFilter = lastE;
	
	lastE = 0;
	For ( i=0 ; i<32 ; i++ )
		if ( ExcludeFilters[i] != "" )
			lastE = i+1;
	iExclF = lastE;
}

function UpdateMapListCaches()
{
	local MVPlayerWatcher aList;
	
	For ( aList=WatcherList ; aList!=none ; aList=aList.nextWatcher )
	{
		if ( aList.bInitialized )
		{
			if ( aList.MapListCacheActor != none )
			{
				aList.MapListCacheActor.Destroy();
				aList.MapListCacheActor = none;
			}
			aList.GotoState('Initializing','GetCache');
		}
	}
}

function OpenWindowFor( PlayerPawn Sender, optional MVPlayerWatcher W)
{
	//local MapVoteWRI MVWRI;
	
	if ( bLevelSwitchPending )
		return;
	if ( ServerCodeName == '' )	
	{
		Sender.ClientMessage("Map Vote not setup, load map list using MUTATE BDBMAPVOTE RELOAD");
		return;
	}
	if ( W == none )
		W = GetWatcherFor( Sender);
	if ( W != none )
	{
		if ( W.MapListCacheActor == none )
			Sender.ClientMessage("Please wait, Map List Cache not retrieved");
		else if ( W.MapVoteWRIActor != none )
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
	local MVPlayerWatcher W;
	if ( bLevelSwitchPending )		return;
	For ( W=WatcherList ; W!=none ; W=W.nextWatcher )
		if ( CanVote(W.Watched) && (W.MapVoteWRIActor == none) )
			OpenWindowFor( W.Watched, W);
}

function PlayerVoted( PlayerPawn Sender, string MapString)
{
	local MVPlayerWatcher W;
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
	if ( W == none || W.bOverflow )
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
	W.bOverflow = true;
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
		GotoMap(MapString,true);
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
	local MVPlayerWatcher W, UniqueVotes[32];
	local float UniqueCount[32];
	local int i, iU, iBest, j;
	local float Total, Current;
	local bool bTie;

	if ( !bVotingStage )
	{
		For ( W=WatcherList ; W!=none ; W=W.nextWatcher )
			if ( CanVote(W.Watched) )
			{
				Total += 1;
				if ( W.PlayerVote != "" )
					Current += 1;
			}
		if ( (Current * 100 / Total) >= MidGameVotePercent )
		{
			BroadcastMessage("Mid game voting has initiated!!",True);
			GotoState('Voting','Begin');
			return;
		}
		Total = 0;
	}
	
	For ( W=WatcherList ; W!=none ; W=W.nextWatcher )
	{
		if ( CanVote(W.Watched) )
			Total += 1;
		if ( W.PlayerVote != "" )
		{
			For ( i=0 ; i<iU ; i++ )
			{
				if ( UniqueVotes[i].PlayerVote == W.PlayerVote )
				{
					UniqueCount[i] += VotePriority( int(Extension.ByDelimiter(W.PlayerVote,":",1)) );
					Goto NEXT_PLAYER;
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
	For ( i=1 ; i<iU ; i++ )
	{
		j = int(Extension.ByDelimiter( UniqueVotes[i].PlayerVote,":",1));
		FMapVotes[i] = UniqueCount[i];
		StrMapVotes[i] = string(j) $ "," $ Extension.ByDelimiter( UniqueVotes[i].PlayerVote,":") $ "," $ GameName(j) $ "," $ RuleName(j) $ "," $ string(UniqueCount[i]);
		if ( UniqueCount[i] == UniqueCount[iBest] )
			bTie = true;
		else if ( UniqueCount[i] > UniqueCount[iBest] )
		{
			iBest = i;
			bTie = false;
		}
	}

	if ( bForceTravel && UniqueVotes[iBest] == none ) //Random map
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
		GotoMap( UniqueVotes[iBest].PlayerVote, false);
		iU = int(Extension.ByDelimiter( UniqueVotes[iBest].PlayerVote,":",1));
		BroadcastMessage( Extension.ByDelimiter(UniqueVotes[iBest].PlayerVote,":") @ GameRuleCombo( iU) @ "has won by absolute majority.",True);
	}
	else if ( bForceTravel && bTie )
	{
		Current = 1;
		For ( i=iBest+1 ; i<iU ; i++ )
		{
			if ( UniqueCount[i] == UniqueCount[iBest] )
			{
				Current += 1;
				if ( 1 <= (FRand() * Current) )
					iBest = i;
			}
		}
		GotoMap( UniqueVotes[iBest].PlayerVote, false);
		iU = int(Extension.ByDelimiter( UniqueVotes[iBest].PlayerVote,":",1));
		BroadcastMessage( CapNumberWord(Current)$"map draw,"@Extension.ByDelimiter(UniqueVotes[iBest].PlayerVote,":") @ GameRuleCombo( iU) @ "selected.",True);
	}
	else if ( bForceTravel )
	{
		GotoMap( UniqueVotes[iBest].PlayerVote, false);
		iU = int(Extension.ByDelimiter( UniqueVotes[iBest].PlayerVote,":",1));
		BroadcastMessage( Extension.ByDelimiter(UniqueVotes[iBest].PlayerVote,":") @ GameRuleCombo( iU) @ "has won by simple majority.",True);
	}

	if ( !bForceTravel ) //Do not update rankings if we're leaving the map
	{
		i = 1;
		While ( i<iMapVotes )
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
		For ( i=1 ; i<iMapVotes ; i++ )
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

final function MVPlayerWatcher GetWatcherFor( PlayerPawn Other)
{
	local MVPlayerWatcher W;
	For ( W=WatcherList ; W!=none ; W=W.nextWatcher )
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
	
	For ( i=0 ; i<32 ; i++ )
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
	For ( i=0 ; i<iAlias ; i++ )
		if ( InStr(PostAlias[i], "<") >= 0 )
			PostAlias[i] = ParseAliases( PostAlias[i]);
}

final function string ParseAliases( string Command)
{
	local string preStr, aStr;
	local int i;
	
	i = InStr( Command, "<");
	While ( i >= 0 )
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
			For ( i=0 ; i<iAlias ; i++ )
			{
				if ( PreAlias[i] == aStr )
				{
					aStr = PostAlias[i];
					Goto SUCCESS;
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
		Goto END;
	LastMsg = S;
	CommonCommands( Sender, S);

	END:

	if ( DontPass( S) )
		return true;

	if ( NextMessageMutator != None )
		return NextMessageMutator.MutatorTeamMessage( Sender, Receiver, PRI, S, Type, bBeep );
	return true;
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
		return true;
}

function CommonCommands( Actor Sender, String S)
{
	if ( PlayerPawn(Sender) == none )
		return;

	if ( (S ~= "!v") || (S ~= "!vote") || (S ~= "!mapvote") || (S ~= "!kickvote") )
		Mutate( "BDBMAPVOTE VOTEMENU", PlayerPawn(Sender) );
}

defaultproperties
{
      ClientPackage="MVE2c"
      ServerInfoURL=""
      MapInfoURL=""
      HTTPMapListLocation=""
      TravelString="TDM-LiandriDocksv2?Game=Botpack.TeamGamePlus"
      CurrentMode=""
      TravelIdx=24
      VoteTimeLimit=60
      HTTPMapListPort=0
      DefaultGameTypeIdx=0
      ServerCodeName="UT-Server"
      MidGameVotePercent=51
      KickPercent=51
      MapCostAddPerLoad=0
      MapCostMaxAllow=0
      PlayerIDType=PID_Default
      bFirstRun=False
      bWelcomeWindow=False
      bSpecsAllowed=False
      bAutoOpen=True
      ScoreBoardTime=0
      ScoreBoardDelay=5
      EndGameTime=0.000000
      bKickVote=True
      bEnableHTTPMapList=False
      bLevelSwitchPending=False
      bVotingStage=False
      bMapChangeIssued=False
      bXCGE_DynLoader=False
      bOverrideServerPackages=True
      bResetServerPackages=False
      MainServerPackages=""
      DefaultSettings=""
      DefaultTickRate=0
      pos=0
      CustomGame(0)=(bEnabled=True,GameName="DeathMatch",RuleName="Instagib",GameClass="Botpack.DeathMatchPlus",FilterCode="DMlist",bHasRandom=True,VotePriority=1.000000,MutatorList="fnn155.NewNetIG,ClassicCrotchShotv1_1.CrotchShot,SBU2.SSBServerActor,fnn155.ScoreSave,MAmut.MAmut,UTChat16f.UTChat",Settings="FragLimit=30,TimeLimit=0,GameSpeed=1.00,MinPlayers=2,bUseTranslocator=False",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(1)=(bEnabled=True,GameName="DeathMatch",RuleName="SniperArena",GameClass="Botpack.DeathMatchPlus",FilterCode="DMlist",bHasRandom=True,VotePriority=1.000000,MutatorList="fnn155.NewNetSA,fnn155.UnlimitedAmmo,SPRemover.Remover,SBU2.SSBServerActor,fnn155.ScoreSave,MAmut.MAmut,UTChat16f.UTChat",Settings="FragLimit=30,TimeLimit=0,GameSpeed=1.00,MinPlayers=2,bUseTranslocator=False",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(2)=(bEnabled=True,GameName="DeathMatch",RuleName="RocketArena+",GameClass="Botpack.DeathMatchPlus",FilterCode="RA",bHasRandom=True,VotePriority=1.000000,MutatorList="ArenaFFN.Profile5,fnn155.DoubleJump,SBU2.SSBServerActor,fnn155.ScoreSave,MAmut.MAmut,UTChat16f.UTChat",Settings="FragLimit=30,GameSpeed=1.00,TimeLimit=0,MinPlayers=2,bUseTranslocator=False",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(3)=(bEnabled=True,GameName="DeathMatch",RuleName="Combogib",GameClass="Botpack.DeathMatchPlus",FilterCode="DMlist",bHasRandom=True,VotePriority=1.000000,MutatorList="fnn155.NewNetCG,fnn155.DoubleJump,SBU2.SSBServerActor,fnn155.ScoreSave,MAmut.MAmut,UTChat16f.UTChat",Settings="FragLimit=30,TimeLimit=0,GameSpeed=1.00,MinPlayers=2,bUseTranslocator=False",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(4)=(bEnabled=True,GameName="DeathMatch",RuleName="Weapons",GameClass="Botpack.DeathMatchPlus",FilterCode="DMlist",bHasRandom=True,VotePriority=1.000000,MutatorList="SBU2.SSBServerActor,fnn155.ScoreSave,MAmut.MAmut,UTChat16f.UTChat",Settings="FragLimit=30,TimeLimit=0,GameSpeed=1.00,MinPlayers=2,bUseTranslocator=True",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(5)=(bEnabled=True,GameName="DeathMatch",RuleName="Unreal1",GameClass="Botpack.DeathMatchPlus",FilterCode="DMlist",bHasRandom=True,VotePriority=1.000000,MutatorList="ArenaFFN.Profile1,WSRH.WSRH,SBU2.SSBServerActor,fnn155.ScoreSave,MAmut.MAmut,UTChat16f.UTChat",Settings="FragLimit=30,TimeLimit=0,GameSpeed=1.00,MinPlayers=2,bUseTranslocator=False",Packages="OldDispersionFFN-fixed,OldASMDFFN,OldAutoMagFFN,OldEightBallFFN,OldFlakFFN,OldRazorJackFFN,OldMinigunFFN,OldBioRifleFFN,OldStingerFFN,OldRifleFFN,OLweapons",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(6)=(bEnabled=True,GameName="DeathMatch",RuleName="Camper!",GameClass="Botpack.DeathMatchPlus",FilterCode="cmDMlist",bHasRandom=True,VotePriority=1.000000,MutatorList="fnn155.NewNetSA,fnn155.DoubleJump,SPRemover.Remover,SBU2.SSBServerActor,heineken2.heineken2,fnn155.ScoreSave,MAmut.MAmut,UTChat16f.UTChat",Settings="FragLimit=15,TimeLimit=10,GameSpeed=1.10,MinPlayers=2,bUseTranslocator=True",Packages="heineken2",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(7)=(bEnabled=True,GameName="DeathMatch",RuleName="FlakArena",GameClass="Botpack.DeathMatchPlus",FilterCode="DMlist",bHasRandom=True,VotePriority=1.000000,MutatorList="ArenaFFN.Profile7,fnn155.DoubleJump,SBU2.SSBServerActor,fnn155.ScoreSave,MAmut.MAmut,UTChat16f.UTChat",Settings="FragLimit=30,TimeLimit=0,GameSpeed=1.00,MinPlayers=2,bUseTranslocator=False",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(8)=(bEnabled=True,GameName="DeathMatch",RuleName="RandomArena",GameClass="Botpack.DeathMatchPlus",FilterCode="DMlist",bHasRandom=True,VotePriority=1.000000,MutatorList="ArenaFFN.Profile4,fnn155.DoubleJump,SBU2.SSBServerActor,fnn155.ScoreSave,MAmut.MAmut,UTChat16f.UTChat",Settings="FragLimit=30,TimeLimit=0,GameSpeed=1.00,MinPlayers=1,bUseTranslocator=False",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(9)=(bEnabled=True,GameName="DeathMatch",RuleName="Mutant 1vsAll",GameClass="Mutant.Mutant",FilterCode="DMlist",bHasRandom=True,VotePriority=1.000000,MutatorList="fnn155.NewNetIG,TimeLimit=10,SBU2.SSBServerActor,fnn155.ScoreSave,MAmut.MAmut,UTChat16f.UTChat",Settings="FragLimit=100,TimeLimit=10,bUseTranslocator=False",Packages="Mutant",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(10)=(bEnabled=True,GameName="DeathMatch",RuleName="RidiDeemer",GameClass="Botpack.DeathMatchPlus",FilterCode="DMlist",bHasRandom=True,VotePriority=1.000000,MutatorList="RidiculousDeemer.RidiculousDeemerArena,fnn155.DoubleJump,SBU2.SSBServerActor,fnn155.ScoreSave,MAmut.MAmut,UTChat16f.UTChat",Settings="FragLimit=15,TimeLimit=10,GameSpeed=1.00,MinPlayers=2,bUseTranslocator=False",Packages="RidiculousDeemer",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(11)=(bEnabled=True,GameName="DeathMatch",RuleName="PanArena",GameClass="Botpack.DeathMatchPlus",FilterCode="DMlist",bHasRandom=True,VotePriority=1.000000,MutatorList="ArenaFFN.Profile6,fnn155.DoubleJump,SBU2.SSBServerActor,fnn155.ScoreSave,MAmut.MAmut,UTChat16f.UTChat",Settings="FragLimit=15,TimeLimit=10,GameSpeed=1.00,MinPlayers=2,bUseTranslocator=False",Packages="FF_FryingPan",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(12)=(bEnabled=True,GameName="Capture The Flag",RuleName="Instagib",GameClass="Botpack.CTFGame",FilterCode="CTFlist",bHasRandom=True,VotePriority=1.000000,MutatorList="fnn155.NewNetIG,FastCap.FC_Mutator,fsb20a.FragSB,fnn155.ScoreSave,UTChat16f.UTChat",Settings="TimeLimit=15,GameSpeed=1.00,MinPlayers=2,MaxTeams=2,MaxTeamSize=16,bUseTranslocator=False",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(13)=(bEnabled=True,GameName="Capture The Flag",RuleName="Combogib",GameClass="Botpack.CTFGame",FilterCode="CTFlist",bHasRandom=True,VotePriority=1.000000,MutatorList="fnn155.NewNetCG,fnn155.DoubleJump,FastCap.FC_Mutator,fsb20a.FragSB,fnn155.ScoreSave,UTChat16f.UTChat",Settings="TimeLimit=15,GameSpeed=1.00,MinPlayers=2,MaxTeams=2,MaxTeamSize=16,bUseTranslocator=False",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(14)=(bEnabled=True,GameName="Capture The Flag",RuleName="Weapons",GameClass="Botpack.CTFGame",FilterCode="CTFlist",bHasRandom=True,VotePriority=1.000000,MutatorList="FastCap.FC_Mutator,fsb20a.FragSB,fnn155.ScoreSave,UTChat16f.UTChat",Settings="TimeLimit=15,MinPlayers=2,MaxTeams=2,MaxTeamSize=16,GameSpeed=1.00,bUseTranslocator=True",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(15)=(bEnabled=True,GameName="Capture The Flag",RuleName="FlakArena",GameClass="Botpack.CTFGame",FilterCode="CTFlist",bHasRandom=True,VotePriority=1.000000,MutatorList="ArenaFFN.Profile7,fnn155.DoubleJump,FastCap.FC_Mutator,fsb20a.FragSB,fnn155.ScoreSave,UTChat16f.UTChat",Settings="TimeLimit=15,GameSpeed=1.00,MinPlayers=2,MaxTeams=2,MaxTeamSize=16,bUseTranslocator=False",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(16)=(bEnabled=True,GameName="Capture The Flag",RuleName="SniperArena",GameClass="Botpack.CTFGame",FilterCode="CTFlist",bHasRandom=True,VotePriority=1.000000,MutatorList="fnn155.NewNetSA,fnn155.UnlimitedAmmo,fsb20a.FragSB,FastCap.FC_Mutator,SPRemover.Remover,fnn155.ScoreSave,UTChat16f.UTChat",Settings="TimeLimit=15,MinPlayers=2,MaxTeams=2,MaxTeamSize=16,GameSpeed=1.00,bUseTranslocator=False",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(17)=(bEnabled=True,GameName="Capture The Flag",RuleName="RocketArena+",GameClass="Botpack.CTFGame",FilterCode="CTFlist",bHasRandom=True,VotePriority=1.000000,MutatorList="ArenaFFN.Profile5,fsb20a.FragSB,fnn155.DoubleJump,FastCap.FC_Mutator,fnn155.ScoreSave,UTChat16f.UTChat",Settings="TimeLimit=15,MinPlayers=2,MaxTeams=2,MaxTeamSize=16,GameSpeed=1.15,bUseTranslocator=False",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(18)=(bEnabled=True,GameName="Capture The Flag",RuleName="Burger iCTF",GameClass="FFNBurgerCTF.BurgerCTFGame",FilterCode="bCTF",bHasRandom=True,VotePriority=1.000000,MutatorList="fnn155.NewNetIG,fnn155.DoubleJump,fsb20a.FragSB,fnn155.ScoreSave,UTChat16f.UTChat",Settings="TimeLimit=15,GameSpeed=1.00,MinPlayers=2,bUseTranslocator=False",Packages="FFNBurgerCTF",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(19)=(bEnabled=True,GameName="Capture The Flag",RuleName="CTF4 Insta",GameClass="CTF4.CTF4Game",FilterCode="CTF4list",bHasRandom=True,VotePriority=1.000000,MutatorList="fnn155.NewNetIG,fnn155.DoubleJump,fsb20a.FragSB,UTChat16f.UTChat",Settings="TimeLimit=15,MinPlayers=4,MaxTeamSize=4,MaxTeams=4,GameSpeed=1.00,bUseTranslocator=False",Packages="CTF4",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(20)=(bEnabled=True,GameName="Capture The Flag",RuleName="CTF4 Weapons",GameClass="CTF4.CTF4Game",FilterCode="CTF4list",bHasRandom=True,VotePriority=1.000000,MutatorList="fnn155.DoubleJump,fnn155.GiveWeapons,fsb20a.FragSB,UTChat16f.UTChat",Settings="TimeLimit=15,MinPlayers=4,MaxTeamSize=4,MaxTeams=4,GameSpeed=1.00,bUseTranslocator=False",Packages="CTF4",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(21)=(bEnabled=True,GameName="Capture The Flag",RuleName="Strangelove",GameClass="Botpack.CTFGame",FilterCode="slCTFlist",bHasRandom=True,VotePriority=1.000000,MutatorList="ArenaFFN2.Profile1,fnn155.DoubleJump,fnn155.RXFix,NoSLPickup120.PickupMutator,FastCap.FC_Mutator,fsb20a.FragSB,fnn155.ScoreSave,UTChat16f.UTChat",Settings="TimeLimit=15,MinPlayers=2,MaxTeams=2,MaxTeamSize=16,GameSpeed=1.15,bUseTranslocator=False",Packages="SLV204,SLV2Models,SLV2Sounds,SLV2Textures,SLV2Fonts",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(22)=(bEnabled=True,GameName="Capture The Flag",RuleName="XVehicleCTF TEST",GameClass="Botpack.CTFGame",FilterCode="vCTFlist",bHasRandom=False,VotePriority=1.000000,MutatorList="XVehicles.XVehiclesCTF,fnn155.DoubleJump,fsb20a.FragSB,FixCTFBots.FixCTFBots,UTChat16f.UTChat",Settings="FragLimit=30,GameSpeed=1.00,MinPlayers=2,bUseTranslocator=False",Packages="XVehicles,XTreadVeh,XWheelVeh,xZones",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(23)=(bEnabled=True,GameName="Team DeathMatch",RuleName="Instagib",GameClass="BotPack.TeamGamePlus",FilterCode="TDMlist",bHasRandom=True,VotePriority=1.000000,MutatorList="fnn155.NewNetIG,fsb20a.FragSB,fnn155.ScoreSave,UTChat16f.UTChat",Settings="GameSpeed=1.00,MaxTeams=2,MaxTeamSize=16,MinPlayers=1,TimeLimit=15,bUseTranslocator=False",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(24)=(bEnabled=True,GameName="Team Deathmatch",RuleName="Combogib",GameClass="Botpack.TeamGamePlus",FilterCode="TDMlist",bHasRandom=True,VotePriority=1.000000,MutatorList="fnn155.NewNetCG,fnn155.DoubleJump,fsb20a.FragSB,fnn155.ScoreSave,UTChat16f.UTChat",Settings="GameSpeed=1.00,MaxTeams=2,MaxTeamSize=16,MinPlayers=1,TimeLimit=15,bUseTranslocator=False",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(25)=(bEnabled=True,GameName="Team Deathmatch",RuleName="Weapons",GameClass="Botpack.TeamGamePlus",FilterCode="TDMlist",bHasRandom=True,VotePriority=1.000000,MutatorList="fsb20a.FragSB,fnn155.ScoreSave,UTChat16f.UTChat",Settings="GameSpeed=1.00,MaxTeams=2,MaxTeamSize=16,MinPlayers=1,TimeLimit=15,bUseTranslocator=True",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(26)=(bEnabled=True,GameName="Team DeathMatch",RuleName="RocketArena+",GameClass="BotPack.TeamGamePlus",FilterCode="TDMlist",bHasRandom=True,VotePriority=1.000000,MutatorList="ArenaFFN.Profile5,fnn155.DoubleJump,fsb20a.FragSB,fnn155.ScoreSave,UTChat16f.UTChat",Settings="GameSpeed=1.00,MaxTeams=2,MaxTeamSize=16,MinPlayers=1,TimeLimit=15,bUseTranslocator=False",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(27)=(bEnabled=True,GameName="Team DeathMatch",RuleName="SniperArena",GameClass="BotPack.TeamGamePlus",FilterCode="TDMlist",bHasRandom=True,VotePriority=1.000000,MutatorList="fnn155.NewNetSA,fsb20a.FragSB,fnn155.UnlimitedAmmo,fnn155.ScoreSave,UTChat16f.UTChat",Settings="GameSpeed=1.00,MaxTeams=2,MaxTeamSize=16,MinPlayers=1,TimeLimit=15,bUseTranslocator=False",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(28)=(bEnabled=True,GameName="Team DeathMatch",RuleName="Instagib xTDM",GameClass="BotPack.TeamGamePlus",FilterCode="TDMlist",bHasRandom=True,VotePriority=1.000000,MutatorList="fnn155.NewNetIG,SmartSB103.SmartSB,MAmut.MAmut,fnn155.ScoreSave,UTChat16f.UTChat",Settings="MinPlayers=4,GameSpeed=1.00,MaxTeams=4,MaxTeamSize=4,TimeLimit=15,bUseTranslocator=False",Packages="SmartSB103",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(29)=(bEnabled=True,GameName="Last Man Standing",RuleName="Instagib",GameClass="fnn155.LastManStanding",FilterCode="DMlist",bHasRandom=True,VotePriority=1.000000,MutatorList="fnn155.NewNetIG,SBU2.SSBServerActor,ClassicCrotchShotv1_1.CrotchShot,fnn155.ScoreSave,MAmut.MAmut,UTChat16f.UTChat",Settings="GameSpeed=1.00,TimeLimit=10,MinPlayers=0,bUseTranslocator=False,FragLimit=10",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(30)=(bEnabled=True,GameName="Last Man Standing",RuleName="Combogib",GameClass="fnn155.LastManStanding",FilterCode="DMlist",bHasRandom=True,VotePriority=1.000000,MutatorList="fnn155.NewNetCG,fnn155.DoubleJump,SBU2.SSBServerActor,fnn155.ScoreSave,MAmut.MAmut,UTChat16f.UTChat",Settings="GameSpeed=1.00,TimeLimit=10,MinPlayers=0,bUseTranslocator=False,FragLimit=10",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(31)=(bEnabled=True,GameName="Last Man Standing",RuleName="SniperArena",GameClass="fnn155.LastManStanding",FilterCode="DMlist",bHasRandom=True,VotePriority=1.000000,MutatorList="fnn155.NewNetSA,SBU2.SSBServerActor,SPRemover.Remover,fnn155.ScoreSave,MAmut.MAmut,UTChat16f.UTChat",Settings="GameSpeed=1.00,TimeLimit=10,MinPlayers=0,bUseTranslocator=False,FragLimit=10",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(32)=(bEnabled=True,GameName="Last Man Standing",RuleName="Weapons",GameClass="fnn155.LastManStanding",FilterCode="DMlist",bHasRandom=True,VotePriority=1.000000,MutatorList="SBU2.SSBServerActor,fnn155.ScoreSave,MAmut.MAmut,UTChat16f.UTChat",Settings="GameSpeed=1.00,TimeLimit=10,MinPlayers=0,bUseTranslocator=True,FragLimit=10",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(33)=(bEnabled=True,GameName="Low Gravity Game",RuleName="Instagib DM",GameClass="Botpack.DeathMatchPlus",FilterCode="lgDMist",bHasRandom=True,VotePriority=1.000000,MutatorList="fnn155.NewNetZIG,fnn155.DoubleJump,BotPack.LowGrav,SBU2.SSBServerActor,fnn155.ScoreSave,MAmut.MAmut,UTChat16f.UTChat",Settings="FragLimit=30,GameSpeed=1.25,TimeLimit=10,MinPlayers=2,bUseTranslocator=False",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(34)=(bEnabled=True,GameName="Low Gravity Game",RuleName="Instagib CTF",GameClass="Botpack.CTFGame",FilterCode="lgCTFlist",bHasRandom=True,VotePriority=1.000000,MutatorList="fnn155.NewNetZIG,fnn155.DoubleJump,fsb20a.FragSB,BotPack.LowGrav,FastCap.FC_Mutator,fnn155.ScoreSave,UTChat16f.UTChat",Settings="TimeLimit=15,GameSpeed=1.25,MinPlayers=2,bUseTranslocator=False",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(35)=(bEnabled=True,GameName="Low Gravity Game",RuleName="Sniper DM",GameClass="Botpack.DeathMatchPlus",FilterCode="lgDMist",bHasRandom=True,VotePriority=1.000000,MutatorList="fnn155.NewNetSA,fnn155.DoubleJump,BotPack.LowGrav,fnn155.UnlimitedAmmo,SBU2.SSBServerActor,fnn155.ScoreSave,MAmut.MAmut,UTChat16f.UTChat",Settings="FragLimit=30,GameSpeed=1.25,TimeLimit=10,MinPlayers=2,bUseTranslocator=False",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(36)=(bEnabled=True,GameName="Low Gravity Game",RuleName="Sniper CTF",GameClass="Botpack.CTFGame",FilterCode="lgCTFlist",bHasRandom=True,VotePriority=1.000000,MutatorList="fnn155.NewNetSA,fnn155.DoubleJump,fsb20a.FragSB,BotPack.LowGrav,fnn155.UnlimitedAmmo,FastCap.FC_Mutator,SPRemover.Remover,fnn155.ScoreSave,UTChat16f.UTChat",Settings="TimeLimit=15,GameSpeed=1.25,MinPlayers=2,bUseTranslocator=False",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(37)=(bEnabled=True,GameName="Low Gravity Game",RuleName="RocketArena+ DM",GameClass="Botpack.DeathMatchPlus",FilterCode="lgDMist",bHasRandom=True,VotePriority=1.000000,MutatorList="ArenaFFN.Profile5,BotPack.LowGrav,fnn155.DoubleJump,SBU2.SSBServerActor,fnn155.ScoreSave,MAmut.MAmut,UTChat16f.UTChat",Settings="FragLimit=30,GameSpeed=1.25,MinPlayers=2,bUseTranslocator=False,FragLimit=30",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(38)=(bEnabled=True,GameName="Low Gravity Game",RuleName="RocketArena+ CTF",GameClass="Botpack.CTFGame",FilterCode="lgCTFlist",bHasRandom=True,VotePriority=1.000000,MutatorList="ArenaFFN.Profile5,BotPack.LowGrav,fnn155.DoubleJump,FastCap.FC_Mutator,fsb20a.FragSB,fnn155.ScoreSave,UTChat16f.UTChat",Settings="TimeLimit=15,GameSpeed=1.25,MinPlayers=2,bUseTranslocator=False",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(39)=(bEnabled=True,GameName="Co-op Campaigns",RuleName="Unreal Campaign",GameClass="CoopFFNxv3.CoopFFN",FilterCode="premadeu",bHasRandom=False,VotePriority=1.000000,MutatorList="ArenaFFN.Profile3,fnn155.DoubleJump,fnn155.TeleportToPoint,SBU2.SSBServerActor,MAmut.MAmut",Settings="GameSpeed=1.00,MinPlayers=0",Packages="CoopFFNxv3,OldDispersionFFN-fixed,OldASMDFFN,OldAutoMagFFN,OldEightBallFFN,OldFlakFFN,OldRazorJackFFN,OldMinigunFFN,OldBioRifleFFN,OldStingerFFN,OldRifleFFN",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(40)=(bEnabled=True,GameName="Co-op Campaigns",RuleName="VA Coop Maps",GameClass="CoopFFNxv3.CoopFFN",FilterCode="premadeVA",bHasRandom=True,VotePriority=1.000000,MutatorList="ArenaFFN.Profile3,fnn155.DoubleJump,fnn155.TeleportToPoint,SBU2.SSBServerActor,MAmut.MAmut",Settings="GameSpeed=1.00,MinPlayers=0",Packages="CoopFFNxv3,OldDispersionFFN-fixed,OldASMDFFN,OldAutoMagFFN,OldEightBallFFN,OldFlakFFN,OldRazorJackFFN,OldMinigunFFN,OldBioRifleFFN,OldStingerFFN,OldRifleFFN",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(41)=(bEnabled=True,GameName="Co-op Campaigns",RuleName="Operation Napali",GameClass="CoopFFNxv3.CoopFFN",FilterCode="NP",bHasRandom=False,VotePriority=1.000000,MutatorList="ArenaFFN.Profile3,fnn155.DoubleJump,fnn155.TeleportToPoint,SBU2.SSBServerActor,MAmut.MAmut",Settings="GameSpeed=1.00,MinPlayers=0",Packages="CoopFFNxv3,OldDispersionFFN-fixed,OldASMDFFN,OldAutoMagFFN,OldEightBallFFN,OldFlakFFN,OldRazorJackFFN,OldMinigunFFN,OldBioRifleFFN,OldStingerFFN,OldRifleFFN",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(42)=(bEnabled=True,GameName="Co-op Campaigns",RuleName="Xidia & Xidia Gold",GameClass="CoopFFNxv3.CoopFFN",FilterCode="Xid",bHasRandom=False,VotePriority=1.000000,MutatorList="ArenaFFN.Profile3,fnn155.DoubleJump,fnn155.TeleportToPoint,SBU2.SSBServerActor,MAmut.MAmut",Settings="GameSpeed=1.00,MinPlayers=0",Packages="CoopFFNxv3,OldDispersionFFN-fixed,OldASMDFFN,OldAutoMagFFN,OldEightBallFFN,OldFlakFFN,OldRazorJackFFN,OldMinigunFFN,OldBioRifleFFN,OldStingerFFN,OldRifleFFN",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(43)=(bEnabled=True,GameName="Co-op Campaigns",RuleName="Nali Chronicles",GameClass="CoopFFNxv3.CoopFFN",FilterCode="NC",bHasRandom=False,VotePriority=1.000000,MutatorList="ArenaFFN.Profile3,fnn155.DoubleJump,fnn155.TeleportToPoint,SBU2.SSBServerActor,MAmut.MAmut",Settings="GameSpeed=1.00,MinPlayers=0",Packages="CoopFFNxv3,OldDispersionFFN-fixed,OldASMDFFN,OldAutoMagFFN,OldEightBallFFN,OldFlakFFN,OldRazorJackFFN,OldMinigunFFN,OldBioRifleFFN,OldStingerFFN,OldRifleFFN",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(44)=(bEnabled=True,GameName="Co-op Campaigns",RuleName="Return To Napali",GameClass="CoopFFNxv3.CoopFFN",FilterCode="premadertnp",bHasRandom=False,VotePriority=1.000000,MutatorList="ArenaFFN.Profile3,fnn155.DoubleJump,fnn155.TeleportToPoint,SBU2.SSBServerActor,MAmut.MAmut",Settings="GameSpeed=1.00,MinPlayers=0",Packages="CoopFFNxv3,OldDispersionFFN-fixed,OldASMDFFN,OldAutoMagFFN,OldEightBallFFN,OldFlakFFN,OldRazorJackFFN,OldMinigunFFN,OldBioRifleFFN,OldStingerFFN,OldRifleFFN",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(45)=(bEnabled=True,GameName="Co-op Campaigns",RuleName="PSX-Rise of J'rath",GameClass="CoopFFNxv3.CoopFFN",FilterCode="UPB",bHasRandom=False,VotePriority=1.000000,MutatorList="ArenaFFN.Profile3,fnn155.DoubleJump,fnn155.TeleportToPoint,SBU2.SSBServerActor,MAmut.MAmut",Settings="GameSpeed=1.00,MinPlayers=0",Packages="CoopFFNxv3,OldDispersionFFN-fixed,OldASMDFFN,OldAutoMagFFN,OldEightBallFFN,OldFlakFFN,OldRazorJackFFN,OldMinigunFFN,OldBioRifleFFN,OldStingerFFN,OldRifleFFN",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(46)=(bEnabled=True,GameName="Monster Hunt",RuleName="Classic",GameClass="MonsterHunt2v3.MonsterHunt",FilterCode="MH",bHasRandom=True,VotePriority=1.000000,MutatorList="ArenaFFN.Profile2,fnn155.DoubleJump,fnn155.TeleportToPoint,fsb20a.FragSB,UTChat16f.UTChat",Settings="GameSpeed=1.00,MinPlayers=0,MaxTeams=1",Packages="MonsterHunt,MonsterHunt2v3,OldDispersionFFN-fixed,OldASMDFFN,OldAutoMagFFN,OldEightBallFFN,OldFlakFFN,OldRazorJackFFN,OldMinigunFFN,OldBioRifleFFN,OldStingerFFN,OldRifleFFN,OLweapons",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(47)=(bEnabled=True,GameName="Monster Hunt",RuleName="Combogib",GameClass="MonsterHunt2v3.MonsterHunt",FilterCode="iMH",bHasRandom=True,VotePriority=1.000000,MutatorList="fnn155.NewNetCG,fnn155.DoubleJump,fsb20a.FragSB,fnn155.TeleportToPoint,MAmut.MAmut,UTChat16f.UTChat",Settings="GameSpeed=1.00,MinPlayers=1",Packages="MonsterHunt,MonsterHunt2v3",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(48)=(bEnabled=True,GameName="Monster Hunt",RuleName="Nali Weapons III",GameClass="MonsterHunt2v3.MonsterHunt",FilterCode="NW3",bHasRandom=True,VotePriority=1.000000,MutatorList="fnn155.DisableWeapons,fnn155.DoubleJump,fnn155.TeleportToPoint,MAmut.MAmut,fsb20a.FragSB,UTChat16f.UTChat,SYF.StopYourFighting,NWCoreVIII.NWMainReplacer,NWModifiersVIII.ModifMut,NWMHExtrasVIII.NWMHMut,TheOneModifierV1.NWTheOneModifier,NWUltraGoreSSEa.NWBloodyMess_UGSSE",Settings="GameSpeed=1.00,MinPlayers=0,TimeLimit=90",Packages="MonsterHunt,MonsterHunt2v3,NWCoreVIII,NWExtrasVIII,NWModifiersVIII,NWBoltRifleVIII,NWCybotLauncherVIII,NWFlameTrackerVIII,NWFreezerVIII,NWGravitonVIII,NWIonizerVIII,NWIRPRVIII,NWMegatonVIII,NWMultiMissileVIII,NWNuclearFXVIII,NWNuclearLauncherVIII,NWRTVIII,NWSuperBoltRifleVIII,NWTheExecutionerVIII,NWTheMinerVIII,NWTheOversurrectorVIII,NWUltimaProtosVIII,NWVulcanVIII,TheOneModifierV1,NWWREVIII,NWUltraGoreSSEa,ExuWeaponsLiteV4a,SackTest1",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(49)=(bEnabled=True,GameName="Domination",RuleName="Instagib",GameClass="Botpack.Domination",FilterCode="iDOM",bHasRandom=True,VotePriority=1.000000,MutatorList="fnn155.NewNetIG,fsb20a.FragSB,MAmut.MAmut,UTChat16f.UTChat",Settings="GameSpeed=1.00,TimeLimit=15,bUseTranslocator=False",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(50)=(bEnabled=True,GameName="Domination",RuleName="Weapons",GameClass="Botpack.Domination",FilterCode="DOM",bHasRandom=True,VotePriority=1.000000,MutatorList="fnn155.GiveWeapons,fsb20a.FragSB,MAmut.MAmut,UTChat16f.UTChat",Settings="GameSpeed=1.00,bUseTranslocator=True",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(51)=(bEnabled=True,GameName="GunGames",RuleName="DeathMatch",GameClass="Botpack.DeathMatchPlus",FilterCode="DMlist",bHasRandom=True,VotePriority=1.000000,MutatorList="GunGameFFN.Profile3,SBU2.SSBServerActor,MAmut.MAmut,UTChat16f.UTChat",Settings="TimeLimit=0,MinPlayers=2,GameSpeed=1.00",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(52)=(bEnabled=True,GameName="GunGames",RuleName="Capture The Flag",GameClass="Botpack.CTFGame",FilterCode="CTFlist",bHasRandom=True,VotePriority=1.000000,MutatorList="GunGameFFN.Profile4,FastCap.FC_Mutator,fsb20a.FragSB,UTChat16f.UTChat",Settings="TimeLimit=15,GameSpeed=1.00,MinPlayers=2,MaxTeams=2,MaxTeamSize=16,bUseTranslocator=False",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(53)=(bEnabled=True,GameName="GunGames",RuleName="Last Man Standing",GameClass="fnn155.LastManStanding",FilterCode="DMlist",bHasRandom=True,VotePriority=1.000000,MutatorList="GunGameFFN.Profile5,fnn155.DoubleJump,SBU2.SSBServerActor,MAmut.MAmut,UTChat16f.UTChat",Settings="GameSpeed=1.00,MinPlayers=2,bUseTranslocator=False,FragLimit=11",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(54)=(bEnabled=True,GameName="JailBreak",RuleName="Instagib",GameClass="JailBreak.JailBreak",FilterCode="JBlist",bHasRandom=False,VotePriority=1.000000,MutatorList="fnn155.NewNetIG,fnn155.DoubleJump,JailPeace.JailPeace,JBRSIndicator.JBRSIndicator,NoJailKill.NoJailKill,WrongJailCB.WrongJail,MAmut.MAmut,UTChat16f.UTChat",Settings="GameSpeed=1.00,bNoLlamas=True",Packages="JailBreak,JBArena,JBRSIndicator,JailFight,WrongJailCB,NoJailKill,NoFeignDeath",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(55)=(bEnabled=True,GameName="JailBreak",RuleName="RocketArena+",GameClass="JailBreak.JailBreak",FilterCode="JBlist",bHasRandom=False,VotePriority=1.000000,MutatorList="ArenaFFN.Profile5,fnn155.DoubleJump,JailPeace.JailPeace,JBRSIndicator.JBRSIndicator,NoJailKill.NoJailKill,WrongJailCB.WrongJail,MAmut.MAmut,UTChat16f.UTChat",Settings="GameSpeed=1.00,bNoLlamas=True",Packages="JailBreak,JBArena,JBRSIndicator,JailFight,WrongJailCB,NoJailKill,NoFeignDeath",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(56)=(bEnabled=True,GameName="JailBreak",RuleName="Weapons",GameClass="JailBreak.JailBreak",FilterCode="JBlist",bHasRandom=False,VotePriority=1.000000,MutatorList="fnn155.GiveWeapons,fnn155.DoubleJump,JailPeace.JailPeace,JBRSIndicator.JBRSIndicator,NoJailKill.NoJailKill,WrongJailCB.WrongJail,MAmut.MAmut,UTChat16f.UTChat",Settings="GameSpeed=1.00,MinPlayers=2",Packages="JailBreak,JBArena,JBRSIndicator,JailFight,WrongJailCB,NoJailKill,NoFeignDeath",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(57)=(bEnabled=True,GameName="Assault",RuleName="Instagib",GameClass="LeagueAS140.LeagueAssault",FilterCode="ASlist",bHasRandom=True,VotePriority=1.000000,MutatorList="fnn155.NewNetIG,fnn155.DoubleJump,fsb20a.FragSB,UTChat16f.UTChat",Settings="GameSpeed=1.00",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(58)=(bEnabled=True,GameName="Assault",RuleName="Weapons",GameClass="LeagueAS140.LeagueAssault",FilterCode="ASlist",bHasRandom=True,VotePriority=1.000000,MutatorList="fnn155.DoubleJump,fsb20a.FragSB,UTChat16f.UTChat",Settings="GameSpeed=1.00",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(59)=(bEnabled=True,GameName="Misc.",RuleName="BunnyTrack",GameClass="BTGame.BTGame",FilterCode="CTF-BT",bHasRandom=True,VotePriority=1.000000,MutatorList="fnn155.CmdMut,UTChat16f.UTChat",Settings="GameSpeed=1.00",Packages="BTGame",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(60)=(bEnabled=True,GameName="Misc.",RuleName="SoccerUT",GameClass="Soccer.SoccerMatch",FilterCode="SCR",bHasRandom=True,VotePriority=1.000000,MutatorList="fnn155.CmdMut",Settings="",Packages="Soccer,SoccerFonts",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(61)=(bEnabled=True,GameName="Misc.",RuleName="NuclearRaces",GameClass="NuclearRacesBETA1-3.NuclearRace",FilterCode="NR",bHasRandom=False,VotePriority=1.000000,MutatorList="SLV205.StrangeMutator,ArenaFFN.Profile8,fnn155.RXFix,fnn155.DoubleJump,UTChat16f.UTChat",Settings="GameSpeed=1.00,MinPlayers=2,bUseTranslocator=False",Packages="NuclearRacesBETA1-3,SLV205,SLV2Models,SLV2Sounds,SLV2Textures,SLV2Fonts",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(62)=(bEnabled=True,GameName="DeathMatch",RuleName="RipperArena",GameClass="Botpack.DeathMatchPlus",FilterCode="DMlist",bHasRandom=True,VotePriority=1.000000,MutatorList="ArenaFFN.Profile2,fnn155.DoubleJump,ClassicCrotchShotv1_1.CrotchShot,SBU2.SSBServerActor,fnn155.ScoreSave,MAmut.MAmut,UTChat16f.UTChat",Settings="FragLimit=30,TimeLimit=0,GameSpeed=1.00,MinPlayers=2,bUseTranslocator=False",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(63)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(64)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(65)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(66)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(67)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(68)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(69)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(70)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(71)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(72)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(73)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(74)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(75)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(76)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(77)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(78)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(79)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(80)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(81)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(82)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(83)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(84)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(85)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(86)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(87)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(88)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(89)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(90)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(91)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(92)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(93)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(94)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(95)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(96)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(97)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(98)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(99)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(100)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(101)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(102)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(103)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(104)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(105)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(106)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(107)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(108)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(109)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(110)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(111)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(112)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(113)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(114)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(115)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(116)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(117)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(118)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(119)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(120)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(121)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(122)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(123)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(124)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(125)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(126)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(127)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(128)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(129)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(130)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(131)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(132)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(133)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(134)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(135)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(136)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(137)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(138)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(139)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(140)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(141)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(142)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(143)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(144)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(145)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(146)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(147)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(148)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(149)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(150)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(151)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(152)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(153)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(154)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(155)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(156)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(157)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(158)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(159)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(160)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(161)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(162)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(163)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(164)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(165)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(166)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(167)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(168)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(169)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(170)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(171)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(172)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(173)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(174)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(175)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(176)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(177)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(178)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(179)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(180)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(181)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(182)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(183)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(184)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(185)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(186)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(187)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(188)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(189)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(190)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(191)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(192)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(193)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(194)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(195)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(196)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(197)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(198)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(199)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(200)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(201)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(202)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(203)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(204)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(205)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(206)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(207)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(208)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(209)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(210)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(211)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(212)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(213)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(214)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(215)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(216)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(217)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(218)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(219)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(220)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(221)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(222)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(223)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(224)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(225)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(226)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(227)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(228)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(229)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(230)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(231)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(232)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(233)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(234)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(235)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(236)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(237)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(238)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(239)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(240)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(241)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(242)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(243)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(244)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(245)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(246)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(247)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(248)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(249)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(250)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(251)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(252)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(253)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(254)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(255)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(256)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(257)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(258)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(259)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(260)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(261)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(262)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(263)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(264)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(265)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(266)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(267)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(268)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(269)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(270)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(271)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(272)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(273)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(274)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(275)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(276)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(277)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(278)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(279)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(280)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(281)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(282)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(283)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(284)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(285)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(286)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(287)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(288)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(289)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(290)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(291)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(292)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(293)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(294)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(295)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(296)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(297)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(298)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(299)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(300)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(301)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(302)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(303)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(304)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(305)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(306)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(307)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(308)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(309)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(310)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(311)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(312)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(313)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(314)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(315)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(316)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(317)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(318)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(319)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(320)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(321)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(322)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(323)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(324)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(325)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(326)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(327)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(328)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(329)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(330)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(331)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(332)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(333)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(334)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(335)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(336)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(337)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(338)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(339)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(340)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(341)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(342)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(343)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(344)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(345)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(346)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(347)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(348)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(349)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(350)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(351)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(352)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(353)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(354)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(355)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(356)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(357)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(358)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(359)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(360)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(361)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(362)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(363)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(364)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(365)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(366)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(367)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(368)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(369)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(370)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(371)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(372)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(373)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(374)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(375)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(376)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(377)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(378)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(379)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(380)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(381)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(382)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(383)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(384)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(385)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(386)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(387)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(388)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(389)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(390)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(391)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(392)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(393)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(394)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(395)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(396)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(397)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(398)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(399)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(400)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(401)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(402)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(403)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(404)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(405)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(406)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(407)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(408)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(409)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(410)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(411)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(412)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(413)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(414)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(415)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(416)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(417)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(418)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(419)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(420)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(421)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(422)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(423)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(424)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(425)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(426)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(427)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(428)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(429)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(430)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(431)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(432)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(433)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(434)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(435)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(436)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(437)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(438)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(439)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(440)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(441)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(442)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(443)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(444)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(445)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(446)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(447)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(448)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(449)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(450)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(451)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(452)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(453)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(454)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(455)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(456)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(457)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(458)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(459)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(460)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(461)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(462)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(463)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(464)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(465)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(466)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(467)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(468)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(469)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(470)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(471)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(472)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(473)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(474)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(475)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(476)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(477)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(478)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(479)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(480)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(481)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(482)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(483)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(484)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(485)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(486)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(487)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(488)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(489)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(490)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(491)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(492)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(493)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(494)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(495)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(496)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(497)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(498)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(499)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(500)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(501)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(502)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(503)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(504)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(505)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(506)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(507)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(508)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(509)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(510)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(511)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      EmptyGame=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=False,VotePriority=0.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      iGames=0
      Aliases(0)=""
      Aliases(1)=""
      Aliases(2)=""
      Aliases(3)=""
      Aliases(4)=""
      Aliases(5)=""
      Aliases(6)=""
      Aliases(7)=""
      Aliases(8)=""
      Aliases(9)=""
      Aliases(10)=""
      Aliases(11)=""
      Aliases(12)=""
      Aliases(13)=""
      Aliases(14)=""
      Aliases(15)=""
      Aliases(16)=""
      Aliases(17)=""
      Aliases(18)=""
      Aliases(19)=""
      Aliases(20)=""
      Aliases(21)=""
      Aliases(22)=""
      Aliases(23)=""
      Aliases(24)=""
      Aliases(25)=""
      Aliases(26)=""
      Aliases(27)=""
      Aliases(28)=""
      Aliases(29)=""
      Aliases(30)=""
      Aliases(31)=""
      PreAlias(0)=""
      PreAlias(1)=""
      PreAlias(2)=""
      PreAlias(3)=""
      PreAlias(4)=""
      PreAlias(5)=""
      PreAlias(6)=""
      PreAlias(7)=""
      PreAlias(8)=""
      PreAlias(9)=""
      PreAlias(10)=""
      PreAlias(11)=""
      PreAlias(12)=""
      PreAlias(13)=""
      PreAlias(14)=""
      PreAlias(15)=""
      PreAlias(16)=""
      PreAlias(17)=""
      PreAlias(18)=""
      PreAlias(19)=""
      PreAlias(20)=""
      PreAlias(21)=""
      PreAlias(22)=""
      PreAlias(23)=""
      PreAlias(24)=""
      PreAlias(25)=""
      PreAlias(26)=""
      PreAlias(27)=""
      PreAlias(28)=""
      PreAlias(29)=""
      PreAlias(30)=""
      PreAlias(31)=""
      PostAlias(0)=""
      PostAlias(1)=""
      PostAlias(2)=""
      PostAlias(3)=""
      PostAlias(4)=""
      PostAlias(5)=""
      PostAlias(6)=""
      PostAlias(7)=""
      PostAlias(8)=""
      PostAlias(9)=""
      PostAlias(10)=""
      PostAlias(11)=""
      PostAlias(12)=""
      PostAlias(13)=""
      PostAlias(14)=""
      PostAlias(15)=""
      PostAlias(16)=""
      PostAlias(17)=""
      PostAlias(18)=""
      PostAlias(19)=""
      PostAlias(20)=""
      PostAlias(21)=""
      PostAlias(22)=""
      PostAlias(23)=""
      PostAlias(24)=""
      PostAlias(25)=""
      PostAlias(26)=""
      PostAlias(27)=""
      PostAlias(28)=""
      PostAlias(29)=""
      PostAlias(30)=""
      PostAlias(31)=""
      iAlias=0
      MapFilters(0)="DMlist DM-*"
      MapFilters(1)="RA RA-*"
      MapFilters(2)="cmDMlist DM-!*"
      MapFilters(3)="CTFlist CTF-*"
      MapFilters(4)="bCTF bCTF-*"
      MapFilters(5)="CTF4list CTF4-*"
      MapFilters(6)="slCTFlist slCTF-*"
      MapFilters(7)="vCTFlist CTF-XV*"
      MapFilters(8)="TDMlist TDM-*"
      MapFilters(9)="lgDM lgDM-*"
      MapFilters(10)="lgCTFlist lgCTF-*"
      MapFilters(11)="lgDM lgDM-*"
      MapFilters(12)="NP NP*"
      MapFilters(13)="Xid Xid*"
      MapFilters(14)="NC NC*"
      MapFilters(15)="UPB UPB*"
      MapFilters(16)="MH MH-*"
      MapFilters(17)="iMH MH-*"
      MapFilters(18)="NW3 NW3-*"
      MapFilters(19)="iDOM DOM-*"
      MapFilters(20)="DOM DOM-*"
      MapFilters(21)="CTF CTF-*"
      MapFilters(22)="DOM DOM-*"
      MapFilters(23)="JBlist JB-*"
      MapFilters(24)="ASlist AS-*"
      MapFilters(25)="CTF-BT CTF-BT-*"
      MapFilters(26)="SCR SCR-*"
      MapFilters(27)="NR NR-*"
      MapFilters(28)=""
      MapFilters(29)=""
      MapFilters(30)=""
      MapFilters(31)=""
      MapFilters(32)=""
      MapFilters(33)=""
      MapFilters(34)=""
      MapFilters(35)=""
      MapFilters(36)=""
      MapFilters(37)=""
      MapFilters(38)=""
      MapFilters(39)=""
      MapFilters(40)=""
      MapFilters(41)=""
      MapFilters(42)=""
      MapFilters(43)=""
      MapFilters(44)=""
      MapFilters(45)=""
      MapFilters(46)=""
      MapFilters(47)=""
      MapFilters(48)=""
      MapFilters(49)=""
      MapFilters(50)=""
      MapFilters(51)=""
      MapFilters(52)=""
      MapFilters(53)=""
      MapFilters(54)=""
      MapFilters(55)=""
      MapFilters(56)=""
      MapFilters(57)=""
      MapFilters(58)=""
      MapFilters(59)=""
      MapFilters(60)=""
      MapFilters(61)=""
      MapFilters(62)="DMlist DM-*"
      MapFilters(63)=""
      MapFilters(64)=""
      MapFilters(65)=""
      MapFilters(66)="premadeu DKVortex2"
      MapFilters(67)="premadeu DKNyleve"
      MapFilters(68)="premadeu DKdig"
      MapFilters(69)="premadeu DKdug"
      MapFilters(70)="premadeu DKpassage"
      MapFilters(71)="premadeu DKChizra"
      MapFilters(72)="premadeu DKceremony"
      MapFilters(73)="premadeu DKdark"
      MapFilters(74)="premadeu DKharobed"
      MapFilters(75)="premadeu DKTerraLift"
      MapFilters(76)="premadeu DKterraniux"
      MapFilters(77)="premadeu DKNoork"
      MapFilters(78)="premadeu DKRuins"
      MapFilters(79)="premadeu DKTrench"
      MapFilters(80)="premadeu DKisvkran4"
      MapFilters(81)="premadeu DKIsvkran32"
      MapFilters(82)="premadeu DKISVDECK1"
      MapFilters(83)="premadeu DKspirevillage"
      MapFilters(84)="premadeu DKThesunspire"
      MapFilters(85)="premadeu DKSkycaves"
      MapFilters(86)="premadeu DKSkyTown"
      MapFilters(87)="premadeu DKSkyBase"
      MapFilters(88)="premadeu DKVeloraEnd"
      MapFilters(89)="premadeu DKBluff"
      MapFilters(90)="premadeu DKdasapass"
      MapFilters(91)="premadeu DKdasacellars"
      MapFilters(92)="premadeu DKnaliboat"
      MapFilters(93)="premadeu DKNALIC"
      MapFilters(94)="premadeu DKNaliLord"
      MapFilters(95)="premadeu DKDCrater"
      MapFilters(96)="premadeu DKextremebeg"
      MapFilters(97)="premadeu DKextremelab"
      MapFilters(98)="premadeu DKextremecore"
      MapFilters(99)="premadeu DKextremegen"
      MapFilters(100)="premadeu DKExtremeDGen"
      MapFilters(101)="premadeu DKExtremeDark"
      MapFilters(102)="premadeu DKExtremeEnd"
      MapFilters(103)="premadeu DKQueenEnd"
      MapFilters(104)=""
      MapFilters(105)="premadeflp FLP-votlan"
      MapFilters(106)="premadeflp FLP-Cherokee"
      MapFilters(107)="premadeflp FLP-Flotsam"
      MapFilters(108)="premadeflp FLP-HazardPay"
      MapFilters(109)="premadeflp FLPinterintro"
      MapFilters(110)="premadeflp FLP-LowerSoN"
      MapFilters(111)="premadeflp FLP-Marty"
      MapFilters(112)="premadeflp FLP-MineEscape"
      MapFilters(113)="premadeflp FLP-Rajalcast"
      MapFilters(114)="premadeflp FLP-struck"
      MapFilters(115)="premadeflp FLP-Tenrak"
      MapFilters(116)=""
      MapFilters(117)="premadertnp DuskFalls"
      MapFilters(118)="premadertnp Nevec"
      MapFilters(119)="premadertnp Eldora"
      MapFilters(120)="premadertnp Glathriel1"
      MapFilters(121)="premadertnp Glathriel2"
      MapFilters(122)="premadertnp Crashsite"
      MapFilters(123)="premadertnp Crashsite1"
      MapFilters(124)="premadertnp Crashsite2"
      MapFilters(125)="premadertnp Spireland"
      MapFilters(126)="premadertnp Nagomi"
      MapFilters(127)="premadertnp Velora"
      MapFilters(128)="premadertnp NagomiSun"
      MapFilters(129)="premadertnp Foundry"
      MapFilters(130)="premadertnp Toxic"
      MapFilters(131)="premadertnp Glacena"
      MapFilters(132)="premadertnp Abyss"
      MapFilters(133)="premadertnp Nalic2"
      MapFilters(134)=""
      MapFilters(135)="premadeVA CoopPortal"
      MapFilters(136)="premadeVA Andromeda-Part1"
      MapFilters(137)="premadeVA Andromeda-Part2"
      MapFilters(138)="premadeVA ATApocHead"
      MapFilters(139)="premadeVA ATBunker"
      MapFilters(140)="premadeVA ATCanyon"
      MapFilters(141)="premadeVA ATCaverns"
      MapFilters(142)="premadeVA ATCliffs"
      MapFilters(143)="premadeVA ATEaster"
      MapFilters(144)="premadeVA ATEnding"
      MapFilters(145)="premadeVA ATMerc"
      MapFilters(146)="premadeVA ATSewers"
      MapFilters(147)="premadeVA ATShip"
      MapFilters(148)="premadeVA ATSpaceport"
      MapFilters(149)="premadeVA Attacked_intro"
      MapFilters(150)="premadeVA attacked1"
      MapFilters(151)="premadeVA Attacked2"
      MapFilters(152)="premadeVA Attacked3[1]"
      MapFilters(153)="premadeVA Attacked3[2]"
      MapFilters(154)="premadeVA Attacked4[wtf]"
      MapFilters(155)="premadeVA Attacked5"
      MapFilters(156)="premadeVA Attacked6"
      MapFilters(157)="premadeVA ATVillage"
      MapFilters(158)="premadeVA ATWater"
      MapFilters(159)="premadeVA ChapelOfTheElders"
      MapFilters(160)="premadeVA DAWN2"
      MapFilters(161)="premadeVA DivineAnnex"
      MapFilters(162)="premadeVA dnspu4"
      MapFilters(163)="premadeVA dnspu4-2"
      MapFilters(164)="premadeVA dnspu4-3"
      MapFilters(165)="premadeVA Dusk2"
      MapFilters(166)="premadeVA EhactoraOne"
      MapFilters(167)="premadeVA EhactoraTwo"
      MapFilters(168)="premadeVA EhactoraThree"
      MapFilters(169)="premadeVA EhactoraFour"
      MapFilters(170)="premadeVA EhactoraFive"
      MapFilters(171)="premadeVA Enslaved"
      MapFilters(172)="premadeVA fissionsmelter"
      MapFilters(173)="premadeVA ForestRunSP"
      MapFilters(174)="premadeVA GatewayUT2"
      MapFilters(175)="premadeVA GMVortex"
      MapFilters(176)="premadeVA GothicResurrection"
      MapFilters(177)="premadeVA HCL1"
      MapFilters(178)="premadeVA HCL2"
      MapFilters(179)="premadeVA HCL3"
      MapFilters(180)="premadeVA HCL4"
      MapFilters(181)="premadeVA HCL5"
      MapFilters(182)="premadeVA Hexephet"
      MapFilters(183)="premadeVA illhaven_1"
      MapFilters(184)="premadeVA illhaven_101"
      MapFilters(185)="premadeVA illhaven_102"
      MapFilters(186)="premadeVA illhaven_103"
      MapFilters(187)="premadeVA illhaven_104"
      MapFilters(188)="premadeVA illhaven_105"
      MapFilters(189)="premadeVA illhaven_106"
      MapFilters(190)="premadeVA illhaven_107"
      MapFilters(191)="premadeVA illhaven_108"
      MapFilters(192)="premadeVA illhaven_109"
      MapFilters(193)="premadeVA illhaven_110"
      MapFilters(194)="premadeVA illhaven_111"
      MapFilters(195)="premadeVA illhaven_112"
      MapFilters(196)="premadeVA illhaven_113"
      MapFilters(197)="premadeVA illhaven_114"
      MapFilters(198)="premadeVA illhaven_115"
      MapFilters(199)="premadeVA illhaven_115d"
      MapFilters(200)="premadeVA Illhaven_2"
      MapFilters(201)="premadeVA Illhaven_3"
      MapFilters(202)="premadeVA Illhaven_4"
      MapFilters(203)="premadeVA Illhaven_5"
      MapFilters(204)="premadeVA Invasion_1"
      MapFilters(205)="premadeVA Invasion_2"
      MapFilters(206)="premadeVA Invasion_3"
      MapFilters(207)="premadeVA Invasion_4"
      MapFilters(208)="premadeVA Invasion_5"
      MapFilters(209)="premadeVA IOSdemo"
      MapFilters(210)="premadeVA Karkuth"
      MapFilters(211)="premadeVA Legacy-1"
      MapFilters(212)="premadeVA Legacy-10"
      MapFilters(213)="premadeVA Legacy-11"
      MapFilters(214)="premadeVA Legacy-2"
      MapFilters(215)="premadeVA Legacy-3"
      MapFilters(216)="premadeVA Legacy-4"
      MapFilters(217)="premadeVA Legacy-5"
      MapFilters(218)="premadeVA Legacy-6"
      MapFilters(219)="premadeVA Legacy-7"
      MapFilters(220)="premadeVA Legacy-8"
      MapFilters(221)="premadeVA Legacy-9"
      MapFilters(222)="premadeVA LivingPlanet"
      MapFilters(223)="premadeVA Naliship"
      MapFilters(224)="premadeVA Neriux"
      MapFilters(225)="premadeVA NewAlc1"
      MapFilters(226)="premadeVA NewAlc2"
      MapFilters(227)="premadeVA Nightfall"
      MapFilters(228)="premadeVA Noon"
      MapFilters(229)="premadeVA NP02DavidM"
      MapFilters(230)="premadeVA NRMC_SerpentT"
      MapFilters(231)="premadeVA NrgatothBase"
      MapFilters(232)="premadeVA Ortican"
      MapFilters(233)="premadeVA PaNunu"
      MapFilters(234)="premadeVA Peanutmine"
      MapFilters(235)="premadeVA Pitchiz"
      MapFilters(236)="premadeVA pml1"
      MapFilters(237)="premadeVA pml2"
      MapFilters(238)="premadeVA pml3"
      MapFilters(239)="premadeVA pml4"
      MapFilters(240)="premadeVA pml5"
      MapFilters(241)="premadeVA pmlend"
      MapFilters(242)="premadeVA RiseOfUSP"
      MapFilters(243)="premadeVA RTNPSWarship"
      MapFilters(244)="premadeVA sancient1"
      MapFilters(245)="premadeVA sbegin"
      MapFilters(246)="premadeVA sbegin2"
      MapFilters(247)="premadeVA ScorchedCastle"
      MapFilters(248)="premadeVA SeGrethValley"
      MapFilters(249)="premadeVA SG01"
      MapFilters(250)="premadeVA SG02"
      MapFilters(251)="premadeVA SG03"
      MapFilters(252)="premadeVA SG04"
      MapFilters(253)="premadeVA SG05"
      MapFilters(254)="premadeVA ShowDown"
      MapFilters(255)="premadeVA Shrak1"
      MapFilters(256)="premadeVA Shrak2"
      MapFilters(257)="premadeVA Shrak3"
      MapFilters(258)="premadeVA Shrak4"
      MapFilters(259)="premadeVA SkaarjCastle_V2F"
      MapFilters(260)="premadeVA SkaarjTowerF"
      MapFilters(261)="premadeVA SkyLvl1"
      MapFilters(262)="premadeVA SkyLvl2"
      MapFilters(263)="premadeVA SkyLvl3"
      MapFilters(264)="premadeVA SkyLvl4"
      MapFilters(265)="premadeVA SP-Inside"
      MapFilters(266)="premadeVA stemple"
      MapFilters(267)="premadeVA ST-Neriux"
      MapFilters(268)="premadeVA ST-NrgatothBase"
      MapFilters(269)="premadeVA ST-SeGrethValley"
      MapFilters(270)="premadeVA ST-thecoastline"
      MapFilters(271)="premadeVA svalley2"
      MapFilters(272)="premadeVA Tarmation"
      MapFilters(273)="premadeVA Tarmation2"
      MapFilters(274)="premadeVA tashara1"
      MapFilters(275)="premadeVA Tashara2"
      MapFilters(276)="premadeVA Tashara3"
      MapFilters(277)="premadeVA Terraniux"
      MapFilters(278)="premadeVA theElder"
      MapFilters(279)="premadeVA theElder01"
      MapFilters(280)="premadeVA theElder02"
      MapFilters(281)="premadeVA theElder02fix"
      MapFilters(282)="premadeVA tridig1"
      MapFilters(283)="premadeVA TV2Oldskool"
      MapFilters(284)="premadeVA UAbyss"
      MapFilters(285)="premadeVA Unreal"
      MapFilters(286)="premadeVA USP-01-Hellscrag"
      MapFilters(287)="premadeVA USP-02-Sarevok"
      MapFilters(288)="premadeVA USP-03-Naveed-LH"
      MapFilters(289)="premadeVA USP-04-Drevlin"
      MapFilters(290)="premadeVA USP-05-Jaunie-Frieza"
      MapFilters(291)="premadeVA USP-06-Jaunie"
      MapFilters(292)="premadeVA USP-07-Zynthetic"
      MapFilters(293)="premadeVA USP-08-Zynthetic"
      MapFilters(294)="premadeVA USP-09-Waffnuffly"
      MapFilters(295)="premadeVA USP-10-MMANUGITU"
      MapFilters(296)="premadeVA USP-11-MMANUGITU"
      MapFilters(297)="premadeVA USP-12-Hellscrag"
      MapFilters(298)="premadeVA USP-13-Willis"
      MapFilters(299)="premadeVA USP-14-Maekh"
      MapFilters(300)="premadeVA USP-15-EBM"
      MapFilters(301)="premadeVA USP-16-MrProphet"
      MapFilters(302)="premadeVA UTIllhaven1"
      MapFilters(303)="premadeVA UTIllhaven2"
      MapFilters(304)="premadeVA UTIllhaven3"
      MapFilters(305)="premadeVA UTIllhaven4"
      MapFilters(306)="premadeVA UTIllhaven5"
      MapFilters(307)="premadeVA UTIllhaven6"
      MapFilters(308)="premadeVA UTLNP01"
      MapFilters(309)="premadeVA UTLNP02"
      MapFilters(310)="premadeVA UTLNP03"
      MapFilters(311)="premadeVA UTLNP04"
      MapFilters(312)="premadeVA UTLNP05"
      MapFilters(313)="premadeVA UTLNP06"
      MapFilters(314)="premadeVA UTLNP07"
      MapFilters(315)="premadeVA UTLNP08"
      MapFilters(316)="premadeVA UTLNP09"
      MapFilters(317)="premadeVA UTLNP10"
      MapFilters(318)="premadeVA UTLNP11"
      MapFilters(319)="premadeVA UTLNP12"
      MapFilters(320)="premadeVA UTLNP13"
      MapFilters(321)="premadeVA UTLNP14"
      MapFilters(322)="premadeVA UTLNP15"
      MapFilters(323)="premadeVA UTLNP16"
      MapFilters(324)="premadeVA UTLNP17"
      MapFilters(325)="premadeVA UTLNP18"
      MapFilters(326)="premadeVA UTLNP19"
      MapFilters(327)="premadeVA Vacillations"
      MapFilters(328)="premadeVA Vigil99"
      MapFilters(329)="premadeVA WhirlMap"
      MapFilters(330)="premadeVA WhirlMap2"
      MapFilters(331)="premadeVA WhirlMap3"
      MapFilters(332)="premadeVA WhitePalace"
      MapFilters(333)="premadeVA WhitePalace]["
      MapFilters(334)="premadeVA Xerania"
      MapFilters(335)="premadeVA zp01-umssakuracrashsite"
      MapFilters(336)="premadeVA zp02-genesisoutpost"
      MapFilters(337)="premadeVA zp03-eldoracaves"
      MapFilters(338)="premadeVA zp04-krogaaroutpost"
      MapFilters(339)="premadeVA zp05-nitromining"
      MapFilters(340)="premadeVA zp06-mercship"
      MapFilters(341)="premadeVA zp07-nurglevillage"
      MapFilters(342)="premadeVA zp08-thelostmines.unr"
      MapFilters(343)="premadeVA zp09-undergroundfacility"
      MapFilters(344)="premadeVA zp10-thelostshippart1"
      MapFilters(345)="premadeVA zp11-thelostshippart2"
      MapFilters(346)="premadeVA zp12-extremebattle"
      MapFilters(347)=""
      MapFilters(348)=""
      MapFilters(349)=""
      MapFilters(350)=""
      MapFilters(351)=""
      MapFilters(352)=""
      MapFilters(353)=""
      MapFilters(354)=""
      MapFilters(355)=""
      MapFilters(356)=""
      MapFilters(357)=""
      MapFilters(358)=""
      MapFilters(359)=""
      MapFilters(360)=""
      MapFilters(361)=""
      MapFilters(362)=""
      MapFilters(363)=""
      MapFilters(364)=""
      MapFilters(365)=""
      MapFilters(366)=""
      MapFilters(367)=""
      MapFilters(368)=""
      MapFilters(369)=""
      MapFilters(370)=""
      MapFilters(371)=""
      MapFilters(372)=""
      MapFilters(373)=""
      MapFilters(374)=""
      MapFilters(375)=""
      MapFilters(376)=""
      MapFilters(377)=""
      MapFilters(378)=""
      MapFilters(379)=""
      MapFilters(380)=""
      MapFilters(381)=""
      MapFilters(382)=""
      MapFilters(383)=""
      MapFilters(384)=""
      MapFilters(385)=""
      MapFilters(386)=""
      MapFilters(387)=""
      MapFilters(388)=""
      MapFilters(389)=""
      MapFilters(390)=""
      MapFilters(391)=""
      MapFilters(392)=""
      MapFilters(393)=""
      MapFilters(394)=""
      MapFilters(395)=""
      MapFilters(396)=""
      MapFilters(397)=""
      MapFilters(398)=""
      MapFilters(399)=""
      MapFilters(400)=""
      MapFilters(401)=""
      MapFilters(402)=""
      MapFilters(403)=""
      MapFilters(404)=""
      MapFilters(405)=""
      MapFilters(406)=""
      MapFilters(407)=""
      MapFilters(408)=""
      MapFilters(409)=""
      MapFilters(410)=""
      MapFilters(411)=""
      MapFilters(412)=""
      MapFilters(413)=""
      MapFilters(414)=""
      MapFilters(415)=""
      MapFilters(416)=""
      MapFilters(417)=""
      MapFilters(418)=""
      MapFilters(419)=""
      MapFilters(420)=""
      MapFilters(421)=""
      MapFilters(422)=""
      MapFilters(423)=""
      MapFilters(424)=""
      MapFilters(425)=""
      MapFilters(426)=""
      MapFilters(427)=""
      MapFilters(428)=""
      MapFilters(429)=""
      MapFilters(430)=""
      MapFilters(431)=""
      MapFilters(432)=""
      MapFilters(433)=""
      MapFilters(434)=""
      MapFilters(435)=""
      MapFilters(436)=""
      MapFilters(437)=""
      MapFilters(438)=""
      MapFilters(439)=""
      MapFilters(440)=""
      MapFilters(441)=""
      MapFilters(442)=""
      MapFilters(443)=""
      MapFilters(444)=""
      MapFilters(445)=""
      MapFilters(446)=""
      MapFilters(447)=""
      MapFilters(448)=""
      MapFilters(449)=""
      MapFilters(450)=""
      MapFilters(451)=""
      MapFilters(452)=""
      MapFilters(453)=""
      MapFilters(454)=""
      MapFilters(455)=""
      MapFilters(456)=""
      MapFilters(457)=""
      MapFilters(458)=""
      MapFilters(459)=""
      MapFilters(460)=""
      MapFilters(461)=""
      MapFilters(462)=""
      MapFilters(463)=""
      MapFilters(464)=""
      MapFilters(465)=""
      MapFilters(466)=""
      MapFilters(467)=""
      MapFilters(468)=""
      MapFilters(469)=""
      MapFilters(470)=""
      MapFilters(471)=""
      MapFilters(472)=""
      MapFilters(473)=""
      MapFilters(474)=""
      MapFilters(475)=""
      MapFilters(476)=""
      MapFilters(477)=""
      MapFilters(478)=""
      MapFilters(479)=""
      MapFilters(480)=""
      MapFilters(481)=""
      MapFilters(482)=""
      MapFilters(483)=""
      MapFilters(484)=""
      MapFilters(485)=""
      MapFilters(486)=""
      MapFilters(487)=""
      MapFilters(488)=""
      MapFilters(489)=""
      MapFilters(490)=""
      MapFilters(491)=""
      MapFilters(492)=""
      MapFilters(493)=""
      MapFilters(494)=""
      MapFilters(495)=""
      MapFilters(496)=""
      MapFilters(497)=""
      MapFilters(498)=""
      MapFilters(499)=""
      MapFilters(500)=""
      MapFilters(501)=""
      MapFilters(502)=""
      MapFilters(503)=""
      MapFilters(504)=""
      MapFilters(505)=""
      MapFilters(506)=""
      MapFilters(507)=""
      MapFilters(508)=""
      MapFilters(509)=""
      MapFilters(510)=""
      MapFilters(511)=""
      MapFilters(512)=""
      MapFilters(513)=""
      MapFilters(514)=""
      MapFilters(515)=""
      MapFilters(516)=""
      MapFilters(517)=""
      MapFilters(518)=""
      MapFilters(519)=""
      MapFilters(520)=""
      MapFilters(521)=""
      MapFilters(522)=""
      MapFilters(523)=""
      MapFilters(524)=""
      MapFilters(525)=""
      MapFilters(526)=""
      MapFilters(527)=""
      MapFilters(528)=""
      MapFilters(529)=""
      MapFilters(530)=""
      MapFilters(531)=""
      MapFilters(532)=""
      MapFilters(533)=""
      MapFilters(534)=""
      MapFilters(535)=""
      MapFilters(536)=""
      MapFilters(537)=""
      MapFilters(538)=""
      MapFilters(539)=""
      MapFilters(540)=""
      MapFilters(541)=""
      MapFilters(542)=""
      MapFilters(543)=""
      MapFilters(544)=""
      MapFilters(545)=""
      MapFilters(546)=""
      MapFilters(547)=""
      MapFilters(548)=""
      MapFilters(549)=""
      MapFilters(550)=""
      MapFilters(551)=""
      MapFilters(552)=""
      MapFilters(553)=""
      MapFilters(554)=""
      MapFilters(555)=""
      MapFilters(556)=""
      MapFilters(557)=""
      MapFilters(558)=""
      MapFilters(559)=""
      MapFilters(560)=""
      MapFilters(561)=""
      MapFilters(562)=""
      MapFilters(563)=""
      MapFilters(564)=""
      MapFilters(565)=""
      MapFilters(566)=""
      MapFilters(567)=""
      MapFilters(568)=""
      MapFilters(569)=""
      MapFilters(570)=""
      MapFilters(571)=""
      MapFilters(572)=""
      MapFilters(573)=""
      MapFilters(574)=""
      MapFilters(575)=""
      MapFilters(576)=""
      MapFilters(577)=""
      MapFilters(578)=""
      MapFilters(579)=""
      MapFilters(580)=""
      MapFilters(581)=""
      MapFilters(582)=""
      MapFilters(583)=""
      MapFilters(584)=""
      MapFilters(585)=""
      MapFilters(586)=""
      MapFilters(587)=""
      MapFilters(588)=""
      MapFilters(589)=""
      MapFilters(590)=""
      MapFilters(591)=""
      MapFilters(592)=""
      MapFilters(593)=""
      MapFilters(594)=""
      MapFilters(595)=""
      MapFilters(596)=""
      MapFilters(597)=""
      MapFilters(598)=""
      MapFilters(599)=""
      MapFilters(600)=""
      MapFilters(601)=""
      MapFilters(602)=""
      MapFilters(603)=""
      MapFilters(604)=""
      MapFilters(605)=""
      MapFilters(606)=""
      MapFilters(607)=""
      MapFilters(608)=""
      MapFilters(609)=""
      MapFilters(610)=""
      MapFilters(611)=""
      MapFilters(612)=""
      MapFilters(613)=""
      MapFilters(614)=""
      MapFilters(615)=""
      MapFilters(616)=""
      MapFilters(617)=""
      MapFilters(618)=""
      MapFilters(619)=""
      MapFilters(620)=""
      MapFilters(621)=""
      MapFilters(622)=""
      MapFilters(623)=""
      MapFilters(624)=""
      MapFilters(625)=""
      MapFilters(626)=""
      MapFilters(627)=""
      MapFilters(628)=""
      MapFilters(629)=""
      MapFilters(630)=""
      MapFilters(631)=""
      MapFilters(632)=""
      MapFilters(633)=""
      MapFilters(634)=""
      MapFilters(635)=""
      MapFilters(636)=""
      MapFilters(637)=""
      MapFilters(638)=""
      MapFilters(639)=""
      MapFilters(640)=""
      MapFilters(641)=""
      MapFilters(642)=""
      MapFilters(643)=""
      MapFilters(644)=""
      MapFilters(645)=""
      MapFilters(646)=""
      MapFilters(647)=""
      MapFilters(648)=""
      MapFilters(649)=""
      MapFilters(650)=""
      MapFilters(651)=""
      MapFilters(652)=""
      MapFilters(653)=""
      MapFilters(654)=""
      MapFilters(655)=""
      MapFilters(656)=""
      MapFilters(657)=""
      MapFilters(658)=""
      MapFilters(659)=""
      MapFilters(660)=""
      MapFilters(661)=""
      MapFilters(662)=""
      MapFilters(663)=""
      MapFilters(664)=""
      MapFilters(665)=""
      MapFilters(666)=""
      MapFilters(667)=""
      MapFilters(668)=""
      MapFilters(669)=""
      MapFilters(670)=""
      MapFilters(671)=""
      MapFilters(672)=""
      MapFilters(673)=""
      MapFilters(674)=""
      MapFilters(675)=""
      MapFilters(676)=""
      MapFilters(677)=""
      MapFilters(678)=""
      MapFilters(679)=""
      MapFilters(680)=""
      MapFilters(681)=""
      MapFilters(682)=""
      MapFilters(683)=""
      MapFilters(684)=""
      MapFilters(685)=""
      MapFilters(686)=""
      MapFilters(687)=""
      MapFilters(688)=""
      MapFilters(689)=""
      MapFilters(690)=""
      MapFilters(691)=""
      MapFilters(692)=""
      MapFilters(693)=""
      MapFilters(694)=""
      MapFilters(695)=""
      MapFilters(696)=""
      MapFilters(697)=""
      MapFilters(698)=""
      MapFilters(699)=""
      MapFilters(700)=""
      MapFilters(701)=""
      MapFilters(702)=""
      MapFilters(703)=""
      MapFilters(704)=""
      MapFilters(705)=""
      MapFilters(706)=""
      MapFilters(707)=""
      MapFilters(708)=""
      MapFilters(709)=""
      MapFilters(710)=""
      MapFilters(711)=""
      MapFilters(712)=""
      MapFilters(713)=""
      MapFilters(714)=""
      MapFilters(715)=""
      MapFilters(716)=""
      MapFilters(717)=""
      MapFilters(718)=""
      MapFilters(719)=""
      MapFilters(720)=""
      MapFilters(721)=""
      MapFilters(722)=""
      MapFilters(723)=""
      MapFilters(724)=""
      MapFilters(725)=""
      MapFilters(726)=""
      MapFilters(727)=""
      MapFilters(728)=""
      MapFilters(729)=""
      MapFilters(730)=""
      MapFilters(731)=""
      MapFilters(732)=""
      MapFilters(733)=""
      MapFilters(734)=""
      MapFilters(735)=""
      MapFilters(736)=""
      MapFilters(737)=""
      MapFilters(738)=""
      MapFilters(739)=""
      MapFilters(740)=""
      MapFilters(741)=""
      MapFilters(742)=""
      MapFilters(743)=""
      MapFilters(744)=""
      MapFilters(745)=""
      MapFilters(746)=""
      MapFilters(747)=""
      MapFilters(748)=""
      MapFilters(749)=""
      MapFilters(750)=""
      MapFilters(751)=""
      MapFilters(752)=""
      MapFilters(753)=""
      MapFilters(754)=""
      MapFilters(755)=""
      MapFilters(756)=""
      MapFilters(757)=""
      MapFilters(758)=""
      MapFilters(759)=""
      MapFilters(760)=""
      MapFilters(761)=""
      MapFilters(762)=""
      MapFilters(763)=""
      MapFilters(764)=""
      MapFilters(765)=""
      MapFilters(766)=""
      MapFilters(767)=""
      MapFilters(768)=""
      MapFilters(769)=""
      MapFilters(770)=""
      MapFilters(771)=""
      MapFilters(772)=""
      MapFilters(773)=""
      MapFilters(774)=""
      MapFilters(775)=""
      MapFilters(776)=""
      MapFilters(777)=""
      MapFilters(778)=""
      MapFilters(779)=""
      MapFilters(780)=""
      MapFilters(781)=""
      MapFilters(782)=""
      MapFilters(783)=""
      MapFilters(784)=""
      MapFilters(785)=""
      MapFilters(786)=""
      MapFilters(787)=""
      MapFilters(788)=""
      MapFilters(789)=""
      MapFilters(790)=""
      MapFilters(791)=""
      MapFilters(792)=""
      MapFilters(793)=""
      MapFilters(794)=""
      MapFilters(795)=""
      MapFilters(796)=""
      MapFilters(797)=""
      MapFilters(798)=""
      MapFilters(799)=""
      MapFilters(800)=""
      MapFilters(801)=""
      MapFilters(802)=""
      MapFilters(803)=""
      MapFilters(804)=""
      MapFilters(805)=""
      MapFilters(806)=""
      MapFilters(807)=""
      MapFilters(808)=""
      MapFilters(809)=""
      MapFilters(810)=""
      MapFilters(811)=""
      MapFilters(812)=""
      MapFilters(813)=""
      MapFilters(814)=""
      MapFilters(815)=""
      MapFilters(816)=""
      MapFilters(817)=""
      MapFilters(818)=""
      MapFilters(819)=""
      MapFilters(820)=""
      MapFilters(821)=""
      MapFilters(822)=""
      MapFilters(823)=""
      MapFilters(824)=""
      MapFilters(825)=""
      MapFilters(826)=""
      MapFilters(827)=""
      MapFilters(828)=""
      MapFilters(829)=""
      MapFilters(830)=""
      MapFilters(831)=""
      MapFilters(832)=""
      MapFilters(833)=""
      MapFilters(834)=""
      MapFilters(835)=""
      MapFilters(836)=""
      MapFilters(837)=""
      MapFilters(838)=""
      MapFilters(839)=""
      MapFilters(840)=""
      MapFilters(841)=""
      MapFilters(842)=""
      MapFilters(843)=""
      MapFilters(844)=""
      MapFilters(845)=""
      MapFilters(846)=""
      MapFilters(847)=""
      MapFilters(848)=""
      MapFilters(849)=""
      MapFilters(850)=""
      MapFilters(851)=""
      MapFilters(852)=""
      MapFilters(853)=""
      MapFilters(854)=""
      MapFilters(855)=""
      MapFilters(856)=""
      MapFilters(857)=""
      MapFilters(858)=""
      MapFilters(859)=""
      MapFilters(860)=""
      MapFilters(861)=""
      MapFilters(862)=""
      MapFilters(863)=""
      MapFilters(864)=""
      MapFilters(865)=""
      MapFilters(866)=""
      MapFilters(867)=""
      MapFilters(868)=""
      MapFilters(869)=""
      MapFilters(870)=""
      MapFilters(871)=""
      MapFilters(872)=""
      MapFilters(873)=""
      MapFilters(874)=""
      MapFilters(875)=""
      MapFilters(876)=""
      MapFilters(877)=""
      MapFilters(878)=""
      MapFilters(879)=""
      MapFilters(880)=""
      MapFilters(881)=""
      MapFilters(882)=""
      MapFilters(883)=""
      MapFilters(884)=""
      MapFilters(885)=""
      MapFilters(886)=""
      MapFilters(887)=""
      MapFilters(888)=""
      MapFilters(889)=""
      MapFilters(890)=""
      MapFilters(891)=""
      MapFilters(892)=""
      MapFilters(893)=""
      MapFilters(894)=""
      MapFilters(895)=""
      MapFilters(896)=""
      MapFilters(897)=""
      MapFilters(898)=""
      MapFilters(899)=""
      MapFilters(900)=""
      MapFilters(901)=""
      MapFilters(902)=""
      MapFilters(903)=""
      MapFilters(904)=""
      MapFilters(905)=""
      MapFilters(906)=""
      MapFilters(907)=""
      MapFilters(908)=""
      MapFilters(909)=""
      MapFilters(910)=""
      MapFilters(911)=""
      MapFilters(912)=""
      MapFilters(913)=""
      MapFilters(914)=""
      MapFilters(915)=""
      MapFilters(916)=""
      MapFilters(917)=""
      MapFilters(918)=""
      MapFilters(919)=""
      MapFilters(920)=""
      MapFilters(921)=""
      MapFilters(922)=""
      MapFilters(923)=""
      MapFilters(924)=""
      MapFilters(925)=""
      MapFilters(926)=""
      MapFilters(927)=""
      MapFilters(928)=""
      MapFilters(929)=""
      MapFilters(930)=""
      MapFilters(931)=""
      MapFilters(932)=""
      MapFilters(933)=""
      MapFilters(934)=""
      MapFilters(935)=""
      MapFilters(936)=""
      MapFilters(937)=""
      MapFilters(938)=""
      MapFilters(939)=""
      MapFilters(940)=""
      MapFilters(941)=""
      MapFilters(942)=""
      MapFilters(943)=""
      MapFilters(944)=""
      MapFilters(945)=""
      MapFilters(946)=""
      MapFilters(947)=""
      MapFilters(948)=""
      MapFilters(949)=""
      MapFilters(950)=""
      MapFilters(951)=""
      MapFilters(952)=""
      MapFilters(953)=""
      MapFilters(954)=""
      MapFilters(955)=""
      MapFilters(956)=""
      MapFilters(957)=""
      MapFilters(958)=""
      MapFilters(959)=""
      MapFilters(960)=""
      MapFilters(961)=""
      MapFilters(962)=""
      MapFilters(963)=""
      MapFilters(964)=""
      MapFilters(965)=""
      MapFilters(966)=""
      MapFilters(967)=""
      MapFilters(968)=""
      MapFilters(969)=""
      MapFilters(970)=""
      MapFilters(971)=""
      MapFilters(972)=""
      MapFilters(973)=""
      MapFilters(974)=""
      MapFilters(975)=""
      MapFilters(976)=""
      MapFilters(977)=""
      MapFilters(978)=""
      MapFilters(979)=""
      MapFilters(980)=""
      MapFilters(981)=""
      MapFilters(982)=""
      MapFilters(983)=""
      MapFilters(984)=""
      MapFilters(985)=""
      MapFilters(986)=""
      MapFilters(987)=""
      MapFilters(988)=""
      MapFilters(989)=""
      MapFilters(990)=""
      MapFilters(991)=""
      MapFilters(992)=""
      MapFilters(993)=""
      MapFilters(994)=""
      MapFilters(995)=""
      MapFilters(996)=""
      MapFilters(997)=""
      MapFilters(998)=""
      MapFilters(999)=""
      MapFilters(1000)=""
      MapFilters(1001)=""
      MapFilters(1002)=""
      MapFilters(1003)=""
      MapFilters(1004)=""
      MapFilters(1005)=""
      MapFilters(1006)=""
      MapFilters(1007)=""
      MapFilters(1008)=""
      MapFilters(1009)=""
      MapFilters(1010)=""
      MapFilters(1011)=""
      MapFilters(1012)=""
      MapFilters(1013)=""
      MapFilters(1014)=""
      MapFilters(1015)=""
      MapFilters(1016)=""
      MapFilters(1017)=""
      MapFilters(1018)=""
      MapFilters(1019)=""
      MapFilters(1020)=""
      MapFilters(1021)=""
      MapFilters(1022)=""
      MapFilters(1023)=""
      ExcludeFilters(0)="CTFlist CTF-BT-*"
      ExcludeFilters(1)="CTFlist CTF-XV-*"
      ExcludeFilters(2)="DMlist DM-!*"
      ExcludeFilters(3)=""
      ExcludeFilters(4)=""
      ExcludeFilters(5)=""
      ExcludeFilters(6)=""
      ExcludeFilters(7)=""
      ExcludeFilters(8)=""
      ExcludeFilters(9)=""
      ExcludeFilters(10)=""
      ExcludeFilters(11)=""
      ExcludeFilters(12)=""
      ExcludeFilters(13)=""
      ExcludeFilters(14)=""
      ExcludeFilters(15)=""
      ExcludeFilters(16)=""
      ExcludeFilters(17)=""
      ExcludeFilters(18)=""
      ExcludeFilters(19)=""
      ExcludeFilters(20)=""
      ExcludeFilters(21)=""
      ExcludeFilters(22)=""
      ExcludeFilters(23)=""
      ExcludeFilters(24)=""
      ExcludeFilters(25)=""
      ExcludeFilters(26)=""
      ExcludeFilters(27)=""
      ExcludeFilters(28)=""
      ExcludeFilters(29)=""
      ExcludeFilters(30)=""
      ExcludeFilters(31)=""
      iFilter=0
      iExclF=0
      CurrentID=0
      WatcherList=None
      InactiveList=None
      MapList=None
      Extension=None
      ExtensionClass="MVES.MV_SubExtension"
      bSaveConfig=False
      bGenerateMapList=False
      LastMsg=""
      StrMapVotes(0)=""
      StrMapVotes(1)=""
      StrMapVotes(2)=""
      StrMapVotes(3)=""
      StrMapVotes(4)=""
      StrMapVotes(5)=""
      StrMapVotes(6)=""
      StrMapVotes(7)=""
      StrMapVotes(8)=""
      StrMapVotes(9)=""
      StrMapVotes(10)=""
      StrMapVotes(11)=""
      StrMapVotes(12)=""
      StrMapVotes(13)=""
      StrMapVotes(14)=""
      StrMapVotes(15)=""
      StrMapVotes(16)=""
      StrMapVotes(17)=""
      StrMapVotes(18)=""
      StrMapVotes(19)=""
      StrMapVotes(20)=""
      StrMapVotes(21)=""
      StrMapVotes(22)=""
      StrMapVotes(23)=""
      StrMapVotes(24)=""
      StrMapVotes(25)=""
      StrMapVotes(26)=""
      StrMapVotes(27)=""
      StrMapVotes(28)=""
      StrMapVotes(29)=""
      StrMapVotes(30)=""
      StrMapVotes(31)=""
      FMapVotes(0)=0.000000
      FMapVotes(1)=0.000000
      FMapVotes(2)=0.000000
      FMapVotes(3)=0.000000
      FMapVotes(4)=0.000000
      FMapVotes(5)=0.000000
      FMapVotes(6)=0.000000
      FMapVotes(7)=0.000000
      FMapVotes(8)=0.000000
      FMapVotes(9)=0.000000
      FMapVotes(10)=0.000000
      FMapVotes(11)=0.000000
      FMapVotes(12)=0.000000
      FMapVotes(13)=0.000000
      FMapVotes(14)=0.000000
      FMapVotes(15)=0.000000
      FMapVotes(16)=0.000000
      FMapVotes(17)=0.000000
      FMapVotes(18)=0.000000
      FMapVotes(19)=0.000000
      FMapVotes(20)=0.000000
      FMapVotes(21)=0.000000
      FMapVotes(22)=0.000000
      FMapVotes(23)=0.000000
      FMapVotes(24)=0.000000
      FMapVotes(25)=0.000000
      FMapVotes(26)=0.000000
      FMapVotes(27)=0.000000
      FMapVotes(28)=0.000000
      FMapVotes(29)=0.000000
      FMapVotes(30)=0.000000
      FMapVotes(31)=0.000000
      RankMapVotes(0)=0
      RankMapVotes(1)=0
      RankMapVotes(2)=0
      RankMapVotes(3)=0
      RankMapVotes(4)=0
      RankMapVotes(5)=0
      RankMapVotes(6)=0
      RankMapVotes(7)=0
      RankMapVotes(8)=0
      RankMapVotes(9)=0
      RankMapVotes(10)=0
      RankMapVotes(11)=0
      RankMapVotes(12)=0
      RankMapVotes(13)=0
      RankMapVotes(14)=0
      RankMapVotes(15)=0
      RankMapVotes(16)=0
      RankMapVotes(17)=0
      RankMapVotes(18)=0
      RankMapVotes(19)=0
      RankMapVotes(20)=0
      RankMapVotes(21)=0
      RankMapVotes(22)=0
      RankMapVotes(23)=0
      RankMapVotes(24)=0
      RankMapVotes(25)=0
      RankMapVotes(26)=0
      RankMapVotes(27)=0
      RankMapVotes(28)=0
      RankMapVotes(29)=0
      RankMapVotes(30)=0
      RankMapVotes(31)=0
      iMapVotes=0
      StrKickVotes(0)=""
      StrKickVotes(1)=""
      StrKickVotes(2)=""
      StrKickVotes(3)=""
      StrKickVotes(4)=""
      StrKickVotes(5)=""
      StrKickVotes(6)=""
      StrKickVotes(7)=""
      StrKickVotes(8)=""
      StrKickVotes(9)=""
      StrKickVotes(10)=""
      StrKickVotes(11)=""
      StrKickVotes(12)=""
      StrKickVotes(13)=""
      StrKickVotes(14)=""
      StrKickVotes(15)=""
      StrKickVotes(16)=""
      StrKickVotes(17)=""
      StrKickVotes(18)=""
      StrKickVotes(19)=""
      StrKickVotes(20)=""
      StrKickVotes(21)=""
      StrKickVotes(22)=""
      StrKickVotes(23)=""
      StrKickVotes(24)=""
      StrKickVotes(25)=""
      StrKickVotes(26)=""
      StrKickVotes(27)=""
      StrKickVotes(28)=""
      StrKickVotes(29)=""
      StrKickVotes(30)=""
      StrKickVotes(31)=""
      KickVoteCount(0)=0
      KickVoteCount(1)=0
      KickVoteCount(2)=0
      KickVoteCount(3)=0
      KickVoteCount(4)=0
      KickVoteCount(5)=0
      KickVoteCount(6)=0
      KickVoteCount(7)=0
      KickVoteCount(8)=0
      KickVoteCount(9)=0
      KickVoteCount(10)=0
      KickVoteCount(11)=0
      KickVoteCount(12)=0
      KickVoteCount(13)=0
      KickVoteCount(14)=0
      KickVoteCount(15)=0
      KickVoteCount(16)=0
      KickVoteCount(17)=0
      KickVoteCount(18)=0
      KickVoteCount(19)=0
      KickVoteCount(20)=0
      KickVoteCount(21)=0
      KickVoteCount(22)=0
      KickVoteCount(23)=0
      KickVoteCount(24)=0
      KickVoteCount(25)=0
      KickVoteCount(26)=0
      KickVoteCount(27)=0
      KickVoteCount(28)=0
      KickVoteCount(29)=0
      KickVoteCount(30)=0
      KickVoteCount(31)=0
      iKickVotes=0
      BanList(0)=""
      BanList(1)=""
      BanList(2)=""
      BanList(3)=""
      BanList(4)=""
      BanList(5)=""
      BanList(6)=""
      BanList(7)=""
      BanList(8)=""
      BanList(9)=""
      BanList(10)=""
      BanList(11)=""
      BanList(12)=""
      BanList(13)=""
      BanList(14)=""
      BanList(15)=""
      BanList(16)=""
      BanList(17)=""
      BanList(18)=""
      BanList(19)=""
      BanList(20)=""
      BanList(21)=""
      BanList(22)=""
      BanList(23)=""
      BanList(24)=""
      BanList(25)=""
      BanList(26)=""
      BanList(27)=""
      BanList(28)=""
      BanList(29)=""
      BanList(30)=""
      BanList(31)=""
}
