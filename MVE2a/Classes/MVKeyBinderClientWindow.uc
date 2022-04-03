//================================================================================
// MVKeyBinderClientWindow.
//================================================================================
class MVKeyBinderClientWindow extends UMenuDialogClientWindow;

var string RealKeyName[255];
var MVKeyBinderListBox lstKeyList;
var UWindowSmallButton SaveButton;
var float CloseRequestTime;
var UMenuLabelControl lblMessage;

function Created ()
{
	local Color C;
	local Color TextColor;

	TextColor.R=255;
	TextColor.G=255;
	TextColor.B=255;
	Super.Created();
	C.R=0;
	C.G=0;
	C.B=128;
	lstKeyList=MVKeyBinderListBox(CreateControl(Class'MVKeyBinderListBox',10.00,23.00,460.00,92.00));
	lstKeyList.bAcceptsFocus=False;
	lstKeyList.Items.Clear();
	SaveButton=UWindowSmallButton(CreateControl(Class'UWindowSmallButton',215.00,120.00,50.00,20.00));
	SaveButton.Text="Set/Save";
	SaveButton.DownSound=Sound'WindowClose';
	SaveButton.bDisabled=False;
	SaveButton.bAcceptsFocus=False;
	lblMessage=UMenuLabelControl(CreateControl(Class'UMenuLabelControl',10.00,150.00,460.00,40.00));
	lblMessage.SetText("");
	lblMessage.SetFont(3);
	lblMessage.SetTextColor(TextColor);
	lblMessage.bAcceptsFocus=False;
	SetAcceptsFocus();
	LoadExistingKeys();
}

function KeyDown (int Key, float X, float Y)
{
	local int i;
	local KeyBinderListItem KeyItem;

	KeyItem=KeyBinderListItem(lstKeyList.Items);
JL0019:
	if ( KeyItem != None )
	{
		if ( RealKeyName[Key] == KeyItem.KeyName )
		{
			lstKeyList.SetSelectedItem(KeyItem);
			lstKeyList.MakeSelectedVisible();
		} else {
			KeyItem=KeyBinderListItem(KeyItem.Next);
			goto JL0019;
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

	i=0;
JL0007:
	if ( i < 255 )
	{
		A=KeyBinderListItem(lstKeyList.Items.Append(Class'KeyBinderListItem'));
		KeyName=GetPlayerOwner().ConsoleCommand("KEYNAME " $ string(i));
		A.KeyName=KeyName;
		RealKeyName[i]=KeyName;
		if ( KeyName != "" )
		{
			Alias=GetPlayerOwner().ConsoleCommand("KEYBINDING " $ KeyName);
			A.CommandString=Alias;
			if ( Caps(Alias) == "MUTATE BDBMAPVOTE VOTEMENU" )
			{
				lstKeyList.SetSelectedItem(A);
				lstKeyList.MakeSelectedVisible();
				CloseRequestTime=GetPlayerOwner().Level.TimeSeconds;
				lblMessage.SetText("Your Map Vote Hot Key is " $ KeyName);
				bFound=True;
			}
		}
		i++;
		goto JL0007;
	}
	if (  !bFound )
	{
		lblMessage.SetText("Press/Select a Desired Map Vote Hot Key");
	}
}

function Notify (UWindowDialogControl C, byte E)
{
	local string CommandString;

	Super.Notify(C,E);
	switch (E)
	{
		case 2:
		switch (C)
		{
			case SaveButton:
			SaveKeyBind();
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
	GetPlayerOwner().ConsoleCommand("SET Input " $ KeyName $ " " $ CommandString);
	KeyBinderListItem(lstKeyList.SelectedItem).CommandString=CommandString;
}

function Paint (Canvas C, float MouseX, float MouseY)
{
	C.DrawColor = class'MapVoteClientConfig'.Default.BackgroundColor;
	DrawStretchedTexture(C,0.00,0.00,WinWidth,WinHeight,Texture'BackgroundTexture');
	Super.Paint(C,MouseX,MouseY);
	C.DrawColor.R=255;
	C.DrawColor.G=255;
	C.DrawColor.B=255;
	DrawStretchedTexture(C,10.00,10.00,460.00,13.00,Texture'ListsBoxBackground');
	C.DrawColor.R=0;
	C.DrawColor.G=0;
	C.DrawColor.B=0;
	C.Font=Root.Fonts[0];
	ClipText(C,15.00,11.00,"Keyboard Key");
	ClipText(C,115.00,11.00,"Console Commands");
	DrawStretchedTexture(C,105.00,10.00,1.00,13.00,Texture'ListsBoxBackground');
}

defaultproperties
{
}
