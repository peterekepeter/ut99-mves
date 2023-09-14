//================================================================================
// MapVoteNavBar.
//================================================================================
class MapVoteNavBar extends UMenuDialogClientWindow;

var UWindowSmallButton ServerInfoButton;
var UWindowSmallButton MapInfoButton;
var UWindowSmallButton ReportButton1;
var UWindowSmallButton ReportButton2;
var UWindowSmallButton TipsButton;
var UWindowSmallButton AboutButton;
var UWindowSmallButton CloseButton;
var bool bShowWelcomeWindow;

var Color BackgroundColor;

/*var string RealKeyName[255];
var UMenuLabelControl  lblKeyBind;
var UMenuLabelControl  lblMenuKey;
var UMenuRaisedButton  ButMenuKey;
var string OldMenuKey;
var bool   bMenu;*/

function Created ()
{
	local Color TextColor;

	Super.Created();
	TextColor.R=171;
	TextColor.G=171;
	TextColor.B=171;
	ServerInfoButton=UWindowSmallButton(CreateControl(Class'UWindowSmallButton',1.00,0,59.00,10.00));
	ServerInfoButton.Text="Server Info";
	ServerInfoButton.DownSound=Sound'Click';
	MapInfoButton=UWindowSmallButton(CreateControl(Class'UWindowSmallButton',60.00,0,59.00,10.00));
	MapInfoButton.Text="Map Info";
	MapInfoButton.DownSound=Sound'Click';
	// ReportButton1=UWindowSmallButton(CreateControl(Class'UWindowSmallButton',120.00,0,139.00,10.00));
	// ReportButton1.Text="Report 1: Map Vote Ranking";
	// ReportButton1.DownSound=Sound'Click';
	// ReportButton1.bDisabled=True;
	// ReportButton2=UWindowSmallButton(CreateControl(Class'UWindowSmallButton',260.00,0,139.00,10.00));
	// ReportButton2.Text="Report 2: Map Vote Sequence";
	// ReportButton2.DownSound=Sound'Click';
	// ReportButton2.bDisabled=True;
	AboutButton=UWindowSmallButton(CreateControl(Class'UWindowSmallButton',120.00,0,39.00,10.00));
	AboutButton.Text="About";
	AboutButton.DownSound=Sound'Click';
	TipsButton=UWindowSmallButton(CreateControl(Class'UWindowSmallButton',160.00,0,69.00,10.00));
	TipsButton.Text="Map Vote Tips";
	TipsButton.DownSound=Sound'Click';
	/*lblKeyBind = UMenuLabelControl(CreateControl(class'UMenuLabelControl',715.00,2.0,100,10.00));
	lblKeyBind.SetText("");
	lblKeyBind.TextColor = (TextColor);
	lblKeyBind.SetFont(F_Bold);
	lblMenuKey = UMenuLabelControl(CreateControl(class'UMenuLabelControl', 520,2.0,110.00,10.00));
	lblMenuKey.TextColor = (TextColor);
	lblMenuKey.SetText("Bind Map Vote Key ...");
	lblMenuKey.SetFont(F_Bold);
	ButMenuKey = UMenuRaisedButton(CreateControl(class'UMenuRaisedButton', 635.00,-2.0,69.00,10.00));
	ButMenuKey.bAcceptsFocus = False;
	ButMenuKey.bIgnoreLDoubleClick = True;
	ButMenuKey.bIgnoreMDoubleClick = True;
	ButMenuKey.bIgnoreRDoubleClick = True;
	SetAcceptsFocus();
	LoadExistingKeys();*/
	//CloseButton=UWindowSmallButton(CreateControl(Class'UWindowSmallButton',850.00,0,80.00,10.00));
	CloseButton=UWindowSmallButton(CreateControl(Class'UWindowSmallButton',WinWidth - 89,0,80.00,10.00));
	CloseButton.Text="Close";
	//CloseButton.DownSound=Sound'WindowClose';
	BackgroundColor = class'MapVoteClientConfig'.static.GetInstance().BackgroundColor;
}

function Notify (UWindowDialogControl C, byte E)
{
	local string CurrentMapName;
	local int pos;
	local ServerInfoWindow InfoWindow;

	InfoWindow=ServerInfoWindow(ParentWindow.ParentWindow);
	Super.Notify(C,E);
	switch (E)
	{
		case 2:
		switch (C)
		{
			case ServerInfoButton:
				InfoWindow.ShowServerInfoPage();
				break;
			case MapInfoButton:
				InfoWindow.ShowMapInfoPage();
				break;
			case ReportButton1:
				GetPlayerOwner().ConsoleCommand("MUTATE BDBMAPVOTE REPORT PC");
				break;
			case ReportButton2:
				GetPlayerOwner().ConsoleCommand("MUTATE BDBMAPVOTE REPORT SEQ");
				break;
			case TipsButton:
				InfoWindow.ShowTipsPage();
				break;
			case AboutButton:
				InfoWindow.ShowAboutPage();
				break;
			case CloseButton:
				Root.CloseActiveWindow();
				break;
			default:
		}
		break;
		default:
	}
}

function Paint (Canvas C, float X, float Y)
{
	C.DrawColor = BackgroundColor;
	DrawStretchedTexture(C,0.00,0.00,WinWidth,WinHeight,Texture'BackgroundTexture');
}
function Close (bool ByParent)
{
	Class'MapVoteNavBar'.Default.bShowWelcomeWindow=False;
	Super.Close(ByParent);
}

defaultproperties
{
	bShowWelcomeWindow=True
}
