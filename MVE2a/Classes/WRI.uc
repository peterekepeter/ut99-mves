//================================================================================
// WRI.
//================================================================================

class WRI extends Info;

var() Class<UWindowWindow> WindowClass;
var() int WinLeft;
var() int WinTop;
var() int WinWidth;
var() int WinHeight;
var() bool DestroyOnClose;
var UWindowWindow TheWindow;
var int TicksPassed;
var bool bDestroyRequested;

replication
{
    reliable if(Role < ROLE_Authority)
        DestroyWRI;

    reliable if(Role == ROLE_Authority)
        CloseWindow, OpenWindow;
}

event PostBeginPlay ()
{
	Super.PostBeginPlay();
	OpenIfNecessary();
}

simulated event PostNetBeginPlay ()
{
	PostBeginPlay();
	OpenIfNecessary();
}

simulated function OpenIfNecessary ()
{
	local PlayerPawn P;

	if ( Owner != None )
	{
		P=PlayerPawn(Owner);
		if ( (P != None) && (P.Player != None) && (P.Player.Console != None) )
		{
			OpenWindow();
		}
	}
}

simulated function bool OpenWindow()
{
	local PlayerPawn P;
	local WindowConsole C;

	P=PlayerPawn(Owner);
	if ( P == None )
	{
		Log("#### -- Attempted to open a window on something other than a PlayerPawn");
		DestroyWRI();
		return False;
	}
	if ( P.Player.Console != None )
		C = WindowConsole(P.Player.Console);
	if ( C == None )
	{
		Log("#### -- No Console");
		DestroyWRI();
		return False;
	}
	if ( !C.bCreatedRoot || ( C.Root == None) )
	{
		C.CreateRootWindow(None);
	}
	C.bQuickKeyEnable=True;
	C.LaunchUWindow();
	TicksPassed=1;
	return True;
}

simulated function Tick (float DeltaTime)
{
	if ( TicksPassed != 0 )
	{
		if ( TicksPassed++  == 10 )
		{
			SetupWindow();
			TicksPassed=0;
		}
	}
	if ( DestroyOnClose && (TheWindow != None) && !TheWindow.bWindowVisible && !bDestroyRequested )
	{
		bDestroyRequested=True;
		DestroyWRI();
	}
}

simulated function bool SetupWindow ()
{
	local WindowConsole C;

	if ( PlayerPawn(Owner) != None && PlayerPawn(Owner).Player.Console != None)
		C = WindowConsole(PlayerPawn(Owner).Player.Console);
	if ( C != None )
	{
		TheWindow=C.Root.CreateWindow(WindowClass,WinLeft,WinTop,WinWidth,WinHeight);
		PlayerPawn(Owner).PlaySound(Sound'WindowOpen');
	}
	if ( TheWindow == None )
	{
		Log("#### -- CreateWindow Failed");
		DestroyWRI();
		return False;
	}
	if ( C != None && C.bShowConsole )
		C.HideConsole();
	TheWindow.bLeaveOnscreen=True;
	TheWindow.ShowWindow();
	return True;
}

simulated function CloseWindow ()
{
	local WindowConsole C;

	if ( PlayerPawn(Owner) != None && PlayerPawn(Owner).Player.Console != None )
		C = WindowConsole(PlayerPawn(Owner).Player.Console);
	if ( C != None )
		C.bQuickKeyEnable=False;
	if ( TheWindow != None )
		TheWindow.Close();
}

function DestroyWRI ()
{
	Destroy();
}

defaultproperties
{
      WindowClass=None
      WinLeft=0
      WinTop=0
      WinWidth=0
      WinHeight=0
      DestroyOnClose=True
      TheWindow=None
      TicksPassed=0
      bDestroyRequested=False
      RemoteRole=ROLE_SimulatedProxy
      NetPriority=2.000000
}
