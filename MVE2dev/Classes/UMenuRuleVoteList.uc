class UMenuRuleVoteList extends UWindowListBoxItem;

var string RuleName;
var int listNum;

function int Compare (UWindowList A, UWindowList B)
{
	if ( Caps(UMenuRuleVoteList(A).RuleName) < Caps(UMenuRuleVoteList(B).RuleName) )
	{
		return -1;
	}
	return 1;
}
