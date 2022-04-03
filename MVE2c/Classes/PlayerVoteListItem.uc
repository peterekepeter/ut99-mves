//================================================================================
// PlayerVoteListItem.
//================================================================================
class PlayerVoteListItem extends UWindowListBoxItem;

var string PlayerName;
var bool bHasVoted;

function int Compare (UWindowList t, UWindowList B)
{
	if ( Caps(PlayerVoteListItem(t).PlayerName) < Caps(PlayerVoteListItem(B).PlayerName) )
	{
		return -1;
	}
	return 1;
}

defaultproperties
{
      PlayerName=""
      bHasVoted=False
}
