//================================================================================
// MapListServer.
//================================================================================
class MapListServer expands WebApplication;

/* Usage:
[UWeb.WebServer]
Applications[0]="MapVote.MapListServer"
ApplicationPaths[0]="/maplist"
bEnabled=True

http://server.ip.address/maplist/servercode
*/

var MV_MapList MapList;

event Query(WebRequest Request, WebResponse Response)
{
	local string aStr;
	local int i;
	local MVPlayerWatcher W;

	aStr = Mid(Request.URI, 1);

	if ( MapList == none )
	{
		if ( !GetMapList() )
		{
			Error503(Response);
			return;
		}
	}
	if ( MapList.MapCount == 0 || MapList.Mutator.ServerCodeName == '' )
	{
		Error501(Response);
		return;
	}
	if ( !(Left(aStr, Len(string(MapList.Mutator.ServerCodeName)) ) ~= string(MapList.Mutator.ServerCodeName)) )
	{
		Error400(Response);
		return;
	}

	aStr = Response.Connection.IpAddrToString(Response.Connection.RemoteAddr);
	Log( "HTTP query from "$aStr, 'MapVote' ); //Safe to log?
	W = ValidPlayerWithIP( RemovePort(aStr) );
	if ( W == none )
	{
		Error401( Response);
		return;
	}

	//Implement overflow protection later


	aStr = Mid(Request.URI, 1 + Len(string(MapList.Mutator.ServerCodeName)) );
	if ( Left(aStr,5) == "&val=" )
		aStr = Mid( aStr, 5);

	//We can send up to 1kb, so the maplist will split it starting by the specified "$val=" property
	//Each query is done every 0.5 second (scaled down to server speed) until list is finished
	aStr = MapList.GetStringSection( aStr);
	Response.SendText( aStr, true ); 
	if ( InStr(aStr,chr(13)$"[END]") < InStr(aStr,chr(13)$"[NEXT]") )
	{
		W.TicksLeft = 1;
		W.bHTTPLoading = false;
	}
	else
	{
		W.TicksLeft++;
		W.bHTTPLoading = true;
	}
}


function bool GetMapList()
{
	ForEach Level.AllActors (class'MV_MapList', MapList)
		return true;
}

function CleanUp()
{
	MapList = none;
}

function Error503( WebResponse Response)
{
	Response.HTTPResponse("HTTP/1.1 503 Service Unavailable");
	Response.SendText("<TITLE>503 Service Unavailable</TITLE><H1>503 Service Unavailable</H1>The map list is currently unavailable to requests.");
}

function Error501( WebResponse Response)
{
	Response.HTTPResponse("HTTP/1.1 501 Not Implemented");
	Response.SendText("<TITLE>501 Not Implemented</TITLE><H1>501 Not Implemented</H1>The map list has not been setup.");
}

function Error400( WebResponse Response)
{
	Response.HTTPResponse("HTTP/1.1 400 Bad Request");
	Response.SendText("<TITLE>400 Bad Request</TITLE><H1>400 Bad Request</H1>The map list you requested is not the one currently in use on the server.");
}

function Error401( WebResponse Response)
{
	Response.HTTPResponse("HTTP/1.1 401 Unauthorized");
	Response.SendText("<TITLE>401 Unauthorized</TITLE><H1>401 Unauthorized</H1>You are not playing on the server.");
}

function string RemovePort( string IP)
{
	if ( InStr(IP, ":") > 0 )
		return Left(IP, InStr(IP, ":"));
	return IP;
}

function MVPlayerWatcher ValidPlayerWithIP( string IP)
{
	local MVPlayerWatcher W;
	
	For ( W=MapList.Mutator.WatcherList ; W!=none ; W=W.nextWatcher )
		if ( W.PlayerIP == IP )
			return W;
}

defaultproperties
{
      MapList=None
}
