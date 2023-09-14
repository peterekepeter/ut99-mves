class ConfigWindow extends UWindowPageWindow;

var string RealKeyName[255];
var UWindowSmallButton CloseButton;
var UMenuLabelControl  lblKeyBind;
var UMenuLabelControl  lblMenuKey;
var UMenuRaisedButton  ButMenuKey;
var string OldMenuKey;
var bool   bMenu;

var UWindowHSliderControl RSlider, GSlider, BSlider, RBSlider, GBSlider, BBSlider;
var UWindowHSliderControl BXT, Title1, Title2, Title3, Title4, Title5, Title6;
var UWindowHSliderControl sldMsgTimeOut;
var UWindowLabelControl BXTL, TitleText1, TitleText2, TitleText3, TitleText4, TitleText5, TitleText6;
var UWindowLabelControl lblMLT1, lblMLT2, lblMLT3, lblMLT4, lblMLT5, lblMLT6, lblMT;
var UWindowLabelControl lblBXT, lblBG, lblHMT, lblHMT2, lblMS, lblMsgTimeOut;
var bool bSliderInited;
var UWindowCheckbox cbUseMsgTimeout;

var MapVoteClientConfig Config;
//var UWindowCheckbox bStartupLogo;

function Paint (Canvas C, float MouseX, float MouseY)
{
	Super.Paint(C,MouseX,MouseY);
	C.DrawColor = Config.BackgroundColor;
	DrawStretchedTexture(C,0.0,0.0,WinWidth,WinHeight,Texture'BackgroundTexture');
	C.DrawColor.R = 0;
	C.DrawColor.G = 255;
	C.DrawColor.B = 0;
	DrawStretchedTexture(C,10.0,25.0,635.0,2.0,Texture'ListsBoxBackground');
	DrawStretchedTexture(C,10.0,120.0,635.0,2.0,Texture'ListsBoxBackground');
	DrawStretchedTexture(C,10.0,240.0,635.0,2.0,Texture'ListsBoxBackground');
	//DrawStretchedTexture(C,10.0,300.0,635.0,2.0,Texture'ListsBoxBackground');
	DrawStretchedTexture(C,10.0,420.0,635.0,2.0,Texture'ListsBoxBackground');
	C.DrawColor = Config.BoxesColor;
	DrawStretchedTexture(C,468.5,170.661,100.0,20.0,Texture'ListsBoxBackground');
}

