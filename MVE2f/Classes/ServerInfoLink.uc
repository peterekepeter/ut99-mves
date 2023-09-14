//================================================================================
// ServerInfoLink.
//================================================================================

class ServerInfoLink extends UBrowserHTTPClient;

var config int UpdateServerTimeout;
var ServerInfoWindow UpdateWindow;

function BrowseCurrentURI (string ServerAddress, string URI, int ServerPort)
{
	Log("Browse " $ ServerAddress $ ":" $ ServerPort $ URI);
	Browse(ServerAddress,URI,ServerPort,UpdateServerTimeout);
}

function Failure ()
{
	UpdateWindow.Failure();
}

function Success ()
{
	UpdateWindow.Success();
}

function ProcessData (string Data)
{
	UpdateWindow.SetMOTD(Data);
}

function HTTPError (int ErrorCode)
{
	UpdateWindow.FailWith(ErrorCode);
}

function HTTPReceivedData (string Data)
{
	ProcessData(Data);
	Success();
}

defaultproperties
{
	UpdateServerTimeout=10
}
