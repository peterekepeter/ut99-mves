//================================================================================
// MapStatusListItem.
//================================================================================
class MapStatusListItem extends UWindowListBoxItem;

var int rank;
var string MapName;
var string GameModeName;
var string RuleName;
var int VoteCount;
var int CGNum;

function int Compare (UWindowList t, UWindowList B)
{
	if ( Caps(MapStatusListItem(t).MapName) < Caps(MapStatusListItem(B).MapName) )
	{
		return -1;
	}
	return 1;
}