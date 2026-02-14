//================================================================================
// MapVote.
//================================================================================
class MapVote expands Mutator config(MVE_Config);

const MaxGametypes = 100;
const ClientPackageInternal = "MVE2dev";

var() config string ClientPackage;		// Load this package
var() config string ClientLogoTexture; // Clients will load and display this texture
var() config string ClientScreenshotPackage; // Load this package

var() config name ServerCodeName; //Necessary for our ServerCode

var() config bool bWelcomeWindow;
var() config string ServerInfoURL;
var() config string ServerInfoVersion;
var() config bool bServerInfoRequiresAccept;
var() config string ServerInfoAcceptLabel;
var() config string MapInfoURL;

var() config int VoteTimeLimit;
var() config int ScoreBoardDelay;

var() config bool bSpecsAllowed;
var() config bool bAutoOpen;
var() config bool bKickVote;
var() config int MidGameVotePercent, KickPercent;
var() config int MapCostAddPerLoad, MapCostMaxAllow, RuleCostMaxAllow;

var() config int ServerIdleAfterMinutes;
var() config bool bSwitchToRandomMapOnIdle;
var() config bool bSwitchToDefaultMapOnIdle;
var() config string DefaultMap;
var() config int DefaultGameTypeIdx; //For crashes

var() config bool bEnableHTTPMapList;
var() config string HTTPMapListLocation; //HTTPMapListPort is needs to be attached here as well
var() config int HTTPMapListPort;

enum EIDType
{
	PID_Default,
	PID_NexGen
};

var() config EIDType PlayerIDType;

var() config bool bShutdownServerOnTravel;
var() config bool bSortAndDeduplicateMaps;
var() config bool bEnableMapOverrides;
var() config bool bEnableMapTags;
var() config bool bAutoSetGameName;
var() config bool bFixMutatorsQueryLagSpikes;
var() config bool bFixNetNewsForPlayers;
var() config bool bFixMissingSongPlayback;

var() config bool bReloadConfigDuringReload;
var() config bool bReloadOnEveryRun, bFullscanOnNextRun, bSaveConfigOnNextRun, bReloadOnNextRun;

var() config bool bOverrideServerPackages;
var() config bool bResetServerPackages;

var() config string MainServerPackages;
var() config string MainMutatorList;
var() config string MainServerActors;

var() config string DefaultSettings;
var() config int DefaultTickRate;
var() config string DefaultUrlParameters;


struct GameType
{
	var() config bool bEnabled;
	var() config string GameName;
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
	var() config string Extends;
	var() config string UrlParameters;
	var() config string ExcludeMutators;
	var() config string ExcludeActors;
};

var() config GameType CustomGame[100];
var() config string Aliases[32];
var() config string MapFilters[1024], ExcludeFilters[32];

var int ScoreBoardTime;
var float EndGameTime;

var string CurrentMode; //Clear on restart, if "", take gametype's default game mode

var bool bRunning;
var bool bLevelSwitchPending;
var bool bVotingStage;
var int VotingStagePreBeginWait;
var bool bMapChangeIssued;
var bool bMapChangeByMVE;
var bool bXCGE_DynLoader;
var bool bMissingClientPackage;

var int pos;
var GameType EmptyGame;
var GameType CurrentGame;
var int CurrentGameIdx;
var int iGames;

var MV_Aliases AliasesLogic;
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

