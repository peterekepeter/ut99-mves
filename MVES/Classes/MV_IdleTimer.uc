class MV_IdleTimer extends Info;

var MapVote MapVote;
var int EmptyMinutes;
var bool bIsIdle;

function Initialize(MapVote MapVote, bool isIdle, int EmptyMinutes)
{
	local string time;
	Self.MapVote = MapVote;
	Self.EmptyMinutes = EmptyMinutes;
	Self.bIsIdle = isIdle;
	if (isIdle)
	{
		time = GetRelativeTime(EmptyMinutes);
		Log("[MVE] Currently idle, has been empty for at least "$time);
	}
	SetTimer(60, True);
}

function Timer()
{
	local Pawn P;
	local int count;

	count = 0;

	// TODO: idea improve watch and handle player count changes
	// so each class is notified of change rather than each class tracking
	for (P = Level.PawnList; P != None; P = P.NextPawn)
	{
		if (P.bIsPlayer && PlayerPawn(P) != None)
		{
			count += 1;
		}
	}

	if (count > 0)
	{
		EmptyMinutes = 0;   
		
		if (bIsIdle)
		{
			// state transition -> not idle
			Log("[MVE] Server not in idle mode any longer");
			bIsIdle = False;
			SaveIdleState();
		}
	}
	else 
	{
		EmptyMinutes += 1;
		LogIdleMessage(EmptyMinutes);
	}

	if (!bIsIdle && MapVote.ServerIdleAfterMinutes != 0 && EmptyMinutes >= MapVote.ServerIdleAfterMinutes)
	{   
		// state transition -> idle
		Log("[MVE] Server is switching to idle mode");
		bIsIdle = True; 
		SaveIdleState();
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
	local string time;
	time = GetIdleMessage(m);
	if (time == "")
	{
		// noop
	}
	else if (bIsIdle)
	{
		SaveIdleState();
		Log("[MVE] Server has been empty for "$time);
	}
	else 
	{
		SaveIdleState();
		Log("[MVE] Server is idle and has been empty for "$time);
	}
}

static function string GetIdleMessage(int m)
{
	local int modulo;
	local string message;

	modulo = 0;
	message = "";

	if (m <= 15)  
	{
		modulo = 5; // log every 5 minutes
	}
	else if (m <= 60)
	{
		modulo = 15; // log every 15 minutes
	}
	else if (m <= 60 * 12)
	{
		// less than 12 hours
		modulo = 60; // log every hour
	}
	else if (m <= 60 * 24)
	{
		// less or equal to 1 day
		modulo = 2 * 60; // log every second hour
	}
	else
	{
		modulo = 24 * 60; // otherlise log daily
	}

	// execute
	if (modulo > 0 && m % modulo == 0) 
	{
		message = GetRelativeTime(m);
	}

	return message;
}

static function string GetRelativeTime(int m)
{
	if (m <= 60)
	{
		return m$" minutes";
	}
	else if (m <= 60 * 24)
	{
		return (m / 60)$" hours";
	}
	else
	{
		return (m / 60 / 24)$" days";
	}
}

function SaveIdleState()
{
	MapVote.SaveIdleState(bIsIdle, EmptyMinutes);
}
