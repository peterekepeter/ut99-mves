//================================================================================
// ServerInfoLink.
//================================================================================

class ServerInfoLink extends UBrowserHTTPClient;

var config int UpdateServerTimeout;
var ServerInfoWindow UpdateWindow;

function BrowseCurrentURI (string ServerAddress, string URI, int ServerPort)
{
  Log("browsing " $ ServerAddress $ URI $ ":" $ string(ServerPort));
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
  if ( ErrorCode == 404 )
  {
    Log("404 Error");
    UpdateWindow.SetMOTD("<html><body bgcolor=#000000><br><br><br><center><b>Information or Server Unavailable</b></center></body></html>");
  } else {
    Failure();
  }
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
