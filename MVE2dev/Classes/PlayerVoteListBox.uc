//================================================================================
// PlayerVoteListBox.
//================================================================================
class PlayerVoteListBox extends MVBaseListBox;

var bool bDisabled;

var Color BXTC;
var Color BXC;

function Paint (Canvas C, float MouseX, float MouseY)
{
	C.DrawColor = BXC;
	DrawStretchedTexture(C,0.00,0.00,WinWidth,WinHeight,Texture'ListsBoxBackground');
	Super.Paint(C,MouseX,MouseY);
}

function Created()
{
	local MapVoteClientConfig config;
	Super.Created();
	config = class'MapVoteClientConfig'.static.GetInstance();
	BXTC = config.GetColorOfBoxesTextColor();
	BXC = config.BoxesColor;
}

function DrawItem (Canvas C, UWindowList Item, float X, float Y, float W, float H)
{
	if ( bDisabled )
	{
		PlayerVoteListItem(Item).bSelected=False;
	}
	if ( PlayerVoteListItem(Item).bSelected )
	{
		C.DrawColor.R=0;
		C.DrawColor.G=0;
		C.DrawColor.B=128;
		DrawStretchedTexture(C,X,Y,W,H - 1,Texture'ListsBoxBackground');
		C.DrawColor.R=255;
		C.DrawColor.G=255;
		C.DrawColor.B=255;
	} else {
		if ( PlayerVoteListItem(Item).bHasVoted )
		{
			C.DrawColor.R=32;
			C.DrawColor.G=255;
			C.DrawColor.B=32;
		} else {
		C.DrawColor = BXC;
		}
		DrawStretchedTexture(C,X,Y,W,H - 1,Texture'ListsBoxBackground');
		if ( Left(PlayerVoteListItem(Item).PlayerName,1) == "9" )
		{
			C.DrawColor.R=75;
			C.DrawColor.G=75;
			C.DrawColor.B=75;
		} else {
			C.DrawColor = BXTC;
		}
	}
	C.Font=Root.Fonts[0];
	ClipText(C,X + 2,Y,Left(Mid(PlayerVoteListItem(Item).PlayerName,1),3) $ " - " $ Mid(PlayerVoteListItem(Item).PlayerName,4));
}

function KeyDown (int Key, float X, float Y)
{
	local int i;
	local UWindowListBoxItem ItemPointer;
	local PlayerPawn P;

	Super.KeyDown(Key, X, Y);

	if ( bDisabled )
	{
		return;
	}
	P=GetPlayerOwner();
	if(Key == P.EInputKey.IK_MouseWheelDown || Key == P.EInputKey.IK_Down)
	{
		if ( (SelectedItem != None) && (SelectedItem.Next != None) )
		{
			SetSelectedItem(UWindowListBoxItem(SelectedItem.Next));
			MakeSelectedVisible();
		}
	}
	if(Key == P.EInputKey.IK_MouseWheelUp || Key == P.EInputKey.IK_Up)
	{
		if ( (SelectedItem != None) && (SelectedItem.Prev != None) && (SelectedItem.Sentinel != SelectedItem.Prev) )
		{
			SetSelectedItem(UWindowListBoxItem(SelectedItem.Prev));
			MakeSelectedVisible();
		}
	}
	if(Key == P.EInputKey.IK_PageDown)
	{
		if ( SelectedItem != None )
		{
			ItemPointer=SelectedItem;
			i=0;
JL0149:
			if ( i < 7 )
			{
				if ( ItemPointer.Next == None )
				{
					return;
				}
				ItemPointer=UWindowListBoxItem(ItemPointer.Next);
				i++;
				goto JL0149;
			}
			SetSelectedItem(ItemPointer);
			MakeSelectedVisible();
		}
	}
	if(Key == P.EInputKey.IK_PageUp)
	{
		if ( SelectedItem != None )
		{
			ItemPointer=SelectedItem;
			i=0;
JL01D2:
			if ( i < 7 )
			{
				if ( (ItemPointer.Prev == None) || (ItemPointer.Prev == SelectedItem.Sentinel) )
				{
					return;
				}
				ItemPointer=UWindowListBoxItem(ItemPointer.Prev);
				i++;
				goto JL01D2;
			}
			SetSelectedItem(ItemPointer);
			MakeSelectedVisible();
		}
	}
	ParentWindow.KeyDown(Key,X,Y);
}

function SelectPlayer (string PlayerName)
{
	local PlayerVoteListItem PlayerItem;
	local string PlayerID;

	if ( bDisabled )
	{
		return;
	}
	PlayerID=Left(PlayerName,3);
	PlayerItem=PlayerVoteListItem(Items);
JL002A:
	if ( PlayerItem != None )
	{
		if ( PlayerID == Right(Left(PlayerItem.PlayerName,4),3) )
		{
			SetSelectedItem(PlayerItem);
			MakeSelectedVisible();
		} else {
			PlayerItem=PlayerVoteListItem(PlayerItem.Next);
			goto JL002A;
		}
	}
}

function DoubleClickItem (UWindowListBoxItem i)
{
	if ( bDisabled )
	{
		return;
	}
	UWindowDialogClientWindow(ParentWindow).Notify(self,11);
}

function EditCopy()
{
	local PlayerPawn P;

	P = GetPlayerOwner();

	P.CopyToClipboard(PlayerVoteListItem(SelectedItem).PlayerName);
}

defaultproperties
{
	BXTC=(R=0,G=0,B=0,A=0)
	ItemHeight=12.000000
	ListClass=Class'PlayerVoteListItem'
}
