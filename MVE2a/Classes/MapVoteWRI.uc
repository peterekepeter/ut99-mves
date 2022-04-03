//================================================================================
// MapVoteWRI.
//================================================================================

class MapVoteWRI extends WRI;

var string MapList[4096];
var string RuleList[512];
var int RuleListCount;
var string GameModeName[ArrayCount(RuleList)];
var string RuleName[ArrayCount(RuleList)];
var int RuleCount;
var float VotePriority[ArrayCount(RuleList)];
var string MapList1[256];
var string MapList2[256];
var string MapList3[256];
var string MapList4[256];
var string MapList5[256];
var string MapList6[256];
var string MapList7[256];
var string MapList8[256];
var string MapList9[256];
var string MapList10[256];
var string MapList11[256];
var string MapList12[256];
var string MapList13[256];
var string MapList14[256];
var string MapList15[256];
var string MapList16[256];
var int MapCount;
var int iNewMaps[32];
var bool bSetVoteList;
var bool bSetAdminWindow;
var string PlayerName[32];
var bool bKickVote;
var int gPlayerCount;
var string MapVoteResults[32];
var string KickVoteResults[32];
var string GameTypes;
var string OtherClass;
var int VoteTimeLimit;
var int KickPercent;
var bool bAutoOpen;
var int ScoreBoardDelay;
var bool bCheckOtherGameTie;
var string ServerInfoURL;
var string MapInfoURL;
var string ReportText;
var string Mode;
var int RepeatLimit;
var string MapVoteHistoryType;
var int MidGameVotePercent;
var int MinMapCount;
var string MapPreFixOverRide;
var string PreFixSwap;
var string OtherPreFix;
var string HasStartWindow;
var bool bEntryWindows;
var bool bDebugMode;
var bool bRemoveCrashedMaps;
var string ActGameClass;
var string ActGamePrefix;
var string MapVoteTitle;
var string CustomGames[ArrayCount(RuleList)];
var string CustomGamesState;
var string PrefixDictionary;
//var string ASClass;
var bool bUpdated;
var bool blastCheck;
var int gAdminChechsum;
var int gPlayerChecksum;
var bool bAdminDone;
var string LogoTexture;
var bool bOpenWindowDispatched;
var bool bSetupWindowDelayDone;
var MapListCache ClientCache;
var bool bMapListLoad;
var MapVoteClientConfig ClientConf;
var MapVoteTabWindow CWindow;
var Class<MapListCacheHelper> Helper;

replication
{
  reliable if ( Role == ROLE_Authority )
    SendBTRecord,SendReportText,UpdateKickVoteResults,UpdateMapVoteResults,UpdatePlayerVoted,RemovePlayerName,AddNewPlayer,
    PlayerName,bKickVote,MapVoteResults,KickVoteResults,GameTypes,OtherClass,VoteTimeLimit,KickPercent,bAutoOpen,
    ScoreBoardDelay,bCheckOtherGameTie,ServerInfoURL,MapInfoURL,Mode,RepeatLimit,MapVoteHistoryType,MidGameVotePercent,
    MinMapCount,MapPreFixOverRide,PreFixSwap,OtherPreFix,HasStartWindow,bEntryWindows,bDebugMode,bRemoveCrashedMaps,
    ActGameClass,ActGamePrefix,MapVoteTitle,CustomGames,CustomGamesState,PrefixDictionary,LogoTexture;
  reliable if ( Role < ROLE_Authority )
    ClientNeedBTRecord;
}

simulated function PostBeginPlay()
{
    super.PostBeginPlay();
    if(bDemoRecording || bClientDemoRecording)
    {
        Destroy();
        return;
    }
    ClientConf = new (class'MapVoteClientConfig', 'MapVoteClientConfig') class'MapVoteClientConfig';
    GetMapList();
}

