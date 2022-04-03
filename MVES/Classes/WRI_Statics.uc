//=============================================================================
// WRI_Statics.
//=============================================================================
class WRI_Statics expands Object;

static function bool OpenWindow( Info WRI)
{
	if ( WRI.IsA('WRI') )
		return WRI(WRI).OpenWindow();
}

static function CloseWindow( Info WRI)
{
	if ( WRI.IsA('WRI') )
		WRI(WRI).CloseWindow();
}

static function AddNewPlayer( Info MapVoteWRI, string NewPlayerName, bool bHasVoted)
{
	if ( MapVoteWRI.IsA('MapVoteWRI') )
		MapVoteWRI(MapVoteWRI).AddNewPlayer( NewPlayerName, bHasVoted);
}

static function RemovePlayerName( Info MapVoteWRI, string OldPlayerName)
{
	if ( MapVoteWRI.IsA('MapVoteWRI') )
		MapVoteWRI(MapVoteWRI).RemovePlayerName( OldPlayerName);
}

static function UpdatePlayerVoted( Info MapVoteWRI, string PlayerID)
{
	if ( MapVoteWRI.IsA('MapVoteWRI') )
		MapVoteWRI(MapVoteWRI).UpdatePlayerVoted( PlayerID);
}

static function UpdateMapVoteResults( Info MapVoteWRI, string Text, int i)
{
	if ( MapVoteWRI.IsA('MapVoteWRI') )
		MapVoteWRI(MapVoteWRI).UpdateMapVoteResults( Text, i);
}

static function UpdateKickVoteResults( Info MapVoteWRI, string Text, int i)
{
	if ( MapVoteWRI.IsA('MapVoteWRI') )
		MapVoteWRI(MapVoteWRI).UpdateKickVoteResults( Text, i);
}

static function SendReportText( Info MapVoteWRI, string p_ReportText)
{
	if ( MapVoteWRI.IsA('MapVoteWRI') )
		MapVoteWRI(MapVoteWRI).SendReportText( p_ReportText);
}