function Created()
{
	local Color C, BXTC, TitleColor, TitleColor1, TitleColor2, TitleColor3, TitleColor4, TitleColor5, TitleColor6;

	Super.Created();

	Config = class'MapVoteClientConfig'.static.GetInstance();

	BXTC = Config.GetColorOfBoxesTextColor();
	TitleColor1 = Config.GetColorOfGameModTitleColor();
	TitleColor2 = Config.GetColorOfRuleTitleColor();
	TitleColor3 = Config.GetColorOfMapTitleColor();
	TitleColor4 = Config.GetColorOfKickVoteTitleColor();
	TitleColor5 = Config.GetColorOfPlayerTitleColor();
	TitleColor6 = Config.GetColorOfMapVoteTitleColor();

	C.R=171;
	C.G=171;
	C.B=171;

	lblBG=UMenuLabelControl(CreateControl(Class'UMenuLabelControl',10.00,15.00,90.00,20.00));
	lblBG.SetText("Background Color");
	lblBG.SetTextColor(C);

	lblKeyBind = UMenuLabelControl(CreateControl(Class'UMenuLabelControl',260.0,480.0,100.0,10.0));
	lblKeyBind.SetText("");
	lblKeyBind.TextColor = (C);
	lblKeyBind.SetFont(F_Normal);

	lblMenuKey = UMenuLabelControl(CreateControl(Class'UMenuLabelControl',20.0,480.0,110.0,10.0));
	lblMenuKey.TextColor = (C);
	lblMenuKey.SetText("Bind Map Vote Key ...");
	lblMenuKey.SetFont(F_Normal);

	ButMenuKey = UMenuRaisedButton(CreateControl(Class'UMenuRaisedButton',177.0,476.5,69.0,1.0));
	ButMenuKey.bAcceptsFocus = False;
	ButMenuKey.Align=TA_Center;
	ButMenuKey.bIgnoreLDoubleClick = True;
	ButMenuKey.bIgnoreMDoubleClick = True;
	ButMenuKey.bIgnoreRDoubleClick = True;

	RSlider = UWindowHSliderControl(CreateControl(Class'UWindowHSliderControl',20.0,43.0,WinWidth - 350,200.0));
	RSlider.SetText("Red Color");
	RSlider.SetRange(1,255,1);
	RSlider.bAcceptsFocus=False;
	RSlider.SetValue(Config.BackgroundColor.R);
	RSlider.SetHelpText("Configure Red Color");
	RSlider.SetFont(F_Normal);
	RSlider.MinValue=1;
	RSlider.MaxValue=255;
	RSlider.Step=1;
	RSlider.Align = TA_Left;
	RSlider.SetTextColor(C);

	GSlider = UWindowHSliderControl(CreateControl(Class'UWindowHSliderControl',20.0,63.0,WinWidth - 350,200.0));
	GSlider.SetText("Green Color");
	GSlider.SetRange(1,255,1);
	GSlider.bAcceptsFocus=False;
	GSlider.SetValue(Config.BackgroundColor.G);
	GSlider.SetHelpText("Configure Green Color");
	GSlider.SetFont(F_Normal);
	GSlider.MinValue=1;
	GSlider.MaxValue=255;
	GSlider.Step=1;
	GSlider.Align = TA_Left;
	GSlider.SetTextColor(C);

	BSlider = UWindowHSliderControl(CreateControl(Class'UWindowHSliderControl',20.0,83.0,WinWidth - 350,200.0));
	BSlider.SetText("Blue Color");
	BSlider.SetRange(1,255,1);
	BSlider.bAcceptsFocus=False;
	BSlider.SetValue(Config.BackgroundColor.B);
	BSlider.SetHelpText("Configure Blue Color");
	BSlider.SetFont(F_Normal);
	BSlider.MinValue=1;
	BSlider.MaxValue=255;
	BSlider.Step=1;
	BSlider.Align = TA_Left;
	BSlider.SetTextColor(C);

	//=================================================================================

	lblBG = UMenuLabelControl(CreateControl(Class'UMenuLabelControl',10.0,110.0,180.0,20.0));
	lblBG.SetText("Boxes Color");
	lblBG.SetTextColor(C);

	RBSlider = UWindowHSliderControl(CreateControl(Class'UWindowHSliderControl',20.0,135.0,WinWidth - 350,200.0));
	RBSlider.SetText("Red Color");
	RBSlider.SetRange(1,255,1);
	RBSlider.bAcceptsFocus=False;
	RBSlider.SetValue(Config.BoxesColor.R);
	RBSlider.SetHelpText("Configure Red Color");
	RBSlider.SetFont(F_Normal);
	RBSlider.MinValue=1;
	RBSlider.MaxValue=255;
	RBSlider.Step=1;
	RBSlider.Align = TA_Left;
	RBSlider.SetTextColor(C);

	GBSlider = UWindowHSliderControl(CreateControl(Class'UWindowHSliderControl',20.0,155.0,WinWidth - 350,200.0));
	GBSlider.SetText("Green Color");
	GBSlider.SetRange(1,255,1);
	GBSlider.bAcceptsFocus=False;
	GBSlider.SetValue(Config.BoxesColor.G);
	GBSlider.SetHelpText("Configure Green Color");
	GBSlider.SetFont(F_Normal);
	GBSlider.MinValue=1;
	GBSlider.MaxValue=255;
	GBSlider.Step=1;
	GBSlider.Align = TA_Left;
	GBSlider.SetTextColor(C);

	BBSlider = UWindowHSliderControl(CreateControl(Class'UWindowHSliderControl',20.0,175.0,WinWidth - 350,200.0));
	BBSlider.SetText("Blue Color");
	BBSlider.SetRange(1,255,1);
	BBSlider.bAcceptsFocus=False;
	BBSlider.SetValue(Config.BoxesColor.B);
	BBSlider.SetHelpText("Configure Blue Color");
	BBSlider.SetFont(F_Normal);
	BBSlider.MinValue=1;
	BBSlider.MaxValue=255;
	BBSlider.Step=1;
	BBSlider.Align = TA_Left;
	BBSlider.SetTextColor(C);

	BXT = UWindowHSliderControl(CreateControl(Class'UWindowHSliderControl',20.0,195.0,WinWidth - 350,200.0));
	BXT.SetText("Boxes Text Color");
	BXT.SetRange(0,10,1);
	BXT.bAcceptsFocus=False;
	BXT.SetValue(Config.BoxesTextColor);
	BXT.SetFont(F_Normal);
	BXT.Align = TA_Left;
	BXT.SetTextColor(C);

	BXTL = UWindowLabelControl(CreateControl(Class'UWindowLabelControl',360.0,195.0,WinWidth - 0,0.0));
	BXTL.Align = TA_Left;
	BXTL.SetText(Config.GetNameOfBoxesTextColor());
	BXTL.SetTextColor(C);

	lblBXT = UMenuLabelControl(CreateControl(Class'UMenuLabelControl',438.0,175.5,WinWidth - 500,200.0));
	lblBXT.SetText("Boxes Text Color");
	lblBXT.Align=TA_Center;
	lblBXT.SetTextColor(BXTC);

	lblHMT = UMenuLabelControl(CreateControl(Class'UMenuLabelControl',145.0,215.0,WinWidth - 400,200.0));
	lblHMT.SetText("(Press the Close button to apply these changes)");
	lblHMT.SetTextColor(C);

	//=================================================================================
	lblMT = UMenuLabelControl(CreateControl(Class'UMenuLabelControl',10.0,230.0,90.0,20.0));
	lblMT.SetText("Titles Color");
	lblMT.SetTextColor(C);
	//=================================================================================

	Title1 = UWindowHSliderControl(CreateControl(Class'UWindowHSliderControl',20.0,255.0,WinWidth - 350,200.0));
	Title1.SetText("Game Mod Title Color");
	Title1.SetRange(0,10,1);
	Title1.bAcceptsFocus=False;
	Title1.SetValue(Config.GameModTitleColor);
	Title1.SetFont(F_Normal);
	Title1.Align = TA_Left;
	Title1.SetTextColor(C);

	TitleText1 = UWindowLabelControl(CreateControl(Class'UWindowLabelControl',360.0,255.0,WinWidth - 0,0.0));
	TitleText1.Align = TA_Left;
	TitleText1.SetText(Config.GetNameOfGameModTitleColor());
	TitleText1.SetTextColor(C);

	lblMLT1 = UMenuLabelControl(CreateControl(Class'UMenuLabelControl',469.0,255.0,WinWidth - 500,200.0));
	lblMLT1.SetFont(1);
	lblMLT1.SetText("Game Mod");
	lblMLT1.Align=TA_Left;
	lblMLT1.SetTextColor(TitleColor1);

	//=================================================================================

	Title2 = UWindowHSliderControl(CreateControl(Class'UWindowHSliderControl',20.0,279.0,WinWidth - 350,200.0));
	Title2.SetText("Rule Title Color");
	Title2.SetRange(0,10,1);
	Title2.bAcceptsFocus=False;
	Title2.SetValue(Config.RuleTitleColor);
	Title2.SetFont(F_Normal);
	Title2.Align = TA_Left;
	Title2.SetTextColor(C);

	TitleText2 = UWindowLabelControl(CreateControl(Class'UWindowLabelControl',360.0,279.0,WinWidth - 0,0.0));
	TitleText2.Align = TA_Left;
	TitleText2.SetText(Config.GetNameOfRuleTitleColor());
	TitleText2.SetTextColor(C);

	lblMLT2 = UMenuLabelControl(CreateControl(Class'UMenuLabelControl',469.0,279.0,WinWidth - 500,200.0));
	lblMLT2.SetFont(1);
	lblMLT2.SetText("Rule");
	lblMLT2.Align=TA_Left;
	lblMLT2.SetTextColor(TitleColor2);

	//=================================================================================

	Title3 = UWindowHSliderControl(CreateControl(Class'UWindowHSliderControl',20.0,303.0,WinWidth - 350,200.0));
	Title3.SetText("Map Title Color");
	Title3.SetRange(0,10,1);
	Title3.bAcceptsFocus=False;
	Title3.SetValue(Config.MapTitleColor);
	Title3.SetFont(F_Normal);
	Title3.Align = TA_Left;
	Title3.SetTextColor(C);

	TitleText3 = UWindowLabelControl(CreateControl(Class'UWindowLabelControl',360.0,303.0,WinWidth - 0,0.0));
	TitleText3.Align = TA_Left;
	TitleText3.SetText(Config.GetNameOfMapTitleColor());
	TitleText3.SetTextColor(C);

	lblMLT3 = UMenuLabelControl(CreateControl(Class'UMenuLabelControl',469.0,303.0,WinWidth - 500,200.0));
	lblMLT3.SetFont(1);
	lblMLT3.SetText("Map");
	lblMLT3.Align=TA_Left;
	lblMLT3.SetTextColor(TitleColor3);

	//=================================================================================

	Title4 = UWindowHSliderControl(CreateControl(Class'UWindowHSliderControl',20.0,327.0,WinWidth - 350,200.0));
	Title4.SetText("Kick Vote Title Color");
	Title4.SetRange(0,10,1);
	Title4.bAcceptsFocus=False;
	Title4.SetValue(Config.KickVoteTitleColor);
	Title4.SetFont(F_Normal);
	Title4.Align = TA_Left;
	Title4.SetTextColor(C);

	TitleText4 = UWindowLabelControl(CreateControl(Class'UWindowLabelControl',360.0,327.0,WinWidth - 0,0.0));
	TitleText4.Align = TA_Left;
	TitleText4.SetText(Config.GetNameOfKickVoteTitleColor());
	TitleText4.SetTextColor(C);

	lblMLT4 = UMenuLabelControl(CreateControl(Class'UMenuLabelControl',469.0,327.0,WinWidth - 500,200.0));
	lblMLT4.SetFont(1);
	lblMLT4.SetText("Kick Vote");
	lblMLT4.Align=TA_Left;
	lblMLT4.SetTextColor(TitleColor4);

	//=================================================================================

	Title5 = UWindowHSliderControl(CreateControl(Class'UWindowHSliderControl',20.0,351.0,WinWidth - 350,200.0));
	Title5.SetText("Player Title Color");
	Title5.SetRange(0,10,1);
	Title5.bAcceptsFocus=False;
	Title5.SetValue(Config.PlayerTitleColor);
	Title5.SetFont(F_Normal);
	Title5.Align = TA_Left;
	Title5.SetTextColor(C);

	TitleText5 = UWindowLabelControl(CreateControl(Class'UWindowLabelControl',360.0,351.0,WinWidth - 0,0.0));
	TitleText5.Align = TA_Left;
	TitleText5.SetText(Config.GetNameOfPlayerTitleColor());
	TitleText5.SetTextColor(C);

	lblMLT5 = UMenuLabelControl(CreateControl(Class'UMenuLabelControl',469.0,351.0,WinWidth - 500,200.0));
	lblMLT5.SetFont(1);
	lblMLT5.SetText("Player");
	lblMLT5.Align=TA_Left;
	lblMLT5.SetTextColor(TitleColor5);

	//=================================================================================

	Title6 = UWindowHSliderControl(CreateControl(Class'UWindowHSliderControl',20.0,375.0,WinWidth - 350,200.0));
	Title6.SetText("Map Vote Title Color");
	Title6.SetRange(0,10,1);
	Title6.bAcceptsFocus=False;
	Title6.SetValue(Config.MapVoteTitleColor);
	Title6.SetFont(F_Normal);
	Title6.Align = TA_Left;
	Title6.SetTextColor(C);

	TitleText6 = UWindowLabelControl(CreateControl(Class'UWindowLabelControl',360.0,375.0,WinWidth - 0,0.0));
	TitleText6.Align = TA_Left;
	TitleText6.SetText(Config.GetNameOfMapVoteTitleColor());
	TitleText6.SetTextColor(C);

	lblMLT6 = UMenuLabelControl(CreateControl(Class'UMenuLabelControl',469.0,375.0,WinWidth - 500,200.0));
	lblMLT6.SetFont(1);
	lblMLT6.SetText("Map Vote");
	lblMLT6.Align=TA_Left;
	lblMLT6.SetTextColor(TitleColor6);

	//=================================================================================
	lblHMT2 = UMenuLabelControl(CreateControl(Class'UMenuLabelControl',145.0,395.0,WinWidth - 400,200.0));
	lblHMT2.SetText("(Press the Close button to apply these changes)");
	lblHMT2.SetTextColor(C);
	//=================================================================================

	lblMS = UMenuLabelControl(CreateControl(Class'UMenuLabelControl',10.0,410.0,150.0,20.0));
	lblMS.SetText("Misc");
	lblMS.SetTextColor(C);

	sldMsgTimeOut = UWindowHSliderControl(CreateControl(Class'UWindowHSliderControl',20.0,457.0,WinWidth - 350,200.0));
	sldMsgTimeOut.bAcceptsFocus=False;
	sldMsgTimeOut.SetRange(3,60,1);
	sldMsgTimeOut.SetText("Adjust Message Expiration Time");
	sldMsgTimeOut.SetTextColor(C);
	sldMsgTimeOut.SetValue(Config.MsgTimeOut);

	lblMsgTimeOut = UMenuLabelControl(CreateControl(Class'UMenuLabelControl',360.0,457.0,WinWidth - 0,0.0));
	lblMsgTimeOut.SetText(string(int(sldMsgTimeOut.Value)) $ " sec");
	lblMsgTimeOut.SetTextColor(C);

	cbUseMsgTimeout = UWindowCheckbox(CreateControl(Class'UWindowCheckbox',177.0,437.0,100.0,20.0));
	cbUseMsgTimeout.bAcceptsFocus=False;
	cbUseMsgTimeout.SetText("Change Message Expiration Time");
	cbUseMsgTimeout.SetTextColor(C);
	cbUseMsgTimeout.SetFont(0);
	cbUseMsgTimeout.Align=TA_Right;
	cbUseMsgTimeout.SetSize(170.00,1.00);
	cbUseMsgTimeout.bChecked=Config.bUseMsgTimeout;

/*
	bStartupLogo = UWindowCheckbox(CreateControl(Class'UWindowCheckbox',689.00,600,110.00,20.00));
	bStartupLogo.bAcceptsFocus=False;
	bStartupLogo.SetText("Show Startup Logo");
	bStartupLogo.SetTextColor(C);
	bStartupLogo.SetFont(0);
	bStartupLogo.Align=TA_Right;
	bStartupLogo.bChecked=Config.bStartupLogo;
*/
	CloseButton = UWindowSmallButton(CreateControl(Class'UWindowSmallButton',570.0,480.0,80.0,10.0));
	CloseButton.Text="Close";
	//CloseButton.DownSound=Sound'WindowClose';

	LoadExistingKeys();
	SetAcceptsFocus();
}

