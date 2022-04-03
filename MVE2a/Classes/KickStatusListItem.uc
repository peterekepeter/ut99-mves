//================================================================================
// KickStatusListItem.
//================================================================================
class KickStatusListItem extends UWindowListBoxItem;

var string PlayerName;
var int VoteCount;

function int Compare (UWindowList t, UWindowList B)
{
	if ( Caps(KickStatusListItem(t).PlayerName) < Caps(KickStatusListItem(B).PlayerName) )
	{
		return -1;
	}
	return 1;
}

defaultproperties
{
      PlayerName=""
      VoteCount=0
}
