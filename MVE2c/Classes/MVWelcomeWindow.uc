//================================================================================
// MVWelcomeWindow.
//================================================================================
class MVWelcomeWindow extends UWindowFramedWindow;

var float StartTime;
var bool bHasStartWindow;

function Created ()
{
	bSizable=False;
	Super.Created();
	StartTime=GetPlayerOwner().Level.TimeSeconds;
	WinLeft=Root.WinWidth / 2 - WinWidth / 2;
	WinTop=Root.WinHeight / 2 - WinHeight / 2;
}

function Close (optional bool bByParent)
{
	local UWindowWindow KeyBinderWindow;

	Super.Close(bByParent);
	KeyBinderWindow=Root.FindChildWindow(Class'MVKeyBinderFrameWindow',True);
	if ( bHasStartWindow && (KeyBinderWindow == None) )
	{
		FocusStartWindow();
	} else {
		WindowConsole(GetPlayerOwner().Player.Console).CloseUWindow();
	}
}

function FocusStartWindow ()
{
	local UWindowWindow Child;

	Child=Root.LastChildWindow;
JL0014:
	if ( Child != None )
	{
		if ( (Left(string(Child.Class),6) == "UTMenu") || (Left(string(Child.Class),5) == "UMenu") )
		{
			WindowConsole(GetPlayerOwner().Player.Console).CloseUWindow();
		} else {
			if ( Child.Class != self.Class )
			{
				goto JL00C1;
			}
		}
		Child=Child.PrevSiblingWindow;
		goto JL0014;
	}
JL00C1:
	if ( Child == None )
	{
		WindowConsole(GetPlayerOwner().Player.Console).CloseUWindow();
	} else {
		Child.bLeaveOnscreen=True;
		Child.FocusWindow();
		Child.ShowWindow();
	}
}

function Tick (float DeltaTime)
{
	local UWindowWindow KeyBinderWindow;

	if ( (StartTime > 0) && (GetPlayerOwner().Level.TimeSeconds > StartTime + 3) )
	{
		StartTime=0.00;
		FocusWindow();
		BringToFront();
		ShowWindow();
		KeyBinderWindow=Root.FindChildWindow(Class'MVKeyBinderFrameWindow',True);
		if ( KeyBinderWindow != None )
		{
			KeyBinderWindow.FocusWindow();
			KeyBinderWindow.BringToFront();
			KeyBinderWindow.ShowWindow();
		}
	}
	Super.Tick(DeltaTime);
}

defaultproperties
{
      StartTime=0.000000
      bHasStartWindow=False
      ClientClass=Class'ServerInfoWindow'
      WindowTitle="Map Vote Welcome Window"
}