simulated function GetMapList()
{
    local int i;
    local MapListCache Cache;

    // End:0x0E
    if(bMapListLoad == true)
    {
        return;
    }
    // End:0x1B
    if(Owner == none)
    {
        return;
    }
    // End:0x38
    foreach Owner.ChildActors(class'MapListCache', ClientCache)
    {
        // End:0x38
        break;        
    }    
    // End:0x46
    if(ClientCache == none)
    {
        return;
    }
    // End:0x5D
    if(ClientCache.bClientLoadEnd == false)
    {
        return;
    }
    MapCount = ClientCache.MapCount;
    i = 0;
    J0x78:
    // End:0x10E [Loop If]
    if(i < ArrayCount(RuleList))
    {
        RuleList[i] = ClientCache.RuleList[i];
        GameModeName[i] = ClientCache.GameModeName[i];
        RuleName[i] = ClientCache.RuleName[i];
        VotePriority[i] = ClientCache.GetVotePriority(i);
        ++ i;
        // [Loop Continue]
        goto J0x78;
    }
    RuleListCount = ClientCache.RuleListCount;
    RuleCount = ClientCache.RuleCount;
    i = 0;
    J0x13D:
    // End:0x356 [Loop If]
    if(i < 256)
    {
        MapList1[i] = ClientCache.MapList1[i];
        MapList2[i] = ClientCache.MapList2[i];
        MapList3[i] = ClientCache.MapList3[i];
        MapList4[i] = ClientCache.MapList4[i];
        MapList5[i] = ClientCache.MapList5[i];
        MapList6[i] = ClientCache.MapList6[i];
        MapList7[i] = ClientCache.MapList7[i];
        MapList8[i] = ClientCache.MapList8[i];
        MapList9[i] = ClientCache.MapList9[i];
        MapList10[i] = ClientCache.MapList10[i];
        MapList11[i] = ClientCache.MapList11[i];
        MapList12[i] = ClientCache.MapList12[i];
        MapList13[i] = ClientCache.MapList13[i];
        MapList14[i] = ClientCache.MapList14[i];
        MapList15[i] = ClientCache.MapList15[i];
        MapList16[i] = ClientCache.MapList16[i];
        ++ i;
        // [Loop Continue]
        goto J0x13D;
    }
    for (i = 0; i < ArrayCount(iNewMaps); i++)
    	iNewMaps[i] = ClientCache.iNewMaps[i];
    bMapListLoad = true;
}

simulated function bool OpenWindow ()
{
  if ( PlayerPawn(Owner).Player.Console.bTyping )
  {
    SetTimer(0.5,False);
    return False;
  }
  bOpenWindowDispatched = True;
  Super.OpenWindow();
}

simulated function bool SetupWindow()
{
    local int i;

    if(!bSetupWindowDelayDone)
    {
        SetTimer(0.50, false);
        return false;
    }
    if(ClientConf.bUseMsgTimeout)
    {
        class'SayMessagePlus'.default.Lifetime = int(ClientConf.MsgTimeOut);
        class'CriticalStringPlus'.default.Lifetime = int(ClientConf.MsgTimeOut);
        class'RedSayMessagePlus'.default.Lifetime = int(ClientConf.MsgTimeOut);
        class'TeamSayMessagePlus'.default.Lifetime = int(ClientConf.MsgTimeOut);
        class'StringMessagePlus'.default.Lifetime = int(ClientConf.MsgTimeOut);
        class'DeathMessagePlus'.default.Lifetime = int(ClientConf.MsgTimeOut);
    }
	
    DebugLog("MapVoteWRI: SetupWindow()");

    if(super.SetupWindow())
    {
        SetTimer(Level.TimeDilation,False);
        CWindow = MapVoteTabWindow(MapVoteFramedWindow(TheWindow).ClientArea);
	} else {
		Log("Super.SetupWindow() = false");
	}
}

