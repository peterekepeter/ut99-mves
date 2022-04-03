//================================================================================
// ServerInfoWindow.
//================================================================================
class ServerInfoWindow extends UWindowPageWindow;

var UWindowVSplitter VSplitter;
var ServerInfoLink Link;
var UBrowserUpdateServerTextArea TextArea;
var localized string QueryText;
var localized string FailureText;
var Class<ServerInfoLink> LinkClass;
var Class<UBrowserUpdateServerTextArea> TextAreaClass;
var bool bGotMOTD;
var string StatusBarText;
var bool bHadInitialQuery;
var int tries;
var int NumTries;
var string WebServer;
var string FilePath;
var int Port;
var string ServerInfoURL;
var string MapInfoURL;
var string version;

function Created ()
{
	local string Core;
	local string Dev;

	Core="<html><body><center><br><br><h1><font color=\"FFFF00\">Map Vote Extended 2a</font></h1><br><br><b>Core developement: BDB (Bruce Bickar)<br><br>";
	Dev="Enhancements by: (Deepu)<br><br>Support: <a href=\"http://forum.ultimateut.tk\">Ultimate UT Forum</a></b></center></body></html>";

	Super.Created();
	version=Left(string(self.Class),InStr(string(self.Class),"."));
	SetSize(ParentWindow.WinWidth,ParentWindow.WinHeight);
	VSplitter=UWindowVSplitter(CreateWindow(Class'UWindowVSplitter',0.00,0.00,WinWidth,WinHeight));
	TextArea=UBrowserUpdateServerTextArea(CreateControl(TextAreaClass,0.00,0.00,WinWidth,WinHeight,self));
	TextArea.SetHTML(Core$Dev);
	VSplitter.TopClientWindow=TextArea;
	VSplitter.bSizable=False;
	VSplitter.bBottomGrow=False;
	VSplitter.SplitPos=ParentWindow.WinHeight - 45;
	VSplitter.BottomClientWindow=VSplitter.CreateWindow(Class'MapVoteNavBar',0.00,0.00,WinWidth,WinHeight,OwnerWindow);
	SetAcceptsFocus();
}

function BrowseWebPage (string p_URLString)
{
	local int P1;
	local int P2;

	P1=InStr(p_URLString,"/");
	if ( P1 <= 0 )
	{
		Log("Invalid URL");
		return;
	}
	WebServer=Left(p_URLString,P1);
	FilePath=Mid(p_URLString,P1);
	P2=InStr(WebServer,":");
	if ( P2 <= 0 )
	{
		Port=80;
	} else {
		if ( int(Mid(WebServer,P2 + 1)) < 2 )
		{
			Log("Invalid web server port");
			return;
		}
		WebServer=Left(WebServer,P2);
		Port=int(Mid(WebServer,P2 + 1));
	}
	Log("WebServer=" $ WebServer);
	Log("FilePath=" $ FilePath);
	Log("Port=" $ string(Port));
	Query();
}

function Query ()
{
	Log("Query()...");
	bHadInitialQuery=True;
	StatusBarText=QueryText;
	if ( Link != None )
	{
		Link.UpdateWindow=None;
		Link.Destroy();
	}
	Link=GetEntryLevel().Spawn(LinkClass);
	Link.UpdateWindow=self;
	Link.BrowseCurrentURI(WebServer,FilePath,Port);
	bGotMOTD=False;
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
	Log("Browse Failure");
	Link.UpdateWindow=None;
	Link.Destroy();
	Link=None;
	tries++;
	if ( tries < NumTries )
	{
		Query();
		return;
	}
	StatusBarText=FailureText;
	tries=0;
	SetMOTD("<html><body bgcolor=#000000><br><br><br><center><b>Information Unavailable</b></center></body></html>");
}

function Success ()
{
	StatusBarText="";
	Link.UpdateWindow=None;
	Link.Destroy();
	Link=None;
	tries=0;
}

simulated function SetInfoServerAddress (string p_ServerInfoURL, string p_MapInfoURL)
{
	ServerInfoURL=p_ServerInfoURL;
	MapInfoURL=p_MapInfoURL;
}

defaultproperties
{
      VSplitter=None
      Link=None
      TextArea=None
      QueryText="Querying Server..."
      FailureText="The server did not respond."
      LinkClass=Class'ServerInfoLink'
      TextAreaClass=Class'UBrowser.UBrowserUpdateServerTextArea'
      bGotMOTD=False
      StatusBarText=""
      bHadInitialQuery=False
      tries=0
      NumTries=3
      WebServer=""
      FilePath=""
      Port=0
      ServerInfoURL=""
      MapInfoURL=""
      version=""
}
