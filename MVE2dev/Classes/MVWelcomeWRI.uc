//================================================================================
// MVWelcomeWRI.
//================================================================================
class MVWelcomeWRI extends WRI;

var string ServerInfoURL;
var string MapInfoURL;
var bool bHasStartWindow;
var bool bFixNetNews;
var string RequireAccept;
var string ServerCode;
var string ServerInfoVersion;

replication
{
	reliable if( Role == ROLE_Authority )
		ServerInfoURL, RequireAccept, MapInfoURL, bHasStartWindow, bFixNetNews, ServerInfoVersion, ServerCode;
}

simulated function bool SetupWindow ()
{
	SetTimer(1.0, True);
}

simulated function bool IsOpenNecessary()
{
	return !Class'MapVoteNavBar'.Default.bWelcomeWindowWasShown 
		|| !Class'MapVoteNavBar'.Default.bWelcomeKeybinderCheck;
}

simulated function MapVoteCache GetPerServerConfig() 
{
	return class'MapVoteCache'.Static.GetStrNamedInstance(ServerCode);
}

simulated function Timer ()
{
	local WindowConsole C;
	local UWindowWindow KeyBinderWindow;
	local bool bHotKeyBound, bHasWindow;
	local MapVoteCache MVC;
	local string RequiredInfoSignature;
	local string PlayerName;
	local string RequiredKeybindSignature;
	local string RequiredAcceptSignature;
	local bool bRequireAccept;

	if ( ServerCode == "" ) 
	{
		return;
	}

	if ( RequireAccept == "" )
	{
		return;
	}

	MVC = GetPerServerConfig();

	PlayerName = PlayerPawn(Owner).PlayerReplicationInfo.PlayerName;
	RequiredInfoSignature = PlayerName$ServerInfoVersion;
	RequiredKeybindSignature = PlayerName;
	bRequireAccept = RequireAccept != "None";

	if ( bRequireAccept )
		RequiredAcceptSignature = PlayerName$"_checked_"$ServerInfoVersion;
	else 
		RequiredAcceptSignature = "";

	if ( bFixNetNews ) 
	{
		class'MVFixNetNews'.Static.FixNetNews();
	}

	if ( 
		MVC.InfoSeenSignature == RequiredInfoSignature && 
		( !bRequireAccept || MVC.InfoAcceptSignature == RequiredAcceptSignature ) 
	) 
	{
		// was shown in previous playsession, this disables WelcomeWRI
		// TODO check for playername
		class'MapVoteNavBar'.Default.bWelcomeWindowWasShown = True;
	}

	if ( MVC.KeybindSeenSignature == RequiredKeybindSignature )
	{
		class'MapVoteNavBar'.Default.bWelcomeKeybinderCheck = True;
	}

	if ( MVC.InfoSeenSignature != RequiredInfoSignature 
		|| bRequireAccept && MVC.InfoAcceptSignature != RequiredAcceptSignature )
	{
		Super.SetupWindow();
		MVWelcomeWindow(TheWindow).bHasStartWindow = bHasStartWindow;
		ServerInfoWindow(TheWindow.FirstChildWindow).SetInfoServerAddress(ServerInfoURL,MapInfoURL);
		ServerInfoWindow(TheWindow.FirstChildWindow).ShowServerInfoPage();
		if ( bRequireAccept ) 
		{
			ServerInfoWindow(TheWindow.FirstChildWindow).NavBar.SetRequiredAccept(bRequireAccept, RequireAccept, RequiredAcceptSignature, MVC); 
		}
		else
		{
			class'MapVoteNavBar'.Default.bWelcomeWindowWasShown = True;
		}
		bHasWindow = True;
		MVC.InfoSeenSignature = RequiredInfoSignature;
		MVC.SaveConfig();
	}
	else if ( MVC.KeybindSeenSignature != RequiredKeybindSignature )
	{
		Class'MapVoteNavBar'.Default.bWelcomeKeybinderCheck = True;
		bHotKeyBound = IsHotKeyBound();
		if ( !bHotKeyBound )
		{
			C = WindowConsole(PlayerPawn(Owner).Player.Console);
			KeyBinderWindow = C.Root.CreateWindow(Class'MVKeyBinderFrameWindow',0.00,0.00,480.00,240.00);
			PlayerPawn(Owner).PlaySound(Sound'WindowOpen');
			MVKeyBinderFrameWindow(KeyBinderWindow).bHasStartWindow = bHasStartWindow;
			KeyBinderWindow.bLeaveOnscreen = True;
			KeyBinderWindow.ShowWindow();
			bHasWindow = True;
			MVC.KeybindSeenSignature = RequiredKeybindSignature;
			MVC.SaveConfig();
		}
	}

	if ( !bHasWindow )
	{
		WindowConsole(PlayerPawn(Owner).Player.Console).CloseUWindow();
	}

	DestroyWRI();
}

simulated function bool IsHotKeyBound ()
{
	local int i;
	local string KeyName;
	local string Alias;

	for ( i = 0; i < 255; i+=1 )
	{
		KeyName = PlayerPawn(Owner).ConsoleCommand("KEYNAME "$string(i));
		if ( KeyName != "" )
		{
			Alias = PlayerPawn(Owner).ConsoleCommand("KEYBINDING "$KeyName);
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
	WinWidth=600
	WinHeight=450
}