simulated function SetVoteList()
{
    local int i;
    local string temp;
    local int iTemp, iGameMode, Count, iNewMap;
    local string RuleStr, MapName, SList, sNewMaps[ArrayCount(iNewMaps)];

    i = 0;
    J0x07:
	if ( i < 4096 )
	{
		if ( i < 256 )
		{
			temp=MapList1[i % 256];
		}else
			if ( i < 512 )
			{
				temp=MapList2[i % 256];
			}else
				if ( i < 768 )
				{
					temp=MapList3[i % 256];
				}else
					if ( i < 1024 )
					{
						temp=MapList4[i % 256];
					}else
						if ( i < 1280 )
						{
							temp=MapList5[i % 256];
						}else
							if ( i < 1536 )
							{
								temp=MapList6[i % 256];
							}else
								if ( i < 1792 )
								{
									temp=MapList7[i % 256];
								}else

								if ( i < 2048 )
								{
									temp=MapList8[i % 256];
								}else

								if ( i < 2304 )
								{
									temp=MapList9[i % 256];
								}else

								if ( i < 2560 )
								{
									temp=MapList10[i % 256];
								}else

								if ( i < 2816 )
								{
									temp=MapList11[i % 256];
								}else

								if ( i < 3072 )
								{
									temp=MapList12[i % 256];
								}else

								if ( i < 3328 )
								{
									temp=MapList13[i % 256];
								}else

								if ( i < 3584 )
								{
									temp=MapList14[i % 256];
								}else

								if ( i < 3840 )
								{
									temp=MapList15[i % 256];
								}else

								if ( i < 4096 )
								{
									temp=MapList16[i % 256];
								}
        // End:0x2F2
        if(temp == "")
        {
            // [Explicit Continue]
            goto J0x3D1;
        }
        for (iNewMap = 0; iNewMap < ArrayCount(iNewMaps); iNewMap++)
	    	if (i != 0 && iNewMaps[iNewMap] == i)
	    		break;
        MapList[i] = temp;
        MapName = MapList[i];
        SList = MapList[i];
        MapName = Left(MapName, InStr(MapName, ":"));
        SList = Mid(SList, InStr(SList, ":"));
        MapList[i] = MapName;       
        if (iNewMap != ArrayCount(iNewMaps))
        	 sNewMaps[iNewMap] = SList;
        J0x364:
        // End:0x3D1 [Loop If]
        if(InStr(SList, ":") != -1)
        {
            iTemp = int(Mid(SList, InStr(SList, ":") + 1, 2));
            CWindow.AddMapName(iTemp, MapList[i]);            
            SList = Mid(SList, InStr(SList, ":") + 1);
            J0x3D1:
            // [Loop Continue]
            goto J0x364;
        }
        ++ i;
        goto J0x07;
    }
    for (i = 0; i < ArrayCount(iNewMaps); i++)
    	for (SList = sNewMaps[i]; InStr(SList, ":") != -1; SList = Mid(SList, InStr(SList, ":") + 1)) {
    		CWindow.AddMapName(-int(Mid(SList, InStr(SList, ":") + 1, 2)), MapList[iNewMaps[i]]);
    	}
    i = 0;
    J0x3E2:
    // End:0x4F9 [Loop If]
    if(i < ArrayCount(RuleList))
    {
        temp = RuleList[i];
        CWindow.MapWindow.GetMapListBox(i).VotePriority = VotePriority[i];
        // End:0x440
        if(temp == "")
        {
            // [Explicit Continue]
            goto J0x4EF;
        }
        iGameMode = int(Mid(temp, InStr(temp, ":") + 1, 2));
        CWindow.AddGameMode(iGameMode, GameModeName[iGameMode]);
        J0x47C:
        // End:0x4EF [Loop If]
        if(InStr(temp, ":") != -1)
        {
            iTemp = int(Mid(temp, InStr(temp, ":") + 1, 2));
            temp = Mid(temp, InStr(temp, ":") + 3);
            CWindow.AddGameRule(iGameMode, RuleName[iTemp], iTemp);
            J0x4EF:
            // [Loop Continue]
            goto J0x47C;
        }
        ++ i;
        // [Loop Continue]
        goto J0x3E2;
    }
    bSetVoteList = true;
}

