//================================================================================
// MapStatusListBox.
//================================================================================
class MapStatusListBox extends UWindowListBox;

function Created ()
{
	Super.Created();
	VertSB.Close();
	VertSB=UWindowVScrollbar(CreateWindow(Class'PlainVScrollBar',WinWidth - 12,0.00,12.00,WinHeight));
}

function Paint (Canvas C, float MouseX, float MouseY)
{
	C.DrawColor.R=255;
	C.DrawColor.G=255;
	C.DrawColor.B=255;
	DrawStretchedTexture(C,0.00,0.00,WinWidth,1.00,Texture'ListsBoxBackground');
	DrawStretchedTexture(C,0.00,0.00,1.00,WinHeight - 1,Texture'ListsBoxBackground');
	DrawStretchedTexture(C,28.00,0.00,1.00,WinHeight - 1,Texture'ListsBoxBackground');
	DrawStretchedTexture(C,188.70,0.00,1.00,WinHeight - 1,Texture'ListsBoxBackground');
	DrawStretchedTexture(C,349.40,0.00,1.00,WinHeight - 1,Texture'ListsBoxBackground');
	DrawStretchedTexture(C,510.10,0.00,1.00,WinHeight - 1,Texture'ListsBoxBackground');
	DrawStretchedTexture(C,0.00,WinHeight - 1,WinWidth,1.00,Texture'ListsBoxBackground');
	Super.Paint(C,MouseX,MouseY);
}

function DrawItem (Canvas C, UWindowList Item, float X, float Y, float W, float H)
{
	if ( MapStatusListItem(Item).bSelected )
	{
		C.DrawColor.R=0;
		C.DrawColor.G=0;
		C.DrawColor.B=128;
		DrawStretchedTexture(C,X,Y + 1,W,H - 2,Texture'ListsBoxBackground');
		C.DrawColor.R=255;
		C.DrawColor.G=255;
		C.DrawColor.B=255;
		DrawStretchedTexture(C,X,Y + H - 1,W,1.00,Texture'ListsBoxBackground');
		DrawStretchedTexture(C,0.00,Y,1.00,H,Texture'ListsBoxBackground');
		DrawStretchedTexture(C,28.00,Y,1.00,H,Texture'ListsBoxBackground');
		DrawStretchedTexture(C,188.70,Y,1.00,H,Texture'ListsBoxBackground');
		DrawStretchedTexture(C,349.40,Y,1.00,H,Texture'ListsBoxBackground');
		DrawStretchedTexture(C,510.10,Y,1.00,H,Texture'ListsBoxBackground');
	} else {
		C.DrawColor.R=255;
		C.DrawColor.G=255;
		C.DrawColor.B=255;
		DrawStretchedTexture(C,X,Y + H - 1,W,1.00,Texture'ListsBoxBackground');
	}
	C.Font=Root.Fonts[0];
	ClipText(C,X + 5,Y,string(MapStatusListItem(Item).rank));
	ClipText(C,X + 33,Y,MapStatusListItem(Item).MapName);
	ClipText(C,X + 193.7,Y,MapStatusListItem(Item).GameModeName);
	ClipText(C,X + 354.4,Y,MapStatusListItem(Item).RuleName);
	ClipText(C,X + 515.1,Y,Left(string(MapStatusListItem(Item).VoteCount),3));
}

function SelectMap (string MapName)
{
	local MapStatusListItem MapItem;

	for ( MapItem=MapStatusListItem(Items); MapItem != None; MapItem=MapStatusListItem(MapItem.Next) )
	{
		if ( MapName ~= MapItem.MapName )
		{
			SetSelectedItem(MapItem);
			MakeSelectedVisible();
			break;
		}
	}
}

function DoubleClickItem (UWindowListBoxItem i)
{
	UWindowDialogClientWindow(ParentWindow).Notify(self,11);
}

defaultproperties
{
	ItemHeight=13.000000
	ListClass=Class'MapStatusListItem'
}