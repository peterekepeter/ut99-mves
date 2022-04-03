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
	ReportButton1=UWindowSmallButton(CreateControl(Class'UWindowSmallButton',120.00,0,139.00,10.00));
	ReportButton1.Text="Report 1: Map Vote Ranking";
	ReportButton1.DownSound=Sound'Click';
	ReportButton1.bDisabled=True;
	ReportButton2=UWindowSmallButton(CreateControl(Class'UWindowSmallButton',260.00,0,139.00,10.00));
	ReportButton2.Text="Report 2: Map Vote Sequence";
	ReportButton2.DownSound=Sound'Click';
	ReportButton2.bDisabled=True;
	AboutButton=UWindowSmallButton(CreateControl(Class'UWindowSmallButton',400.00,0,39.00,10.00));
	AboutButton.Text="About";
	AboutButton.DownSound=Sound'Click';
	TipsButton=UWindowSmallButton(CreateControl(Class'UWindowSmallButton',440.00,0,69.00,10.00));
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
}

function Notify (UWindowDialogControl C, byte E)
{
	local string CurrentMapName;
	local int pos;
	local ServerInfoWindow MainWindow;
	local string Core;
	local string Dev;
	local string Line1, Line2, Line3, Line4, Line5, Line6, Line7, Line8, Line9;

	Core="<html><body><center><br><br><h1><font color=\"FFFF00\">Map Vote Extended 2a</font></h1><br><br><b>Core developement: BDB (Bruce Bickar)<br><br>";
	Dev="Enhancements by: (Deepu)<br><br>Support: <a href=\"http://forum.ultimateut.tk\">Ultimate UT Forum</a></b></center></body></html>";

	Line1="<html><body><center><br><br><h1><font color=\"#0000FF\">Map Vote Tips</font></h1><br><br></center>";
	Line2="<p><b><u>Tips</u></b></p><p>1. Click the <b>'Config'</b> tab to set background, boxes, boxes text, titles color & bind option.</p>";
	Line3="<p>2. Say !v or !vote to bring up Map Vote window at anytime.</p>";
	Line4="<p>3. To send messages to other players while the Map Vote window is open just Click the text box at the bottom of the main window, type your text message and press the Enter key.</p>";
	Line5="<p>4. You can place a vote for a map by double clicking the name.</p>";
	Line6="<p>5. You can call a kick vote by clicking on name of players and then click on kick button.</p>";
	Line7="<p>6. When selecting a map the screenshot is loaded automatically, this loading process causes a short delay in the processing of mouse movement. If this short delay is disruptive you can click the check box under the screen-shot to disable loading.</p>";
	Line8="<p>7. If you click the name of a map in the voting status section of the window (at the bottom) it will automatically select that same map in the map list.";
	Line9=" This makes it easy to counter vote when time is running out and a map that you dislike is winning.</p>";
	//Line10="<p>8. If <b>'Map Info'</b> has been configured by your server admin then you can select a map name in the list, then click the <b>'Info'</b> button. This will switch to the <b>'Info'</b>";
	//Line11=" tab and display information about the selected map (if it is available).</p>";

	MainWindow=ServerInfoWindow(ParentWindow.ParentWindow);
	Super.Notify(C,E);
	switch (E)
	{
		case 2:
		switch (C)
		{
			case ServerInfoButton:
			MainWindow.BrowseWebPage(MainWindow.ServerInfoURL);
			break;
			case MapInfoButton:
			CurrentMapName=GetPlayerOwner().GetURLMap();
			pos=InStr(CurrentMapName,".");
			if ( pos > 0 )
			{
				CurrentMapName=Left(CurrentMapName,pos);
			}
			if ( CurrentMapName != "" )
			{
				MainWindow.BrowseWebPage(MainWindow.MapInfoURL $ CurrentMapName $ ".htm");
			}
			break;
			case ReportButton1:
			GetPlayerOwner().ConsoleCommand("MUTATE BDBMAPVOTE REPORT PC");
			break;
			case ReportButton2:
			GetPlayerOwner().ConsoleCommand("MUTATE BDBMAPVOTE REPORT SEQ");
			break;
			case TipsButton:
			MainWindow.TextArea.SetHTML(Line1$Line2$Line3$Line4$Line5$Line6$Line7$Line8$Line9);
			break;
			case AboutButton:
			MainWindow.TextArea.SetHTML(Core$Dev);
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
	C.DrawColor = class'MapVoteClientConfig'.Default.BackgroundColor;
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
