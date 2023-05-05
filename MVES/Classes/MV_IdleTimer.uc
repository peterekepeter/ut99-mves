class MV_IdleTimer extends Info;

const EMPTY = "[MVE] IdleTimer: server has been empty for ";

var MapVote MapVote;
var int IdleMinutes;
var bool bIsIdle;

function Initialize(MapVote MapVote)
{
	Self.MapVote = MapVote;
	SetTimer(60, True);
	bIsIdle = False;
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
		bIsIdle = False;
	}
	else 
	{
		IdleMinutes += 1;

		LogIdleMessage(IdleMinutes);
	}

	if (!bIsIdle && MapVote.ServerIdleAfterMinutes != 0 && IdleMinutes >= MapVote.ServerIdleAfterMinutes)
	{   
		bIsIdle = True;
		if (MapVote.bSwitchToDefaultMapOnIdle)
		{
			MapVote.SwitchToDefaultMap();
		}
		else if (MapVote.bSwitchToRandomMapOnIdle) 
		{
			MapVote.SwitchToRandomMap();
		}
	}
}


function LogIdleMessage(int m)
{
	if (m <= 15 && m % 5 == 0)  
	{
		Log(EMPTY$m$" minutes");
	}
	else if (m <= 60 && m % 15 == 0)
	{
		Log(EMPTY$m$" minutes");
	}
	else if (m <= 60 * 12 && m % 60 == 0)
	{
		Log(EMPTY$(m / 60)$" hours");
	}
	else if (m <= 60 * 24 && m % 120 == 0)
	{
		Log(EMPTY$(m / 60)$" hours");
	}
	else if (m % (24&60) == 0)
	{
		Log(EMPTY$(m / 60 / 24)$" days");
	}
}