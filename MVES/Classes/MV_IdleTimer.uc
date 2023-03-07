class MV_IdleTimer extends Info;

var MapVote MapVote;
var int IdleMinutes;
var bool DispatchedSwitchToDefaultMap;

function Initialize(MapVote MapVote)
{
	Self.MapVote = MapVote;
	SetTimer(60, True);
	DispatchedSwitchToDefaultMap = False;
}

function Timer()
{
	local Pawn P;
	local int count;


	count = 0;

	for (P = Level.PawnList; P != None; P = P.NextPawn)
	{
		if (P.bIsPlayer && PlayerPawn(P) != None)
		{
			count += 1;
		}
	}

	if (count > 0)
	{
		IdleMinutes = 0;   
	}
	else 
	{
		IdleMinutes += 1;
	}

	Log("IdleMinutes: "$IdleMinutes);

	if (!DispatchedSwitchToDefaultMap && IdleMinutes >= MapVote.DefaultMapSwitchAfterIdleMinutes)
	{   
		Log("SwitchToDefaultMap");
		DispatchedSwitchToDefaultMap = True;
		MapVote.SwitchToDefaultMap();
	}
}