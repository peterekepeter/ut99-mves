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
//var UWindowCheckbox bStartupLogo;

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

function Paint (Canvas C, float MouseX, float MouseY)
{
	Super.Paint(C,MouseX,MouseY);
	C.DrawColor = Class'MapVoteClientConfig'.Default.BackgroundColor;
	DrawStretchedTexture(C,0.0,0.0,WinWidth,WinHeight,Texture'BackgroundTexture');
	C.DrawColor.R = 0;
	C.DrawColor.G = 255;
	C.DrawColor.B = 0;
	DrawStretchedTexture(C,10.0,25.0,635.0,2.0,Texture'ListsBoxBackground');
	DrawStretchedTexture(C,10.0,120.0,635.0,2.0,Texture'ListsBoxBackground');
	DrawStretchedTexture(C,10.0,240.0,635.0,2.0,Texture'ListsBoxBackground');
	//DrawStretchedTexture(C,10.0,300.0,635.0,2.0,Texture'ListsBoxBackground');
	DrawStretchedTexture(C,10.0,420.0,635.0,2.0,Texture'ListsBoxBackground');
	C.DrawColor = Class'MapVoteClientConfig'.Default.BoxesColor;
	DrawStretchedTexture(C,468.5,170.661,100.0,20.0,Texture'ListsBoxBackground');
}

