//================================================================================
// PlainVScrollBar.
//================================================================================
class PlainVScrollBar extends UWindowVScrollbar;

function Paint (Canvas C, float X, float Y)
{
	C.DrawColor.R=255;
	C.DrawColor.G=255;
	C.DrawColor.B=255;
	DrawStretchedTexture(C,0.00,0.00,1.00,WinHeight,Texture'ListsBoxBackground');
	DrawStretchedTexture(C,WinWidth - 1,0.00,1.00,WinHeight,Texture'ListsBoxBackground');
	if (  !bDisabled )
	{
		DrawUpBevel(C,0.00,ThumbStart,12.00,ThumbHeight,Texture'ListsBoxBackground');
	}
}

defaultproperties
{
}
