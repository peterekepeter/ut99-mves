class MV_PlayerDetector expands Info;

var MapVote MapVote;

function Initialize(MapVote mv){
    MapVote = mv;
	SetTimer(4.87, True);
}

function Timer()
{
	local pawn P;

	For ( P=Level.PawnList ; P!=none ; P=P.nextPawn )
	{
		DetectNewPlayer(P);
	}
}

function DetectNewPlayer(Pawn Pawn)
{
	// called by GameInfo.RestartPlayer()
	local PlayerPawn P;
	local MVPlayerWatcher watcher;
	P = PlayerPawn(Pawn);

	if (P != none) {
		if (P.PlayerReplicationInfo != none)
		{
			watcher = MapVote.GetWatcherFor(P);
			if (watcher == none) {
				MapVote.PlayerJoined(P);
			}
		} 

	}
}