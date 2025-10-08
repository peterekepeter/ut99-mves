//================================================================================
// MVWelcomeWRI.
//================================================================================
class MVWelcomeWRI extends WRI;

var string ServerInfoURL;
var string MapInfoURL;
var bool bHasStartWindow;
var bool bFixNetNews;

replication
{
	reliable if( Role == ROLE_Authority )
		ServerInfoURL, MapInfoURL, bHasStartWindow, bFixNetNews;
}

simulated function bool SetupWindow ()
{
	SetTimer(1.0, False);
}

simulated function bool IsOpenNecessary()
{
	return !Class'MapVoteNavBar'.Default.bWelcomeWindowWasShown 
		|| !Class'MapVoteNavBar'.Default.bWelcomeKeybinderCheck;
}

simulated function Timer ()
{
	local WindowConsole C;
	local UWindowWindow KeyBinderWindow;
	local bool bHotKeyBound, bHasWindow;

	if ( bFixNetNews ) 
	{
		class'MVFixNetNews'.Static.FixNetNews();
	}

	if ( !Class'MapVoteNavBar'.Default.bWelcomeWindowWasShown && ServerInfoURL != "" )
	{
		Super.SetupWindow();
		MVWelcomeWindow(TheWindow).bHasStartWindow = bHasStartWindow;
		ServerInfoWindow(TheWindow.FirstChildWindow).SetInfoServerAddress(ServerInfoURL,MapInfoURL);
		ServerInfoWindow(TheWindow.FirstChildWindow).ShowServerInfoPage();
		Class'MapVoteNavBar'.Default.bWelcomeWindowWasShown = True;
		bHasWindow = True;
	}
	else if ( !Class'MapVoteNavBar'.Default.bWelcomeKeybinderCheck )
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
		}
	}

	if (!bHasWindow)
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
