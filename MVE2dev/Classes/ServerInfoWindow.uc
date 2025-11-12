//================================================================================
// ServerInfoWindow.
//================================================================================
class ServerInfoWindow extends UWindowPageWindow;

var UWindowVSplitter VSplitter;
var ServerInfoLink Link;
var UBrowserUpdateServerTextArea TextArea;
var Class<ServerInfoLink> LinkClass;
var Class<UBrowserUpdateServerTextArea> TextAreaClass;
var bool bHadInitialQuery;
var int tries;
var int NumTries;
var string WebServer;
var string FilePath;
var int Port;
var string ServerInfoURL;
var string MapInfoURL;
var string version;
var bool bShownInitial;
var MapVoteNavBar NavBar;

function Created ()
{
	Super.Created();
	version = Left(string(Self.Class),InStr(string(Self.Class),"."));
	SetSize(ParentWindow.WinWidth,ParentWindow.WinHeight);
	VSplitter = UWindowVSplitter(CreateWindow(Class'UWindowVSplitter',0.00,0.00,WinWidth,WinHeight));
	TextArea = UBrowserUpdateServerTextArea(CreateControl(TextAreaClass,0,0,WinWidth,WinHeight,Self));
	VSplitter.TopClientWindow = TextArea;
	VSplitter.bSizable = False;
	VSplitter.bBottomGrow = False;
	VSplitter.SplitPos = ParentWindow.WinHeight - 45;
	NavBar = MapVoteNavBar(VSplitter.CreateWindow(Class'MapVoteNavBar',0.00,0.00,WinWidth,WinHeight,OwnerWindow));
	VSplitter.BottomClientWindow = NavBar;
	SetAcceptsFocus();
}

function ShowWindow()
{
	Super.ShowWindow();
	ShowInitialPage();
}

function ShowInitialPage()
{
	if (bShownInitial) return; // don't change user content
	bShownInitial = True;

	if (ServerInfoURL != "")
	{
		ShowServerInfoPage(); // prefer showing server
	} 
	else 
	{
		ShowAboutPage();
	}
}

function ShowServerInfoPage()
{
	ShowWebPage(ServerInfoURL);
}

function ShowMapInfoPage() 
{
	local string CurrentMapName;
	local int pos;

	CurrentMapName = GetPlayerOwner().GetURLMap();
	pos = InStr(CurrentMapName,".");
	if ( pos > 0 )
	{
		CurrentMapName = Left(CurrentMapName,pos);
	}
	ShowWebPage(MapInfoURL $ CurrentMapName $ ".htm");
}

function ShowAboutPage()
{
	local string Core, Dev, Dev2, Support;
	local string SupportLink;
	
	SupportLink = "http://ut99.org/viewtopic.php?p=140965";
	Core = "<html><body><center><br><br><h1><font color=\"FFFF00\">Map Vote Extended</font></h1><br><br><b>Core developement: BDB (Bruce Bickar)<br><br>";
	Dev = "Enhancements by: (Deepu)<br><br>";
	Dev2 = "Improvements by: (21)<br><br>";
	Support = "Support: <a href=\""$SupportLink$"\">UT99 Forum</a></b></center></body></html>";

	SetMOTD(Core$Dev$Dev2$Support);
}

function ShowTipsPage()
{
	local string Line1, Line2, Line3, Line4, Line5, Line6, Line7, Line8, Line9;

	Line1 = "<html><body><center><br><br><h1><font color=\"#0000FF\">Map Vote Tips</font></h1><br><br></center>";
	Line2 = "<p><b><u>Tips</u></b></p><p>1. Click the <b>'Config'</b> tab to set background, boxes, boxes text, titles color & bind option.</p>";
	Line3 = "<p>2. Say !v or !vote to bring up Map Vote window at anytime.</p>";
	Line4 = "<p>3. To send messages to other players while the Map Vote window is open just Click the text box at the bottom of the main window, type your text message and press the Enter key.</p>";
	Line5 = "<p>4. You can place a vote for a map by double clicking the name.</p>";
	Line6 = "<p>5. You can call a kick vote by clicking on name of players and then click on kick button.</p>";
	Line7 = "<p>6. When selecting a map the screenshot is loaded automatically, this loading process causes a short delay in the processing of mouse movement. If this short delay is disruptive you can click the check box under the screen-shot to disable loading.</p>";
	Line8 = "<p>7. If you click the name of a map in the voting status section of the window (at the bottom) it will automatically select that same map in the map list.";
	Line9 = " This makes it easy to counter vote when time is running out and a map that you dislike is winning.</p>";
	//Line10="<p>8. If <b>'Map Info'</b> has been configured by your server admin then you can select a map name in the list, then click the <b>'Info'</b> button. This will switch to the <b>'Info'</b>";
	//Line11=" tab and display information about the selected map (if it is available).</p>";

	SetMOTD(Line1$Line2$Line3$Line4$Line5$Line6$Line7$Line8$Line9);
}

