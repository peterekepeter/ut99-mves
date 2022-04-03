//================================================================================
// DummyListBox.
//================================================================================
class DummyListBox extends UWindowListBox;

function Paint (Canvas C, float MouseX, float MouseY)
{
	if ( Items.Next != None )
	{
		C.DrawColor.R=255;
		C.DrawColor.G=255;
		C.DrawColor.B=255;
	} else {
		C.DrawColor.R=100;
		C.DrawColor.G=100;
		C.DrawColor.B=100;
	}
	C.DrawColor.R=100;
	C.DrawColor.G=100;
	C.DrawColor.B=100;
	DrawStretchedTexture(C,0.00,0.00,WinWidth,WinHeight,Texture'ListsBoxBackground');
	Super.Paint(C,MouseX,MouseY);
}

defaultproperties
{
      ItemHeight=12.000000
      ListClass=Class'UMenuGameModeVoteList'
}
