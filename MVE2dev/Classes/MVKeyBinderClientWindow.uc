//================================================================================
// MVKeyBinderClientWindow.
//================================================================================
class MVKeyBinderClientWindow extends UMenuDialogClientWindow;

var string RealKeyName[255];
var MVKeyBinderListBox lstKeyList;
var UWindowSmallButton SaveButton;
var UWindowSmallButton CloseButton;
var float CloseRequestTime;
var UMenuLabelControl lblMessage1;
var UMenuLabelControl lblMessage2;

var Color BackgroundColor;

function Created ()
{
	local Color C;
	local Color TextColor;

	TextColor.R = 255;
	TextColor.G = 255;
	TextColor.B = 255;
	Super.Created();
	C.R = 0;
	C.G = 0;
	C.B = 128;
	lstKeyList = MVKeyBinderListBox(CreateControl(Class'MVKeyBinderListBox',10.00,53.00,460.00,92.00));
	lstKeyList.bAcceptsFocus = False;
	lstKeyList.Items.Clear();
	SaveButton = UWindowSmallButton(CreateControl(Class'UWindowSmallButton',300.00,160.00,80.00,20.00));
	SaveButton.Text = "Bind";
	SaveButton.DownSound = Sound'WindowClose';
	SaveButton.bDisabled = True;
	SaveButton.bAcceptsFocus = False;
	SaveButton.SetFont(F_Bold);
	lblMessage1 = UMenuLabelControl(CreateControl(Class'UMenuLabelControl',10.00,10.00,460.00,40.00));
	lblMessage1.SetText("");
	lblMessage1.SetTextColor(TextColor);
	lblMessage1.bAcceptsFocus = False;
	lblMessage2 = UMenuLabelControl(CreateControl(Class'UMenuLabelControl',10.00,160.00,280.00,40.00));
	lblMessage2.SetText("Note: you can always open mapvote by typing !v into chat");
	lblMessage2.SetTextColor(TextColor);
	lblMessage2.bAcceptsFocus = False;
	CloseButton = UWindowSmallButton(CreateControl(Class'UWindowSmallButton',390.00,160.00,80.00,20.00));
	CloseButton.Text = "Close";
	SetAcceptsFocus();
	LoadExistingKeys();
	BackgroundColor = class'MapVoteClientConfig'.static.GetInstance().BackgroundColor;
}

function KeyDown (int Key, float X, float Y)
{
	local int i;
	local KeyBinderListItem KeyItem;
	local bool found;
	local PlayerPawn P;

	found = False;

	P = GetPlayerOwner();
	
	if( Key == P.EInputKey.IK_MouseWheelDown || Key == P.EInputKey.IK_Down )
	{
		if ( (lstKeyList.SelectedItem != None) && (lstKeyList.SelectedItem.Next != None) )
		{
			lstKeyList.SetSelectedItem(UWindowListBoxItem(lstKeyList.SelectedItem.Next));
			lstKeyList.MakeSelectedVisible();
		}
		return;
	}

	if( Key == P.EInputKey.IK_MouseWheelUp || Key == P.EInputKey.IK_Up )
	{
		if ( (lstKeyList.SelectedItem != None) && (lstKeyList.SelectedItem.Prev != None) && (lstKeyList.SelectedItem.Sentinel != lstKeyList.SelectedItem.Prev) )
		{
			lstKeyList.SetSelectedItem(UWindowListBoxItem(lstKeyList.SelectedItem.Prev));
			lstKeyList.MakeSelectedVisible();
		}
		return;
	}

	KeyItem = KeyBinderListItem(lstKeyList.Items);

	while ( KeyItem != None )
	{
		if ( RealKeyName[Key] != "" && RealKeyName[Key] == KeyItem.KeyName )
		{
			if ( KeyItem.Prev != None && KeyItem.Prev.Prev != None )
			{
				lstKeyList.SetSelectedItem(KeyBinderListItem(KeyItem.Prev.Prev));
				lstKeyList.MakeSelectedVisible();
			}
			if ( KeyItem.Next != None && KeyItem.Next.Next != None )
			{
				lstKeyList.SetSelectedItem(KeyBinderListItem(KeyItem.Next.Next));
				lstKeyList.MakeSelectedVisible();
			}
			lstKeyList.SetSelectedItem(KeyItem);
			lstKeyList.MakeSelectedVisible();
			found = True;
			break;
		} 
		else 
		{
			KeyItem = KeyBinderListItem(KeyItem.Next);
			continue;
		}
	}
}