function ShowWebPage (string p_URLString)
{
	local int P1,P2;

	if (InStr(p_URLString, "http://") == 0)
	{
		p_URLString = Mid(p_URLString,7);
	}

	P1 = InStr(p_URLString,"/");
	if ( P1 <= 0 )
	{
		FailWith(0, "Invalid URL: "$p_URLString);
		return;
	}
	WebServer = Left(p_URLString,P1);
	FilePath = Mid(p_URLString,P1);
	P2 = InStr(WebServer,":");
	if ( P2 <= 0 ) 
	{
		Port = 80;
	} 
	else 
	{
		Port = int(Mid(WebServer,P2 + 1));
		WebServer = Left(WebServer,P2);
		if ( Port < 2 )
		{
			FailWith(0, "Invalid web server port: "$Port);
			return;
		}
	}
	// execute
	StartHttpRequest();
}

function StartHttpRequest() 
{
	bHadInitialQuery = True;
	if ( Link != None )
	{
		Link.UpdateWindow = None;
		Link.Destroy();
	}
	Link = GetEntryLevel().Spawn(LinkClass);
	Link.UpdateWindow = Self;
	Link.BrowseCurrentURI(WebServer, FilePath, Port);
}

function BeforePaint (Canvas C, float X, float Y)
{
	local UBrowserMainWindow W;

	Super.BeforePaint(C,X,Y);
	TextArea.SetSize(WinWidth,WinHeight);
}

function SetMOTD (string MOTD)
{
	TextArea.SetHTML(MOTD);
}

function Failure ()
{
	Link.UpdateWindow = None;
	Link.Destroy();
	Link = None;
	tries ++ ;
	if ( tries < NumTries )
	{
		StartHttpRequest();
		return;
	}
	else 
	{
		Log("Browse Failure");
	}
	tries = 0;
	
}

function FailWith(optional int code, optional string message) 
{
	local string codeMessage;
	if (message == "") 
	{
		if (code > 0) 
		{
			codeMessage = string(code);
		}

		if (code == 404) 
		{
			message = "Not Found";
		}
		else if (code == 500) 
		{
			message = "Internal Server Error. Try again later.";
		}
		else 
		{
			message = "Information Unavailable";
		}
	}
	else 
	{
		if (code > 0) 
		{
			codeMessage = string(code);
		}

		if (code == 404) 
		{
			codeMessage = codeMessage$" Not Found";
		}
		else if (400 <= code && code < 500)
		{
			codeMessage = codeMessage$" Bad Request";
		}
		else if (500 <= code)
		{
			codeMessage = codeMessage$" Server Error";
		}
	}
	SetMOTD(
		"<html><body bgcolor=#000000><br><br><br><center><h1>Error "$
		codeMessage
		$"</h1><br><b>"$
		message
		$"</b><br><br>Client version: <b>"$
		version
		$"</b></center></body></html>");
}

function Success ()
{
	Link.UpdateWindow = None;
	Link.Destroy();
	Link = None;
	tries = 0;
}

simulated function SetInfoServerAddress (string p_ServerInfoURL, string p_MapInfoURL)
{
	ServerInfoURL = p_ServerInfoURL;
	MapInfoURL = p_MapInfoURL;
}

defaultproperties
{
	LinkClass=Class'ServerInfoLink'
	TextAreaClass=Class'UBrowser.UBrowserUpdateServerTextArea'
	NumTries=3
}