function Notify(UWindowDialogControl C, byte E)
{
	switch(E)
	{
		case DE_Click:
			switch(C)
			{
		   		case ButMenuKey:
		   			if(ButMenuKey != None)
		   			{
	    				bMenu = True;
	        			ButMenuKey.bDisabled = True;
	        			DisplayInfo();
	        		}
	        	break;	

				case CloseButton:
					ParentWindow.ParentWindow.ParentWindow.Close();
				break;
			}
			break;

		case DE_Change: // the message sent by sliders and checkboxes
			switch(C) 
			{
				case RSlider:
					if(RSlider != None)
					{
						Config.BackgroundColor.R = RSlider.GetValue();
						Config.SaveConfig();
					}
					break;

				case GSlider:
					if(GSlider != None)
					{
						Config.BackgroundColor.G = GSlider.GetValue();
						Config.SaveConfig();
					}
					break;

				case BSlider:
					if(BSlider != None)
					{
						Config.BackgroundColor.B = BSlider.GetValue();
						Config.SaveConfig();
					}
					break;

				case RBSlider:
					if(RBSlider != None)
					{
						Config.BoxesColor.R = RBSlider.GetValue();
						Config.SaveConfig();
					}
					break;

				case GBSlider:
					if(GBSlider != None)
					{
						Config.BoxesColor.G = GBSlider.GetValue();
						Config.SaveConfig();
					}
					break;

				case BBSlider:
					if(BBSlider != None)
					{
						Config.BoxesColor.B = BBSlider.GetValue();
						Config.SaveConfig();
					}
					break;

				case BXT:
					if(BXT != None && BXTL != None && lblBXT != None)
					{
						Config.BoxesTextColor = int(BXT.GetValue());
						Config.SaveConfig();
						BXTL.SetText(Config.GetNameOfBoxesTextColor());
						lblBXT.SetTextColor(Config.GetColorOfBoxesTextColor());
					}
					break;

				case Title1:
					if(Title1 != None && TitleText1 != None && lblMLT1 != None)
					{
						Config.GameModTitleColor = int(Title1.GetValue());
						Config.SaveConfig();				
						TitleText1.SetText(Config.GetNameOfGameModTitleColor());
						lblMLT1.SetTextColor(Config.GetColorOfGameModTitleColor());
					}
					break;

				case Title2:
					if(Title2 != None && TitleText2 != None && lblMLT2 != None)
					{
						Config.RuleTitleColor = int(Title2.GetValue());
						Config.SaveConfig();				
						TitleText2.SetText(Config.GetNameOfRuleTitleColor());
						lblMLT2.SetTextColor(Config.GetColorOfRuleTitleColor());
					}
					break;

				case Title3:
					if(Title3 != None && TitleText3 != None && lblMLT3 != None)
					{
						Config.MapTitleColor = int(Title3.GetValue());
						Config.SaveConfig();					
						TitleText3.SetText(Config.GetNameOfMapTitleColor());
						lblMLT3.SetTextColor(Config.GetColorOfMapTitleColor());	
					}
					break;

				case Title4:
					if(Title4 != None && TitleText4 != None && lblMLT4 != None)
					{
						Config.KickVoteTitleColor = int(Title4.GetValue());
						Config.SaveConfig();				
						TitleText4.SetText(Config.GetNameOfKickVoteTitleColor());
						lblMLT4.SetTextColor(Config.GetColorOfKickVoteTitleColor());
					}
					break;

				case Title5:
					if(Title5 != None && TitleText5 != None && lblMLT5 != None)
					{
						Config.PlayerTitleColor = int(Title5.GetValue());
						Config.SaveConfig();								
						TitleText5.SetText(Config.GetNameOfPlayerTitleColor());
						lblMLT5.SetTextColor(Config.GetColorOfPlayerTitleColor());
					}
					break;

				case Title6:
					if(Title6 != None && TitleText6 != None && lblMLT6 != None)
					{
						Config.MapVoteTitleColor = int(Title6.GetValue());
						Config.SaveConfig();								
						TitleText6.SetText(Config.GetNameOfMapVoteTitleColor());
						lblMLT6.SetTextColor(Config.GetColorOfMapVoteTitleColor());
					}
					break;

				case sldMsgTimeOut:
					if ( sldMsgTimeOut != None && lblMsgTimeOut != None )
					{
						lblMsgTimeOut.SetText(string(int(sldMsgTimeOut.Value)) $ " sec");
						Config.MsgTimeOut = sldMsgTimeOut.GetValue();
						Config.SaveConfig();						
					}
					break;
			}
			break;
	}

	Super.Notify(C,E);
}

