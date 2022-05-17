//================================================================================
// MapVoteListBox.
//================================================================================

class MapVoteListBox extends UWindowListBox;

var int Count;
var float VotePriority;
var Localized String ColorCol[11];
var Color WhiteColor, BlackColor;
var Color RedColor;
var Color PurpleColor;
var Color LightBlueColor;
var Color TurquoiseColor;
var Color GreenColor;
var Color OrangeColor;
var Color YellowColor;
var Color PinkColor;
var Color DeepBlueColor;
var Color BXTC;
var MapVoteClientWindow CW;

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
	C.DrawColor = class'MapVoteClientConfig'.Default.BoxesColor;
	DrawStretchedTexture(C,0.00,0.00,WinWidth,WinHeight,Texture'ListsBoxBackground');
	Super.Paint(C,MouseX,MouseY);
}

function Created()
{
	Super.Created();

	if(Class'MapVoteClientConfig'.default.BoxesTextColor == 0)
		BXTC = RedColor;
	else if(Class'MapVoteClientConfig'.default.BoxesTextColor == 1)
		BXTC = PurpleColor;
	else if(Class'MapVoteClientConfig'.default.BoxesTextColor == 2)
		BXTC = LightBlueColor;
	else if(Class'MapVoteClientConfig'.default.BoxesTextColor == 3)
		BXTC = TurquoiseColor;
	else if(Class'MapVoteClientConfig'.default.BoxesTextColor == 4)
		BXTC = GreenColor;
	else if(Class'MapVoteClientConfig'.default.BoxesTextColor == 5)
		BXTC = OrangeColor;
	else if(Class'MapVoteClientConfig'.default.BoxesTextColor == 6)
		BXTC = YellowColor;
	else if(Class'MapVoteClientConfig'.default.BoxesTextColor == 7)
		BXTC = PinkColor;
	else if(Class'MapVoteClientConfig'.default.BoxesTextColor == 8)
		BXTC = WhiteColor;
	else if(Class'MapVoteClientConfig'.default.BoxesTextColor == 9)
		BXTC = DeepBlueColor;
	else if(Class'MapVoteClientConfig'.default.BoxesTextColor == 10)
		BXTC = BlackColor;
}

function DrawItem (Canvas C, UWindowList Item, float X, float Y, float W, float H)
{
	local string MapName, CapMapName, Prefix;
	local bool bSelected;

	if ( UMenuMapVoteList(Item).bSelected )
	{
		C.DrawColor.R=0;
		C.DrawColor.G=0;
		C.DrawColor.B=255;
		DrawStretchedTexture(C,X,Y,W,H - 1,Texture'ListsBoxBackground');
		bSelected=True;
	} else {
		C.DrawColor = class'MapVoteClientConfig'.Default.BoxesColor;
		DrawStretchedTexture(C,X,Y,W,H - 1,Texture'ListsBoxBackground');
		bSelected=False;
	}
	C.Font=Root.Fonts[0];
	MapName = UMenuMapVoteList(Item).MapName;
	if (CW != None)
		Prefix = CW.GetPrefix(UMenuMapVoteList(Item).CGNum);
	if ( Left(MapName,3) == "[X]" )
	{
		C.DrawColor.R=255;
		C.DrawColor.G=0;
		C.DrawColor.B=0;
		ClipText(C,X + 2,Y,Prefix $ Mid(MapName,3));
	}
	else
	{
		if ( bSelected )
		{
			C.DrawColor.R=255;
			C.DrawColor.G=255;
			C.DrawColor.B=255;
		}
		else
		{
			C.DrawColor = BXTC;
		}

		ClipText(C,X + 2,Y,Prefix $ MapName);
	}
}

function KeyDown (int Key, float X, float Y)
{
	local int i;
	local UWindowListBoxItem ItemPointer;
	local PlayerPawn P;

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

function Find(string SearchText)
{
    local int i;
    local UWindowListBoxItem ItemPointer;
    local UMenuMapVoteList MapItem;

    MapItem = UMenuMapVoteList(Items);
    J0x10:
    if(MapItem != none)
    {
        if(Caps(SearchText) <= Caps(Left(MapItem.MapName, Len(SearchText))))
        {
            SetSelectedItem(MapItem);
            MakeSelectedVisible();
            goto J0x70;
        }
        MapItem = UMenuMapVoteList(MapItem.Next);
        J0x70:
        goto J0x10;
    }
}

defaultproperties
{
      Count=0
      VotePriority=0.000000
      ColorCol(0)="Red"
      ColorCol(1)="Purple"
      ColorCol(2)="Light Blue"
      ColorCol(3)="Turquoise"
      ColorCol(4)="Green"
      ColorCol(5)="Orange"
      ColorCol(6)="Yellow"
      ColorCol(7)="Pink"
      ColorCol(8)="White"
      ColorCol(9)="Deep Blue"
      ColorCol(10)="Black"
      WhiteColor=(R=255,G=255,B=255,A=0)
      BlackColor=(R=0,G=0,B=0,A=0)
      RedColor=(R=255,G=0,B=0,A=0)
      PurpleColor=(R=128,G=0,B=128,A=0)
      LightBlueColor=(R=0,G=100,B=255,A=0)
      TurquoiseColor=(R=0,G=255,B=255,A=0)
      GreenColor=(R=0,G=255,B=0,A=0)
      OrangeColor=(R=255,G=120,B=0,A=0)
      YellowColor=(R=255,G=255,B=0,A=0)
      PinkColor=(R=255,G=0,B=255,A=0)
      DeepBlueColor=(R=0,G=0,B=255,A=0)
      BXTC=(R=0,G=0,B=0,A=0)
      CW=None
      ItemHeight=12.000000
      ListClass=Class'UMenuMapVoteList'
}