simulated function bool SetAdminWindow()
{
    local AdminWindow Window;
    local int repAdminChechsum;
    local bool bUpd;
    local int i;

    if(!(CWindow.AdminWindow != none) && PlayerPawn(Owner).PlayerReplicationInfo.bAdmin)
    {
/*         bSetAdminWindow = true;
        return bUpd; */
    Window = AdminWindow(CWindow.AdminWindow.ClientArea);
    repAdminChechsum = Len(GameTypes) + Len(OtherClass) + Len(string(VoteTimeLimit)) + Len(string(KickPercent)) + Len(string(ScoreBoardDelay)) + Len(string(bAutoOpen)) + Len(string(bKickVote)) + Len(PreFixSwap) + Len(string(bDebugMode)) + Len(string(bRemoveCrashedMaps)) + RepeatLimit + Len(MapVoteHistoryType) + MidGameVotePercent + Len(Mode) + MinMapCount + Len(MapPreFixOverRide) + Len(HasStartWindow) + Len(MapInfoURL) + Len(string(bEntryWindows)) + Len(CustomGamesState);
    i = 0;
    J0x138:
    if(i < 63)
    {
        repAdminChechsum += Len(CustomGames[i]);
        ++ i;
        goto J0x138;
    }
    if(gAdminChechsum != repAdminChechsum)
    {
        bUpd = true;
        gAdminChechsum = repAdminChechsum;
    }
    Window.sldVoteTimeLimit.SetValue(float(VoteTimeLimit));
    Window.sldKickPercent.SetValue(float(KickPercent));
    Window.sldScoreBoardDelay.SetValue(float(ScoreBoardDelay));
    Window.cbAutoOpen.bChecked = bAutoOpen;
    Window.cbKickVote.bChecked = bKickVote;
    Window.cbCheckOtherGameTie.bChecked = bCheckOtherGameTie;
    Window.txtRepeatLimit.SetValue(string(RepeatLimit));
    Window.cboMapVoteHistoryType.SetValue(MapVoteHistoryType);
    Window.sldMidGameVotePercent.SetValue(float(MidGameVotePercent));
    Window.cboMode.SetValue(Mode);
    Window.txtMinMapCount.SetValue(string(MinMapCount));
    Window.txtMapVoteTitle.SetValue(MapVoteTitle);
    //Window.txtASClass.SetValue(ASClass);
    //Window.cbRemoveCrashedMaps.bChecked = bRemoveCrashedMaps;
    Window.txtMapInfoURL.SetValue(MapInfoURL);
    Window.cbEntryWindows.bChecked = bEntryWindows;
    Window.cbDebugMode.bChecked = bDebugMode;
    Window.lblActGame.SetText(("C" $ "lass:") @ ActGameClass);
    Window.lblActPrefix.SetText("Map Prefix:" @ ActGamePrefix);
    if(Len(CustomGamesState) > 10)
    {
        i = 0;
        J0x3EF:
        if(i < ArrayCount(RuleList))
        {
            if(Mid(CustomGamesState, i, 1) == "1")
            {
                Window.GetCbCustGame(i).bChecked = true;
            }
            else
            {
                Window.GetCbCustGame(i).bChecked = false;
            }
            if(CustomGames[i] != "")
            {
                Window.GetLblCustGame(i).SetText(CustomGames[i]);
                Window.GetCbCustGame(i).bDisabled = false;
                goto J0x4F6;
            }
            Window.GetLblCustGame(i).SetText("empty");
            Window.GetCbCustGame(i).bDisabled = true;
            J0x4F6:
            ++ i;
            goto J0x3EF;
        }
    }
    if(!bUpd)
    {
        bSetAdminWindow = true;
    }
    return bUpd;
    }
}

