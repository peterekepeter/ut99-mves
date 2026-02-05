class UMenuGameModeVoteList extends UWindowListBoxItem;

var int listNum;
var string GameModeName;

function int Compare (UWindowList A, UWindowList B)
{
	if ( UMenuGameModeVoteList(A).GameModeName < UMenuGameModeVoteList(B).GameModeName )
	{
		return -1;
	}
	return 1;
}