function LoadExistingKeys ()
{
	local int i;
	local string KeyName, Alias;

	for ( i=0; i<255; i++ )
	{
		KeyName=GetPlayerOwner().ConsoleCommand("KEYNAME " $ string(i));
		RealKeyName[i]=KeyName;
		if ( KeyName != "" )
		{
			Alias=GetPlayerOwner().ConsoleCommand("KEYBINDING " $ KeyName);
			if ( Caps(Alias) == "MUTATE BDBMAPVOTE VOTEMENU" )
			{
				ButMenuKey.SetText(KeyName);
				OldMenuKey=KeyName;
			}
		}
	}
}

function KeyDown( int Key, float X, float Y )
{
	ProcessKey(Key, RealKeyName[Key]);

	bMenu = False;
	ButMenuKey.bDisabled = False;

	lblKeyBind.SetText("");
	ParentWindow.KeyDown(Key,X,Y);
}

function DisplayInfo()
{
	lblKeyBind.SetText("Press a Key");
}

function ProcessKey( int KeyNo, string KeyName )
{
    if ( KeyName == "" || KeyName == "Escape" || KeyNo >= 112 && KeyNo <= 117 || KeyNo >= 120 && KeyNo <= 123 || KeyNo >= 48 && KeyNo <= 57 )
	{
		return;
	}

    if (bMenu)
    {
    	SetMenuKey(KeyNo, KeyName);
       	return;
    }
}