function LoadExistingKeys ()
{
	local int i;
	local string KeyName;
	local string Alias;
	local KeyBinderListItem A;
	local bool bFound;

	for ( i = 0; i < 255; i+=1 )
	{
		KeyName = GetPlayerOwner().ConsoleCommand("KEYNAME "$string(i));
		if ( InStr(KeyName, "Unknown") == 0 || InStr(KeyName, "Mouse") != -1 && KeyName != "None" )
		{
			continue;
		}
		A = KeyBinderListItem(lstKeyList.Items.Append(Class'KeyBinderListItem'));
		A.KeyName = KeyName;
		RealKeyName[i] = KeyName;
		if ( KeyName != "" )
		{
			Alias = GetPlayerOwner().ConsoleCommand("KEYBINDING "$KeyName);
			A.CommandString = Alias;
			if ( Caps(Alias) == "MUTATE BDBMAPVOTE VOTEMENU" )
			{
				lstKeyList.SetSelectedItem(A);
				lstKeyList.MakeSelectedVisible();
				CloseRequestTime = GetPlayerOwner().Level.TimeSeconds;
				lblMessage1.SetText("Your MapVote keybind is "$KeyName);
				bFound = True;
			}
		}
	}
	if ( !bFound )
	{
		lblMessage1.SetText("No keybind for MapVote, press any key to search...");
	}
}

function Notify (UWindowDialogControl C, byte E)
{
	local string CommandString;

	Super.Notify(C,E);
	switch (E)
	{
		case DE_Click:
			switch (C)
			{
			case lstKeyList:
				SaveButton.Text = "Bind "$KeyBinderListItem(lstKeyList.SelectedItem).KeyName;
			SaveButton.bDisabled = False;
			break;
			case SaveButton:
				if (!SaveButton.bDisabled) SaveKeyBind();
			break;
			case CloseButton:
				ParentWindow.Close();
			break;
			default:
		}
		break;
		default:
	}
}

function SaveKeyBind ()
{
	local string CommandString;
	SetKey(KeyBinderListItem(lstKeyList.SelectedItem).KeyName,"MUTATE BDBMAPVOTE VOTEMENU");
	ParentWindow.Close();
}

function SetKey (string KeyName, string CommandString)
{
	GetPlayerOwner().ConsoleCommand("SET Input "$KeyName$" "$CommandString);
	KeyBinderListItem(lstKeyList.SelectedItem).CommandString = CommandString;
}

function Paint (Canvas C, float MouseX, float MouseY)
{
	C.DrawColor = BackgroundColor;
	DrawStretchedTexture(C,0.00,0.00,WinWidth,WinHeight,Texture'BackgroundTexture');
	Super.Paint(C,MouseX,MouseY);
	C.DrawColor.R = 255;
	C.DrawColor.G = 255;
	C.DrawColor.B = 255;
	DrawStretchedTexture(C,10.00,40.00,460.00,13.00,Texture'ListsBoxBackground');
	C.DrawColor.R = 0;
	C.DrawColor.G = 0;
	C.DrawColor.B = 0;
	C.Font = Root.Fonts[0];
	ClipText(C,15.00,41.00,"Input");
	ClipText(C,115.00,41.00,"Command");
	DrawStretchedTexture(C,105.00,40.00,1.00,13.00,Texture'ListsBoxBackground');
}


	// ;