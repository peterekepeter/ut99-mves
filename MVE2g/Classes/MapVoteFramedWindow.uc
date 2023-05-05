//================================================================================
// MapVoteFramedWindow.
//================================================================================
class MapVoteFramedWindow extends UWindowFramedWindow;

var string TitleStr;

function BeginPlay ()
{
	Super.BeginPlay();
	TitleStr = Left(string(Default.Class),InStr(string(Default.Class),"."));
	ClientClass = Class'MapVoteTabWindow';
	WindowTitle = TitleStr;
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

function Created ()
{
	Super.Created();
	WinWidth = 666;
	WinHeight = 550;
	WinLeft = (Root.WinWidth - WinWidth) / 2;
	WinTop = (Root.WinHeight - WinHeight) / 2;
}

function Close (optional bool bByParent)
{
	local WindowConsole C;
	local PlayerPawn P;
	
	P = GetPlayerOwner();
	P.PlaySound(Sound'WindowClose');
	if ( (P == None) || (P.Player == None) || (P.Player.Console == None) )
		return;
	C = WindowConsole(P.Player.Console);
	if ( C == None )
		return;
	C.CloseUWindow();
	Super.Close(bByParent);
}

defaultproperties
{
      TitleStr=""
}
