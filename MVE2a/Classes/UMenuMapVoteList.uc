//================================================================================
// UMenuMapVoteList.
//================================================================================

class UMenuMapVoteList extends UWindowListBoxItem;

var string MapName;
var int CGNum;

function int Compare (UWindowList t, UWindowList B)
{
  if ( Caps(UMenuMapVoteList(t).MapName) < Caps(UMenuMapVoteList(B).MapName) )
  {
    return -1;
  }
  return 1;
}

