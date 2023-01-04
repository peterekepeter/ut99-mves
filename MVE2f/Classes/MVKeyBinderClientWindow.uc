//================================================================================
// MVKeyBinderClientWindow.
//================================================================================
class MVKeyBinderClientWindow extends UMenuDialogClientWindow;

var string RealKeyName[255];
var MVKeyBinderListBox lstKeyList;
var UWindowSmallButton SaveButton;
var float CloseRequestTime;
var UMenuLabelControl lblMessage;

var Color BackgroundColor;

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
      BackgroundColor = class'MapVoteClientConfig'.static.GetInstance().BackgroundColor;
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
	C.DrawColor = BackgroundColor;
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
      RealKeyName(0)=""
      RealKeyName(1)=""
      RealKeyName(2)=""
      RealKeyName(3)=""
      RealKeyName(4)=""
      RealKeyName(5)=""
      RealKeyName(6)=""
      RealKeyName(7)=""
      RealKeyName(8)=""
      RealKeyName(9)=""
      RealKeyName(10)=""
      RealKeyName(11)=""
      RealKeyName(12)=""
      RealKeyName(13)=""
      RealKeyName(14)=""
      RealKeyName(15)=""
      RealKeyName(16)=""
      RealKeyName(17)=""
      RealKeyName(18)=""
      RealKeyName(19)=""
      RealKeyName(20)=""
      RealKeyName(21)=""
      RealKeyName(22)=""
      RealKeyName(23)=""
      RealKeyName(24)=""
      RealKeyName(25)=""
      RealKeyName(26)=""
      RealKeyName(27)=""
      RealKeyName(28)=""
      RealKeyName(29)=""
      RealKeyName(30)=""
      RealKeyName(31)=""
      RealKeyName(32)=""
      RealKeyName(33)=""
      RealKeyName(34)=""
      RealKeyName(35)=""
      RealKeyName(36)=""
      RealKeyName(37)=""
      RealKeyName(38)=""
      RealKeyName(39)=""
      RealKeyName(40)=""
      RealKeyName(41)=""
      RealKeyName(42)=""
      RealKeyName(43)=""
      RealKeyName(44)=""
      RealKeyName(45)=""
      RealKeyName(46)=""
      RealKeyName(47)=""
      RealKeyName(48)=""
      RealKeyName(49)=""
      RealKeyName(50)=""
      RealKeyName(51)=""
      RealKeyName(52)=""
      RealKeyName(53)=""
      RealKeyName(54)=""
      RealKeyName(55)=""
      RealKeyName(56)=""
      RealKeyName(57)=""
      RealKeyName(58)=""
      RealKeyName(59)=""
      RealKeyName(60)=""
      RealKeyName(61)=""
      RealKeyName(62)=""
      RealKeyName(63)=""
      RealKeyName(64)=""
      RealKeyName(65)=""
      RealKeyName(66)=""
      RealKeyName(67)=""
      RealKeyName(68)=""
      RealKeyName(69)=""
      RealKeyName(70)=""
      RealKeyName(71)=""
      RealKeyName(72)=""
      RealKeyName(73)=""
      RealKeyName(74)=""
      RealKeyName(75)=""
      RealKeyName(76)=""
      RealKeyName(77)=""
      RealKeyName(78)=""
      RealKeyName(79)=""
      RealKeyName(80)=""
      RealKeyName(81)=""
      RealKeyName(82)=""
      RealKeyName(83)=""
      RealKeyName(84)=""
      RealKeyName(85)=""
      RealKeyName(86)=""
      RealKeyName(87)=""
      RealKeyName(88)=""
      RealKeyName(89)=""
      RealKeyName(90)=""
      RealKeyName(91)=""
      RealKeyName(92)=""
      RealKeyName(93)=""
      RealKeyName(94)=""
      RealKeyName(95)=""
      RealKeyName(96)=""
      RealKeyName(97)=""
      RealKeyName(98)=""
      RealKeyName(99)=""
      RealKeyName(100)=""
      RealKeyName(101)=""
      RealKeyName(102)=""
      RealKeyName(103)=""
      RealKeyName(104)=""
      RealKeyName(105)=""
      RealKeyName(106)=""
      RealKeyName(107)=""
      RealKeyName(108)=""
      RealKeyName(109)=""
      RealKeyName(110)=""
      RealKeyName(111)=""
      RealKeyName(112)=""
      RealKeyName(113)=""
      RealKeyName(114)=""
      RealKeyName(115)=""
      RealKeyName(116)=""
      RealKeyName(117)=""
      RealKeyName(118)=""
      RealKeyName(119)=""
      RealKeyName(120)=""
      RealKeyName(121)=""
      RealKeyName(122)=""
      RealKeyName(123)=""
      RealKeyName(124)=""
      RealKeyName(125)=""
      RealKeyName(126)=""
      RealKeyName(127)=""
      RealKeyName(128)=""
      RealKeyName(129)=""
      RealKeyName(130)=""
      RealKeyName(131)=""
      RealKeyName(132)=""
      RealKeyName(133)=""
      RealKeyName(134)=""
      RealKeyName(135)=""
      RealKeyName(136)=""
      RealKeyName(137)=""
      RealKeyName(138)=""
      RealKeyName(139)=""
      RealKeyName(140)=""
      RealKeyName(141)=""
      RealKeyName(142)=""
      RealKeyName(143)=""
      RealKeyName(144)=""
      RealKeyName(145)=""
      RealKeyName(146)=""
      RealKeyName(147)=""
      RealKeyName(148)=""
      RealKeyName(149)=""
      RealKeyName(150)=""
      RealKeyName(151)=""
      RealKeyName(152)=""
      RealKeyName(153)=""
      RealKeyName(154)=""
      RealKeyName(155)=""
      RealKeyName(156)=""
      RealKeyName(157)=""
      RealKeyName(158)=""
      RealKeyName(159)=""
      RealKeyName(160)=""
      RealKeyName(161)=""
      RealKeyName(162)=""
      RealKeyName(163)=""
      RealKeyName(164)=""
      RealKeyName(165)=""
      RealKeyName(166)=""
      RealKeyName(167)=""
      RealKeyName(168)=""
      RealKeyName(169)=""
      RealKeyName(170)=""
      RealKeyName(171)=""
      RealKeyName(172)=""
      RealKeyName(173)=""
      RealKeyName(174)=""
      RealKeyName(175)=""
      RealKeyName(176)=""
      RealKeyName(177)=""
      RealKeyName(178)=""
      RealKeyName(179)=""
      RealKeyName(180)=""
      RealKeyName(181)=""
      RealKeyName(182)=""
      RealKeyName(183)=""
      RealKeyName(184)=""
      RealKeyName(185)=""
      RealKeyName(186)=""
      RealKeyName(187)=""
      RealKeyName(188)=""
      RealKeyName(189)=""
      RealKeyName(190)=""
      RealKeyName(191)=""
      RealKeyName(192)=""
      RealKeyName(193)=""
      RealKeyName(194)=""
      RealKeyName(195)=""
      RealKeyName(196)=""
      RealKeyName(197)=""
      RealKeyName(198)=""
      RealKeyName(199)=""
      RealKeyName(200)=""
      RealKeyName(201)=""
      RealKeyName(202)=""
      RealKeyName(203)=""
      RealKeyName(204)=""
      RealKeyName(205)=""
      RealKeyName(206)=""
      RealKeyName(207)=""
      RealKeyName(208)=""
      RealKeyName(209)=""
      RealKeyName(210)=""
      RealKeyName(211)=""
      RealKeyName(212)=""
      RealKeyName(213)=""
      RealKeyName(214)=""
      RealKeyName(215)=""
      RealKeyName(216)=""
      RealKeyName(217)=""
      RealKeyName(218)=""
      RealKeyName(219)=""
      RealKeyName(220)=""
      RealKeyName(221)=""
      RealKeyName(222)=""
      RealKeyName(223)=""
      RealKeyName(224)=""
      RealKeyName(225)=""
      RealKeyName(226)=""
      RealKeyName(227)=""
      RealKeyName(228)=""
      RealKeyName(229)=""
      RealKeyName(230)=""
      RealKeyName(231)=""
      RealKeyName(232)=""
      RealKeyName(233)=""
      RealKeyName(234)=""
      RealKeyName(235)=""
      RealKeyName(236)=""
      RealKeyName(237)=""
      RealKeyName(238)=""
      RealKeyName(239)=""
      RealKeyName(240)=""
      RealKeyName(241)=""
      RealKeyName(242)=""
      RealKeyName(243)=""
      RealKeyName(244)=""
      RealKeyName(245)=""
      RealKeyName(246)=""
      RealKeyName(247)=""
      RealKeyName(248)=""
      RealKeyName(249)=""
      RealKeyName(250)=""
      RealKeyName(251)=""
      RealKeyName(252)=""
      RealKeyName(253)=""
      RealKeyName(254)=""
      lstKeyList=None
      SaveButton=None
      CloseRequestTime=0.000000
      lblMessage=None
}
