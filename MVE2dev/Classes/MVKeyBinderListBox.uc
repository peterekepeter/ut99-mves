//================================================================================
// MVKeyBinderListBox.
//================================================================================
class MVKeyBinderListBox extends UWindowListBox;

function Paint (Canvas C, float MouseX, float MouseY)
{
	C.DrawColor.R = 255;
	C.DrawColor.G = 255;
	C.DrawColor.B = 255;
	DrawStretchedTexture(C,0.00,0.00,WinWidth,1.00,Texture'ListsBoxBackground');
	DrawStretchedTexture(C,0.00,0.00,0.00,WinHeight - 1,Texture'ListsBoxBackground');
	Super.Paint(C,MouseX,MouseY);
}

function DrawItem (Canvas C, UWindowList Item, float X, float Y, float W, float H)
{
	if ( KeyBinderListItem(Item).bSelected )
	{
		C.DrawColor.R = 0;
		C.DrawColor.G = 0;
		C.DrawColor.B = 128;
		DrawStretchedTexture(C,X,Y + 1,W,H - 2,Texture'ListsBoxBackground');
		C.DrawColor.R = 255;
		C.DrawColor.G = 255;
		C.DrawColor.B = 255;
		DrawStretchedTexture(C,X,Y + H - 1,W,1.00,Texture'ListsBoxBackground');
		DrawStretchedTexture(C,95.00,Y,1.00,H,Texture'ListsBoxBackground');
		DrawStretchedTexture(C,0.00,Y,1.00,H,Texture'ListsBoxBackground');
		DrawStretchedTexture(C,W,Y,1.00,H,Texture'ListsBoxBackground');
	} 
	else 
	{
		C.DrawColor.R = 255;
		C.DrawColor.G = 255;
		C.DrawColor.B = 255;
		DrawStretchedTexture(C,X,Y + H - 1,W,1.00,Texture'ListsBoxBackground');
		DrawStretchedTexture(C,95.00,Y,1.00,H - 1,Texture'ListsBoxBackground');
		DrawStretchedTexture(C,0.00,Y,1.00,H,Texture'ListsBoxBackground');
		DrawStretchedTexture(C,W,Y,1.00,H,Texture'ListsBoxBackground');
	}
	C.Font = Root.Fonts[0];
	ClipText(C,X + 5,Y,KeyBinderListItem(Item).KeyName);
	ClipText(C,X + 100,Y,KeyBinderListItem(Item).CommandString);
}

defaultproperties
{
	ItemHeight=13.000000
	ListClass=Class'KeyBinderListItem'
}