simulated function Timer()
{
    local int i, MyPlayerCount;
    local bool bHasVoted;
    local int repPlayerCount;
    local string TitleTemp;

    GetMapList();
    if(!bOpenWindowDispatched)
    {
        OpenWindow();
        return;
    }
    if(!bSetupWindowDelayDone)
    {
        bSetupWindowDelayDone = true;
        SetupWindow();
    }
    DebugLog("timer()");
    bUpdated = false;
    if(bMapListLoad && !bSetVoteList)
    {
        SetVoteList();
    }
    if(!bSetAdminWindow)
    {
        bUpdated = SetAdminWindow();
    }
    if(bKickVote || PlayerPawn(Owner).PlayerReplicationInfo.bAdmin)
    {
        CWindow.EnableKickWindow();
    }
    i = 0;
    J0xBE:
    if((i < 32) && PlayerName[i] != "")
    {
        repPlayerCount = i + 1;
        ++ i;
        goto J0xBE;
    }
    if(repPlayerCount != gPlayerCount)
    {
        i = gPlayerCount;
        J0x110:
        if(i < repPlayerCount)
        {
            if(Right(PlayerName[i], 5) == "&?&!&")
            {
                PlayerName[i] = Mid(PlayerName[i], 0, Len(PlayerName[i]) - 5);
                bHasVoted = true;
            }
            else
            {
                bHasVoted = false;
            }
            CWindow.AddPlayerName(PlayerName[i], bHasVoted);
            ++ i;
            goto J0x110;
        }
        gPlayerCount = repPlayerCount;
        bUpdated = true;
    }
    i = 0;
    J0x1BC:
    if((MapVoteResults[i] != "") && i < 31)
    {
        UpdateMapVoteResults(MapVoteResults[i], i);
        ++ i;
        goto J0x1BC;
    }
    i = 0;
    J0x203:
    if((KickVoteResults[i] != "") && i < 31)
    {
        UpdateKickVoteResults(KickVoteResults[i], i);
        ++ i;
        goto J0x203;
    }
	  if ( ClientCache != None )
	  {
		TitleTemp = MapVoteFramedWindow(TheWindow).TitleStr;
		TitleTemp = TitleTemp $ "    " $ string(ClientCache.LoadRuleCount) $ "/" $ string(ClientCache.RuleCount) @ "Game Rule loaded";
		TitleTemp = TitleTemp $ "    " $ string(ClientCache.LoadMapCount) $ "/" $ string(ClientCache.MapCount) @ "Maps loaded";
		TitleTemp = TitleTemp $ "     Mode:" @ Mode;
		MapVoteFramedWindow(TheWindow).WindowTitle = TitleTemp;
	  }
    CWindow.MapWindow.lblTitle.SetText(MapVoteTitle);
    CWindow.MapWindow.LogoTexture = LogoTexture;
    if(ServerInfoURL != "")
    {
        CWindow.InfoWindow.SetInfoServerAddress(ServerInfoURL, MapInfoURL);
        if(CWindow.AdminWindow != none)
        {
            AdminWindow(CWindow.AdminWindow.ClientArea).txtServerInfoURL.SetValue(ServerInfoURL);
        }
    }
    else
    {
        MapVoteNavBar(CWindow.InfoWindow.VSplitter.BottomClientWindow).ServerInfoButton.bDisabled = true;
    }
    MapVoteNavBar(CWindow.InfoWindow.VSplitter.BottomClientWindow).ReportButton1.bDisabled = false;
    MapVoteNavBar(CWindow.InfoWindow.VSplitter.BottomClientWindow).ReportButton2.bDisabled = false;
    CWindow.MapWindow.PrefixDictionary = PrefixDictionary;
    if(!bMapListLoad)
    {
        SetTimer(0.50, false);
        return;
    }
    if(!bUpdated && blastCheck)
    {
        if(CWindow.AdminWindow != none)
        {
            AdminWindow(CWindow.AdminWindow.ClientArea).RemoteSaveButton.bDisabled = false;
        }
        return;
    }
    if(!bUpdated)
    {
        blastCheck = true;
        SetTimer(Level.TimeDilation,False);
        return;
    }
    blastCheck = false;
    SetTimer(0.50, false);
}

simulated function AddNewPlayer (string NewPlayerName, bool bHasVoted)
{
  if ( bKickVote )
  {
    if ( TheWindow != None )
    {
      CWindow.AddPlayerName(NewPlayerName,bHasVoted);
    }
  }
}

simulated function RemovePlayerName (string OldPlayerName)
{
  if ( bKickVote )
  {
    if ( TheWindow != None )
    {
      CWindow.RemovePlayerName(OldPlayerName);
    }
  }
}

simulated function UpdatePlayerVoted (string PlayerID)
{
  if ( TheWindow != None )
  {
    CWindow.UpdatePlayerVoted(PlayerID);
  }
}

simulated function UpdateMapVoteResults (string Text, int i)
{
  if ( TheWindow != None )
  {
    CWindow.UpdateMapVoteResults(Text,i);
  }
}

simulated function UpdateKickVoteResults (string Text, int i)
{
  if ( TheWindow != None )
  {
    CWindow.UpdateKickVoteResults(Text,i);
  }
}

simulated function SendReportText (string p_ReportText)
{
  if ( p_ReportText == "" )
  {
    if ( TheWindow != None )
    {
      CWindow.InfoWindow.SetMOTD(ReportText);
    }
    ReportText = "";
  } else {
    ReportText = ReportText $ p_ReportText;
  }
}

function DestroyWRI ()
{
  Super.DestroyWRI();
}

function DebugLog (string Msg)
{
  Log("MV " $ Msg);
}

function string ClientNeedBTRecord (string MapName)
{
}

simulated function SendBTRecord (string Rec)
{
  if ( (CWindow == None) || (CWindow.ConfigWindow == None) )
  {
    return;
  }
}

