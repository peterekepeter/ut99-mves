//================================================================================
// MapVote.
//================================================================================
class MapVote expands Mutator config(MVE_Config);

var() config string ClientPackage;		// Load this package
var() config string ClientScreenshotPackage; // Load this package
var() config string ClientLogoTexture; // Clients will load and display this texture
var() config string ServerInfoURL;
var() config string MapInfoURL;
var() config string HTTPMapListLocation; //HTTPMapListPort is needs to be attached here as well

var() config int VoteTimeLimit;
var() config int HTTPMapListPort;
var() config bool bSwitchToRandomMapOnIdle;
var() config bool bSwitchToDefaultMapOnIdle;
var() config int ServerIdleAfterMinutes;
var() config string DefaultMap;
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

//?bDeprecated=True
var() config bool bFirstRun; 
var() config bool bSaveConfigOnNextRun, bReloadOnNextRun, bReloadOnEveryRun, bFullscanOnNextRun;
var() config bool bShutdownServerOnTravel;
var() config bool bWelcomeWindow;
var() config bool bSpecsAllowed;
var() config bool bAutoOpen;
var() config int ScoreBoardDelay;
var() config bool bKickVote;
var() config bool bSortAndDeduplicateMaps;
var() config bool bEnableHTTPMapList;
var() config bool bEnableMapOverrides;
var() config bool bEnableMapTags;
var() config bool bAutoSetGameName;

var() config bool bOverrideServerPackages;
var() config bool bResetServerPackages;
var() config string MainServerPackages;

var int ScoreBoardTime;
var float EndGameTime;

var string CurrentMode; //Clear on restart, if "", take gametype's default game mode

var bool bLevelSwitchPending;
var bool bVotingStage;
var int VotingStagePreBeginWait;
var bool bMapChangeIssued;
var bool bXCGE_DynLoader;

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
	var() config string Extends;
};

var() config string DefaultSettings;
var() config int DefaultTickRate;
var int pos;
var() config GameType CustomGame[100];
var GameType EmptyGame;
var GameType CurrentGame;
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


var string LastMsg;

var string StrMapVotes[32];
var float FMapVotes[32];
var int RankMapVotes[32];
var int iMapVotes;

var string StrKickVotes[32];
var int KickVoteCount[32];
var int iKickVotes;

var string BanList[32];

var MV_TravelInfo TravelInfo;
var MV_PlayerDetector PlayerDetector;
var int CurrentID;

var MapVoteResult CurrentMap;
var Music SongOverride;

//XC_GameEngine and Unreal 227 interface
native(1718) final function bool AddToPackageMap( optional string PkgName);

