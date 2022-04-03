//=============================================================================
// MV_NexgenUtil.
//=============================================================================
class MV_NexgenUtil expands Object;

static final function banPlayer( Info NexgenClient, Info RPCI, optional string ByPlayers)
{
	local string rights;
	rights = NexgenClient.GetPropertyText("rights");
	NexgenClient.SetPropertyText("rights", rights $ ",M,H,L");
	// we not use Nexgen...
	//RPCI.banPlayer( int(NexgenClient.GetPropertyText("PlayerNum")), 1, 1, "Kick voted out of the game"@ByPlayers);
	NexgenClient.SetPropertyText("rights", rights);
}

//Add this to Info
/*
function banPlayer(int playerNum, byte banPeriodType, int banPeriodArgs, string reason);
*/

defaultproperties
{
}
