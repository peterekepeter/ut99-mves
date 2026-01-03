//================================================================================
// KickStatusListBox.
//================================================================================
class KickStatusListBox extends MVBaseListBox;

function Created ()
{
	Super.Created();
	VertSB.Close();
	VertSB = UWindowVScrollbar(CreateWindow(Class'PlainVScrollBar',WinWidth - 12,0.0,12.0,WinHeight));
}

function Paint (Canvas C, float MouseX, float MouseY)
{
	C.DrawColor.R = 255;
	C.DrawColor.G = 255;
	C.DrawColor.B = 255;
	DrawStretchedTexture(C,0.0,0.0,WinWidth,1.0,Texture'ListsBoxBackground');
	DrawStretchedTexture(C,0.0,0.0,1.0,WinHeight - 1,Texture'ListsBoxBackground');
	DrawStretchedTexture(C,210.0,0.0,1.0,WinHeight - 1,Texture'ListsBoxBackground');
	DrawStretchedTexture(C,0.0,WinHeight - 1,WinWidth,1.0,Texture'ListsBoxBackground');
	Super.Paint(C,MouseX,MouseY);
}

function DrawItem (Canvas C, UWindowList Item, float X, float Y, float W, float H)
{
	if ( KickStatusListItem(Item).bSelected )
	{
		C.DrawColor.R = 0;
		C.DrawColor.G = 0;
		C.DrawColor.B = 128;
		DrawStretchedTexture(C,X,Y + 1,W,H - 2,Texture'ListsBoxBackground');
		C.DrawColor.R = 255;
		C.DrawColor.G = 255;
		C.DrawColor.B = 255;
		DrawStretchedTexture(C,X,Y + H - 1,W,1.0,Texture'ListsBoxBackground');
		DrawStretchedTexture(C,0.0,Y,1.0,H,Texture'ListsBoxBackground');
		DrawStretchedTexture(C,210.0,Y,1.0,H,Texture'ListsBoxBackground');
	} else {
		C.DrawColor.R = 255;
		C.DrawColor.G = 255;
		C.DrawColor.B = 255;
		DrawStretchedTexture(C,X,Y + H - 1,W,1.0,Texture'ListsBoxBackground');
	}
	C.Font = Root.Fonts[0];
	ClipText(C,X + 5,Y,Left(KickStatusListItem(Item).PlayerName,3) $ " - " $ Mid(KickStatusListItem(Item).PlayerName,3));
	ClipText(C,X + 215,Y,string(KickStatusListItem(Item).VoteCount));
}

function SelectPlayer (string PlayerName)
{
	local KickStatusListItem PlayerItem;

	PlayerItem=KickStatusListItem(Items);

	while ( PlayerItem != None )
	{
		if ( (PlayerName ~= PlayerItem.PlayerName) || (PlayerName ~= PlayerItem.PlayerName) )
		{
			SetSelectedItem(PlayerItem);
			MakeSelectedVisible();
			break;
		}
		PlayerItem=KickStatusListItem(PlayerItem.Next);
	}
}

function DoubleClickItem (UWindowListBoxItem i)
{
	UWindowDialogClientWindow(ParentWindow).Notify(self,11);
}

function EditCopy()
{
	local PlayerPawn P;

	P = GetPlayerOwner();

	P.CopyToClipboard(KickStatusListItem(SelectedItem).PlayerName);
}

defaultproperties
{
      ItemHeight=13.000000
      ListClass=Class'KickStatusListItem'
}