function SetMenuKey(int KeyNo, string KeyName)
{
	GetPlayerOwner().ConsoleCommand("SET Input "$KeyName$" mutate bdbmapvote votemenu");
	ButMenuKey.SetText(KeyName);
	if(OldMenuKey != "" && OldMenuKey != KeyName)
	{
		GetPlayerOwner().ConsoleCommand("SET Input "$OldMenuKey);
	}
}

function Close (optional bool bByParent)
{
	SaveMapVoteConfig();
	Super.Close(bByParent);
}

function SaveMapVoteConfig ()
{
	local bool bSaveNeeded;

	if ( (sldMsgTimeOut == None) || (cbUseMsgTimeout == None) )
	{
		return;
	}
	bSaveNeeded=(Config.MsgTimeOut != sldMsgTimeOut.Value) || (Config.bUseMsgTimeout != cbUseMsgTimeout.bChecked);
	if ( bSaveNeeded )
	{
		Config.MsgTimeOut=int(sldMsgTimeOut.Value);
		Config.bUseMsgTimeout=cbUseMsgTimeout.bChecked;
		Config.SaveConfig();
	}
	if ( Config.bUseMsgTimeout )
	{
		Class'SayMessagePlus'.Default.Lifetime=Config.MsgTimeOut;
		Class'CriticalStringPlus'.Default.Lifetime=Config.MsgTimeOut;
		Class'RedSayMessagePlus'.Default.Lifetime=Config.MsgTimeOut;
		Class'TeamSayMessagePlus'.Default.Lifetime=Config.MsgTimeOut;
		Class'StringMessagePlus'.Default.Lifetime=Config.MsgTimeOut;
		Class'DeathMessagePlus'.Default.Lifetime=Config.MsgTimeOut;
	}
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
      CloseButton=None
      lblKeyBind=None
      lblMenuKey=None
      ButMenuKey=None
      OldMenuKey=""
      bMenu=False
      RSlider=None
      GSlider=None
      BSlider=None
      RBSlider=None
      GBSlider=None
      BBSlider=None
      BXT=None
      Title1=None
      Title2=None
      Title3=None
      Title4=None
      Title5=None
      Title6=None
      sldMsgTimeOut=None
      BXTL=None
      TitleText1=None
      TitleText2=None
      TitleText3=None
      TitleText4=None
      TitleText5=None
      TitleText6=None
      lblMLT1=None
      lblMLT2=None
      lblMLT3=None
      lblMLT4=None
      lblMLT5=None
      lblMLT6=None
      lblMT=None
      lblBXT=None
      lblBG=None
      lblHMT=None
      lblHMT2=None
      lblMS=None
      lblMsgTimeOut=None
      bSliderInited=False
      cbUseMsgTimeout=None
}