var MV_Result CurrentMap;
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
	while (!IsThereAtLeastOneVote() && VotingStagePreBeginWait < VoteTimeLimit)
	{
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
	CountMapVotes(True);
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

event PostBeginPlay()
{
	local class<MV_MainExtension> ExtensionC;
	local string Cmd, NextParm;
	local Actor A;
	local class<Actor> ActorClass;
	local int MapIdx, i, TravelIdx;
	local string LogoTexturePackage;
	local string TravelMap;
	local string CurrentPackages;
	local bool bGotoSuccess;
	local bool bNeedToRestorePackages, bNeedToRestoreMap;

	bRunning = !IsOtherInstanceRunning();
	if ( !bRunning ) 
	{
		Destroy();
		return;
	}

	Log("[MVE] Map Vote Extended version: "$ClientPackageInternal);

	TravelInfo = Spawn(class'MV_TravelInfo');
	Spawn(class'MapVoteDelayedInit').InitializeDelayedInit(Self);
	Spawn(class'MV_IdleTimer').Initialize(Self, TravelInfo.bIsIdle, TravelInfo.EmptyMinutes);

	if ( bReloadOnEveryRun )
	{
		Log("[MVE] [WARNING] bReloadOnEveryRun is enabled, disable it to improve server performance");
		bReloadOnNextRun = True;
	}

	if ( ServerCodeName == '' )
	{
		SetPropertyText("ServerCodeName", "S"$string(Level.Millisecond)$string(rand(MaxInt)));
		Log("[MVE] ServerCodeName is empty! Generating new: "$ServerCodeName);
		bSaveConfigOnNextRun = True;
	}

	if ( bOverrideServerPackages && (bResetServerPackages || MainServerPackages == "") )
	{
		MainServerPackages = GetEngineIniServerPackages();
		bResetServerPackages = False;
		Log("[MVE] Resetting MainServerPackages="$MainServerPackages);
		bSaveConfigOnNextRun = True;
	}

	LoadAliases();
	MapList = new class'MV_MapList';
	MapList.Mutator = Self;
	MapList.Reader = Spawn(class'FsMapsReader');
	MapList.Configure();
	if ( ExtensionClass != "" )
		ExtensionC = class<MV_MainExtension>( DynamicLoadObject(ExtensionClass,class'class') );
	if ( ExtensionC == None )
		ExtensionC = class'MV_MainExtension';
	Extension = new ExtensionC;
	if ( bEnableHTTPMapList && (Level.NetMode != NM_Standalone) )
		Extension.SetupWebApp(MapList);
	RegisterMessageMutator();

	// init player detector
	PlayerDetector = Spawn(class'MV_PlayerDetector');
	PlayerDetector.Initialize(Self);
	
	if ( IsBackgroundMode() )
	{
		CurrentMode = "Background";
		Log("[MVE] Running in background mode until next map is voted");
		CheckClientPackageInstalled();
		return;
	}

	TravelIdx = TravelInfo.GetTravelIdx(Self);
	EvalCustomGame(TravelIdx);

	if ( int(ConsoleCommand("get ini:Engine.Engine.GameEngine XC_Version")) >= 11 ) //Only XC_GameEngine contains this variable
	{
		bXCGE_DynLoader = True;
		Default.bXCGE_DynLoader = True; //So we get to see if it worked from clients!
		AddToPackageMap(ClientPackageInternal);
		if ( ClientScreenshotPackage != "" ) 
		{
			AddToPackageMap(ClientScreenshotPackage);
		}
		if ( ClientLogoTexture != "" )
		{
			LogoTexturePackage = GetPackageNameFromString(ClientLogoTexture);
			if ( LogoTexturePackage != "" )
			{
				AddToPackageMap(LogoTexturePackage);
			}
			else 
			{
				Err("Invalid value for LogoTexturePackage, expected Package.Texture");
			}
		}
	}

	if ( !bOverrideServerPackages )
	{
		CheckClientPackageInstalled();
	}

	if ( DefaultSettings != "" )
	{
		Cmd = DefaultSettings;
		if ( InStr( Cmd, "<") >= 0 )
			Cmd = ParseAliases( Cmd);
		ExecuteSettings(Cmd);
	}

	bNeedToRestorePackages = False;
	if ( bOverrideServerPackages && !bXCGE_DynLoader )
	{
	      // check that current packages contains all packages specified by mapvote
		CurrentPackages = GetEngineIniServerPackages();
		Log("[MVE] CurrentPackages is "$CurrentPackages);
		Log("[MVE] Current TickRate is "$ConsoleCommand("get ini:Engine.Engine.NetworkDevice NetServerMaxTickRate"));
		LogoTexturePackage = GetPackageNameFromString(ClientLogoTexture);
		if ( LogoTexturePackage != "" && InStr(CurrentPackages, "\""$LogoTexturePackage$"\"") < 0 )
		{
			Nfo(LogoTexturePackage$" is missing from ServerPackages");
			bNeedToRestorePackages = True;
		}
		if ( ClientScreenshotPackage != "" && InStr(CurrentPackages, "\""$ClientScreenshotPackage$"\"") < 0 )
		{
			Nfo(ClientScreenshotPackage$" is missing from ServerPackages");
			bNeedToRestorePackages = True;
		}
		if ( ClientPackageInternal != "" && InStr(CurrentPackages, "\""$ClientPackageInternal$"\"") < 0 )
		{
			Nfo(ClientPackageInternal$" is missing from ServerPackages");
			bMissingClientPackage = True;
			bNeedToRestorePackages = True;
		}
		else 
		{
			bMissingClientPackage = False;
		}
		Cmd = CurrentGame.Packages;
		if ( InStr( Cmd, "<") >= 0 )
		{
			Cmd = ParseAliases( Cmd);
		}
		while ( Cmd != "" )
		{
			NextParm = Extension.NextParameter( Cmd, ",");
			if ( NextParm != "" && InStr(CurrentPackages, "\""$ClientPackageInternal$"\"") < 0 )
			{
				Nfo(NextParm$" is missing from ServerPackages");
				bNeedToRestorePackages = True;
			}
		}
		if ( bNeedToRestorePackages )
		{
			Nfo("Mapvote will restart the map to update the required ServerPackages.");
		}
	}

	Cmd = Extension.ByDelimiter( string(Self), ".");
	TravelMap = Extension.ByDelimiter(TravelInfo.TravelString, "?");

	if ( Cmd != TravelMap && TravelInfo.TravelString != "" && TravelMap != "" )
	{
		bNeedToRestoreMap = True;
		Nfo("Current map `"$Cmd$"` does not match the travel map `"$TravelMap$"`");
		Nfo("Will attempt to switch to `"$TravelMap$"`");
	}
	else 
	{
		bNeedToRestoreMap = False;
	}

	if ( (bNeedToRestorePackages || bNeedToRestoreMap) && TravelInfo.RestoreTryCount < 3 ) 
	{
		TravelInfo.RestoreTryCount += 1;
		Nfo("Goto `"$TravelMap$":"$TravelIdx$"`` TryCount: `"$TravelInfo.RestoreTryCount$"`");
		bGotoSuccess = GotoMap(TravelMap$":"$TravelIdx, True);
		if ( bGotoSuccess )
		{
			Level.NextSwitchCountdown = 0; // makes the switch really fast
			return; // will switch to next map
		} 
		else 
		{
			Err("Failed to switch to map from the travel string");	
		}
	}

	if ( TravelInfo.RestoreTryCount != 0 )
	{
		TravelInfo.RestoreTryCount = 0;
		TravelInfo.SaveConfig();
	}

	CurrentMap = GenerateMapResult(Cmd, TravelInfo.TravelIdx);
	CurrentMap.OriginalSong = ""$Level.Song;

	if ( bEnableMapOverrides )
	{
		ProcessMapOverrides(CurrentMap);
		SongOverride = None;
		if ( CurrentMap.Song != "" )
		{
			SongOverride = Music(DynamicLoadObject(CurrentMap.Song, class'Music'));
			Log("[MVE] SongOverride configured to: `"$SongOverride$"`");
		}
	}

	if ( Cmd ~= Left(TravelInfo.TravelString, Len(Cmd) ) )  //CRASH DIDN'T HAPPEN, SETUP GAME
	{
		MapList.History.NewMapPlayed( CurrentMap, MapCostAddPerLoad );
		MapList.History.SaveConfig();
		CurrentMode = CurrentGame.GameName@"-"@CurrentGame.RuleName;
		if ( bAutoSetGameName ) 
		{
			Level.Game.GameName = CurrentGame.RuleName@CurrentGame.GameName;
		}
	DEFAULT_MODE:
		Cmd = CurrentGame.Settings;
		if ( InStr( Cmd, "<") >= 0 )
			Cmd = ParseAliases( Cmd);
		ExecuteSettings(Cmd);
		
		if ( 0 < CurrentMap.ActorCount )
			Log("[MVE] Spawning ServerActors",'MapVote');
		for ( i = 0; i < CurrentMap.ActorCount; i+=1 )
		{
			NextParm = ParseAliases(CurrentMap.Actors[i]);
			if ( InStr(NextParm,".") < 0 )
				NextParm = "Botpack."$NextParm;
			ActorClass = class<Actor>(DynamicLoadObject(NextParm, class'Class'));	
			A = Spawn(ActorClass);
			Log("[MVE] ===> "$string(ActorClass));
		}

		if ( 0 < CurrentMap.MutatorCount )
			Log("[MVE] Spawning Mutators",'MapVote');
		for( i = 0; i < CurrentMap.MutatorCount; i+=1 )
		{
			NextParm = ParseAliases(CurrentMap.Mutators[i]);
			if ( InStr(NextParm,".") < 0 )
				NextParm = "Botpack."$NextParm;
			ActorClass = class<Actor>(DynamicLoadObject(NextParm, class'Class'));	
			A = Spawn(ActorClass);
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
			TravelInfo.SetTravelIdx(Self, DefaultGameTypeIdx);
			goto DEFAULT_MODE;
		}
 		// Log( Level.Game.Class @ CustomGame[DefaultGameTypeIdx].GameClass @ MapIdx @ NextParm @ MapList.TwoDigits(DefaultGameTypeIdx));
		if ( MapIdx >= 0 )
		{
			MapIdx = MapList.FindMap( Cmd, MapIdx + 1);
			if ( MapIdx > 0 )
				goto NEXT_MATCHING_MAP;
		}
		CurrentMode = Level.Game.GameName@"- Crashed";
		if ( bAutoSetGameName ) 
		{
			Level.Game.GameName = "Crashed"@Level.Game.GameName;
		}
		TravelInfo.SetTravelIdx(Self, -1);
		TravelInfo.TravelString = "";
	}
      
	if ( MapList.MapListString == "" && MapList.iMapList > 0 )
		MapList.GenerateString();

	// finally done!
	Log("[MVE] Finished loading map: `"$TravelMap$"` idx: "$TravelIdx$" mode: "$CurrentMode);
}

function bool IsOtherInstanceRunning() 
{
	local bool bDetected;
	local MapVote MV;

	bDetected = False;

	foreach AllActors(class'MapVote', MV)
	{
		if ( MV.bRunning )
			bDetected = True;
	}

	return bDetected;
}

function bool IsBackgroundMode() 
{
	local string url;
	url = Caps(Level.GetLocalURL());
	if ( InStr(url, Caps("Mutator="$Self.Class)) >= 0
		|| InStr(url, Caps(","$Self.Class)) >= 0 ) 
	{
		return False;
	}
	return True;
}

function ExecuteSettings(string Settings) 
{

	while ( Len(Settings) > 0 )
	{
		pos = InStr(Settings,";");
		if ( pos < 0 )
		{
			pos = InStr(Settings,",");
		}
		if ( pos < 0 )
		{
			ExecuteSetting(Settings);
			Settings = "";
		} 
		else 
		{
			ExecuteSetting(Left(Settings,pos));
			Settings = Mid(Settings,pos + 1);
		}
	}
}

function ExecuteSetting (string Setting)
{
	local string Property, Value;
	local int pos;

	Log("[MVE] Set "$Setting);

	Property = Left(Setting,InStr(Setting,"="));
	Value = Mid(Setting,InStr(Setting,"=") + 1);
	pos = InStr(Property, ".");
	if ( pos != -1 ) 
	{
		Log("[MVE] ^^^ [ERROR] Not supported");
		return;

		// className = Left(Property, pos);
		// Property = Mid(Property, pos + 1);
		
		// pos = InStr(Property, ".");
		// if (pos != -1) {
		// 	packageName = className;
		// 	className = Left(Property, pos);
		// 	Property = Mid(Property, pos + 1);
		// }
		
		// if (packageName == "") {
		// 	Log("[MVE] Cannot execute setting: "$Setting);
		// }
		// else {
		// 	cmd = "Set"@packageName$"."$className@Property@Value;
		// 	result = ConsoleCommand(cmd);
		// 	if (result != "") {
		// 		Log("[MVE] [ERROR] "$result);
		// 	}
		// }
	}
	else 
	{
		Level.Game.SetPropertyText(Property,Value);
	}
}

function EvalCustomGame(int idx)
{
	CurrentGame = CustomGame[idx];
	CurrentGameIdx = idx;
}

function Mutate(string Str, PlayerPawn Sender)
{
	if ( Left(Str,10) ~= "BDBMAPVOTE" )
	{
		if ( Mid(Str,11,8) ~= "FULLSCAN" )
		{
			if ( Sender.bAdmin ) 
				GenerateMapList(True);
			else				
				Sender.ClientMessage("Please log in as administrator to run a fullscan");
		}
		else if ( Mid(Str,11,6) ~= "RELOAD" )
		{
			if ( Sender.bAdmin ) 
				GenerateMapList(False);
			else				
				Sender.ClientMessage("Please log in as administrator to reload the map list");
		}
		else if ( Mid(Str,11,8) ~= "VOTEMENU" )
		{
			OpenWindowFor(Sender);
		}
		else if ( Mid(Str,11,3) ~= "MAP" )
		{
			PlayerVoted( Sender, Mid(Str,15) );
		}
		else if ( Mid(Str,11,5) ~= "KICK " )
		{
			PlayerKickVote( Sender, Mid(Str, 17, 3));
		}
		else 
		{
			Sender.ClientMessage("Unknown mapvote mutate command");
		}
	}

	if ( NextMutator != None )
		NextMutator.Mutate( Str, Sender);
}

function bool HandleEndGame ()
{
	// notify next mutator of end game
	Super.HandleEndGame();

	if ( ShouldHandleEndgame() )
	{
		DeathMatchPlus(Level.Game).bDontRestart = True;
		if ( !bVotingStage )
			GotoState('Voting','PreBegin');
		ScoreBoardTime = ScoreBoardDelay;
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
	if ( InStr(name, "MONSTER") != -1 && InStr(name, "HUNT") != -1 )
	{
		return True;
	}
	return False;
}

function bool IsAssaultAndNeedsToSwitchTeams()
{
	local Assault a;
	a = Assault(Level.Game);
	if ( a == None )
	{
		return False;
	}
	if ( a.bDefenseSet )
	{
		return False;
	}
	return True;
}

function ResetAssaultGame()
{
	local Assault a;
	a = Assault(Level.Game);
	if ( a != None ) 
	{
		Log("[MVE] Resetting assault game!");
		a.bDefenseSet = False;
		a.NumDefenses = 0;
		a.CurrentDefender = 1;
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

	if ( Level.Game.IsA('Assault') || Level.Game.IsA('Domination') )
		return False;
	if ( Level.Game.IsA('TeamGamePlus') )
	{
		for ( i = 0 ; i < TeamGamePlus(Level.Game).MaxTeams ; i++ )
			if ( (Best == None) || (Best.Score < TeamGamePlus(Level.Game).Teams[i].Score) )
				Best = TeamGamePlus(Level.Game).Teams[i];
		for ( i = 0 ; i < TeamGamePlus(Level.Game).MaxTeams ; i++ )
			if ( (Best.TeamIndex != i) && (Best.Score == TeamGamePlus(Level.Game).Teams[i].Score) )
				return True;
	}
	else
	{

		for ( P = Level.PawnList ; P != None ; P = P.NextPawn )
			if ( P.bIsPlayer && ((BestP == None) || (P.PlayerReplicationInfo.Score > BestP.PlayerReplicationInfo.Score)) )
				BestP = P;
		for ( P = Level.PawnList ; P != None ; P = P.NextPawn )
			if ( P.bIsPlayer && (BestP != P) && (P.PlayerReplicationInfo.Score == BestP.PlayerReplicationInfo.Score) )
				return True;
	}
}

function bool SwitchToDefaultMap()
{
	local string TravelMap;
	TravelMap = GetDefaultMapWithDefaultMode();
	Log("[MVE] SwitchToDefaultMap "$TravelMap);
	return GotoMap(TravelMap, True);
}

function bool SwitchToRandomMap()
{
	local string TravelMap;
	TravelMap = GetRandomMapWithCurrentMode();
	Log("[MVE] SwitchToRandomMap "$TravelMap);
	return GotoMap(TravelMap, True);
}

function string GetDefaultMapWithDefaultMode() 
{
	return DefaultMap$":"$DefaultGameTypeIdx;
}

function string GetRandomMapWithCurrentMode()
{
	return "Random:"$CurrentGameIdx;
}

event Timer()
{
	if ( ScoreBoardTime > 0 )
	{
		ScoreBoardTime--;
		if ( ScoreBoardTime == 0 )
		{
			EndGameTime = Level.TimeSeconds;
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
		bMapChangeIssued = True;
		MapChangeIssued();
	}
	if ( bMapChangeIssued && (Level.NextSwitchCountdown < 0) && (Level.NextURL == "") )
	{
		// Handle switch failure
		bLevelSwitchPending = False;
		bMapChangeIssued = False;
		bMapChangeByMVE = False;
		
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
		bReloadOnNextRun = False;
		bFullscanOnNextRun = False;
		bSaveConfigOnNextRun = True;
	}
	if ( bSaveConfigOnNextRun )
	{
		bSaveConfigOnNextRun = False;
		SaveConfig(); // generates properties for configuration
	}
	LastMsg = "";
}

function GenerateMapList(bool bFullscan)
{
	BroadcastMessage("Server is reloading map lists...");
	Log("[MVE] Reloading map list, this may take a while!");

	if ( bReloadConfigDuringReload )
	{
		Log("[MVE] Reload config result: `"@ConsoleCommand("RELOADCFG")$"`");
	}

	if ( IsMapvoteEmpty() )
	{
		Log("[MVE] All gametypes are empty, populating with a basic starter setup");
		GenerateBasicMapvoteConfig();
	}

	if ( MapList == None )
	{
		MapList = new class'MV_MapList';
		MapList.Reader = Spawn(class'FsMapsReader');
		MapList.Configure();
	}

	CleanRules();
	CountFilters();

	MapList.GlobalLoad(bFullscan);
}

//Never happens in local games
function MapChangeIssued()
{
	local string aStr;
	local string notValidReason;
	local int TravelIdx;

	TravelIdx = TravelInfo.GetTravelIdx(Self);

	if ( !bMapChangeByMVE ) 
	{
		aStr = ParseMapFromURL(Level.NextURL);
		if ( aStr == "" ) 
		{
			// ?Restart from Assault gametype should end up here
			Log("[MVE] Detected level restart initiated outside of MVE in URL "$Level.NextURL, 'MapVote');
		}
		else 
		{
			// coop teleporters end up here
			Log("[MVE] Detected map change to `"$aStr$"` initiated outside of MVE in URL "$Level.NextURL, 'MapVote');
			TravelInfo.TravelString = aStr;
		}
	}
	else 
	{
		Log("[MVE] Map change issued with URL: "$Level.NextURL, 'MapVote');
		aStr = Extension.ByDelimiter( Level.NextURL, "?");
		aStr = Extension.ByDelimiter( aStr, "#" )$":"$string(TravelIdx) ; //Map name plus current IDX
		while ( InStr( aStr, " ") == 0 )
		{
			aStr = Mid( aStr, 1);
		}
		if ( MapList.IsValidMap( aStr, notValidReason ) )	
		{
			if ( Level.bNextItems )
			{
				BroadcastMessage( Extension.ByDelimiter( aStr, ":")$GameRuleCombo(TravelIdx)@"has been selected as next map.", True);
			}
			else 
			{			
				BroadcastMessage( Extension.ByDelimiter( aStr, ":")$GameRuleCombo(TravelIdx)@"has been forced.", True);
			}
			TravelInfo.TravelString = Level.NextURL;
		}
		else
		{
			Log("[MVE] Map code "$aStr$" not found in map list: "$notValidReason, 'MapVote');
		}
	}
	// TODO some of these save configs might not be necessary
	TravelInfo.SaveConfig();
}

static function string ParseMapFromURL(string change)
{
	local int i, j, pos;
	while ( InStr( change, " ") == 0 )
	{
		change = Mid( change, 1);
	}
	pos = Len(change);
	i = InStr(change, "#");
	j = InStr(change, "?");
	if ( i >= 0 ) pos = i;
	if ( j >= 0 && j < pos ) pos = j;
	return Mid(change, 0, pos);
}

function PlayerJoined( PlayerPawn P)
{
	local MVPlayerWatcher MVEPV;
	log("[MVE] PlayerJoined:"@P.PlayerReplicationInfo.PlayerName@"("$P$") with id"@P.PlayerReplicationInfo.PlayerID);

	if ( bEnableMapOverrides && SongOverride != None )
	{
		P.ClientSetMusic(SongOverride, 0, 0, MTRAN_Instant );
	}
	else if ( bFixMissingSongPlayback && Level.Song == None && P.Song == None )
	{
		P.ClientSetMusic(Music'MV_SilentSong', 0, 0, MTRAN_Instant);
	}

	//Give this player a watcher
	if ( InactiveList == None )
	{
		MVEPV = Spawn(class'MVPlayerWatcher');
		MVEPV.Mutator = Self;
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
	for ( W = WatcherList ; W != None ; W = W.nextWatcher )
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
		BroadcastMessage( ToKick.Watched.PlayerReplicationInfo.PlayerName@"has been removed from the game by"@W.Watched.PlayerReplicationInfo.PlayerName, True);
		Log("[MVE]"@ToKick.Watched.PlayerReplicationInfo.PlayerName@"has been removed from the game by"@W.Watched.PlayerReplicationInfo.PlayerName,'MapVote');
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
	BroadcastMessage( W.Watched.PlayerReplicationInfo.PlayerName@"has placed a kick vote on"@ToKick.Watched.PlayerReplicationInfo.PlayerName, True);
	CountKickVotes();
}

function CountKickVotes( optional bool bNoKick)
{
	local MVPlayerWatcher W;
	local int i, pCount;
	local float Pct;

	iKickVotes = 0;
	for ( W = WatcherList ; W != None ; W = W.NextWatcher )
	{
		if ( Spectator(W.Watched) == None )
			pCount++;
		if ( W.KickVoteCode != "" )
		{
			for ( i = 0 ; i < iKickVotes ; i++ )
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
		while ( W != None )
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
				BroadcastMessage( W.Watched.PlayerReplicationInfo.PlayerName@"has been removed from the game.", True);
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
		StrKickVotes[i] = W.PlayerID$W.Watched.PlayerReplicationInfo.PlayerName$","$KickVoteCount[i];
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
	local string Reason;

	if ( Kicked.Watched == None || Kicked.Watched.bDeleteMe )
		return;

	for ( W = WatcherList ; W != None ; W = W.nextWatcher )
		if ( W.KickVoteCode == Kicked.PlayerCode )
			W.KickVoteCode = ""; //Clear
	
	if ( OverrideReason != "" ) Reason = OverrideReason;
	
	if ( Kicked.NexGenClient != None )
	{
		foreach Kicked.Watched.ChildActors (class'Info', NexgenRPCI) //Issue a NexGen ban if possible
			if ( NexgenRPCI.IsA('NexgenClientCore') )
			{
				class'MV_NexgenUtil'.Static.banPlayer( Kicked.NexGenClient, NexgenRPCI, Reason);
				Log("[MVE] Nexgen Ban issued: "$Kicked.NexGenClient@NexgenRPCI, 'MapVote');
				return;
			}
	}

	while ( (i < 32) && (BanList[i] != "") )
		i++;
	if ( i == 32 )	i = Rand(32);
	BanList[i] = Kicked.PlayerCode;
	Log("[MVE] Added "$Kicked.PlayerCode@"to banlist ID"@i,'MapVote');
	Kicked.Watched.Destroy();
}

function bool IpBanned( string Address)
{
	local int i;
	for ( i = 0 ; i < 32 ; i++ )
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

	if ( ClientPackage != ClientPackageInternal )
	{
		ClientPackage = ClientPackageInternal;
		bSave = True;
	}
	
	for ( j = 0 ; j < ArrayCount(CustomGame) ; j++ )
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
	{
		SaveConfig();
	}
}

function CountFilters()
{
	local int i, lastE;
	
	if ( MapFilters[512] != "" ) //Optimization
		lastE = 513;
	for ( i = lastE ; i < 1024 ; i++ )
	{
		if ( MapFilters[i] != "" )
			lastE = i + 1;
	}
	iFilter = lastE;
	
	lastE = 0;
	for ( i = 0 ; i < 32 ; i++ )
		if ( ExcludeFilters[i] != "" )
			lastE = i + 1;
	iExclF = lastE;
}

function UpdateMapListCaches()
{
	local MVPlayerWatcher aList;
	
	for ( aList = WatcherList ; aList != None ; aList = aList.nextWatcher )
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

function OpenWindowFor( PlayerPawn Sender, optional MVPlayerWatcher W)
{
	if ( bMissingClientPackage ) 
	{
		Sender.ClientMessage("Map Vote not set up correctly! Please add `"$ClientPackageInternal$"` to ServerPackages!");
	}
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
	if ( W == None )
	{
		W = GetWatcherFor( Sender);
	}
	if ( W == None )
	{
		Sender.ClientMessage("Looks like you're not part of the voter list. I'll try to fix that now.");
		Err("Player '"$Sender.PlayerReplicationInfo.PlayerName$"' was not part of watchlist but requested to vote");
		PlayerJoined(Sender);
		W = GetWatcherFor( Sender);
	}
	if ( W == None )
	{
		Sender.ClientMessage("Very sorry looks like you're not able to vote!");
		return;
	}
	// if ( W.MapListCacheActor == none )
	// {
	// 	Sender.ClientMessage("Please wait, map list is loading. Try again in 5 seconds.");
	// 	return;
	// }
	if ( W.MapVoteWRIActor != None )
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
	for ( W = WatcherList ; W != None ; W = W.nextWatcher )
		if ( CanVote(W.Watched) && (W.MapVoteWRIActor == None) )
			OpenWindowFor( W.Watched, W);
}

function PlayerVoted( PlayerPawn Sender, string MapString)
{
	local MVPlayerWatcher W;
	local int iU;
	local string prettyMapName;
	local string notValidReason;
	local string mapName;
	local MV_Result R;
	local bool force;

	force = Sender.bAdmin;

	if ( bLevelSwitchPending )
	{
		Sender.ClientMessage("Server is about to change map, voting isn't allowed.");
		return;
	}
	if ( !force && !CanVote(Sender) )
	{
		Sender.ClientMessage("You're not allowed to vote.");
		return;
	}
	W = GetWatcherFor( Sender);
	if ( W == None || W.bOverflow )
		return;
	
	// TODO the [X] convention is no longer used, remove
	if ( Left( MapString, 3) == "[X]" )
	{
		if ( force )
			MapString = Mid( MapString, 3);
		else
		{
			Sender.ClientMessage("This map is not available.");
			return;
		}
	}
	W.bOverflow = True;
	if ( !MapList.IsValidMap(MapString, notValidReason) ) //String is normalized, safe to cast equals
	{
		Sender.ClientMessage("Cannot vote, bad map code: "$notValidReason$" in "$MapString);
		return;
	}

	mapName = Extension.ByDelimiter(MapString,":", 0);
	iU = int(Extension.ByDelimiter(MapString,":",1));
	prettyMapName = mapName@GameRuleCombo(iU);

	// TODO warn if admin passowrd not set
	if ( force )
	{
		Nfo("Admin force switch to "$prettyMapName);
		GotoMap(MapString,True);
		BroadcastMessage("Server Admin has force a map switch to "$prettyMapName, True);
		return;
	}

	// TODO this is not optimal
	R = new class'MV_Result';
	R.GameName = Self.GameName(iU);
	R.RuleName = Self.RuleName(iU);
	R.Map = MapName;
	if ( !MapList.History.IsAllowed(R, Self.MapCostMaxAllow, Self.RuleCostMaxAllow, notValidReason) )
	{
		Sender.ClientMessage("Cannot vote, "$notValidReason$" was played too recently in "$prettyMapName);
		return;
	}

	if ( W.PlayerVote == MapString )
	{
		Sender.ClientMessage("Already voted: "$prettyMapName);
		return;
	}

	// update player vote and notify others of the vote
	W.PlayerVote = MapString;
	Extension.UpdatePlayerVotedInWindows(W);
	BroadcastMessage( Sender.PlayerReplicationInfo.PlayerName$" voted for "$prettyMapName, True);
	// TODO recount votes on player leave
	CountMapVotes();
}

function bool IsThereAtLeastOneVote()
{
	local MVPlayerWatcher W;
	for ( W = WatcherList ; W != None ; W = W.nextWatcher )
	{
		if ( CanVote(W.Watched) )
		{
			if ( W.PlayerVote != "" )
				return True;
		}
	}
	return False;
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
		for ( W = WatcherList ; W != None ; W = W.nextWatcher )
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
	
	for ( W = WatcherList ; W != None ; W = W.nextWatcher )
	{
		if ( CanVote(W.Watched) )
			Total += 1;
		if ( W.PlayerVote != "" )
		{
			for ( i = 0 ; i < iU ; i++ )
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
		StrMapVotes[0] = string(j)$","$Extension.ByDelimiter( UniqueVotes[0].PlayerVote,":")$","$GameName(j)$","$RuleName(j)$","$string(UniqueCount[0]);
	}
	for ( i = 1 ; i < iU ; i++ )
	{
		j = int(Extension.ByDelimiter( UniqueVotes[i].PlayerVote,":",1));
		FMapVotes[i] = UniqueCount[i];
		StrMapVotes[i] = string(j)$","$Extension.ByDelimiter( UniqueVotes[i].PlayerVote,":")$","$GameName(j)$","$RuleName(j)$","$string(UniqueCount[i]);
		if ( UniqueCount[i] == UniqueCount[iBest] )
			bTie = True;
		else if ( UniqueCount[i] > UniqueCount[iBest] )
		{
			iBest = i;
			bTie = False;
		}
	}

	if ( bForceTravel && UniqueVotes[iBest] == None ) 
	{
		// Nobody voted, choose random map
		iU = CurrentGameIdx;
		WinningVote = GetRandomMapWithCurrentMode();
		PrettyVote = "Random"@GameRuleCombo(iU);
		WinningVoteMessage = "No votes sent, next map will be randomly selected";
	}
	else if ( (UniqueCount[iBest] / Total) >= 0.51 ) 
	{
		// Absolute majority
		bForceTravel = True; // upgrade to force travel
		WinningVote = UniqueVotes[iBest].PlayerVote;

		iU = int(Extension.ByDelimiter(WinningVote, ":", 1));
		PrettyVote = Extension.ByDelimiter(WinningVote, ":")@GameRuleCombo(iU);
		
		WinningVoteMessage = PrettyVote$" has won by absolute majority.";
	}
	else if ( bForceTravel && bTie )
	{
            // Choose tiebreaker at random
		Current = 1;
		for ( i = iBest + 1 ; i < iU ; i++ )
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
		PrettyVote = Extension.ByDelimiter(WinningVote, ":")@GameRuleCombo(iU);

		WinningVoteMessage = CapNumberWord(Current)$"map draw,"@PrettyVote@"selected.";
	}
	else if ( bForceTravel )
	{
            // Simple majority
		WinningVote = UniqueVotes[iBest].PlayerVote;

		iU = int(Extension.ByDelimiter(WinningVote, ":", 1));
		PrettyVote = Extension.ByDelimiter(WinningVote, ":")@GameRuleCombo(iU);
		
		WinningVoteMessage = PrettyVote@"has won by simple majority.";
	}

	if ( bForceTravel )
	{
		Nfo("Travel to winning vote"$PrettyVote);
		bGotoSuccess = GotoMap(WinningVote, False);
		if ( bGotoSuccess )
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
		while ( i < iMapVotes )
		{
			if ( FMapVotes[i] > FMapVotes[i - 1] )
			{
				FMapVotes[31] = FMapVotes[i - 1];
				StrMapVotes[31] = StrMapVotes[i - 1];
				FMapVotes[i - 1] = FMapVotes[i];
				StrMapVotes[i - 1] = StrMapVotes[i];
				FMapVotes[i] = FMapVotes[31];
				StrMapVotes[i] = StrMapVotes[31];
				if ( i == 1 )			i++;
				else					i--;
			}
			else
				i++;
		}
		RankMapVotes[0] = 0;
		for ( i = 1 ; i < iMapVotes ; i++ )
		{
			if ( FMapVotes[i] == FMapVotes[i - 1] )
				RankMapVotes[i] = RankMapVotes[i - 1];
			else
				RankMapVotes[i] = i;
//			Log("RANK="$string(RankMapVotes[i]) @ "COUNT="$string(FMapVotes[i]) @ "STR="$StrMapVotes[i]);
		}

		Extension.UpdateMapVotes( WatcherList);
	}
}

function GenerateBasicMapvoteConfig() 
{
	local int i, j, l, totalCount, gameCount, ruleCount, filterCount;
	local string next, desc;
	local Class<TournamentGameInfo> GameClasses[10];
	local string RuleName[10], RuleMutator[10], GameClassName[10];
	local string currentFilter, addedFilterSet;

	while ( gameCount < 10 )
	{
		// enumerate gametypes
		GetNextIntDesc("TournamentGameInfo", i++, next, desc);

		if ( next == "" )
			break;
	
		GameClasses[gameCount] = Class<TournamentGameInfo>(
			DynamicLoadObject(next, class'Class', True)
		);
		if ( GameClasses[gameCount] == None )
			continue;
		
		GameClassName[gameCount] = next;
		gameCount+=1;
	}

	if ( gameCount <= 0 )
	{
		// user deleted all int files, this is a fallback
		GameClasses[0] = class'DeathMatchPlus';
		GameClassName[0] = "Botpack.DeathMatchPlus";
		gameCount += 1;
	}
	
	while ( ruleCount < 10 ) 
	{
		// enumerate mutators
		GetNextIntDesc("Mutator", j++, next, desc);
		
		if ( next == "" )
			break;

		l = InStr(desc, ",");
		if( l == -1 )
		{
			RuleName[ruleCount] = desc;
			// HelpText = "";
		}
		else
		{
			RuleName[ruleCount] = Left(desc, l);
			// HelpText = Mid(NextDescription, l + 1);
		}
		RuleMutator[ruleCount] = next;
		ruleCount += 1;
	}

	if ( ruleCount <= 0 ) 
	{
		// user deleted int files fallback
		RuleName[0] = "Classic";
		RuleMutator[0] = "";
		ruleCount = 1;
	}

	for ( i = 0; i < gameCount; i+=1 )
	{
		// setup filter for gametype
		currentFilter = GameClasses[i].Default.MapPrefix$"list";

		if ( InStr(addedFilterSet, currentFilter) == -1 )
		{
			addedFilterSet = addedFilterSet$";"$currentFilter;
			MapFilters[filterCount++] = currentFilter@GameClasses[i].Default.MapPrefix$"-*";
		}

		// append gametypes
		for ( j = 0; j < ruleCount; j+=1 ) 
		{
			CustomGame[totalCount].bEnabled = True;
			CustomGame[totalCount].VotePriority = 1.0;
			CustomGame[totalCount].GameClass = GameClassName[i];
			CustomGame[totalCount].GameName = GameClasses[i].Default.GameName;
			CustomGame[totalCount].RuleName = RuleName[j];
			CustomGame[totalCount].MutatorList = RuleMutator[j];
			CustomGame[totalCount].FilterCode = currentFilter;
			
			totalCount+=1;

			if ( totalCount > MaxGametypes ) 
				return;
		}
	}
}

//***********************************
//************** ACCESSORS *********
//***********************************

function bool IsMapvoteEmpty() 
{
	local int i;
	
	for ( i = 0; i < MaxGametypes; i+=1 )
		if ( !IsGameEmpty(i) )
			return False;
		
	return True;
}

function bool IsGameEmpty(int Idx)
{
	return CustomGame[Idx] == EmptyGame;
}

final function string GetMapFilter( int Idx)
{
	return MapFilters[Idx];
}

final function string MutatorCode(int i)
{
	if ( CustomGame[i].bEnabled && 
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
	return "["$CustomGame[i].GameName@"-"@CustomGame[i].RuleName$"]";
}

final function float VotePriority( int i)
{
	return CustomGame[i].VotePriority;
}

final function int GetPlayerCount() 
{
	local int count;
	local Pawn p;

	count = 0;

	for ( p = Level.PawnList; p != None; p = p.NextPawn )
	{
		if ( PlayerPawn(p) != None && !p.IsA('Spectator') )
		{
			count += 1;
		}
	}
	
	return count;
}

final function bool CanVote(PlayerPawn Sender)
{
	if ( Sender.Player == None ) 
	{
		return False; // is not a human player, thus cannot vote (sorry bots)
	}
	if ( bLevelSwitchPending )
	{
		return False; // can't vote when mapvote is about to switch levels
	}
	if ( !bSpecsAllowed && Sender.IsA('Spectator') )
	{
		return False;
	}
	return True;
}

final function MV_Result GenerateMapResult(string map, int idx)
{
	local MV_Result r;
	r = class'MV_Result'.Static.Create();
	r.Map = map;
	r.GameIndex = idx;
	PopulateResultWithDefaults(r);
	PopulateResultWithRule(r, idx);

	return r;
}

function PopulateResultWithDefaults(MV_Result r) 
{
	r.SetTickRate(DefaultTickRate);
	r.AddUrlParameters(DefaultUrlParameters);
	r.AddMutators(MainMutatorList);
	r.AddActors(MainServerActors);
}

function PopulateResultWithRule(MV_Result r, int idx)
{
	local string extends, extendsIdx;
	extends = CustomGame[idx].Extends;

	if ( r.IsDerivedFrom(idx) )
	{
		PrintCircularExtendsError(r, idx);
		return;
	}
	else 
	{
		r.AddDerivedFrom(idx);
	}
	
	while ( class'MV_Parser'.Static.TrySplit(extends, ",", extendsIdx, extends) )
	{
		PopulateResultWithRule(r, int(extendsIdx));
	}

	r.RemoveActors(CustomGame[idx].ExcludeActors);
	r.RemoveMutators(CustomGame[idx].ExcludeMutators);
	r.SetGameClass(CustomGame[idx].GameClass);
	r.SetGameName(CustomGame[idx].GameName);
	r.SetRuleName(CustomGame[idx].RuleName);
	r.SetFilterCode(CustomGame[idx].FilterCode);
	r.SetTickRate(CustomGame[idx].TickRate);
	r.AddGameSettings(CustomGame[idx].Settings);
	r.AddActors(CustomGame[idx].ServerActors);
	r.AddMutators(CustomGame[idx].MutatorList);
	r.AddPackages(CustomGame[idx].Packages);
	r.AddUrlParameters(CustomGame[idx].UrlParameters);
}

function PrintCircularExtendsError(MV_Result r, int idx)
{

	local string list;
	local int i, parentIdx;
	list = "";
	for ( i = 0; i < r.DerivedCount; i+=1 )
	{
		parentIdx = r.DerivedFrom[i];
		list = list$" -> "$parentIdx;
	}
	list = list$" -> "$idx;
	Err("Detected circular extends: "$list);
}

// Validity assumed
final function bool SetupTravelString( string mapStringWithIdx )
{
	local string spk, GameClassName, LogoTexturePackage, mapFileName, idxString;
	local MV_Result Result;
	local int idx;

	if ( !class'MV_Parser'.Static.TrySplit(mapStringWithIdx, ":", mapFileName, idxString) ) 
	{
		Log("[MVE] Failed to parse map string `"$mapStringWithIdx$"` defaulting to current mode ");
		idxString = ""$CurrentGameIdx;
	}

	idx = int(idxString);

	if ( GameName(idx) ~= "Random" || RuleName(idx) ~= "Random" ) 
	{
		idx = PickRandomGameFrom(idx);
	}
	
	Result = GenerateMapResult(mapFileName, idx);

	if ( Result.Map ~= "Random" )
	{
		Result.Map = MapList.RandomMap(Result.GameIndex, GetPlayerCount());
	}

	if ( Result.CanMapBeLoaded() == False )
	{
		Err("Map cannot be loaded: `"$Result.Map$"`" );
		return False;
	}

	Result.LoadSongInformation();

	GameClassName = Result.GameClass;

	if ( DynamicLoadObject(ParseAliases(GameClassName),class'Class') == None )
	{
		Err("Game class cannot be loaded: `"$GameClassName$"`" );
		return False;
	}

	TravelInfo.TravelString = (
		Result.Map
		$"?Game="$ParseAliases(GameClassName)
		$"?Mutator="$Self.Class
		$Result.GetUrlParametersString()
	);
	TravelInfo.SetTravelIdx(Self, Result.GameIndex);
	Nfo("-> TravelString: `"$TravelInfo.TravelString$"`");
	Nfo("-> GameIdx: `"$TravelInfo.TravelIdx$"`");
		
	if ( bEnableMapOverrides )
	{
		ProcessMapOverrides(Result);
	}

	if ( bOverrideServerPackages )
	{
		// add screenshot package 
		if ( ClientScreenshotPackage != "" ) 
		{
			Result.AddPackages(ClientScreenshotPackage);
		}
		// add client package
		Result.AddPackages(ClientPackageInternal);
		// add logo texture package
		if ( ClientLogoTexture != "" )
		{
			LogoTexturePackage = GetPackageNameFromString(ClientLogoTexture);
			if ( LogoTexturePackage != "" )
			{
				Result.AddPackages(LogoTexturePackage);
			}
			else 
			{
				Err("Invalid value for LogoTexturePackage, expected Package.Texture");
			}
		}
		// add gametype packages
		Result.AddPackages(CustomGame[Result.GameIndex].Packages);
		// concats main packages
		Result.AddPackages(MainServerPackages);
		spk = Result.GetWrappedPackages();
		if ( InStr( spk, "<") >= 0 )
		{
			spk = ParseAliases( spk);
		}
		ConsoleCommand("set ini:Engine.Engine.GameEngine ServerPackages "$spk);
		Nfo("-> ServerPackages: `"$GetEngineIniServerPackages()$"`");
	}
	if ( Result.TickRate > 0 )
	{
		ConsoleCommand("set ini:Engine.Engine.NetworkDevice NetServerMaxTickRate "$Result.TickRate);
		ConsoleCommand("set ini:Engine.Engine.NetworkDevice LanServerMaxTickRate "$Result.TickRate);
		Nfo("-> TickRate: `"$ConsoleCommand("get ini:Engine.Engine.NetworkDevice NetServerMaxTickRate")$"`");
	}
	return True; // SUCCESS!!!
}

function int PickRandomGameFrom(int idx)
{
	local int i, weight;
	local bool bFilterRule, bFilterGametype;
	local string rule, game;

	rule = CustomGame[idx].RuleName;
	game = CustomGame[idx].GameName;

	bFilterRule = !(rule ~= "Random");
	bFilterGametype = !(rule ~= "Random");

	weight = 1;

	for ( i = 0; i < ArrayCount(CustomGame); i = i + 1 )
	{
		if ( !CustomGame[i].bEnabled )
			continue;
		if ( bFilterRule && !(rule ~= CustomGame[i].RuleName) )
			continue;
		if ( bFilterGametype && !(game ~= CustomGame[i].GameName) )
			continue;
		if ( "Random" ~= CustomGame[i].RuleName )
			continue;
		if ( "Random" ~= CustomGame[i].GameName )
			continue;
		if ( Rand(weight) == 0 )
			idx = i;
		weight = weight + 1;
	}

	return idx;
}

function CheckClientPackageInstalled()
{
	local string CurrentPackages;

	CurrentPackages = GetEngineIniServerPackages();
	if ( ClientPackageInternal != "" && InStr(CurrentPackages, "\""$ClientPackageInternal$"\"") < 0 )
	{
		Err("`"$ClientPackageInternal$"` not in ServerPackages, nobody will be able to vote");
		bMissingClientPackage = True;
	}
	else 
	{
		bMissingClientPackage = False;
	}
}

function string GetEngineIniServerPackages() 
{
	return ConsoleCommand("get ini:Engine.Engine.GameEngine ServerPackages");
}

function string ParseAliases(string input) 
{
	return AliasesLogic.Resolve(input);
}

function ProcessMapOverrides(MV_Result map)
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
	// TODO [X] convention no longer used
	if ( Left(MapString,3) == "[X]" )
	{
		// Random sent me here
		MapString = Mid(MapString,3);
	}
	if ( !SetupTravelString( MapString ) )
	{
		// retry in case the Random option hits something that cannot be loaded
		Nfo("Retrying SetupTravelString"); 
		if ( !SetupTravelString( MapString ) )
		{
			Err("GotoMap: SetupTravelString has failed!");
		}
		return False;
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
	return True;
}

function FailedMap(string voted)
{
	Err("Map has failed! "$voted$" check for missing packages, check configuration.");
}

function RestartVoting()
{
	local MVPlayerWatcher W;
	// clear votes
	for ( W = WatcherList ; W != None ; W = W.nextWatcher )
	{
		W.PlayerVote = "";
	}
	GotoState('Voting','PreBegin');
}

final function RegisterMessageMutator()
{
	local mutator aMut;
	aMut = Level.Game.MessageMutator;
	Level.Game.MessageMutator = Self;
	NextMessageMutator = aMut;
}

final function MVPlayerWatcher GetWatcherFor( PlayerPawn Other)
{
	local MVPlayerWatcher W;
	for ( W = WatcherList ; W != None ; W = W.nextWatcher )
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
	bMapChangeByMVE = True;
	Level.ServerTravel( TravelInfo.TravelString,False);
	if ( bShutdownServerOnTravel )
	{
		Log("[MVE] Shutting down server instance");
		ConsoleCommand("exit");
	}
}

final function ResetCurrentGametypeBeforeTravel()
{
	// put here any code that needs to reset the current gametype settings 
	// before moving on to the next match

	// assault needs this so next game start with full timer and correct team in correct base
	ResetAssaultGame();
}

final function LoadAliases()
{
	local int i;
	
	AliasesLogic = new class'MV_Aliases'();

	for ( i = 0 ; i < 32 ; i++ )
		if ( Aliases[i] != "" ) 
			AliasesLogic.AddAliasLine(Aliases[i]);
}

function bool MutatorTeamMessage( Actor Sender, Pawn Receiver, PlayerReplicationInfo PRI, coerce string S, name Type, optional bool bBeep )
{
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
	local string orgMsg;

	if ( Msg != LastMsg )
	{
		LastMsg = Msg;
		orgMsg = Msg;
		while ( inStr( orgMsg, ":") > -1 )
		{
			orgMsg = Mid( orgMsg, inStr( orgMsg, ":") + 1 );
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
		return True;

}

function CommonCommands( Actor Sender, String S)
{
	if ( PlayerPawn(Sender) == None )
		return;

	if ( (S ~= "!v") || (S ~= "!vote") || (S ~= "!mapvote") || (S ~= "!kickvote") )
		Mutate( "BDBMAPVOTE VOTEMENU", PlayerPawn(Sender) );
}

/// UTIL

static function string GetPackageNameFromString(string objectReference)
{
	local string name, ignore;
	if ( class'MV_Parser'.Static.TrySplit(objectReference, ".", name, ignore) )
	{
		return name;
	}
	return "";
}

static function Err(coerce string message)
{
	class'MV_Util'.Static.Err(message);
}

static function Nfo(coerce string message)
{
	class'MV_Util'.Static.Nfo(message);
}

// TODO investigate why is there save config
// when by default bReloadOnNextRun is False
defaultproperties
{
	bReloadOnNextRun=True
	bReloadConfigDuringReload=True
	bAutoSetGameName=True
	bSortAndDeduplicateMaps=True
	bFixMutatorsQueryLagSpikes=True
	bFixNetNewsForPlayers=True
	bFixMissingSongPlayback=True
	VoteTimeLimit=60
	DefaultMap="DM-Deck16]["
	bSwitchToRandomMapOnIdle=True
	ServerIdleAfterMinutes=60
	ServerCodeName=
	MidGameVotePercent=51
	KickPercent=51
	PlayerIDType=PID_Default
	bAutoOpen=True
	ScoreBoardDelay=5
	bKickVote=True
	ExtensionClass="MVES.MV_SubExtension"
	bSaveConfigOnNextRun=True
	bResetServerPackages=True
	EmptyGame=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(0)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(1)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(2)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(3)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(4)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(5)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(6)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(7)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(8)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(9)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(10)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(11)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(12)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(13)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(14)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(15)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(16)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(17)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(18)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(19)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(20)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(21)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(22)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(23)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(24)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(25)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(26)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(27)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(28)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(29)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(30)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(31)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(32)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(33)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(34)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(35)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(36)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(37)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(38)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(39)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(40)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(41)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(42)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(43)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(44)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(45)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(46)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(47)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(48)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(49)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(50)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(51)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(52)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(53)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(54)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(55)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(56)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(57)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(58)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(59)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(60)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(61)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(62)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(63)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(64)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(65)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(66)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(67)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(68)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(69)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(70)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(71)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(72)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(73)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(74)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(75)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(76)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(77)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(78)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(79)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(80)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(81)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(82)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(83)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(84)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(85)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(86)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(87)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(88)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(89)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(90)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(91)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(92)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(93)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(94)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(95)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(96)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(97)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(98)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
	CustomGame(99)=(bEnabled=False,GameName="",RuleName="",GameClass="",FilterCode="",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=0,ServerActors="")
}