state Voting
{
	event BeginState()
	{
		bVotingStage = True;
		VotingStagePreBeginWait = 0;
		CountMapVotes(); //Call again if mid game, now we do check the maps
	}
	PreBegin:
	Sleep( 5);
	while (!IsThereAtLeastOneVote() && VotingStagePreBeginWait < VoteTimeLimit){
    // wait at most VoteTimeLimit seconds for first vote
    // before starting the countdown (allows players to think and choose next map)
		Sleep(1);
		VotingStagePreBeginWait += 1;
	}
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
	local string LogoTexturePackage;
	local string TravelMap;
	local string CurrentPackages;
	local bool bGotoSuccess;
	local bool bNeedToRestorePackages, bNeedToRestoreMap;
	local MV_IdleTimer MV_IdleTimer;

	Log("[MVE] Map Vote Extended version: "$ClientPackage);

	TravelInfo = Spawn(class'MV_TravelInfo');
	Spawn(class'MapVoteDelayedInit').InitializeDelayedInit(self);
	Spawn(class'MV_IdleTimer').Initialize(self, TravelInfo.bIsIdle, TravelInfo.EmptyMinutes);

	if (bReloadOnEveryRun)
	{
		bReloadOnNextRun = True;
	}

	LoadAliases();
	EvalCustomGame(TravelInfo.TravelIdx);

	if ( int(ConsoleCommand("get ini:Engine.Engine.GameEngine XC_Version")) >= 11 ) //Only XC_GameEngine contains this variable
	{
		bXCGE_DynLoader = true;
		default.bXCGE_DynLoader = true; //So we get to see if it worked from clients!
		AddToPackageMap(ClientPackage);
		if (ClientScreenshotPackage != "") 
		{
			AddToPackageMap(ClientScreenshotPackage);
		}
		if (ClientLogoTexture != "")
		{
			LogoTexturePackage = GetPackageNameFromString(ClientLogoTexture);
			if (LogoTexturePackage != "")
			{
				AddToPackageMap(LogoTexturePackage);
			}
			else {
				Err("Invalid value for LogoTexturePackage, expected Package.Texture");
			}
		}
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

	bNeedToRestorePackages = false;
	if (bOverrideServerPackages && !bXCGE_DynLoader){
	// check that current packages contains all packages specified by mapvote
		CurrentPackages = ConsoleCommand("Get ini:Engine.Engine.GameEngine ServerPackages");
		LogoTexturePackage = GetPackageNameFromString(ClientLogoTexture);
		if (LogoTexturePackage != "" && InStr(CurrentPackages, "\""$LogoTexturePackage$"\"") < 0)
		{
			Nfo(LogoTexturePackage$" is missing from ServerPackages");
			bNeedToRestorePackages = true;
		}
		if (ClientScreenshotPackage != "" && InStr(CurrentPackages, "\""$ClientScreenshotPackage$"\"") < 0)
		{
			Nfo(ClientScreenshotPackage$" is missing from ServerPackages");
			bNeedToRestorePackages = true;
		}
		if (ClientPackage != "" && InStr(CurrentPackages, "\""$ClientPackage$"\"") < 0)
		{
			Nfo(ClientPackage$" is missing from ServerPackages");
			bNeedToRestorePackages = true;
		}
		Cmd = CurrentGame.Packages;
		if ( InStr( Cmd, "<") >= 0 )
		{
			Cmd = ParseAliases( Cmd);
		}
		while ( Cmd != "" )
		{
			NextParm = Extension.NextParameter( Cmd, ",");
			if ( NextParm != "" && InStr(CurrentPackages, "\""$ClientPackage$"\"") < 0)
			{
				Nfo(NextParm$" is missing from ServerPackages");
				bNeedToRestorePackages = true;
			}
		}
		if (bNeedToRestorePackages)
		{
			Nfo("Mapvote will reload the map to update the required ServerPackages.");
		}
	}

	Cmd = Extension.ByDelimiter( string(self), ".");
	TravelMap = Extension.ByDelimiter(TravelInfo.TravelString, "?");

	if (Cmd != TravelMap && TravelInfo.TravelString != "" && TravelMap != "")
	{
		bNeedToRestoreMap = true;
		Nfo("Current map `"$Cmd$"` does not match the travel map `"$TravelMap$"`");
		Nfo("Will attempt to switch to `"$TravelMap$"`");
	}
	else 
	{
		bNeedToRestoreMap = false;
	}

	if ((bNeedToRestorePackages || bNeedToRestoreMap) && TravelInfo.RestoreTryCount < 3) {
		TravelInfo.RestoreTryCount += 1;
		Nfo("Goto `"$TravelMap$":"$TravelInfo.TravelIdx$"`` TryCount: `"$TravelInfo.RestoreTryCount$"`");
		bGotoSuccess = GotoMap(TravelMap$":"$TravelInfo.TravelIdx, true);
		if (bGotoSuccess)
		{
			Level.NextSwitchCountdown = 0; // makes the switch really fast
			return; // will switch to next map
		} 
		else 
		{
			Err("Failed to switch to map from the travel string");	
		}
	}

	if (TravelInfo.RestoreTryCount != 0)
	{
		TravelInfo.RestoreTryCount = 0;
		TravelInfo.SaveConfig();
	}

	CurrentMap = class'MapVoteResult'.static.Create(Cmd, TravelInfo.TravelIdx);
	CurrentMap.OriginalSong = ""$Level.Song;
	
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

	if ( Cmd ~= Left(TravelInfo.TravelString, Len(Cmd) ) )  //CRASH DIDN'T HAPPEN, SETUP GAME
	{
		MapList.History.NewMapPlayed( CurrentMap );
		CurrentMode = CurrentGame.GameName @ "-" @ CurrentGame.RuleName;
		if (bAutoSetGameName) {
			Level.Game.GameName = CurrentGame.RuleName@CurrentGame.GameName;
		}
		DEFAULT_MODE:
		Cmd = CurrentGame.Settings;
		//Log("[MVE] Loading settings:",'MapVote');
		while ( Cmd != "" )
		{
			NextParm = Extension.NextParameter( Cmd, ",");
			Log("[MVE] Execute Setting: "$NextParm,'MapVote');
			if ( InStr(NextParm,"=") > 0 )
				Level.Game.SetPropertyText( Extension.NextParameter(NextParm,"=") , NextParm );
		}
		
		Cmd = ParseAliases(CurrentGame.ServerActors);
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

		Cmd = ParseAliases(CurrentGame.MutatorList);
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
			Log("[MVE]  ===> "$string(ActorClass));
		}
		if ( bXCGE_DynLoader )
		{
			Cmd = CurrentGame.Packages;
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
			TravelInfo.TravelIdx = DefaultGameTypeIdx;
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
		if (bAutoSetGameName) {
			Level.Game.GameName = "Crashed"@Level.Game.GameName;
		}
		TravelInfo.TravelIdx = -1;
		TravelInfo.TravelString = "";
	}
      
	if ( MapList.MapListString == "" && MapList.iMapList > 0 )
		MapList.GenerateString();
	if ( bResetServerPackages && bOverrideServerPackages )
	{
		MainServerPackages = ConsoleCommand("Get ini:Engine.Engine.GameEngine ServerPackages");
		bResetServerPackages = false;
		SaveConfig(); // initially populates updates MVE_Config with MainServerPackages
	}
	// init player detector
	PlayerDetector = Spawn(class'MV_PlayerDetector');
	PlayerDetector.Initialize(self);
	
      // finally done!
	Log("[MVE] Successfully loaded map: `"$TravelMap$"` idx: "$TravelInfo.TravelIdx$" mode: "$CurrentMode);
}

function EvalCustomGame(int idx)
{
	CurrentGame = CustomGame[idx];
}

function Mutate( string MutateString, PlayerPawn Sender)
{
	if ( Left(MutateString,10) ~= "BDBMAPVOTE" )
	{
		if ( Mid(MutateString,11,8) ~= "FULLSCAN" )
		{
			if ( Sender.bAdmin ) 
				MapList.GlobalLoad(true);
			else				
				Sender.ClientMessage("You cannot reload the map list");
		}
		else if ( Mid(MutateString,11,6) ~= "RELOAD" )
		{
			if ( Sender.bAdmin ) 
				MapList.GlobalLoad(false);
			else				
				Sender.ClientMessage("You cannot reload the map list");
		}
		else if ( Mid(MutateString,11,8) ~= "VOTEMENU" )
		{
			OpenWindowFor(Sender);
			// if ( (Level.TimeSeconds > 15) || (Level.NetMode == 0) || Sender.bAdmin )
			// 	OpenWindowFor( Sender);
			// else
			// 	Sender.ClientMessage("Please wait a few seconds to vote");
		}
		else if ( Mid(MutateString,11,3) ~= "MAP" )
			PlayerVoted( Sender, Mid(MutateString,15) );
		else if ( Mid(MutateString,11,5) ~= "KICK " )
			PlayerKickVote( Sender, Mid(MutateString, 17, 3));
		else {
			Sender.ClientMessage("Unknown mapvote command");
			return;
		}
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

function ResetAssaultGame()
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

function SaveIdleState(bool isIdle, int minutes) 
{
	TravelInfo.EmptyMinutes = minutes;
	TravelInfo.bIsIdle = isIdle;
	TravelInfo.SaveConfig();
}

function bool SwitchToDefaultMap()
{
	local string TravelMap;
	Log("[MVE] SwitchToDefaultMap");
	TravelMap = DefaultMap$":"$DefaultGameTypeIdx;
	return GotoMap(TravelMap, True);
}

function bool SwitchToRandomMap()
{
	Log("[MVE] SwitchToRandomMap");
	return GotoMap("Random", True);
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
	if ( bReloadOnNextRun || bFullscanOnNextRun )
	{
		GenerateMapList(bFullscanOnNextRun);
		bReloadOnNextRun = false;
		bFullscanOnNextRun = false;
		bSaveConfigOnNextRun = true;
	}
	if ( bSaveConfigOnNextRun || bFirstRun )
	{
		if (bFirstRun){
			Nfo("bFirstRun is deprecated and will be removed"@
				"use bSaveConfigOnNextRun instead");
		}
		bSaveConfigOnNextRun = false;
		bFirstRun = false;
		SaveConfig(); // generates properties for configuration
	}
	LastMsg = "";
}

function GenerateMapList(bool bFullscan)
{
	if ( MapList == none )
	{
		MapList = Spawn(class'MV_MapList');
		MapList.Mutator = self;
	}
	MapList.GlobalLoad(bFullscan);
}


//Never happens in local games
function MapChangeIssued()
{
	local string aStr;
	local string notValidReason;

	bMapChangeIssued = true;
	Log("[MVE] Map change issued with URL: "$ Level.NextURL, 'MapVote');
	aStr = Extension.ByDelimiter( Level.NextURL, "?");
	aStr = Extension.ByDelimiter( aStr, "#" )  $ ":" $ string(TravelInfo.TravelIdx) ; //Map name plus current IDX
	while ( InStr( aStr, " ") == 0 )
	{
		aStr = Mid( aStr, 1);
	}
	if ( MapList.IsValidMap( aStr, notValidReason ) )	
	{
		if ( Level.bNextItems )
		{
			BroadcastMessage( Extension.ByDelimiter( aStr, ":") $ GameRuleCombo(TravelInfo.TravelIdx) @ "has been selected as next map.", true);
		}
		else 
		{			
			BroadcastMessage( Extension.ByDelimiter( aStr, ":") $ GameRuleCombo(TravelInfo.TravelIdx) @ "has been forced.", true);
		}
		TravelInfo.TravelString = Level.NextURL;
	}
	else
	{
		Log("[MVE] Map code "$aStr$" not found in map list: "$notValidReason, 'MapVote');
	}
	TravelInfo.SaveConfig();
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
	if ( bLevelSwitchPending )
	{
		Sender.ClientMessage("Cannot vote, switching to new map!");
		return;
	}
	if ( ServerCodeName == '' )	
	{
		Sender.ClientMessage("Map Vote not setup, load map list using MUTATE BDBMAPVOTE RELOAD");
		return;
	}
	if ( W == none )
	{
		W = GetWatcherFor( Sender);
	}
	if ( W == none )
	{
		Sender.ClientMessage("Looks like you're not part of the voter list. I'll try to fix that now.");
		Err("Player '"$Sender.PlayerReplicationInfo.PlayerName$"' was not part of watchlist but requested to vote.");
		PlayerJoined(Sender);
		W = GetWatcherFor( Sender);
	}
	if ( W == none )
	{
		Sender.ClientMessage("Very sorry looks like you're not able to vote!");
		return;
	}
	// if ( W.MapListCacheActor == none )
	// {
	// 	Sender.ClientMessage("Please wait, map list is loading. Try again in 5 seconds.");
	// 	return;
	// }
	if ( W.MapVoteWRIActor != none )
	{
		return; // already has actor
	}
	// finally, do open the window!
	W.MapVoteWRIActor = Extension.SpawnVoteWRIActor( Sender);
	Extension.PlayersToWindow( W.MapVoteWRIActor);
	W.MapVoteWRIActor.SetPropertyText("bKickVote", string(bKickVote) );
	W.MapVoteWRIActor.SetPropertyText("Mode", CurrentMode);
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
	local string prettyMapName;
	local string notValidReason;

	if ( bLevelSwitchPending )
	{
		Sender.ClientMessage("Server is about to change map, voting isn't allowed.");
		return;
	}
	if ( !Sender.bAdmin && !CanVote(Sender) )
	{
		Sender.ClientMessage("You're not allowed to vote.");
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
			Sender.ClientMessage("This map is not available.");
			return;
		}
	}
	W.bOverflow = true;
	if ( !MapList.IsValidMap(MapString, notValidReason) ) //String is normalized, safe to cast equals
	{
		Sender.ClientMessage("Cannot vote, bad map code: "$notValidReason$" in "$MapString);
		return;
	}

	iU = int(Extension.ByDelimiter(MapString,":",1));
	prettyMapName = Extension.ByDelimiter(MapString,":") @ GameRuleCombo(iU);

	if ( Sender.bAdmin )
	{
		GotoMap(MapString,true);
		SaveConfig();
		BroadcastMessage("Server Admin has force a map switch to " $ prettyMapName, True);
		return;
	}

	if (W.PlayerVote == MapString)
	{
		Sender.ClientMessage("Already voted: " $ prettyMapName);
		return;
	}

	// update player vote and notify others of the vote
	W.PlayerVote = MapString;
	Extension.UpdatePlayerVotedInWindows(W);
	BroadcastMessage( Sender.PlayerReplicationInfo.PlayerName $ " voted for " $ prettyMapName, True);
	CountMapVotes();
}

function bool IsThereAtLeastOneVote()
{
	local MVPlayerWatcher W;
	For ( W=WatcherList ; W!=none ; W=W.nextWatcher )
	{
		if ( CanVote(W.Watched) )
		{
			if ( W.PlayerVote != "" )
				return true;
		}
	}
	return false;
}

function CountMapVotes( optional bool bForceTravel)
{
	local MVPlayerWatcher W, UniqueVotes[32];
	local float UniqueCount[32];
	local int i, iU, iBest, j;
	local float Total, Current;
	local bool bTie, bGotoSuccess;
	local string PrettyVote;
	local string WinningVote;
	local string WinningVoteMessage;

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
			iU = Rand(MapList.iMapList);
			iBest = MapList.RandomGame(iU);
			if (!CustomGame[iBest].bAvoidRandom || i == 1023) {
				WinningVote = MapList.MapName(iU) $ ":" $ string(iBest);
				
				iU = int(Extension.ByDelimiter(WinningVote, ":", 1));
				PrettyVote = Extension.ByDelimiter(WinningVote, ":") @ GameRuleCombo(iU);

				WinningVoteMessage = "No votes sent, "$PrettyVote$" has been selected";
			}
		}
	}
	else if ( (UniqueCount[iBest] / Total) >= 0.51 ) //Absolute majority
	{
		bForceTravel = true;
		WinningVote = UniqueVotes[iBest].PlayerVote;

		iU = int(Extension.ByDelimiter(WinningVote, ":", 1));
		PrettyVote = Extension.ByDelimiter(WinningVote, ":") @ GameRuleCombo(iU);
		
		WinningVoteMessage = PrettyVote$" has won by absolute majority.";
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
		WinningVote = UniqueVotes[iBest].PlayerVote;
		
		iU = int(Extension.ByDelimiter(WinningVote, ":", 1));
		PrettyVote = Extension.ByDelimiter(WinningVote, ":") @ GameRuleCombo(iU);

		WinningVoteMessage = CapNumberWord(Current)$"map draw,"@PrettyVote@"selected.";
	}
	else if ( bForceTravel )
	{
		WinningVote = UniqueVotes[iBest].PlayerVote;

		iU = int(Extension.ByDelimiter(WinningVote, ":", 1));
		PrettyVote = Extension.ByDelimiter(WinningVote, ":") @ GameRuleCombo(iU);
		
		WinningVoteMessage = PrettyVote@"has won by simple majority.";
	}

	if ( bForceTravel )
	{
		// travel to winning vote
		bGotoSuccess = GotoMap(WinningVote, false);
		if (bGotoSuccess)
		{
			BroadcastMessage(WinningVoteMessage, True);
		}
		else 
		{
			// failed to go to winning vote, restart voting process
			BroadcastMessage("Failed to load "$PrettyVote$", please vote a another map.",True);
			FailedMap(WinningVote);
			RestartVoting();
		}
	}
	else 
	{
		// Do not update rankings if we're leaving the map
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

final function string MutatorCode(int i)
{
	if (CustomGame[i].bEnabled && 
		CustomGame[i].GameClass != "" && 
		CustomGame[i].GameName != "" && 
		CustomGame[i].RuleName != "" && 
		CustomGame[i].VotePriority > 0 
	)
	{
		return CustomGame[i].FilterCode;
	}
	else 
	{
		return "";
	}
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

final function MapVoteResult GenerateMapResult(string map, int idx)
{
	local MapVoteResult r;
	r = class'MapVoteResult'.static.Create();
	r.Map = map;
	r.GameIndex = idx;
	PopulateResultWithRule(r, idx);

	return r;
}

function PopulateResultWithRule(MapVoteResult r, int idx)
{
	local string mutator, extends, extendsIdx;
	extends = CustomGame[idx].Extends;

	if (r.IsDerivedFrom(idx))
	{
		PrintCircularExtendsError(r, idx);
		return;
	}
	else 
	{
		r.AddDerivedFrom(idx);
	}
	
	while (class'MV_Parser'.static.TrySplit(extends, ",", extendsIdx, extends))
	{
		PopulateResultWithRule(r, int(extendsIdx));
	}

	r.SetGameClass(CustomGame[idx].GameClass);
	r.SetGameName(CustomGame[idx].GameName);
	r.SetRuleName(CustomGame[idx].RuleName);
	r.SetFilterCode(CustomGame[idx].FilterCode);
	r.SetTickRate(CustomGame[idx].TickRate);
	r.AddGameSettings(CustomGame[idx].Settings);
	r.AddActors(CustomGame[idx].ServerActors);
	r.AddMutators(CustomGame[idx].MutatorList);
	r.AddPackages(CustomGame[idx].Packages);
}

function PrintCircularExtendsError(MapVoteResult r, int idx){

	local string list;
	local int i, parentIdx;
	list = "";
	for (i=0; i<r.DerivedCount; i+=1)
	{
		parentIdx = r.DerivedFrom[i];
		list = list$" -> "$parentIdx;
	}
	list = list$" -> "$idx;
	Err("Detected circular extends: "$list);
}

//Validity assumed
final function bool SetupTravelString( string mapStringWithIdx )
{
	local string spk, GameClassName, LogoTexturePackage, mapFileName, idxString;
	local int idx, TickRate;
	local MV_MapOverrides MapOverrides;
	local MapVoteResult Result;
	local LevelInfo info;

	class'MV_Parser'.static.TrySplit(mapStringWithIdx, ":", mapFileName, idxString);
	
	Result = GenerateMapResult(mapFileName, int(idxString));

	//RANDOM MAP CHOSEN!
	if ( Result.Map ~= "Random" )
	{
		Result.Map = MapList.RandomMap(Result.GameIndex);
	}

	if (Result.CanMapBeLoaded() == false){
		Err("Map cannot be loaded: `"$Result.Map$"`" );
		return false;
	}

	Result.LoadSongInformation();

	GameClassName = Result.GameClass;

	if ( DynamicLoadObject(ParseAliases(GameClassName),class'Class') == None )
	{
		Err("Game class cannot be loaded: `"$GameClassName$"`" );
		return false;
	}

	TravelInfo.TravelString = Result.Map $ "?Game=" $ ParseAliases(GameClassName);
	TravelInfo.TravelIdx = Result.GameIndex;
	Nfo("-> TravelString: `"$TravelInfo.TravelString$"`");
	Nfo("-> GameIdx: `"$TravelInfo.TravelIdx$"`");
		
	if (bEnableMapOverrides)
	{
		ProcessMapOverrides(Result);
	}

	if ( bOverrideServerPackages )
	{
		// add screenshot package 
		if (ClientScreenshotPackage != "") 
		{
			Result.AddPackages(ClientScreenshotPackage);
		}
		// add client package
		Result.AddPackages(ClientPackage);
		// add logo texture package
		if (ClientLogoTexture != "")
		{
			LogoTexturePackage = GetPackageNameFromString(ClientLogoTexture);
			if (LogoTexturePackage != "")
			{
				Result.AddPackages(LogoTexturePackage);
			}
			else {
				Err("Invalid value for LogoTexturePackage, expected Package.Texture");
			}
		}
		// add gametype packages
		Result.AddPackages(CustomGame[Result.GameIndex].Packages);
		// concats main packages
		spk = Extension.GenerateSPList(Result.GetPackagesStringList()); 
		if ( spk == "" )			
		{	
			spk = MainServerPackages;
		}
		if ( InStr( spk, "<") >= 0 )
		{
			spk = ParseAliases( spk);
		}
		Nfo("-> ServerPackages: `"$spk$"`");
		ConsoleCommand( "set ini:Engine.Engine.GameEngine ServerPackages "$spk);
	}
	TickRate = DefaultTickRate;
	if (CustomGame[idx].TickRate != 0)
		TickRate = CustomGame[idx].TickRate;
	if (TickRate > 0)
	{
		ConsoleCommand( "set ini:Engine.Engine.NetworkDevice NetServerMaxTickRate "$CustomGame[idx].TickRate);
		ConsoleCommand( "set ini:Engine.Engine.NetworkDevice LanServerMaxTickRate "$CustomGame[idx].TickRate);
		Nfo("-> TickRate: `"$TickRate$"`");
	}
	return true; // SUCCESS!!!
}

function ProcessMapOverrides(MapVoteResult map)
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

final function bool GotoMap( string MapString, optional bool bImmediate)
{
	if ( Left(MapString,3) == "[X]" )
	{
		//Random sent me here
		MapString = Mid(MapString,3);
	}
	if (!SetupTravelString( MapString )){
		Err("GotoMap: SetupTravelString has failed!");
		return false;
	}
	ResetCurrentGametypeBeforeTravel();
	TravelInfo.SaveConfig();
	Extension.CloseVoteWindows( WatcherList);
	if ( bImmediate )
	{
		ExecuteTravel();
		bMapChangeIssued = True;
	}
	else
		GotoState('DelayedTravel');
	return true;
}

function FailedMap(string voted)
{
	Err("Map has failed! "$voted$" check for missing packages, check configuration.");
}

function RestartVoting()
{
	local MVPlayerWatcher W;
	// clear votes
	For ( W=WatcherList ; W!=none ; W=W.nextWatcher )
	{
		W.PlayerVote = "";
	}
	GotoState('Voting','PreBegin');
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
	Level.ServerTravel( TravelInfo.TravelString,False);
	if (bShutdownServerOnTravel)
	{
		ConsoleCommand("exit");
	}
}

final function ResetCurrentGametypeBeforeTravel(){
	// put here any code that needs to reset the current gametype settings 
	// before moving on to the next match

	// assault needs this so next game start with full timer and correct team in correct base
	ResetAssaultGame();
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

/// UTIL

static function string GetPackageNameFromString(string objectReference)
{
	local string name, ignore;
	if (class'MV_Parser'.static.TrySplit(objectReference, ".", name, ignore))
	{
		return name;
	}
	return "";
}

static function Err(coerce string message)
{
	class'MV_Util'.static.Err(message);
}

static function Nfo(coerce string message)
{
	class'MV_Util'.static.Nfo(message);
}

defaultproperties
{
      bAutoSetGameName=True
      bSortAndDeduplicateMaps=True
      ClientPackage="MVE2g"
      ServerInfoURL=""
      MapInfoURL=""
      HTTPMapListLocation=""
      CurrentMode=""
      VoteTimeLimit=60
      HTTPMapListPort=0
      DefaultMap="DM-Deck16]["
      DefaultGameTypeIdx=0
      bSwitchToRandomMapOnIdle=True
      bSwitchToDefaultMapOnIdle=False
      ServerIdleAfterMinutes=60
      ServerCodeName="UT-Server"
      MidGameVotePercent=51
      KickPercent=51
      MapCostAddPerLoad=0
      MapCostMaxAllow=0
      PlayerIDType=PID_Default
      bFirstRun=False
      bShutdownServerOnTravel=False
      bWelcomeWindow=False
      bSpecsAllowed=False
      bAutoOpen=True
      ScoreBoardTime=0
      ScoreBoardDelay=5
      EndGameTime=0.000000
      bKickVote=True
      bEnableHTTPMapList=False
      bEnableMapOverrides=False
      bLevelSwitchPending=False
      bVotingStage=False
      bMapChangeIssued=False
      bXCGE_DynLoader=False
      bOverrideServerPackages=False
      bResetServerPackages=False
      MainServerPackages=""
      DefaultSettings=""
      DefaultTickRate=0
      pos=0
      CustomGame(0)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(1)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(2)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(3)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(4)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(5)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(6)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(7)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(8)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(9)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(10)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(11)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(12)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(13)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(14)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(15)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(16)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(17)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(18)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(19)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(20)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(21)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(22)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(23)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(24)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(25)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(26)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(27)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(28)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(29)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(30)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(31)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(32)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(33)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(34)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(35)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(36)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(37)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(38)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(39)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(40)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(41)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(42)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(43)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(44)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(45)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(46)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(47)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(48)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(49)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(50)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(51)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(52)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(53)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(54)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(55)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(56)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(57)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(58)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(59)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(60)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(61)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(62)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(63)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(64)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(65)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(66)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(67)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(68)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(69)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(70)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(71)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(72)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(73)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(74)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(75)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(76)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(77)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(78)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(79)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(80)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(81)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(82)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(83)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(84)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(85)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(86)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(87)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(88)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(89)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(90)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(91)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(92)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(93)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(94)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(95)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(96)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(97)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(98)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      CustomGame(99)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
      EmptyGame=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="",bAvoidRandom=False)
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
      MapFilters(0)=""
      MapFilters(1)=""
      MapFilters(2)=""
      MapFilters(3)=""
      MapFilters(4)=""
      MapFilters(5)=""
      MapFilters(6)=""
      MapFilters(7)=""
      MapFilters(8)=""
      MapFilters(9)=""
      MapFilters(10)=""
      MapFilters(11)=""
      MapFilters(12)=""
      MapFilters(13)=""
      MapFilters(14)=""
      MapFilters(15)=""
      MapFilters(16)=""
      MapFilters(17)=""
      MapFilters(18)=""
      MapFilters(19)=""
      MapFilters(20)=""
      MapFilters(21)=""
      MapFilters(22)=""
      MapFilters(23)=""
      MapFilters(24)=""
      MapFilters(25)=""
      MapFilters(26)=""
      MapFilters(27)=""
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
      MapFilters(62)=""
      MapFilters(63)=""
      MapFilters(64)=""
      MapFilters(65)=""
      MapFilters(66)=""
      MapFilters(67)=""
      MapFilters(68)=""
      MapFilters(69)=""
      MapFilters(70)=""
      MapFilters(71)=""
      MapFilters(72)=""
      MapFilters(73)=""
      MapFilters(74)=""
      MapFilters(75)=""
      MapFilters(76)=""
      MapFilters(77)=""
      MapFilters(78)=""
      MapFilters(79)=""
      MapFilters(80)=""
      MapFilters(81)=""
      MapFilters(82)=""
      MapFilters(83)=""
      MapFilters(84)=""
      MapFilters(85)=""
      MapFilters(86)=""
      MapFilters(87)=""
      MapFilters(88)=""
      MapFilters(89)=""
      MapFilters(90)=""
      MapFilters(91)=""
      MapFilters(92)=""
      MapFilters(93)=""
      MapFilters(94)=""
      MapFilters(95)=""
      MapFilters(96)=""
      MapFilters(97)=""
      MapFilters(98)=""
      MapFilters(99)=""
      MapFilters(100)=""
      MapFilters(101)=""
      MapFilters(102)=""
      MapFilters(103)=""
      MapFilters(104)=""
      MapFilters(105)=""
      MapFilters(106)=""
      MapFilters(107)=""
      MapFilters(108)=""
      MapFilters(109)=""
      MapFilters(110)=""
      MapFilters(111)=""
      MapFilters(112)=""
      MapFilters(113)=""
      MapFilters(114)=""
      MapFilters(115)=""
      MapFilters(116)=""
      MapFilters(117)=""
      MapFilters(118)=""
      MapFilters(119)=""
      MapFilters(120)=""
      MapFilters(121)=""
      MapFilters(122)=""
      MapFilters(123)=""
      MapFilters(124)=""
      MapFilters(125)=""
      MapFilters(126)=""
      MapFilters(127)=""
      MapFilters(128)=""
      MapFilters(129)=""
      MapFilters(130)=""
      MapFilters(131)=""
      MapFilters(132)=""
      MapFilters(133)=""
      MapFilters(134)=""
      MapFilters(135)=""
      MapFilters(136)=""
      MapFilters(137)=""
      MapFilters(138)=""
      MapFilters(139)=""
      MapFilters(140)=""
      MapFilters(141)=""
      MapFilters(142)=""
      MapFilters(143)=""
      MapFilters(144)=""
      MapFilters(145)=""
      MapFilters(146)=""
      MapFilters(147)=""
      MapFilters(148)=""
      MapFilters(149)=""
      MapFilters(150)=""
      MapFilters(151)=""
      MapFilters(152)=""
      MapFilters(153)=""
      MapFilters(154)=""
      MapFilters(155)=""
      MapFilters(156)=""
      MapFilters(157)=""
      MapFilters(158)=""
      MapFilters(159)=""
      MapFilters(160)=""
      MapFilters(161)=""
      MapFilters(162)=""
      MapFilters(163)=""
      MapFilters(164)=""
      MapFilters(165)=""
      MapFilters(166)=""
      MapFilters(167)=""
      MapFilters(168)=""
      MapFilters(169)=""
      MapFilters(170)=""
      MapFilters(171)=""
      MapFilters(172)=""
      MapFilters(173)=""
      MapFilters(174)=""
      MapFilters(175)=""
      MapFilters(176)=""
      MapFilters(177)=""
      MapFilters(178)=""
      MapFilters(179)=""
      MapFilters(180)=""
      MapFilters(181)=""
      MapFilters(182)=""
      MapFilters(183)=""
      MapFilters(184)=""
      MapFilters(185)=""
      MapFilters(186)=""
      MapFilters(187)=""
      MapFilters(188)=""
      MapFilters(189)=""
      MapFilters(190)=""
      MapFilters(191)=""
      MapFilters(192)=""
      MapFilters(193)=""
      MapFilters(194)=""
      MapFilters(195)=""
      MapFilters(196)=""
      MapFilters(197)=""
      MapFilters(198)=""
      MapFilters(199)=""
      MapFilters(200)=""
      MapFilters(201)=""
      MapFilters(202)=""
      MapFilters(203)=""
      MapFilters(204)=""
      MapFilters(205)=""
      MapFilters(206)=""
      MapFilters(207)=""
      MapFilters(208)=""
      MapFilters(209)=""
      MapFilters(210)=""
      MapFilters(211)=""
      MapFilters(212)=""
      MapFilters(213)=""
      MapFilters(214)=""
      MapFilters(215)=""
      MapFilters(216)=""
      MapFilters(217)=""
      MapFilters(218)=""
      MapFilters(219)=""
      MapFilters(220)=""
      MapFilters(221)=""
      MapFilters(222)=""
      MapFilters(223)=""
      MapFilters(224)=""
      MapFilters(225)=""
      MapFilters(226)=""
      MapFilters(227)=""
      MapFilters(228)=""
      MapFilters(229)=""
      MapFilters(230)=""
      MapFilters(231)=""
      MapFilters(232)=""
      MapFilters(233)=""
      MapFilters(234)=""
      MapFilters(235)=""
      MapFilters(236)=""
      MapFilters(237)=""
      MapFilters(238)=""
      MapFilters(239)=""
      MapFilters(240)=""
      MapFilters(241)=""
      MapFilters(242)=""
      MapFilters(243)=""
      MapFilters(244)=""
      MapFilters(245)=""
      MapFilters(246)=""
      MapFilters(247)=""
      MapFilters(248)=""
      MapFilters(249)=""
      MapFilters(250)=""
      MapFilters(251)=""
      MapFilters(252)=""
      MapFilters(253)=""
      MapFilters(254)=""
      MapFilters(255)=""
      MapFilters(256)=""
      MapFilters(257)=""
      MapFilters(258)=""
      MapFilters(259)=""
      MapFilters(260)=""
      MapFilters(261)=""
      MapFilters(262)=""
      MapFilters(263)=""
      MapFilters(264)=""
      MapFilters(265)=""
      MapFilters(266)=""
      MapFilters(267)=""
      MapFilters(268)=""
      MapFilters(269)=""
      MapFilters(270)=""
      MapFilters(271)=""
      MapFilters(272)=""
      MapFilters(273)=""
      MapFilters(274)=""
      MapFilters(275)=""
      MapFilters(276)=""
      MapFilters(277)=""
      MapFilters(278)=""
      MapFilters(279)=""
      MapFilters(280)=""
      MapFilters(281)=""
      MapFilters(282)=""
      MapFilters(283)=""
      MapFilters(284)=""
      MapFilters(285)=""
      MapFilters(286)=""
      MapFilters(287)=""
      MapFilters(288)=""
      MapFilters(289)=""
      MapFilters(290)=""
      MapFilters(291)=""
      MapFilters(292)=""
      MapFilters(293)=""
      MapFilters(294)=""
      MapFilters(295)=""
      MapFilters(296)=""
      MapFilters(297)=""
      MapFilters(298)=""
      MapFilters(299)=""
      MapFilters(300)=""
      MapFilters(301)=""
      MapFilters(302)=""
      MapFilters(303)=""
      MapFilters(304)=""
      MapFilters(305)=""
      MapFilters(306)=""
      MapFilters(307)=""
      MapFilters(308)=""
      MapFilters(309)=""
      MapFilters(310)=""
      MapFilters(311)=""
      MapFilters(312)=""
      MapFilters(313)=""
      MapFilters(314)=""
      MapFilters(315)=""
      MapFilters(316)=""
      MapFilters(317)=""
      MapFilters(318)=""
      MapFilters(319)=""
      MapFilters(320)=""
      MapFilters(321)=""
      MapFilters(322)=""
      MapFilters(323)=""
      MapFilters(324)=""
      MapFilters(325)=""
      MapFilters(326)=""
      MapFilters(327)=""
      MapFilters(328)=""
      MapFilters(329)=""
      MapFilters(330)=""
      MapFilters(331)=""
      MapFilters(332)=""
      MapFilters(333)=""
      MapFilters(334)=""
      MapFilters(335)=""
      MapFilters(336)=""
      MapFilters(337)=""
      MapFilters(338)=""
      MapFilters(339)=""
      MapFilters(340)=""
      MapFilters(341)=""
      MapFilters(342)=""
      MapFilters(343)=""
      MapFilters(344)=""
      MapFilters(345)=""
      MapFilters(346)=""
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
      ExcludeFilters(0)=""
      ExcludeFilters(1)=""
      ExcludeFilters(2)=""
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
      WatcherList=None
      InactiveList=None
      MapList=None
      Extension=None
      ExtensionClass="MVES.MV_SubExtension"
      bSaveConfigOnNextRun=True
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
      PlayerDetector=None
      CurrentID=0
      CurrentMap=None
      SongOverride=None
}
