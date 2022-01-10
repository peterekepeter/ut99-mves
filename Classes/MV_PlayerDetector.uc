class MV_PlayerDetector expands Info;

var MapVote MapVote;

function Initialize(MapVote mv)
{
	MapVote = mv;
	SetTimer(4.87, True);
}

function Timer()
{
	local Pawn P;
	local PlayerPawn PP;

	for ( P=Level.PawnList ; P!=None ; P=P.nextPawn )
	{
		if (!P.bIsPlayer)
		{
			continue;
		}
		PP = PlayerPawn(P);
		if (ShouldJoinMapVote(PP))
		{
			MapVote.PlayerJoined(PP);
		}
	}
}


function bool ShouldJoinMapVote(PlayerPawn PP)
{
	if (PP == None ||
		PP.PlayerReplicationInfo == None ||
		PP.Player == None || 
		MapVote.GetWatcherFor(PP) != None)
	{
		return False; 
	}
	return True;
}