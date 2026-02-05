//================================================================================
// MapVoteListBox.
//================================================================================
class MapVoteListBox extends MVBaseListBox;

var int Count;
var float VotePriority;
var Color BXTC;
var Color BXC;
var bool bRequestingSearch;

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
	if ( UMenuMapVoteList(Item).bSelected )
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
	ClipText(C,X + 2,Y,UMenuMapVoteList(Item).MapName);
}

function KeyDown (int Key, float X, float Y)
{
	local int i;
	local UWindowListBoxItem ItemPointer;
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
		if ( SelectedItem == None ) SelectedItem = UWindowListBoxItem(Items.Last);
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

function SelectMap (string MapName)
{
  local UMenuMapVoteList MapItem;

  MapItem = UMenuMapVoteList(Items);
JL0010:
  if ( MapItem != None )
  {
    if ( MapName ~= MapItem.MapName )
    {
      SetSelectedItem(MapItem);
      MakeSelectedVisible();
    } else {
      MapItem = UMenuMapVoteList(MapItem.Next);
      goto JL0010;
    }
  }
}

function bool isMapInList (string MapName)
{
  local UMenuMapVoteList MapItem;

  MapItem = UMenuMapVoteList(Items);
  JL0010:
  if ( MapItem != None )
  {
    if ( MapName ~= MapItem.MapName )
    {
      return True;
    }
    MapItem = UMenuMapVoteList(MapItem.Next);
    goto JL0010;
  }
  return False;
}

function DoubleClickItem (UWindowListBoxItem i)
{
  UWindowDialogClientWindow(ParentWindow).Notify(self,11);
}

function KeyType(int Key, float X, float Y)
{
	Super.KeyType(Key, X, Y);

	if ( bControlDown ) return;

	// TODO maybe there is a cleaner way to achieve this?
	if ( !bControlDown )
	{
		bRequestingSearch = True;
	}
	ParentWindow.KeyType(Key, X, Y);
}

function EditCopy()
{
	local PlayerPawn P;

	P = GetPlayerOwner();

	P.CopyToClipboard(UMenuMapVoteList(SelectedItem).MapName);
}

defaultproperties
{
	BXTC=(R=0,G=0,B=0,A=0)
	ItemHeight=12.000000
	ListClass=Class'UMenuMapVoteList'
}
