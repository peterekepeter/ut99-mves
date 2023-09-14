//================================================================================
// KeyBinderListItem.
//================================================================================
class KeyBinderListItem extends UWindowListBoxItem;

var string KeyName;
var string CommandString;

function int Compare (UWindowList t, UWindowList B)
{
	if ( Caps(KeyBinderListItem(t).KeyName) < Caps(KeyBinderListItem(B).KeyName) )
	{
		return -1;
	}
	return 1;
}

defaultproperties
{
      KeyName=""
      CommandString=""
}
