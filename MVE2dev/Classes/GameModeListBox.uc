//================================================================================
// GameModeListBox.
//================================================================================
class GameModeListBox extends MVBaseListBox;

var Color BXTC;
var Color BXC;

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
	C.DrawColor = BXC;
	DrawStretchedTexture(C,0.00,0.00,WinWidth,WinHeight,Texture'ListsBoxBackground');
	Super.Paint(C,MouseX,MouseY);
}

function Created()
{
	local MapVoteClientConfig Config;
	Super.Created();
	config = class'MapVoteClientConfig'.static.GetInstance();
	BXTC = Config.GetColorOfBoxesTextColor();
	BXC = Config.BoxesColor;
}

function DrawItem (Canvas C, UWindowList Item, float X, float Y, float W, float H)
{
	if ( UMenuGameModeVoteList(Item).bSelected )
	{
		C.DrawColor.R = 0;
		C.DrawColor.G = 0;
		C.DrawColor.B = 255;
		DrawStretchedTexture(C,X,Y,W,H - 1,Texture'ListsBoxBackground');
		C.DrawColor.R = 255;
		C.DrawColor.G = 255;
		C.DrawColor.B = 255;
	} 
	else 
	{
		C.DrawColor = BXC;
		DrawStretchedTexture(C,X,Y,W,H - 1,Texture'ListsBoxBackground');
		C.DrawColor = BXTC;
	}
	C.Font = Root.Fonts[0];

	ClipText(C,X + 2,Y, UMenuGameModeVoteList(Item).GameModeName);
}

function KeyDown (int Key, float X, float Y)
{
	local int i;
	local UWindowListBoxItem ItemPointer;
	local UMenuMapVoteList MapItem;
	local PlayerPawn P;

	Super.KeyDown(Key, X, Y);

	P=GetPlayerOwner();
	if(Key == P.EInputKey.IK_MouseWheelDown || Key == P.EInputKey.IK_Down)
	{
		if ( SelectedItem == None ) SelectedItem = UWindowListBoxItem(Items);
		if ( (SelectedItem != None) && (SelectedItem.Next != None) )
		{
			SetSelectedItem(UWindowListBoxItem(SelectedItem.Next));
			MakeSelectedVisible();
		}
	}
	if(Key == P.EInputKey.IK_MouseWheelUp || Key == P.EInputKey.IK_Up)
	{
		if ( SelectedItem == None ) SelectedItem = UWindowListBoxItem(Items.Last);
		if ( (SelectedItem != None) && (SelectedItem.Prev != None) && (SelectedItem.Sentinel != SelectedItem.Prev) )
		{
			SetSelectedItem(UWindowListBoxItem(SelectedItem.Prev));
			MakeSelectedVisible();
		}
	}
	if(Key == P.EInputKey.IK_PageDown)
	{
		if ( SelectedItem == None ) SelectedItem = UWindowListBoxItem(Items);
		if ( SelectedItem != None )
		{
			ItemPointer=SelectedItem;
			for( i=0; i<7; i++ )
			{
				if ( ItemPointer.Next == None )
					return;
				ItemPointer=UWindowListBoxItem(ItemPointer.Next);
			}
			SetSelectedItem(ItemPointer);
			MakeSelectedVisible();
		}
	}
	if(Key == P.EInputKey.IK_PageUp)
	{
		if ( SelectedItem == None ) SelectedItem = UWindowListBoxItem(Items.Last);
		if ( SelectedItem != None )
		{
			ItemPointer=SelectedItem;
			for ( i=0; i<7; i++ )
			{
				if ( (ItemPointer.Prev == None) || (ItemPointer.Prev == SelectedItem.Sentinel) )
					return;
				ItemPointer=UWindowListBoxItem(ItemPointer.Prev);
			}
			SetSelectedItem(ItemPointer);
			MakeSelectedVisible();
		}
	}
	ParentWindow.KeyDown(Key,X,Y);
}

function SelectMap(string GameModeName)
{
	local UMenuGameModeVoteList MapItem;

	for ( MapItem = UMenuGameModeVoteList(Items); MapItem != None; MapItem = UMenuGameModeVoteList(MapItem.Next) )
	{
		if( GameModeName ~= MapItem.GameModeName )
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

function Find (string SearchText)
{
	local UMenuGameModeVoteList Item;

	for ( Item = UMenuGameModeVoteList(Items); Item != None; Item = UMenuGameModeVoteList(Item.Next) )
	{
		if ( Caps(SearchText) <= Caps(Left(Item.GameModeName,Len(SearchText))) )
		{
			SetSelectedItem(Item);
			MakeSelectedVisible();
			break;
		}
	}
}

function EditCopy()
{
	local PlayerPawn P;

	P = GetPlayerOwner();

	P.CopyToClipboard(UMenuGameModeVoteList(SelectedItem).GameModeName);
}

defaultproperties
{
      BXTC=(R=0,G=0,B=0,A=0)
      ItemHeight=12.000000
      ListClass=Class'UMenuGameModeVoteList'
}