function Created()
{
	local Color C, BXTC, TitleColor, TitleColor1, TitleColor2, TitleColor3, TitleColor4, TitleColor5, TitleColor6;

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

	if(Class'MapVoteClientConfig'.default.GameModTitleColor == 0)
		TitleColor1 = RedColor;
	else if(Class'MapVoteClientConfig'.default.GameModTitleColor == 1)
		TitleColor1 = PurpleColor;
	else if(Class'MapVoteClientConfig'.default.GameModTitleColor == 2)
		TitleColor1 = LightBlueColor;
	else if(Class'MapVoteClientConfig'.default.GameModTitleColor == 3)
		TitleColor1 = TurquoiseColor;
	else if(Class'MapVoteClientConfig'.default.GameModTitleColor == 4)
		TitleColor1 = GreenColor;
	else if(Class'MapVoteClientConfig'.default.GameModTitleColor == 5)
		TitleColor1 = OrangeColor;
	else if(Class'MapVoteClientConfig'.default.GameModTitleColor == 6)
		TitleColor1 = YellowColor;
	else if(Class'MapVoteClientConfig'.default.GameModTitleColor == 7)
		TitleColor1 = PinkColor;
	else if(Class'MapVoteClientConfig'.default.GameModTitleColor == 8)
		TitleColor1 = WhiteColor;
	else if(Class'MapVoteClientConfig'.default.GameModTitleColor == 9)
		TitleColor1 = DeepBlueColor;
	else if(Class'MapVoteClientConfig'.default.GameModTitleColor == 10)
		TitleColor1 = BlackColor;

	if(Class'MapVoteClientConfig'.default.RuleTitleColor == 0)
		TitleColor2 = RedColor;
	else if(Class'MapVoteClientConfig'.default.RuleTitleColor == 1)
		TitleColor2 = PurpleColor;
	else if(Class'MapVoteClientConfig'.default.RuleTitleColor == 2)
		TitleColor2 = LightBlueColor;
	else if(Class'MapVoteClientConfig'.default.RuleTitleColor == 3)
		TitleColor2 = TurquoiseColor;
	else if(Class'MapVoteClientConfig'.default.RuleTitleColor == 4)
		TitleColor2 = GreenColor;
	else if(Class'MapVoteClientConfig'.default.RuleTitleColor == 5)
		TitleColor2 = OrangeColor;
	else if(Class'MapVoteClientConfig'.default.RuleTitleColor == 6)
		TitleColor2 = YellowColor;
	else if(Class'MapVoteClientConfig'.default.RuleTitleColor == 7)
		TitleColor2 = PinkColor;
	else if(Class'MapVoteClientConfig'.default.RuleTitleColor == 8)
		TitleColor2 = WhiteColor;
	else if(Class'MapVoteClientConfig'.default.RuleTitleColor == 9)
		TitleColor2 = DeepBlueColor;
	else if(Class'MapVoteClientConfig'.default.RuleTitleColor == 10)
		TitleColor2 = BlackColor;

	if(Class'MapVoteClientConfig'.default.MapTitleColor == 0)
		TitleColor3 = RedColor;
	else if(Class'MapVoteClientConfig'.default.MapTitleColor == 1)
		TitleColor3 = PurpleColor;
	else if(Class'MapVoteClientConfig'.default.MapTitleColor == 2)
		TitleColor3 = LightBlueColor;
	else if(Class'MapVoteClientConfig'.default.MapTitleColor == 3)
		TitleColor3 = TurquoiseColor;
	else if(Class'MapVoteClientConfig'.default.MapTitleColor == 4)
		TitleColor3 = GreenColor;
	else if(Class'MapVoteClientConfig'.default.MapTitleColor == 5)
		TitleColor3 = OrangeColor;
	else if(Class'MapVoteClientConfig'.default.MapTitleColor == 6)
		TitleColor3 = YellowColor;
	else if(Class'MapVoteClientConfig'.default.MapTitleColor == 7)
		TitleColor3 = PinkColor;
	else if(Class'MapVoteClientConfig'.default.MapTitleColor == 8)
		TitleColor3 = WhiteColor;
	else if(Class'MapVoteClientConfig'.default.MapTitleColor == 9)
		TitleColor3 = DeepBlueColor;
	else if(Class'MapVoteClientConfig'.default.MapTitleColor == 10)
		TitleColor3 = BlackColor;

	if(Class'MapVoteClientConfig'.default.KickVoteTitleColor == 0)
		TitleColor4 = RedColor;
	else if(Class'MapVoteClientConfig'.default.KickVoteTitleColor == 1)
		TitleColor4 = PurpleColor;
	else if(Class'MapVoteClientConfig'.default.KickVoteTitleColor == 2)
		TitleColor4 = LightBlueColor;
	else if(Class'MapVoteClientConfig'.default.KickVoteTitleColor == 3)
		TitleColor4 = TurquoiseColor;
	else if(Class'MapVoteClientConfig'.default.KickVoteTitleColor == 4)
		TitleColor4 = GreenColor;
	else if(Class'MapVoteClientConfig'.default.KickVoteTitleColor == 5)
		TitleColor4 = OrangeColor;
	else if(Class'MapVoteClientConfig'.default.KickVoteTitleColor == 6)
		TitleColor4 = YellowColor;
	else if(Class'MapVoteClientConfig'.default.KickVoteTitleColor == 7)
		TitleColor4 = PinkColor;
	else if(Class'MapVoteClientConfig'.default.KickVoteTitleColor == 8)
		TitleColor4 = WhiteColor;
	else if(Class'MapVoteClientConfig'.default.KickVoteTitleColor == 9)
		TitleColor4 = DeepBlueColor;
	else if(Class'MapVoteClientConfig'.default.KickVoteTitleColor == 10)
		TitleColor4 = BlackColor;

	if(Class'MapVoteClientConfig'.default.PlayerTitleColor == 0)
		TitleColor5 = RedColor;
	else if(Class'MapVoteClientConfig'.default.PlayerTitleColor == 1)
		TitleColor5 = PurpleColor;
	else if(Class'MapVoteClientConfig'.default.PlayerTitleColor == 2)
		TitleColor5 = LightBlueColor;
	else if(Class'MapVoteClientConfig'.default.PlayerTitleColor == 3)
		TitleColor5 = TurquoiseColor;
	else if(Class'MapVoteClientConfig'.default.PlayerTitleColor == 4)
		TitleColor5 = GreenColor;
	else if(Class'MapVoteClientConfig'.default.PlayerTitleColor == 5)
		TitleColor5 = OrangeColor;
	else if(Class'MapVoteClientConfig'.default.PlayerTitleColor == 6)
		TitleColor5 = YellowColor;
	else if(Class'MapVoteClientConfig'.default.PlayerTitleColor == 7)
		TitleColor5 = PinkColor;
	else if(Class'MapVoteClientConfig'.default.PlayerTitleColor == 8)
		TitleColor5 = WhiteColor;
	else if(Class'MapVoteClientConfig'.default.PlayerTitleColor == 9)
		TitleColor5 = DeepBlueColor;
	else if(Class'MapVoteClientConfig'.default.PlayerTitleColor == 10)
		TitleColor5 = BlackColor;

	if(Class'MapVoteClientConfig'.default.MapVoteTitleColor == 0)
		TitleColor6 = RedColor;
	else if(Class'MapVoteClientConfig'.default.MapVoteTitleColor == 1)
		TitleColor6 = PurpleColor;
	else if(Class'MapVoteClientConfig'.default.MapVoteTitleColor == 2)
		TitleColor6 = LightBlueColor;
	else if(Class'MapVoteClientConfig'.default.MapVoteTitleColor == 3)
		TitleColor6 = TurquoiseColor;
	else if(Class'MapVoteClientConfig'.default.MapVoteTitleColor == 4)
		TitleColor6 = GreenColor;
	else if(Class'MapVoteClientConfig'.default.MapVoteTitleColor == 5)
		TitleColor6 = OrangeColor;
	else if(Class'MapVoteClientConfig'.default.MapVoteTitleColor == 6)
		TitleColor6 = YellowColor;
	else if(Class'MapVoteClientConfig'.default.MapVoteTitleColor == 7)
		TitleColor6 = PinkColor;
	else if(Class'MapVoteClientConfig'.default.MapVoteTitleColor == 8)
		TitleColor6 = WhiteColor;
	else if(Class'MapVoteClientConfig'.default.MapVoteTitleColor == 9)
		TitleColor6 = DeepBlueColor;
	else if(Class'MapVoteClientConfig'.default.MapVoteTitleColor == 10)
		TitleColor6 = BlackColor;

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
	RSlider.SetValue(Class'MapVoteClientConfig'.default.BackgroundColor.R);
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
	GSlider.SetValue(Class'MapVoteClientConfig'.default.BackgroundColor.G);
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
	BSlider.SetValue(Class'MapVoteClientConfig'.default.BackgroundColor.B);
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
	RBSlider.SetValue(Class'MapVoteClientConfig'.default.BoxesColor.R);
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
	GBSlider.SetValue(Class'MapVoteClientConfig'.default.BoxesColor.G);
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
	BBSlider.SetValue(Class'MapVoteClientConfig'.default.BoxesColor.B);
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
	BXT.SetValue(Class'MapVoteClientConfig'.default.BoxesTextColor);
	BXT.SetFont(F_Normal);
	BXT.Align = TA_Left;
	BXT.SetTextColor(C);

	BXTL = UWindowLabelControl(CreateControl(Class'UWindowLabelControl',360.0,195.0,WinWidth - 0,0.0));
	BXTL.Align = TA_Left;
	BXTL.SetText(ColorCol[int(BXT.value)]);
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
	Title1.SetValue(Class'MapVoteClientConfig'.default.GameModTitleColor);
	Title1.SetFont(F_Normal);
	Title1.Align = TA_Left;
	Title1.SetTextColor(C);

	TitleText1 = UWindowLabelControl(CreateControl(Class'UWindowLabelControl',360.0,255.0,WinWidth - 0,0.0));
	TitleText1.Align = TA_Left;
	TitleText1.SetText(ColorCol[int(Title1.value)]);
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
	Title2.SetValue(Class'MapVoteClientConfig'.default.RuleTitleColor);
	Title2.SetFont(F_Normal);
	Title2.Align = TA_Left;
	Title2.SetTextColor(C);

	TitleText2 = UWindowLabelControl(CreateControl(Class'UWindowLabelControl',360.0,279.0,WinWidth - 0,0.0));
	TitleText2.Align = TA_Left;
	TitleText2.SetText(ColorCol[int(Title2.value)]);
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
	Title3.SetValue(Class'MapVoteClientConfig'.default.MapTitleColor);
	Title3.SetFont(F_Normal);
	Title3.Align = TA_Left;
	Title3.SetTextColor(C);

	TitleText3 = UWindowLabelControl(CreateControl(Class'UWindowLabelControl',360.0,303.0,WinWidth - 0,0.0));
	TitleText3.Align = TA_Left;
	TitleText3.SetText(ColorCol[int(Title3.value)]);
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
	Title4.SetValue(Class'MapVoteClientConfig'.default.KickVoteTitleColor);
	Title4.SetFont(F_Normal);
	Title4.Align = TA_Left;
	Title4.SetTextColor(C);

	TitleText4 = UWindowLabelControl(CreateControl(Class'UWindowLabelControl',360.0,327.0,WinWidth - 0,0.0));
	TitleText4.Align = TA_Left;
	TitleText4.SetText(ColorCol[int(Title4.value)]);
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
	Title5.SetValue(Class'MapVoteClientConfig'.default.PlayerTitleColor);
	Title5.SetFont(F_Normal);
	Title5.Align = TA_Left;
	Title5.SetTextColor(C);

	TitleText5 = UWindowLabelControl(CreateControl(Class'UWindowLabelControl',360.0,351.0,WinWidth - 0,0.0));
	TitleText5.Align = TA_Left;
	TitleText5.SetText(ColorCol[int(Title5.value)]);
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
	Title6.SetValue(Class'MapVoteClientConfig'.default.MapVoteTitleColor);
	Title6.SetFont(F_Normal);
	Title6.Align = TA_Left;
	Title6.SetTextColor(C);

	TitleText6 = UWindowLabelControl(CreateControl(Class'UWindowLabelControl',360.0,375.0,WinWidth - 0,0.0));
	TitleText6.Align = TA_Left;
	TitleText6.SetText(ColorCol[int(Title6.value)]);
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
	sldMsgTimeOut.SetValue(Class'MapVoteClientConfig'.Default.MsgTimeOut);

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
	cbUseMsgTimeout.bChecked=Class'MapVoteClientConfig'.Default.bUseMsgTimeout;

/*
	bStartupLogo = UWindowCheckbox(CreateControl(Class'UWindowCheckbox',689.00,600,110.00,20.00));
	bStartupLogo.bAcceptsFocus=False;
	bStartupLogo.SetText("Show Startup Logo");
	bStartupLogo.SetTextColor(C);
	bStartupLogo.SetFont(0);
	bStartupLogo.Align=TA_Right;
	bStartupLogo.bChecked=Class'MapVoteClientConfig'.default.bStartupLogo;
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
						Class'MapVoteClientConfig'.default.BackgroundColor.R = RSlider.GetValue();
						Class'MapVoteClientConfig'.static.StaticSaveConfig();
					}
					break;

				case GSlider:
					if(GSlider != None)
					{
						Class'MapVoteClientConfig'.default.BackgroundColor.G = GSlider.GetValue();
						Class'MapVoteClientConfig'.static.StaticSaveConfig();
					}
					break;

				case BSlider:
					if(BSlider != None)
					{
						Class'MapVoteClientConfig'.default.BackgroundColor.B = BSlider.GetValue();
						Class'MapVoteClientConfig'.static.StaticSaveConfig();
					}
					break;

				case RBSlider:
					if(RBSlider != None)
					{
						Class'MapVoteClientConfig'.default.BoxesColor.R = RBSlider.GetValue();
						Class'MapVoteClientConfig'.static.StaticSaveConfig();
					}
					break;

				case GBSlider:
					if(GBSlider != None)
					{
						Class'MapVoteClientConfig'.default.BoxesColor.G = GBSlider.GetValue();
						Class'MapVoteClientConfig'.static.StaticSaveConfig();
					}
					break;

				case BBSlider:
					if(BBSlider != None)
					{
						Class'MapVoteClientConfig'.default.BoxesColor.B = BBSlider.GetValue();
						Class'MapVoteClientConfig'.static.StaticSaveConfig();
					}
					break;

				case BXT:
					if(BXT != None && BXTL != None && lblBXT != None)
					{
						BXTL.SetText(ColorCol[int(BXT.value)]);
						if(BXT.Value == 0)
							lblBXT.SetTextColor(RedColor);
						else if(BXT.Value == 1)
							lblBXT.SetTextColor(PurpleColor);
						else if(BXT.Value == 2)
							lblBXT.SetTextColor(LightBlueColor);
						else if(BXT.Value == 3)
							lblBXT.SetTextColor(TurquoiseColor);
						else if(BXT.Value == 4)
							lblBXT.SetTextColor(GreenColor);
						else if(BXT.Value == 5)
							lblBXT.SetTextColor(OrangeColor);
						else if(BXT.Value == 6)
							lblBXT.SetTextColor(YellowColor);
						else if(BXT.Value == 7)
							lblBXT.SetTextColor(PinkColor);
						else if(BXT.Value == 8)
							lblBXT.SetTextColor(WhiteColor);
						else if(BXT.Value == 9)
							lblBXT.SetTextColor(DeepBlueColor);
						else if(BXT.Value == 10)
							lblBXT.SetTextColor(BlackColor);
						Class'MapVoteClientConfig'.default.BoxesTextColor = int(BXT.GetValue());
						Class'MapVoteClientConfig'.static.StaticSaveConfig();
					}
					break;

				case Title1:
					if(Title1 != None && TitleText1 != None && lblMLT1 != None)
					{
						TitleText1.SetText(ColorCol[int(Title1.value)]);
						if(Title1.Value == 0)
							lblMLT1.SetTextColor(RedColor);
						else if(Title1.Value == 1)
							lblMLT1.SetTextColor(PurpleColor);
						else if(Title1.Value == 2)
							lblMLT1.SetTextColor(LightBlueColor);
						else if(Title1.Value == 3)
							lblMLT1.SetTextColor(TurquoiseColor);
						else if(Title1.Value == 4)
							lblMLT1.SetTextColor(GreenColor);
						else if(Title1.Value == 5)
							lblMLT1.SetTextColor(OrangeColor);
						else if(Title1.Value == 6)
							lblMLT1.SetTextColor(YellowColor);
						else if(Title1.Value == 7)
							lblMLT1.SetTextColor(PinkColor);
						else if(Title1.Value == 8)
							lblMLT1.SetTextColor(WhiteColor);
						else if(Title1.Value == 9)
							lblMLT1.SetTextColor(DeepBlueColor);
						else if(Title1.Value == 10)
							lblMLT1.SetTextColor(BlackColor);
						Class'MapVoteClientConfig'.default.GameModTitleColor = int(Title1.GetValue());
						Class'MapVoteClientConfig'.static.StaticSaveConfig();						
					}
					break;

				case Title2:
					if(Title2 != None && TitleText2 != None && lblMLT2 != None)
					{
						TitleText2.SetText(ColorCol[int(Title2.value)]);
						if(Title2.Value == 0)
							lblMLT2.SetTextColor(RedColor);
						else if(Title2.Value == 1)
							lblMLT2.SetTextColor(PurpleColor);
						else if(Title2.Value == 2)
							lblMLT2.SetTextColor(LightBlueColor);
						else if(Title2.Value == 3)
							lblMLT2.SetTextColor(TurquoiseColor);
						else if(Title2.Value == 4)
							lblMLT2.SetTextColor(GreenColor);
						else if(Title2.Value == 5)
							lblMLT2.SetTextColor(OrangeColor);
						else if(Title2.Value == 6)
							lblMLT2.SetTextColor(YellowColor);
						else if(Title2.Value == 7)
							lblMLT2.SetTextColor(PinkColor);
						else if(Title2.Value == 8)
							lblMLT2.SetTextColor(WhiteColor);
						else if(Title2.Value == 9)
							lblMLT2.SetTextColor(DeepBlueColor);
						else if(Title2.Value == 10)
							lblMLT2.SetTextColor(BlackColor);
						Class'MapVoteClientConfig'.default.RuleTitleColor = int(Title2.GetValue());
						Class'MapVoteClientConfig'.static.StaticSaveConfig();						
					}
					break;

				case Title3:
					if(Title3 != None && TitleText3 != None && lblMLT3 != None)
					{
						TitleText3.SetText(ColorCol[int(Title3.value)]);
						if(Title3.Value == 0)
							lblMLT3.SetTextColor(RedColor);
						else if(Title3.Value == 1)
							lblMLT3.SetTextColor(PurpleColor);
						else if(Title3.Value == 2)
							lblMLT3.SetTextColor(LightBlueColor);
						else if(Title3.Value == 3)
							lblMLT3.SetTextColor(TurquoiseColor);
						else if(Title3.Value == 4)
							lblMLT3.SetTextColor(GreenColor);
						else if(Title3.Value == 5)
							lblMLT3.SetTextColor(OrangeColor);
						else if(Title3.Value == 6)
							lblMLT3.SetTextColor(YellowColor);
						else if(Title3.Value == 7)
							lblMLT3.SetTextColor(PinkColor);
						else if(Title3.Value == 8)
							lblMLT3.SetTextColor(WhiteColor);
						else if(Title3.Value == 9)
							lblMLT3.SetTextColor(DeepBlueColor);
						else if(Title3.Value == 10)
							lblMLT3.SetTextColor(BlackColor);
						Class'MapVoteClientConfig'.default.MapTitleColor = int(Title3.GetValue());
						Class'MapVoteClientConfig'.static.StaticSaveConfig();						
					}
					break;

				case Title4:
					if(Title4 != None && TitleText4 != None && lblMLT4 != None)
					{
						TitleText4.SetText(ColorCol[int(Title4.value)]);
						if(Title4.Value == 0)
							lblMLT4.SetTextColor(RedColor);
						else if(Title4.Value == 1)
							lblMLT4.SetTextColor(PurpleColor);
						else if(Title4.Value == 2)
							lblMLT4.SetTextColor(LightBlueColor);
						else if(Title4.Value == 3)
							lblMLT4.SetTextColor(TurquoiseColor);
						else if(Title4.Value == 4)
							lblMLT4.SetTextColor(GreenColor);
						else if(Title4.Value == 5)
							lblMLT4.SetTextColor(OrangeColor);
						else if(Title4.Value == 6)
							lblMLT4.SetTextColor(YellowColor);
						else if(Title4.Value == 7)
							lblMLT4.SetTextColor(PinkColor);
						else if(Title4.Value == 8)
							lblMLT4.SetTextColor(WhiteColor);
						else if(Title4.Value == 9)
							lblMLT4.SetTextColor(DeepBlueColor);
						else if(Title4.Value == 10)
							lblMLT4.SetTextColor(BlackColor);
						Class'MapVoteClientConfig'.default.KickVoteTitleColor = int(Title4.GetValue());
						Class'MapVoteClientConfig'.static.StaticSaveConfig();						
					}
					break;

				case Title5:
					if(Title5 != None && TitleText5 != None && lblMLT5 != None)
					{
						TitleText5.SetText(ColorCol[int(Title5.value)]);
						if(Title5.Value == 0)
							lblMLT5.SetTextColor(RedColor);
						else if(Title5.Value == 1)
							lblMLT5.SetTextColor(PurpleColor);
						else if(Title5.Value == 2)
							lblMLT5.SetTextColor(LightBlueColor);
						else if(Title5.Value == 3)
							lblMLT5.SetTextColor(TurquoiseColor);
						else if(Title5.Value == 4)
							lblMLT5.SetTextColor(GreenColor);
						else if(Title5.Value == 5)
							lblMLT5.SetTextColor(OrangeColor);
						else if(Title5.Value == 6)
							lblMLT5.SetTextColor(YellowColor);
						else if(Title5.Value == 7)
							lblMLT5.SetTextColor(PinkColor);
						else if(Title5.Value == 8)
							lblMLT5.SetTextColor(WhiteColor);
						else if(Title5.Value == 9)
							lblMLT5.SetTextColor(DeepBlueColor);
						else if(Title5.Value == 10)
							lblMLT5.SetTextColor(BlackColor);
						Class'MapVoteClientConfig'.default.PlayerTitleColor = int(Title5.GetValue());
						Class'MapVoteClientConfig'.static.StaticSaveConfig();						
					}
					break;

				case Title6:
					if(Title6 != None && TitleText6 != None && lblMLT6 != None)
					{
						TitleText6.SetText(ColorCol[int(Title6.value)]);
						if(Title6.Value == 0)
							lblMLT6.SetTextColor(RedColor);
						else if(Title6.Value == 1)
							lblMLT6.SetTextColor(PurpleColor);
						else if(Title6.Value == 2)
							lblMLT6.SetTextColor(LightBlueColor);
						else if(Title6.Value == 3)
							lblMLT6.SetTextColor(TurquoiseColor);
						else if(Title6.Value == 4)
							lblMLT6.SetTextColor(GreenColor);
						else if(Title6.Value == 5)
							lblMLT6.SetTextColor(OrangeColor);
						else if(Title6.Value == 6)
							lblMLT6.SetTextColor(YellowColor);
						else if(Title6.Value == 7)
							lblMLT6.SetTextColor(PinkColor);
						else if(Title6.Value == 8)
							lblMLT6.SetTextColor(WhiteColor);
						else if(Title6.Value == 9)
							lblMLT6.SetTextColor(DeepBlueColor);
						else if(Title6.Value == 10)
							lblMLT6.SetTextColor(BlackColor);
						Class'MapVoteClientConfig'.default.MapVoteTitleColor = int(Title6.GetValue());
						Class'MapVoteClientConfig'.static.StaticSaveConfig();						
					}
					break;

				case sldMsgTimeOut:
					if ( sldMsgTimeOut != None && lblMsgTimeOut != None )
					{
						lblMsgTimeOut.SetText(string(int(sldMsgTimeOut.Value)) $ " sec");
						Class'MapVoteClientConfig'.Default.MsgTimeOut = sldMsgTimeOut.GetValue();
						Class'MapVoteClientConfig'.static.StaticSaveConfig();
					}
					break;

/*				case bStartupLogo:
					if(bStartupLogo != None)
					{
						class'MapVoteClientConfig'.default.bStartupLogo = bStartupLogo.bChecked;
						class'MapVoteClientConfig'.static.StaticSaveConfig();
					}
					break;
*/
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
	bSaveNeeded=(Class'MapVoteClientConfig'.Default.MsgTimeOut != sldMsgTimeOut.Value) || (Class'MapVoteClientConfig'.Default.bUseMsgTimeout != cbUseMsgTimeout.bChecked);
	if ( bSaveNeeded )
	{
		Class'MapVoteClientConfig'.Default.MsgTimeOut=int(sldMsgTimeOut.Value);
		Class'MapVoteClientConfig'.Default.bUseMsgTimeout=cbUseMsgTimeout.bChecked;
		Class'MapVoteClientConfig'.StaticSaveConfig();
	}
	if ( Class'MapVoteClientConfig'.Default.bUseMsgTimeout )
	{
		Class'SayMessagePlus'.Default.Lifetime=Class'MapVoteClientConfig'.Default.MsgTimeOut;
		Class'CriticalStringPlus'.Default.Lifetime=Class'MapVoteClientConfig'.Default.MsgTimeOut;
		Class'RedSayMessagePlus'.Default.Lifetime=Class'MapVoteClientConfig'.Default.MsgTimeOut;
		Class'TeamSayMessagePlus'.Default.Lifetime=Class'MapVoteClientConfig'.Default.MsgTimeOut;
		Class'StringMessagePlus'.Default.Lifetime=Class'MapVoteClientConfig'.Default.MsgTimeOut;
		Class'DeathMessagePlus'.Default.Lifetime=Class'MapVoteClientConfig'.Default.MsgTimeOut;
	}
}

defaultproperties
{
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
}
