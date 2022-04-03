//================================================================================
// MVKeyBinderFrameWindow.
//================================================================================
class MVKeyBinderFrameWindow extends UWindowFramedWindow;

var bool bHasStartWindow;

function Created ()
{
	bSizable=False;
	Super.Created();
	WinWidth=480.00;
	WinHeight=200.00;
	WinLeft=Root.WinWidth / 2 - WinWidth / 2;
	WinTop=Root.WinHeight / 2 - WinHeight / 2;
}

function ResolutionChanged(float W, float H)
{
	SetDimensions();
}

function SetDimensions()
{
	WinLeft = ParentWindow.WinWidth/2 - WinWidth/2;
	WinTop = ParentWindow.WinHeight/2 - WinHeight/2;
}

function Close (optional bool bByParent)
{
	local UWindowWindow WelcomeWindow;
	local PlayerPawn P;
	
	P = GetPlayerOwner();
	P.PlaySound(Sound'WindowClose');
	Super.Close(bByParent);
	WelcomeWindow=Root.FindChildWindow(Class'MVWelcomeWindow',True);
	if ( WelcomeWindow == None )
	{
		if ( bHasStartWindow )
		{
			FocusStartWindow();
		} else {
			WindowConsole(GetPlayerOwner().Player.Console).CloseUWindow();
		}
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

defaultproperties
{
      bHasStartWindow=False
      ClientClass=Class'MVE2c.MVKeyBinderClientWindow'
      WindowTitle="Map Vote Key Binder"
}
