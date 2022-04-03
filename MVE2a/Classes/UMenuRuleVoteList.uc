//================================================================================
// UMenuRuleVoteList.
//================================================================================

class UMenuRuleVoteList extends UWindowListBoxItem;

var string MapName;
var int listNum;

function int Compare (UWindowList t, UWindowList B)
{
  if ( Caps(UMenuGameModeVoteList(t).MapName) < Caps(UMenuGameModeVoteList(B).MapName) )
  {
    return -1;
  }
  return 1;
}