function GetServerConfig ()
{
	local int i;

	//bKickVote=Class'MapVote'.Default.bKickVote;
/*  	ScoreBoardDelay=Class'MapVote'.Default.ScoreBoardDelay;
	ServerInfoURL=Class'MapVote'.Default.ServerInfoURL;
	MapInfoURL=Class'MapVote'.Default.MapInfoURL;
	Mode=Class'MapVote'.Default.Mode;
	bEntryWindows=Class'MapVote'.Default.bEntryWindows;
	bDebugMode=Class'MapVote'.Default.bDebugMode;
	LogoTexture=Class'MapVote'.Default.LogoTexture;
	List1Title=Class'MapVote'.Default.List1Title;
	List2Title=Class'MapVote'.Default.List2Title;
	List3Title=Class'MapVote'.Default.List3Title;
	List4Title=Class'MapVote'.Default.List4Title;
	MapVoteTitle=Class'MapVote'.Default.MapVoteTitle;
	if ( PlayerPawn(Owner).bAdmin )
	{
		DebugLog("Admin is logged in. Sending admin vars...");
		if ( Class'MapVote'.Default.bDM )
		{
			GameTypes="1";
		} else {
			GameTypes="0";
		}
		if ( Class'MapVote'.Default.bLMS )
		{
			GameTypes=GameTypes $ "1";
		} else {
			GameTypes=GameTypes $ "0";
		}
		if ( Class'MapVote'.Default.bTDM )
		{
			GameTypes=GameTypes $ "1";
		} else {
			GameTypes=GameTypes $ "0";
		}
		if ( Class'MapVote'.Default.bAS )
		{
			GameTypes=GameTypes $ "1";
		} else {
			GameTypes=GameTypes $ "0";
		}
		if ( Class'MapVote'.Default.bDOM )
		{
			GameTypes=GameTypes $ "1";
		} else {
			GameTypes=GameTypes $ "0";
		}
		if ( Class'MapVote'.Default.bCTF )
		{
			GameTypes=GameTypes $ "1";
		} else {
			GameTypes=GameTypes $ "0";
		}
		if ( False )
		{
			GameTypes=GameTypes $ "1";
		} else {
			GameTypes=GameTypes $ "0";
		}
		ActGameClass=string(Level.Game.Class);
		ActGamePrefix=Level.Game.MapPrefix;
		bReloadMapsOnRequestOnly=Class'MapVote'.Default.bReloadMapsOnRequestOnly;
		MinMapCount=Class'MapVote'.Default.MinMapCount;
		bAutoDetect=Class'MapVote'.Default.bAutoDetect;
		RepeatLimit=Class'MapVote'.Default.RepeatLimit;
		KickPercent=Class'MapVote'.Default.KickPercent;
		bUseMapList=Class'MapVote'.Default.bUseMapList;
		bAutoOpen=Class'MapVote'.Default.bAutoOpen;
		VoteTimeLimit=Class'MapVote'.Default.VoteTimeLimit;
		bCheckOtherGameTie=Class'MapVote'.Default.bCheckOtherGameTie;
		MapVoteHistoryType=Class'MapVote'.Default.MapVoteHistoryType;
		MidGameVotePercent=Class'MapVote'.Default.MidGameVotePercent;
		bSortWithPreFix=Class'MapVote'.Default.bSortWithPreFix;
		bRemoveCrashedMaps=Class'MapVote'.Default.bRemoveCrashedMaps;
		ASClass=Class'MapVote'.Default.ASClass;
		bUseExcludeFilter=Class'MapVote'.Default.bUseExcludeFilter;
	} */
}

defaultproperties
{
      RuleCount=0
      MapCount=0
      bSetVoteList=False
      bSetAdminWindow=False
      GameTypes=""
      OtherClass=""
      VoteTimeLimit=0
      KickPercent=0
      bAutoOpen=False
      ScoreBoardDelay=0
      bCheckOtherGameTie=False
      ServerInfoURL=""
      MapInfoURL=""
      ReportText=""
      Mode=""
      RepeatLimit=0
      MapVoteHistoryType=""
      MidGameVotePercent=0
      MinMapCount=0
      MapPreFixOverRide=""
      PreFixSwap=""
      OtherPreFix=""
      HasStartWindow=""
      bEntryWindows=False
      bDebugMode=False
      bRemoveCrashedMaps=False
      ActGameClass=""
      ActGamePrefix=""
      MapVoteTitle=""
      CustomGamesState=""
      PrefixDictionary=""
      bUpdated=False
      blastCheck=False
      gAdminChechsum=0
      gPlayerChecksum=0
      bAdminDone=False
      LogoTexture=""
      bOpenWindowDispatched=False
      bSetupWindowDelayDone=False
      ClientCache=None
      bMapListLoad=False
      ClientConf=None
      CWindow=None
      helper=None
      WindowClass=Class'MapVoteFramedWindow'
      WinLeft=50
      WinTop=20
      WinWidth=670
      WinHeight=550
      NetPriority=3.000000
      NetUpdateFrequency=10.000000
}