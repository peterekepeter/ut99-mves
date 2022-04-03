//================================================================================
// MVWelcomeWRI.
//================================================================================
class MVWelcomeWRI extends WRI;

var string ServerInfoURL;
var string MapInfoURL;
var bool bHasStartWindow;

replication
{
   reliable if( Role==ROLE_Authority )
      ServerInfoURL, MapInfoURL, bHasStartWindow;
}

simulated function bool SetupWindow ()
{
	local int i;
	local WindowConsole C;

	if ( Class'MapVoteClientConfig'.Default.bUseMsgTimeout )
	{
		Class'SayMessagePlus'.Default.Lifetime=Class'MapVoteClientConfig'.Default.MsgTimeOut;
		Class'CriticalStringPlus'.Default.Lifetime=Class'MapVoteClientConfig'.Default.MsgTimeOut;
		Class'RedSayMessagePlus'.Default.Lifetime=Class'MapVoteClientConfig'.Default.MsgTimeOut;
		Class'TeamSayMessagePlus'.Default.Lifetime=Class'MapVoteClientConfig'.Default.MsgTimeOut;
		Class'StringMessagePlus'.Default.Lifetime=Class'MapVoteClientConfig'.Default.MsgTimeOut;
		Class'DeathMessagePlus'.Default.Lifetime=Class'MapVoteClientConfig'.Default.MsgTimeOut;
	}
	if ( (ServerInfoURL != "") && Class'MapVoteNavBar'.Default.bShowWelcomeWindow )
	{
		if ( Super.SetupWindow() )
		{
			SetTimer(1.00,False);
		} else {
			Log("Super.SetupWindow() = false");
		}
	} else {
		SetTimer(1.00,False);
	}
}

simulated function Timer ()
{
	local WindowConsole C;
	local UWindowWindow KeyBinderWindow;
	local UWindowWindow Child;
	local bool bHotKeyBound;

	if ( (ServerInfoURL != "") && Class'MapVoteNavBar'.Default.bShowWelcomeWindow )
	{
		MVWelcomeWindow(TheWindow).bHasStartWindow=bHasStartWindow;
		ServerInfoWindow(TheWindow.FirstChildWindow).SetInfoServerAddress(ServerInfoURL,MapInfoURL);
		ServerInfoWindow(TheWindow.FirstChildWindow).BrowseWebPage(ServerInfoURL);
	}
	C=WindowConsole(PlayerPawn(Owner).Player.Console);
	bHotKeyBound=HotKeyBound();
	if (  !bHotKeyBound )
	{
		KeyBinderWindow=C.Root.CreateWindow(Class'MVKeyBinderFrameWindow',0.00,0.00,480.00,240.00);
		PlayerPawn(Owner).PlaySound(Sound'WindowOpen');
		MVKeyBinderFrameWindow(KeyBinderWindow).bHasStartWindow=bHasStartWindow;
		KeyBinderWindow.bLeaveOnscreen=True;
		KeyBinderWindow.ShowWindow();
	}
	if ( ((ServerInfoURL == "") ||  !Class'MapVoteNavBar'.Default.bShowWelcomeWindow) && bHotKeyBound )
	{
		if ( bHasStartWindow )
		{
			FocusStartWindow();
		} else {
			C.CloseUWindow();
		}
	}
	DestroyWRI();
}
/* 
function GetServerConfig ()
{
	ServerInfoURL=Class'MapVote'.Default.ServerInfoURL;
	MapInfoURL=Class'MapVote'.Default.MapInfoURL;
}
 */
simulated function FocusStartWindow ()
{
	local UWindowWindow Child;
	local WindowConsole C;

	Log("FocusStartWindow");
	C=WindowConsole(PlayerPawn(Owner).Player.Console);
	Child=C.Root.LastChildWindow;

	while ( Child != None )
	{
		if ( (Left(string(Child.Class),6) == "UTMenu") || (Left(string(Child.Class),5) == "UMenu") )
		{
			C.CloseUWindow();
		} else {
			if ( Child.Class != self.Class )
			{
				break;
			}
		}
		Child=Child.PrevSiblingWindow;
	}

	if ( Child == None )
	{
		C.CloseUWindow();
	} else {
		Child.bLeaveOnscreen=True;
		Child.FocusWindow();
		Child.ShowWindow();
	}
}

simulated function bool HotKeyBound ()
{
	local int i;
	local string KeyName;
	local string Alias;

	for ( i=0; i < 255; i++ )
	{
		KeyName=PlayerPawn(Owner).ConsoleCommand("KEYNAME " $ string(i));
		if ( KeyName != "" )
		{
			Alias=PlayerPawn(Owner).ConsoleCommand("KEYBINDING " $ KeyName);
			if ( Caps(Alias) == "MUTATE BDBMAPVOTE VOTEMENU" )
			{
				return True;
			}
		}
	}
	return False;
}

defaultproperties
{
	WindowClass=Class'MVWelcomeWindow'
	//WinLeft=50
	//WinTop=30
	WinWidth=600
	WinHeight=450
}