//================================================================================
// HTTPMapListReceiver.
//================================================================================
class HTTPMapListReceiver extends UBrowserHTTPClient;

var int UpdateServerTimeout;
var MapListCache C;
var bool bDebugMode;

function Spawned ()
{
	C = MapListCache(Owner);
}

function Destroyed ()
{
	C.Link = None;
	Super.Destroyed();
}

function BrowseCurrentURI (string ServerAddress, string URI, int ServerPort)
{
	dlog("##### " $ string(Name) $ " browsing: " $ ServerAddress $ URI $ ":" $ string(ServerPort));
	Browse(ServerAddress,URI,ServerPort,UpdateServerTimeout);
}

function Failure (string Reason)
{
	dlog("##### " $ string(Name) $ ": ERROR" @ Reason);
	C.HTTPStateReset();
}

function Success ()
{
	dlog("##### " $ string(Name) $ ": SUCCESS");
	Destroy();
}

function HTTPError (int ErrorCode)
{
	if ( ErrorCode == -1 )
	{
		Failure("HTTPError TimeOut");
	} else {
		Failure(string(ErrorCode) @ "HTTPError");
	}
}

function HTTPReceivedData (string Data)
{
	local int pos;
	local string temp;
	local string rs;
	local int rslen;
	local string Size;

	rs = Chr(13);
	rslen = Len(rs);
	pos = InStr(Data,"[START]" $ rs);

	if ( (pos == -1) || (InStr(Data,"[END]" $ rs) == -1) && (InStr(Data,"[NEXT]" $ rs) == -1) )
	{
		Failure("MapList start position not found!");
		return;
	}

	Data = Mid(Data,pos + 7 + rslen);
	pos = InStr(Data,rs);
	//JL00E0:
	if ( pos != -1 )
	{
		temp = Left(Data,pos);
		if (  !C.LinkerAddValue(temp) )
		{
			Destroy();
			return;
		}
		else
		{
			if ( temp ~= "[Next]" )
			{
				Destroy();
				return;
			}
			else
			{
				if ( temp ~= "[END]" )
				{
					Success();
					return;
				}
			}
		}
		Data = Mid(Data,pos + rslen);
		pos = InStr(Data,rs);
		//goto JL00E0;
	}
	//dlog("butugiri");
	Destroy();
}

static final function ReplaceText (out string Text, string Replace, string With)
{
	local int i;
	local string Input;

	Input = Text;
	Replace = Caps(Replace);
	Text = "";
	i = InStr(Caps(Input),Replace);
	//JL0034:
	if ( i != -1 )
	{
		Text = Text $ Left(Input,i) $ With;
		Input = Mid(Input,i + Len(Replace));
		i = InStr(Caps(Input),Replace);
		//goto JL0034;
	}
	Text = Text $ Input;
}

final function dlog (string S)
{
	if (  !bDebugMode )
		return;
	Log(S,Class.Name);
}

defaultproperties
{
      UpdateServerTimeout=5
      C=None
      bDebugMode=False
}
