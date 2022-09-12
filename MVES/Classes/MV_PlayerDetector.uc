class MV_PlayerDetector expands Info;

var MapVote MapVote;

function Initialize(MapVote mv)
{
	MapVote = mv;
	SetTimer(4.87, True);
}

function Timer()
{
	// safety net to detect players joined even when 
	// the Level.Game.CurrentID != CurrentID change detection fails
	// this is needed for mapvote to work properly for rejoining players on JailBreak
	DetectPlayers();
}

function DetectPlayers()
{
	local Pawn P;
	for ( P=Level.PawnList ; P!=None ; P=P.nextPawn )
	{
		DetectPlayer(P);
	}
}

function DetectPlayer(Pawn P)
{
	local PlayerPawn PP;
	if (!P.bIsPlayer)
	{
		return;
	}
	PP = PlayerPawn(P);
	if (ShouldJoinMapVote(PP))
	{
		MapVote.PlayerJoined(PP);
	}
}


function bool ShouldJoinMapVote(PlayerPawn PP)
{
	if (PP == None ||
		PP.PlayerReplicationInfo == None ||
		PP.PlayerReplicationInfo.PlayerName == "" ||
		MapVote.GetWatcherFor(PP) != None)
	{
		return False; 
	}
	return True;
}

defaultproperties
{
      MapVote=None
}
