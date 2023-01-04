//================================================================================
// AdminWindow.
//================================================================================
class AdminWindow extends UWindowPageWindow;

var UWindowCheckbox cbLoadDM;
var UWindowCheckbox cbLoadLMS;
var UWindowCheckbox cbLoadTDM;
var UWindowCheckbox cbLoadAS;
var UWindowCheckbox cbLoadDOM;
var UWindowCheckbox cbLoadCTF;
var UWindowCheckbox cbAutoDetect;
var UWindowCheckbox cbCheckOtherGameTie;
var UWindowCheckbox cbReloadMapsOnRequestOnly;
var UWindowCheckbox cbCustGame[100];
var UWindowSmallButton RemoteSaveButton;
var UWindowSmallButton ReloadMapsButton;
var UWindowSmallButton CloseButton;
var UWindowSmallButton ListCrashButton;
var UWindowSmallButton ClearCrashButton;
var UWindowHSliderControl sldVoteTimeLimit;
var UMenuLabelControl lblVoteTimeLimit;
var UWindowHSliderControl sldKickPercent;
var UMenuLabelControl lblKickPercent;
var UWindowEditControl txtRepeatLimit;
var UWindowEditControl txtMinMapCount;
var UWindowHSliderControl sldMidGameVotePercent;
var UWindowComboControl cboMode;
var UWindowEditControl txtServerInfoURL;
var UWindowEditControl txtMapInfoURL;
var UWindowComboControl cboMapVoteHistoryType;
var UMenuLabelControl lblMidGameVotePercent;
var UMenuLabelControl lblGameTypeSection;
var UMenuLabelControl lblMiscSection;
var UMenuLabelControl lblOtherClass;
var UMenuLabelControl lblLimitsLabel;
var UMenuLabelControl lblMapPreFixOverRide;
var UMenuLabelControl lblRepeatLimit;
var UMenuLabelControl lblMinMapCount;
var UMenuLabelControl lblAdvancedSection;
var UMenuLabelControl lblServerInfoURL;
var UMenuLabelControl lblMapInfoURL;
var UMenuLabelControl lblASClass;
var UMenuLabelControl lblActGame;
var UMenuLabelControl lblActPrefix;
var UMenuLabelControl lblCustGame[ArrayCount(cbCustGame)];
var UMenuLabelControl lblTemp;
var UWindowCheckbox cbUseMapList;
var UWindowCheckbox cbAutoOpen;
var UWindowCheckbox cbKickVote;
var UWindowCheckbox cbEntryWindows;
var UWindowHSliderControl sldScoreBoardDelay;
var UMenuLabelControl lblScoreBoardDelay;
var UWindowCheckbox cbSortWithPreFix;
var UWindowCheckbox cbDebugMode;
var UWindowEditControl txtList1Title;
var UWindowEditControl txtList2Title;
var UWindowEditControl txtList3Title;
var UWindowEditControl txtList4Title;
var UWindowEditControl txtMapVoteTitle;
var UWindowEditControl txtList1Priority;
var UWindowEditControl txtList2Priority;
var UWindowEditControl txtList3Priority;
var UWindowEditControl txtList4Priority;
var UWindowEditControl txtASClass;
var UWindowCheckbox cbRemoveCrashedMaps;
var UWindowCheckbox cbUseExcludeFilter;

var MapVoteClientConfig MapVoteClientConfig;

function Created ()
{
	local Color C;
	local int i;
	local int gap;
	local Color TextColor;

	Super.Created();
	TextColor.R = 171;
	TextColor.G = 171;
	TextColor.B = 171;
	DesiredWidth = 600.0;
	DesiredHeight = 500.0;
	gap = 14;
/* 	lblGameTypeSection = UMenuLabelControl(CreateControl(Class'UMenuLabelControl',10.0,10.0,90.0,20.0));
	lblGameTypeSection.SetText("Visual Config");
	lblGameTypeSection.SetTextColor(TextColor);
	cbAutoDetect = UWindowCheckbox(CreateControl(Class'UWindowCheckbox',420.0,30.0,20.0,20.0));
	cbAutoDetect.bAcceptsFocus = False;
	lblTemp = UMenuLabelControl(CreateControl(Class'UMenuLabelControl',440.0,30.0,60.0,20.0));
	lblTemp.SetText("Auto Detect");
	lblTemp.SetTextColor(TextColor);
	cbLoadDM = UWindowCheckbox(CreateControl(Class'UWindowCheckbox',420.0,25.0 + 2 * gap,20.0,20.0));
	lblTemp = UMenuLabelControl(CreateControl(Class'UMenuLabelControl',440.0,25.0 + 2 * gap,60.0,20.0));
	lblTemp.SetText("DM");
	lblTemp.SetTextColor(TextColor);
	cbLoadTDM = UWindowCheckbox(CreateControl(Class'UWindowCheckbox',420.0,25.0 + 3 * gap,20.0,20.0));
	lblTemp = UMenuLabelControl(CreateControl(Class'UMenuLabelControl',440.0,25.0 + 3 * gap,60.0,20.0));
	lblTemp.SetText("TDM");
	lblTemp.SetTextColor(TextColor);
	cbLoadLMS = UWindowCheckbox(CreateControl(Class'UWindowCheckbox',420.0,25.0 + 4 * gap,20.0,20.0));
	lblTemp = UMenuLabelControl(CreateControl(Class'UMenuLabelControl',440.0,25.0 + 4 * gap,60.0,20.0));
	lblTemp.SetText("LMS");
	lblTemp.SetTextColor(TextColor);
	cbLoadCTF = UWindowCheckbox(CreateControl(Class'UWindowCheckbox',420.0,25.0 + 5 * gap,20.0,20.0));
	lblTemp = UMenuLabelControl(CreateControl(Class'UMenuLabelControl',440.0,25.0 + 5 * gap,60.0,20.0));
	lblTemp.SetText("CTF");
	lblTemp.SetTextColor(TextColor);
	cbLoadDOM = UWindowCheckbox(CreateControl(Class'UWindowCheckbox',420.0,25.0 + 6 * gap,20.0,20.0));
	lblTemp = UMenuLabelControl(CreateControl(Class'UMenuLabelControl',440.0,25.0 + 6 * gap,60.0,20.0));
	lblTemp.SetText("DOM");
	lblTemp.SetTextColor(TextColor);
	cbLoadAS = UWindowCheckbox(CreateControl(Class'UWindowCheckbox',420.0,25.0 + 7 * gap,20.0,20.0));
	lblTemp = UMenuLabelControl(CreateControl(Class'UMenuLabelControl',440.0,25.0 + 7 * gap,130.0,20.0));
	lblTemp.SetText("Assault:");
	lblTemp.SetTextColor(TextColor);
	txtASClass = UWindowEditControl(CreateControl(Class'UWindowEditControl',480.0,24.0 + 7 * gap,140.0,20.0));
	txtASClass.SetNumericOnly(False);
	txtASClass.EditBoxWidth = 140.0;

		cbCustGame[0]=UWindowCheckbox(CreateControl(Class'UWindowCheckbox',420.00,20.00 + (9 + 0) * gap,20.00,20.00));
		lblCustGame[0]=UMenuLabelControl(CreateControl(Class'UMenuLabelControl',440.00,20.00 + (9 + 0) * gap,200.00,20.00));
		lblCustGame[0].SetText("empty");
		lblCustGame[0].SetTextColor(TextColor);

		cbCustGame[1]=UWindowCheckbox(CreateControl(Class'UWindowCheckbox',420.00,20.00 + (9 + 1) * gap,20.00,20.00));
		lblCustGame[1]=UMenuLabelControl(CreateControl(Class'UMenuLabelControl',440.00,20.00 + (9 + 1) * gap,200.00,20.00));
		lblCustGame[1].SetText("empty");
		lblCustGame[1].SetTextColor(TextColor);

		cbCustGame[2]=UWindowCheckbox(CreateControl(Class'UWindowCheckbox',420.00,20.00 + (9 + 2) * gap,20.00,20.00));
		lblCustGame[2]=UMenuLabelControl(CreateControl(Class'UMenuLabelControl',440.00,20.00 + (9 + 2) * gap,200.00,20.00));
		lblCustGame[2].SetText("empty");
		lblCustGame[2].SetTextColor(TextColor);

		cbCustGame[3]=UWindowCheckbox(CreateControl(Class'UWindowCheckbox',420.00,20.00 + (9 + 3) * gap,20.00,20.00));
		lblCustGame[3]=UMenuLabelControl(CreateControl(Class'UMenuLabelControl',440.00,20.00 + (9 + 3) * gap,200.00,20.00));
		lblCustGame[3].SetText("empty");
		lblCustGame[3].SetTextColor(TextColor);

		cbCustGame[4]=UWindowCheckbox(CreateControl(Class'UWindowCheckbox',420.00,20.00 + (9 + 4) * gap,20.00,20.00));
		lblCustGame[4]=UMenuLabelControl(CreateControl(Class'UMenuLabelControl',440.00,20.00 + (9 + 4) * gap,200.00,20.00));
		lblCustGame[4].SetText("empty");
		lblCustGame[4].SetTextColor(TextColor);

		cbCustGame[5]=UWindowCheckbox(CreateControl(Class'UWindowCheckbox',420.00,20.00 + (9 + 5) * gap,20.00,20.00));
		lblCustGame[5]=UMenuLabelControl(CreateControl(Class'UMenuLabelControl',440.00,20.00 + (9 + 5) * gap,200.00,20.00));
		lblCustGame[5].SetText("empty");
		lblCustGame[5].SetTextColor(TextColor);

		cbCustGame[6]=UWindowCheckbox(CreateControl(Class'UWindowCheckbox',420.00,20.00 + (9 + 6) * gap,20.00,20.00));
		lblCustGame[6]=UMenuLabelControl(CreateControl(Class'UMenuLabelControl',440.00,20.00 + (9 + 6) * gap,200.00,20.00));
		lblCustGame[6].SetText("empty");
		lblCustGame[6].SetTextColor(TextColor);

		cbCustGame[7]=UWindowCheckbox(CreateControl(Class'UWindowCheckbox',420.00,20.00 + (9 + 7) * gap,20.00,20.00));
		lblCustGame[7]=UMenuLabelControl(CreateControl(Class'UMenuLabelControl',440.00,20.00 + (9 + 7) * gap,200.00,20.00));
		lblCustGame[7].SetText("empty");
		lblCustGame[7].SetTextColor(TextColor);

		cbCustGame[8]=UWindowCheckbox(CreateControl(Class'UWindowCheckbox',420.00,20.00 + (9 + 8) * gap,20.00,20.00));
		lblCustGame[8]=UMenuLabelControl(CreateControl(Class'UMenuLabelControl',440.00,20.00 + (9 + 8) * gap,200.00,20.00));
		lblCustGame[8].SetText("empty");
		lblCustGame[8].SetTextColor(TextColor);

		cbCustGame[9]=UWindowCheckbox(CreateControl(Class'UWindowCheckbox',420.00,20.00 + (9 + 9) * gap,20.00,20.00));
		lblCustGame[9]=UMenuLabelControl(CreateControl(Class'UMenuLabelControl',440.00,20.00 + (9 + 9) * gap,200.00,20.00));
		lblCustGame[9].SetText("empty");
		lblCustGame[9].SetTextColor(TextColor);

		cbCustGame[10]=UWindowCheckbox(CreateControl(Class'UWindowCheckbox',420.00,20.00 + (9 + 10) * gap,20.00,20.00));
		lblCustGame[10]=UMenuLabelControl(CreateControl(Class'UMenuLabelControl',440.00,20.00 + (9 + 10) * gap,200.00,20.00));
		lblCustGame[10].SetText("empty");
		lblCustGame[10].SetTextColor(TextColor);

		cbCustGame[11]=UWindowCheckbox(CreateControl(Class'UWindowCheckbox',420.00,20.00 + (9 + 11) * gap,20.00,20.00));
		lblCustGame[11]=UMenuLabelControl(CreateControl(Class'UMenuLabelControl',440.00,20.00 + (9 + 11) * gap,200.00,20.00));
		lblCustGame[11].SetText("empty");
		lblCustGame[11].SetTextColor(TextColor);

		cbCustGame[12]=UWindowCheckbox(CreateControl(Class'UWindowCheckbox',420.00,20.00 + (9 + 12) * gap,20.00,20.00));
		lblCustGame[12]=UMenuLabelControl(CreateControl(Class'UMenuLabelControl',440.00,20.00 + (9 + 12) * gap,200.00,20.00));
		lblCustGame[12].SetText("empty");
		lblCustGame[12].SetTextColor(TextColor);

		cbCustGame[13]=UWindowCheckbox(CreateControl(Class'UWindowCheckbox',420.00,20.00 + (9 + 13) * gap,20.00,20.00));
		lblCustGame[13]=UMenuLabelControl(CreateControl(Class'UMenuLabelControl',440.00,20.00 + (9 + 13) * gap,200.00,20.00));
		lblCustGame[13].SetText("empty");
		lblCustGame[13].SetTextColor(TextColor);

		cbCustGame[14]=UWindowCheckbox(CreateControl(Class'UWindowCheckbox',420.00,20.00 + (9 + 14) * gap,20.00,20.00));
		lblCustGame[14]=UMenuLabelControl(CreateControl(Class'UMenuLabelControl',440.00,20.00 + (9 + 14) * gap,200.00,20.00));
		lblCustGame[14].SetText("empty");
		lblCustGame[14].SetTextColor(TextColor);

		cbCustGame[15]=UWindowCheckbox(CreateControl(Class'UWindowCheckbox',420.00,20.00 + (9 + 15) * gap,20.00,20.00));
		lblCustGame[15]=UMenuLabelControl(CreateControl(Class'UMenuLabelControl',440.00,20.00 + (9 + 15) * gap,200.00,20.00));
		lblCustGame[15].SetText("empty");
		lblCustGame[15].SetTextColor(TextColor);

		cbCustGame[16]=UWindowCheckbox(CreateControl(Class'UWindowCheckbox',490.00,20.00 + (9 + 0) * gap,20.00,20.00));
		lblCustGame[16]=UMenuLabelControl(CreateControl(Class'UMenuLabelControl',510.00,20.00 + (9 + 0) * gap,200.00,20.00));
		lblCustGame[16].SetText("empty");
		lblCustGame[16].SetTextColor(TextColor);

		cbCustGame[17]=UWindowCheckbox(CreateControl(Class'UWindowCheckbox',490.00,20.00 + (9 + 1) * gap,20.00,20.00));
		lblCustGame[17]=UMenuLabelControl(CreateControl(Class'UMenuLabelControl',510.00,20.00 + (9 + 1) * gap,200.00,20.00));
		lblCustGame[17].SetText("empty");
		lblCustGame[17].SetTextColor(TextColor);

		cbCustGame[18]=UWindowCheckbox(CreateControl(Class'UWindowCheckbox',490.00,20.00 + (9 + 2) * gap,20.00,20.00));
		lblCustGame[18]=UMenuLabelControl(CreateControl(Class'UMenuLabelControl',510.00,20.00 + (9 + 2) * gap,200.00,20.00));
		lblCustGame[18].SetText("empty");
		lblCustGame[18].SetTextColor(TextColor);

		cbCustGame[19]=UWindowCheckbox(CreateControl(Class'UWindowCheckbox',490.00,20.00 + (9 + 3) * gap,20.00,20.00));
		lblCustGame[19]=UMenuLabelControl(CreateControl(Class'UMenuLabelControl',510.00,20.00 + (9 + 3) * gap,200.00,20.00));
		lblCustGame[19].SetText("empty");
		lblCustGame[19].SetTextColor(TextColor);

		cbCustGame[20]=UWindowCheckbox(CreateControl(Class'UWindowCheckbox',490.00,20.00 + (9 + 4) * gap,20.00,20.00));
		lblCustGame[20]=UMenuLabelControl(CreateControl(Class'UMenuLabelControl',510.00,20.00 + (9 + 4) * gap,200.00,20.00));
		lblCustGame[20].SetText("empty");
		lblCustGame[20].SetTextColor(TextColor);

		cbCustGame[21]=UWindowCheckbox(CreateControl(Class'UWindowCheckbox',490.00,20.00 + (9 + 5) * gap,20.00,20.00));
		lblCustGame[21]=UMenuLabelControl(CreateControl(Class'UMenuLabelControl',510.00,20.00 + (9 + 5) * gap,200.00,20.00));
		lblCustGame[21].SetText("empty");
		lblCustGame[21].SetTextColor(TextColor);

		cbCustGame[22]=UWindowCheckbox(CreateControl(Class'UWindowCheckbox',490.00,20.00 + (9 + 6) * gap,20.00,20.00));
		lblCustGame[22]=UMenuLabelControl(CreateControl(Class'UMenuLabelControl',510.00,20.00 + (9 + 6) * gap,200.00,20.00));
		lblCustGame[22].SetText("empty");
		lblCustGame[22].SetTextColor(TextColor);

		cbCustGame[23]=UWindowCheckbox(CreateControl(Class'UWindowCheckbox',490.00,20.00 + (9 + 7) * gap,20.00,20.00));
		lblCustGame[23]=UMenuLabelControl(CreateControl(Class'UMenuLabelControl',510.00,20.00 + (9 + 7) * gap,200.00,20.00));
		lblCustGame[23].SetText("empty");
		lblCustGame[23].SetTextColor(TextColor);

		cbCustGame[24]=UWindowCheckbox(CreateControl(Class'UWindowCheckbox',490.00,20.00 + (9 + 8) * gap,20.00,20.00));
		lblCustGame[24]=UMenuLabelControl(CreateControl(Class'UMenuLabelControl',510.00,20.00 + (9 + 8) * gap,200.00,20.00));
		lblCustGame[24].SetText("empty");
		lblCustGame[24].SetTextColor(TextColor);

		cbCustGame[25]=UWindowCheckbox(CreateControl(Class'UWindowCheckbox',490.00,20.00 + (9 + 9) * gap,20.00,20.00));
		lblCustGame[25]=UMenuLabelControl(CreateControl(Class'UMenuLabelControl',510.00,20.00 + (9 + 9) * gap,200.00,20.00));
		lblCustGame[25].SetText("empty");
		lblCustGame[25].SetTextColor(TextColor);

		cbCustGame[26]=UWindowCheckbox(CreateControl(Class'UWindowCheckbox',490.00,20.00 + (9 + 10) * gap,20.00,20.00));
		lblCustGame[26]=UMenuLabelControl(CreateControl(Class'UMenuLabelControl',510.00,20.00 + (9 + 10) * gap,200.00,20.00));
		lblCustGame[26].SetText("empty");
		lblCustGame[26].SetTextColor(TextColor);

		cbCustGame[27]=UWindowCheckbox(CreateControl(Class'UWindowCheckbox',490.00,20.00 + (9 + 11) * gap,20.00,20.00));
		lblCustGame[27]=UMenuLabelControl(CreateControl(Class'UMenuLabelControl',510.00,20.00 + (9 + 11) * gap,200.00,20.00));
		lblCustGame[27].SetText("empty");
		lblCustGame[27].SetTextColor(TextColor);

		cbCustGame[28]=UWindowCheckbox(CreateControl(Class'UWindowCheckbox',490.00,20.00 + (9 + 12) * gap,20.00,20.00));
		lblCustGame[28]=UMenuLabelControl(CreateControl(Class'UMenuLabelControl',510.00,20.00 + (9 + 12) * gap,200.00,20.00));
		lblCustGame[28].SetText("empty");
		lblCustGame[28].SetTextColor(TextColor);

		cbCustGame[29]=UWindowCheckbox(CreateControl(Class'UWindowCheckbox',490.00,20.00 + (9 + 13) * gap,20.00,20.00));
		lblCustGame[29]=UMenuLabelControl(CreateControl(Class'UMenuLabelControl',510.00,20.00 + (9 + 13) * gap,200.00,20.00));
		lblCustGame[29].SetText("empty");
		lblCustGame[29].SetTextColor(TextColor);

		cbCustGame[30]=UWindowCheckbox(CreateControl(Class'UWindowCheckbox',490.00,20.00 + (9 + 14) * gap,20.00,20.00));
		lblCustGame[30]=UMenuLabelControl(CreateControl(Class'UMenuLabelControl',510.00,20.00 + (9 + 14) * gap,200.00,20.00));
		lblCustGame[30].SetText("empty");
		lblCustGame[30].SetTextColor(TextColor);

		cbCustGame[31]=UWindowCheckbox(CreateControl(Class'UWindowCheckbox',490.00,20.00 + (9 + 15) * gap,20.00,20.00));
		lblCustGame[31]=UMenuLabelControl(CreateControl(Class'UMenuLabelControl',510.00,20.00 + (9 + 15) * gap,200.00,20.00));
		lblCustGame[31].SetText("empty");
		lblCustGame[31].SetTextColor(TextColor);

		cbCustGame[32]=UWindowCheckbox(CreateControl(Class'UWindowCheckbox',560.00,20.00 + (9 + 0) * gap,20.00,20.00));
		lblCustGame[32]=UMenuLabelControl(CreateControl(Class'UMenuLabelControl',580.00,20.00 + (9 + 0) * gap,200.00,20.00));
		lblCustGame[32].SetText("empty");
		lblCustGame[32].SetTextColor(TextColor);

		cbCustGame[33]=UWindowCheckbox(CreateControl(Class'UWindowCheckbox',560.00,20.00 + (9 + 1) * gap,20.00,20.00));
		lblCustGame[33]=UMenuLabelControl(CreateControl(Class'UMenuLabelControl',580.00,20.00 + (9 + 1) * gap,200.00,20.00));
		lblCustGame[33].SetText("empty");
		lblCustGame[33].SetTextColor(TextColor);

		cbCustGame[34]=UWindowCheckbox(CreateControl(Class'UWindowCheckbox',560.00,20.00 + (9 + 2) * gap,20.00,20.00));
		lblCustGame[34]=UMenuLabelControl(CreateControl(Class'UMenuLabelControl',580.00,20.00 + (9 + 2) * gap,200.00,20.00));
		lblCustGame[34].SetText("empty");
		lblCustGame[34].SetTextColor(TextColor);

		cbCustGame[35]=UWindowCheckbox(CreateControl(Class'UWindowCheckbox',560.00,20.00 + (9 + 3) * gap,20.00,20.00));
		lblCustGame[35]=UMenuLabelControl(CreateControl(Class'UMenuLabelControl',580.00,20.00 + (9 + 3) * gap,200.00,20.00));
		lblCustGame[35].SetText("empty");
		lblCustGame[35].SetTextColor(TextColor);

		cbCustGame[36]=UWindowCheckbox(CreateControl(Class'UWindowCheckbox',560.00,20.00 + (9 + 4) * gap,20.00,20.00));
		lblCustGame[36]=UMenuLabelControl(CreateControl(Class'UMenuLabelControl',580.00,20.00 + (9 + 4) * gap,200.00,20.00));
		lblCustGame[36].SetText("empty");
		lblCustGame[36].SetTextColor(TextColor);

		cbCustGame[37]=UWindowCheckbox(CreateControl(Class'UWindowCheckbox',560.00,20.00 + (9 + 5) * gap,20.00,20.00));
		lblCustGame[37]=UMenuLabelControl(CreateControl(Class'UMenuLabelControl',580.00,20.00 + (9 + 5) * gap,200.00,20.00));
		lblCustGame[37].SetText("empty");
		lblCustGame[37].SetTextColor(TextColor);

		cbCustGame[38]=UWindowCheckbox(CreateControl(Class'UWindowCheckbox',560.00,20.00 + (9 + 6) * gap,20.00,20.00));
		lblCustGame[38]=UMenuLabelControl(CreateControl(Class'UMenuLabelControl',580.00,20.00 + (9 + 6) * gap,200.00,20.00));
		lblCustGame[38].SetText("empty");
		lblCustGame[38].SetTextColor(TextColor);

		cbCustGame[39]=UWindowCheckbox(CreateControl(Class'UWindowCheckbox',560.00,20.00 + (9 + 7) * gap,20.00,20.00));
		lblCustGame[39]=UMenuLabelControl(CreateControl(Class'UMenuLabelControl',580.00,20.00 + (9 + 7) * gap,200.00,20.00));
		lblCustGame[39].SetText("empty");
		lblCustGame[39].SetTextColor(TextColor);

		cbCustGame[40]=UWindowCheckbox(CreateControl(Class'UWindowCheckbox',560.00,20.00 + (9 + 8) * gap,20.00,20.00));
		lblCustGame[40]=UMenuLabelControl(CreateControl(Class'UMenuLabelControl',580.00,20.00 + (9 + 8) * gap,200.00,20.00));
		lblCustGame[40].SetText("empty");
		lblCustGame[40].SetTextColor(TextColor);

		cbCustGame[41]=UWindowCheckbox(CreateControl(Class'UWindowCheckbox',560.00,20.00 + (9 + 9) * gap,20.00,20.00));
		lblCustGame[41]=UMenuLabelControl(CreateControl(Class'UMenuLabelControl',580.00,20.00 + (9 + 9) * gap,200.00,20.00));
		lblCustGame[41].SetText("empty");
		lblCustGame[41].SetTextColor(TextColor);

		cbCustGame[42]=UWindowCheckbox(CreateControl(Class'UWindowCheckbox',560.00,20.00 + (9 + 10) * gap,20.00,20.00));
		lblCustGame[42]=UMenuLabelControl(CreateControl(Class'UMenuLabelControl',580.00,20.00 + (9 + 10) * gap,200.00,20.00));
		lblCustGame[42].SetText("empty");
		lblCustGame[42].SetTextColor(TextColor);

		cbCustGame[43]=UWindowCheckbox(CreateControl(Class'UWindowCheckbox',560.00,20.00 + (9 + 11) * gap,20.00,20.00));
		lblCustGame[43]=UMenuLabelControl(CreateControl(Class'UMenuLabelControl',580.00,20.00 + (9 + 11) * gap,200.00,20.00));
		lblCustGame[43].SetText("empty");
		lblCustGame[43].SetTextColor(TextColor);

		cbCustGame[44]=UWindowCheckbox(CreateControl(Class'UWindowCheckbox',560.00,20.00 + (9 + 12) * gap,20.00,20.00));
		lblCustGame[44]=UMenuLabelControl(CreateControl(Class'UMenuLabelControl',580.00,20.00 + (9 + 12) * gap,200.00,20.00));
		lblCustGame[44].SetText("empty");
		lblCustGame[44].SetTextColor(TextColor);

		cbCustGame[45]=UWindowCheckbox(CreateControl(Class'UWindowCheckbox',560.00,20.00 + (9 + 13) * gap,20.00,20.00));
		lblCustGame[45]=UMenuLabelControl(CreateControl(Class'UMenuLabelControl',580.00,20.00 + (9 + 13) * gap,200.00,20.00));
		lblCustGame[45].SetText("empty");
		lblCustGame[45].SetTextColor(TextColor);

		cbCustGame[46]=UWindowCheckbox(CreateControl(Class'UWindowCheckbox',560.00,20.00 + (9 + 14) * gap,20.00,20.00));
		lblCustGame[46]=UMenuLabelControl(CreateControl(Class'UMenuLabelControl',580.00,20.00 + (9 + 14) * gap,200.00,20.00));
		lblCustGame[46].SetText("empty");
		lblCustGame[46].SetTextColor(TextColor);

		cbCustGame[47]=UWindowCheckbox(CreateControl(Class'UWindowCheckbox',560.00,20.00 + (9 + 15) * gap,20.00,20.00));
		lblCustGame[47]=UMenuLabelControl(CreateControl(Class'UMenuLabelControl',580.00,20.00 + (9 + 15) * gap,200.00,20.00));
		lblCustGame[47].SetText("empty");
		lblCustGame[47].SetTextColor(TextColor);

	cbUseExcludeFilter = UWindowCheckbox(CreateControl(Class'UWindowCheckbox',420.0,10.0 + 26 * gap,20.0,20.0));
	lblTemp = UMenuLabelControl(CreateControl(Class'UMenuLabelControl',440.0,10.0 + 26 * gap,170.0,20.0));
	lblTemp.SetText("Use Exclude Filter");
	lblTemp.SetTextColor(TextColor);
	lblLimitsLabel = UMenuLabelControl(CreateControl(Class'UMenuLabelControl',10.0,110.0,50.0,20.0));
	lblLimitsLabel.SetText("Limits");
	lblLimitsLabel.SetTextColor(TextColor);
	sldVoteTimeLimit = UWindowHSliderControl(CreateControl(Class'UWindowHSliderControl',10.0,130.0,170.0,20.0));
	sldVoteTimeLimit.bAcceptsFocus = False;
	sldVoteTimeLimit.MinValue = 20.0;
	sldVoteTimeLimit.MaxValue = 180.0;
	sldVoteTimeLimit.Step = 10;
	sldVoteTimeLimit.SetText("Voting Time Limit");
	sldVoteTimeLimit.SetTextColor(TextColor);
	lblVoteTimeLimit = UMenuLabelControl(CreateControl(Class'UMenuLabelControl',190.0,130.0,40.0,20.0));
	lblVoteTimeLimit.SetText(string(sldVoteTimeLimit.Value) $ " sec");
	lblVoteTimeLimit.SetTextColor(TextColor);
	sldKickPercent = UWindowHSliderControl(CreateControl(Class'UWindowHSliderControl',10.0,150.0,170.0,20.0));
	sldKickPercent.MinValue = 10.0;
	sldKickPercent.MaxValue = 100.0;
	sldKickPercent.Step = 1;
	sldKickPercent.SetText("Kick Votes Req.");
	sldKickPercent.SetTextColor(TextColor);
	lblKickPercent = UMenuLabelControl(CreateControl(Class'UMenuLabelControl',190.0,150.0,40.0,20.0));
	lblKickPercent.SetText(string(sldKickPercent.Value) $ " %");
	lblKickPercent.SetTextColor(TextColor);
	sldScoreBoardDelay = UWindowHSliderControl(CreateControl(Class'UWindowHSliderControl',10.0,170.0,180.0,20.0));
	sldScoreBoardDelay.MinValue = 1.0;
	sldScoreBoardDelay.MaxValue = 30.0;
	sldScoreBoardDelay.Step = 1;
	sldScoreBoardDelay.SetText("ScoreBoard Delay");
	sldScoreBoardDelay.SetTextColor(TextColor);
	lblScoreBoardDelay = UMenuLabelControl(CreateControl(Class'UMenuLabelControl',195.0,170.0,40.0,20.0));
	lblScoreBoardDelay.SetText(string(sldScoreBoardDelay.Value) $ " sec");
	lblScoreBoardDelay.SetTextColor(TextColor);
	sldMidGameVotePercent = UWindowHSliderControl(CreateControl(Class'UWindowHSliderControl',10.0,190.0,195.0,20.0));
	sldMidGameVotePercent.MinValue = 1.0;
	sldMidGameVotePercent.MaxValue = 100.0;
	sldMidGameVotePercent.Step = 1;
	sldMidGameVotePercent.SetText("Mid-Game Voter Req.");
	sldMidGameVotePercent.SetTextColor(TextColor);
	lblMidGameVotePercent = UMenuLabelControl(CreateControl(Class'UMenuLabelControl',210.0,190.0,40.0,20.0));
	lblMidGameVotePercent.SetText(string(sldMidGameVotePercent.Value) $ " %");
	lblMidGameVotePercent.SetTextColor(TextColor);
	txtRepeatLimit = UWindowEditControl(CreateControl(Class'UWindowEditControl',230.0,130.0,95.0,20.0));
	txtRepeatLimit.SetNumericOnly(True);
	txtRepeatLimit.SetText("Don't Show Last");
	txtRepeatLimit.SetTextColor(TextColor);
	txtRepeatLimit.EditBoxWidth = 20.0;
	lblRepeatLimit = UMenuLabelControl(CreateControl(Class'UMenuLabelControl',330.0,130.0,60.0,20.0));
	lblRepeatLimit.SetText("maps Played");
	lblRepeatLimit.SetTextColor(TextColor);
	txtMinMapCount = UWindowEditControl(CreateControl(Class'UWindowEditControl',230.0,150.0,120.0,20.0));
	txtMinMapCount.SetNumericOnly(True);
	txtMinMapCount.SetText("Reload Map List when");
	txtMinMapCount.SetTextColor(TextColor);
	txtMinMapCount.EditBoxWidth = 20.0;
	lblMinMapCount = UMenuLabelControl(CreateControl(Class'UMenuLabelControl',230.0,165.0,200.0,20.0));
	lblMinMapCount.SetText("maps remain. (Elimiation Mode only)");
	lblMinMapCount.SetTextColor(TextColor);
	lblMiscSection = UMenuLabelControl(CreateControl(Class'UMenuLabelControl',10.0,210.0,50.0,20.0));
	lblMiscSection.SetText("Misc.");
	lblMiscSection.SetTextColor(TextColor);
	cbUseMapList = UWindowCheckbox(CreateControl(Class'UWindowCheckbox',10.0,230.0,300.0,20.0));
	cbUseMapList.SetText("Use the Map Cycle List instead of all maps");
	cbUseMapList.SetTextColor(TextColor);
	cbUseMapList.SetFont(0);
	cbUseMapList.Align=TA_Right;
	cbUseMapList.SetSize(200.0,1.0);
	cbAutoOpen = UWindowCheckbox(CreateControl(Class'UWindowCheckbox',10.0,250.0,300.0,20.0));
	cbAutoOpen.SetText("Open Voting Window at Game End");
	cbAutoOpen.SetTextColor(TextColor);
	cbAutoOpen.SetFont(0);
	cbAutoOpen.Align=TA_Right;
	cbAutoOpen.SetSize(200.0,1.0);
	cbKickVote = UWindowCheckbox(CreateControl(Class'UWindowCheckbox',10.0,270.0,300.0,20.0));
	cbKickVote.SetText("Enable Player Kick Voting");
	cbKickVote.SetTextColor(TextColor);
	cbKickVote.SetFont(0);
	cbKickVote.Align=TA_Right;
	cbKickVote.SetSize(200.0,1.0);
	cbCheckOtherGameTie = UWindowCheckbox(CreateControl(Class'UWindowCheckbox',10.0,290.0,300.0,20.0));
	cbCheckOtherGameTie.SetText("Check Sudden Death OverTime");
	cbCheckOtherGameTie.SetTextColor(TextColor);
	cbCheckOtherGameTie.SetFont(0);
	cbCheckOtherGameTie.Align=TA_Right;
	cbCheckOtherGameTie.SetSize(200.0,1.0);
	cboMode = UWindowComboControl(CreateControl(Class'UWindowComboControl',230.0,230.0,120.0,1.0));
	cboMode.SetText("Mode");
	cboMode.SetTextColor(TextColor);
	cboMode.SetEditable(False);
	cboMode.EditBoxWidth = 90.0;
	cboMode.AddItem("Majority");
	cboMode.AddItem("Elimination");
	cboMode.AddItem("Score");
	cboMode.AddItem("Accumulation");
	lblActGame = UMenuLabelControl(CreateControl(Class'UMenuLabelControl',230.0,260.0,200.0,20.0));
	lblActGame.SetTextColor(TextColor);
	lblActPrefix = UMenuLabelControl(CreateControl(Class'UMenuLabelControl',230.0,280.0,200.0,20.0));
	lblActPrefix.SetTextColor(TextColor);
	lblAdvancedSection = UMenuLabelControl(CreateControl(Class'UMenuLabelControl',10.0,310.0,50.0,20.0));
	lblAdvancedSection.SetText("Advanced");
	lblAdvancedSection.SetTextColor(TextColor);
	txtServerInfoURL = UWindowEditControl(CreateControl(Class'UWindowEditControl',10.0,330.0,370.0,15.0));
	txtServerInfoURL.SetNumericOnly(False);
	txtServerInfoURL.SetText("Welcome Page Web Server URL");
	txtServerInfoURL.SetTextColor(TextColor);
	txtServerInfoURL.EditBoxWidth = 210.0;
	lblServerInfoURL = UMenuLabelControl(CreateControl(Class'UMenuLabelControl',10.0,347.0,400.0,20.0));
	lblServerInfoURL.SetText("Example: www.MyServer.com:80/UnrealStuff/WelcomePage.htm");
	lblServerInfoURL.SetTextColor(TextColor);
	txtMapInfoURL = UWindowEditControl(CreateControl(Class'UWindowEditControl',10.0,365.0,370.0,15.0));
	txtMapInfoURL.SetNumericOnly(False);
	txtMapInfoURL.SetText("Map Information Web Server URL");
	txtMapInfoURL.SetTextColor(TextColor);
	txtMapInfoURL.EditBoxWidth = 210.0;
	lblMapInfoURL = UMenuLabelControl(CreateControl(Class'UMenuLabelControl',10.0,382.0,400.0,20.0));
	lblMapInfoURL.SetText("Example: www.MyServer.com:80/MapFiles/");
	lblMapInfoURL.SetTextColor(TextColor);
	cboMapVoteHistoryType = UWindowComboControl(CreateControl(Class'UWindowComboControl',10.0,395.0,370.0,1.0));
	cboMapVoteHistoryType.SetText("Map Vote History Class Type");
	cboMapVoteHistoryType.SetTextColor(TextColor);
	cboMapVoteHistoryType.SetEditable(True);
	cboMapVoteHistoryType.EditBoxWidth = 210.0;
	cboMapVoteHistoryType.AddItem("MapVoteULv1_2.MapVoteHistory1");
	cboMapVoteHistoryType.AddItem("MapVoteULv1_2.MapVoteHistory2");
	cboMapVoteHistoryType.AddItem("MapVoteULv1_2.MapVoteHistory3");
	cboMapVoteHistoryType.AddItem("MapVoteULv1_2.MapVoteHistory4");
	cbEntryWindows = UWindowCheckbox(CreateControl(Class'UWindowCheckbox',10.0,420.0,320.0,20.0));
	cbEntryWindows.SetText("Open Welcome Window and KeyBinder when player enters server");
	cbEntryWindows.SetTextColor(TextColor);
	cbEntryWindows.SetFont(0);
	cbEntryWindows.Align=TA_Right;
	cbEntryWindows.SetSize(320.0,1.0);
	cbSortWithPreFix = UWindowCheckbox(CreateControl(Class'UWindowCheckbox',10.0,445.0,140.0,20.0));
	cbSortWithPreFix.SetText("Sort Maps with PreFix");
	cbSortWithPreFix.SetTextColor(TextColor);
	cbSortWithPreFix.SetFont(0);
	cbSortWithPreFix.Align=TA_Right;
	cbSortWithPreFix.SetSize(120.0,1.0);
	cbSortWithPreFix.bAcceptsFocus = False;
	cbDebugMode = UWindowCheckbox(CreateControl(Class'UWindowCheckbox',10.0,470.0,140.0,20.0));
	cbDebugMode.SetText("Debug Mode");
	cbDebugMode.SetTextColor(TextColor);
	cbDebugMode.SetFont(0);
	cbDebugMode.Align=TA_Right;
	cbDebugMode.SetSize(80.0,1.0);
	cbDebugMode.bAcceptsFocus = False;
	ListCrashButton = UWindowSmallButton(CreateControl(Class'UWindowSmallButton',170.0,470.0,100.0,20.0));
	ListCrashButton.Text = "List crashed maps";
	ListCrashButton.DownSound = Sound'Click';
	ClearCrashButton = UWindowSmallButton(CreateControl(Class'UWindowSmallButton',280.0,470.0,100.0,20.0));
	ClearCrashButton.Text = "Clear crash List";
	ClearCrashButton.DownSound = Sound'Click';
	cbRemoveCrashedMaps = UWindowCheckbox(CreateControl(Class'UWindowCheckbox',170.0,450.0,140.0,20.0));
	cbRemoveCrashedMaps.SetText("Remove crashed maps");
	cbRemoveCrashedMaps.SetTextColor(TextColor);
	cbRemoveCrashedMaps.SetFont(0);
	cbRemoveCrashedMaps.Align=TA_Right;
	cbRemoveCrashedMaps.SetSize(120.0,1.0);
	lblGameTypeSection = UMenuLabelControl(CreateControl(Class'UMenuLabelControl',420.0,10.0,120.0,20.0));
	lblGameTypeSection.SetText("Game Types");
	lblGameTypeSection.SetTextColor(TextColor);
	txtMapVoteTitle = UWindowEditControl(CreateControl(Class'UWindowEditControl',10.0,30.0,190.0,20.0));
	txtMapVoteTitle.SetNumericOnly(False);
	txtMapVoteTitle.SetText("Map Vote Title");
	txtMapVoteTitle.SetTextColor(TextColor);
	txtMapVoteTitle.EditBoxWidth = 120.0;
	txtList1Title = UWindowEditControl(CreateControl(Class'UWindowEditControl',10.0,45.0,190.0,20.0));
	txtList1Title.SetNumericOnly(False);
	txtList1Title.SetText("List 1 Title");
	txtList1Title.SetTextColor(TextColor);
	txtList1Title.EditBoxWidth = 120.0;
	txtList2Title = UWindowEditControl(CreateControl(Class'UWindowEditControl',10.0,60.0,190.0,20.0));
	txtList2Title.SetNumericOnly(False);
	txtList2Title.SetText("List 2 Title");
	txtList2Title.SetTextColor(TextColor);
	txtList2Title.EditBoxWidth = 120.0;
	txtList3Title = UWindowEditControl(CreateControl(Class'UWindowEditControl',10.0,75.0,190.0,20.0));
	txtList3Title.SetNumericOnly(False);
	txtList3Title.SetText("List 3 Title");
	txtList3Title.SetTextColor(TextColor);
	txtList3Title.EditBoxWidth = 120.0;
	txtList4Title = UWindowEditControl(CreateControl(Class'UWindowEditControl',10.0,90.0,190.0,20.0));
	txtList4Title.SetNumericOnly(False);
	txtList4Title.SetText("List 4 Title");
	txtList4Title.SetTextColor(TextColor);
	txtList4Title.EditBoxWidth = 120.0;
	txtList1Priority = UWindowEditControl(CreateControl(Class'UWindowEditControl',230.0,45.0,160.0,20.0));
	txtList1Priority.SetNumericOnly(False);
	txtList1Priority.SetText("Priority");
	txtList1Priority.SetTextColor(TextColor);
	txtList1Priority.EditBoxWidth = 120.0;
	txtList2Priority = UWindowEditControl(CreateControl(Class'UWindowEditControl',230.0,60.0,160.0,20.0));
	txtList2Priority.SetNumericOnly(False);
	txtList2Priority.SetText("Priority");
	txtList2Priority.SetTextColor(TextColor);
	txtList2Priority.EditBoxWidth = 120.0;
	txtList3Priority = UWindowEditControl(CreateControl(Class'UWindowEditControl',230.0,75.0,160.0,20.0));
	txtList3Priority.SetNumericOnly(False);
	txtList3Priority.SetText("Priority");
	txtList3Priority.SetTextColor(TextColor);
	txtList3Priority.EditBoxWidth = 120.0;
	txtList4Priority = UWindowEditControl(CreateControl(Class'UWindowEditControl',230.0,90.0,160.0,20.0));
	txtList4Priority.SetNumericOnly(False);
	txtList4Priority.SetText("Priority");
	txtList4Priority.SetTextColor(TextColor);
	txtList4Priority.EditBoxWidth = 120.0;
	RemoteSaveButton = UWindowSmallButton(CreateControl(Class'UWindowSmallButton',425.0,400.0,190.0,20.0));
	RemoteSaveButton.Text = "Save";
	RemoteSaveButton.DownSound = Sound'Click';
	RemoteSaveButton.SetAcceptsFocus();
	RemoteSaveButton.FocusWindow();
	RemoteSaveButton.bDisabled = True;
	cbReloadMapsOnRequestOnly = UWindowCheckbox(CreateControl(Class'UWindowCheckbox',425.0,430.0,300.0,20.0));
	cbReloadMapsOnRequestOnly.SetText("Reload Maps on request only");
	cbReloadMapsOnRequestOnly.SetTextColor(TextColor);
	cbReloadMapsOnRequestOnly.SetFont(0);
	cbReloadMapsOnRequestOnly.Align=TA_Right;
	cbReloadMapsOnRequestOnly.SetSize(150.0,1.0);
	ReloadMapsButton = UWindowSmallButton(CreateControl(Class'UWindowSmallButton',425.0,450.0,190.0,20.0));
	ReloadMapsButton.Text = "Reload Maps";
	ReloadMapsButton.DownSound = Sound'Click';
	CloseButton = UWindowSmallButton(CreateControl(Class'UWindowSmallButton',425.0,475.0,190.0,20.0));
	CloseButton.Text = "Close";
 */
	ReloadMapsButton = UWindowSmallButton(CreateControl(Class'UWindowSmallButton',250.0,250.0,190.0,20.0));
	ReloadMapsButton.Text = "Reload Maps";
	ReloadMapsButton.DownSound = Sound'Click';
	CloseButton = UWindowSmallButton(CreateControl(Class'UWindowSmallButton',250.0,275.0,190.0,20.0));
	CloseButton.Text = "Close";
}

function Notify (UWindowDialogControl C, byte E)
{
	local int i;
	local string CustString;

	Super.Notify(C,E);
	switch (E)
	{
		case 2:
		switch (C)
		{
			case ListCrashButton:
			GetPlayerOwner().ConsoleCommand("MUTATE BDBMAPVOTE LISTCRASHEDMAPS");
			break;
			case ClearCrashButton:
			GetPlayerOwner().ConsoleCommand("MUTATE BDBMAPVOTE CLEARCRASHEDMAPS");
			break;
			case CloseButton:
			ParentWindow.ParentWindow.ParentWindow.Close();
			break;
			case RemoteSaveButton:
			GetPlayerOwner().ConsoleCommand("ADMIN SET MVES.MapVote bDM " $ string(cbLoadDM.bChecked));
			GetPlayerOwner().ConsoleCommand("ADMIN SET MVES.MapVote bLMS " $ string(cbLoadLMS.bChecked));
			GetPlayerOwner().ConsoleCommand("ADMIN SET MVES.MapVote bTDM " $ string(cbLoadTDM.bChecked));
			GetPlayerOwner().ConsoleCommand("ADMIN SET MVES.MapVote bAS " $ string(cbLoadAS.bChecked));
			GetPlayerOwner().ConsoleCommand("ADMIN SET MVES.MapVote bDOM " $ string(cbLoadDOM.bChecked));
			GetPlayerOwner().ConsoleCommand("ADMIN SET MVES.MapVote bCTF " $ string(cbLoadCTF.bChecked));
			GetPlayerOwner().ConsoleCommand("ADMIN SET MVES.MapVote VoteTimeLimit " $ string(int(sldVoteTimeLimit.Value)));
			GetPlayerOwner().ConsoleCommand("ADMIN SET MVES.MapVote KickPercent " $ string(int(sldKickPercent.Value)));
			GetPlayerOwner().ConsoleCommand("ADMIN SET MVES.MapVote bUseMapList " $ string(cbUseMapList.bChecked));
			GetPlayerOwner().ConsoleCommand("ADMIN SET MVES.MapVote bAutoOpen " $ string(cbAutoOpen.bChecked));
			GetPlayerOwner().ConsoleCommand("ADMIN SET MVES.MapVote bKickVote " $ string(cbKickVote.bChecked));
			GetPlayerOwner().ConsoleCommand("ADMIN SET MVES.MapVote ScoreBoardDelay " $ string(int(sldScoreBoardDelay.Value)));
			GetPlayerOwner().ConsoleCommand("ADMIN SET MVES.MapVote bAutoDetect " $ string(cbAutoDetect.bChecked));
			GetPlayerOwner().ConsoleCommand("ADMIN SET MVES.MapVote bCheckOtherGameTie " $ string(cbCheckOtherGameTie.bChecked));
			GetPlayerOwner().ConsoleCommand("ADMIN SET MVES.MapVote RepeatLimit " $ txtRepeatLimit.GetValue());
			GetPlayerOwner().ConsoleCommand("ADMIN SET MVES.MapVote MapVoteHistoryType " $ cboMapVoteHistoryType.GetValue());
			GetPlayerOwner().ConsoleCommand("ADMIN SET MVES.MapVote ServerInfoURL " $ txtServerInfoURL.GetValue());
			GetPlayerOwner().ConsoleCommand("ADMIN SET MVES.MapVote MapInfoURL " $ txtMapInfoURL.GetValue());
			GetPlayerOwner().ConsoleCommand("ADMIN SET MVES.MapVote MidGameVotePercent " $ string(int(sldMidGameVotePercent.Value)));
			GetPlayerOwner().ConsoleCommand("ADMIN SET MVES.MapVote Mode " $ cboMode.GetValue());
			GetPlayerOwner().ConsoleCommand("ADMIN SET MVES.MapVote MinMapCount " $ txtMinMapCount.GetValue());
			GetPlayerOwner().ConsoleCommand("ADMIN SET MVES.MapVote bEntryWindows " $ string(cbEntryWindows.bChecked));
			GetPlayerOwner().ConsoleCommand("ADMIN SET MVES.MapVote bSortWithPreFix " $ string(cbSortWithPreFix.bChecked));
			GetPlayerOwner().ConsoleCommand("ADMIN SET MVES.MapVote bDebugMode " $ string(cbDebugMode.bChecked));
			GetPlayerOwner().ConsoleCommand("ADMIN SET MVES.MapVote MapVoteTitle " $ txtMapVoteTitle.GetValue());
			GetPlayerOwner().ConsoleCommand("ADMIN SET MVES.MapVote List1Title " $ txtList1Title.GetValue());
			GetPlayerOwner().ConsoleCommand("ADMIN SET MVES.MapVote List2Title " $ txtList2Title.GetValue());
			GetPlayerOwner().ConsoleCommand("ADMIN SET MVES.MapVote List3Title " $ txtList3Title.GetValue());
			GetPlayerOwner().ConsoleCommand("ADMIN SET MVES.MapVote List4Title " $ txtList4Title.GetValue());
			GetPlayerOwner().ConsoleCommand("ADMIN SET MVES.MapVote List1Priority " $ txtList1Priority.GetValue());
			GetPlayerOwner().ConsoleCommand("ADMIN SET MVES.MapVote List2Priority " $ txtList2Priority.GetValue());
			GetPlayerOwner().ConsoleCommand("ADMIN SET MVES.MapVote List3Priority " $ txtList3Priority.GetValue());
			GetPlayerOwner().ConsoleCommand("ADMIN SET MVES.MapVote List4Priority " $ txtList4Priority.GetValue());
			if ( (txtASClass.GetValue() == "") || (Len(txtASClass.GetValue()) < 10) )
			{
				txtASClass.SetValue("Botpack.Assault");
			}
			GetPlayerOwner().ConsoleCommand("ADMIN SET MVES.MapVote ASClass " $ txtASClass.GetValue());
			GetPlayerOwner().ConsoleCommand("ADMIN SET MVES.MapVote bRemoveCrashedMaps " $ string(cbRemoveCrashedMaps.bChecked));
			GetPlayerOwner().ConsoleCommand("ADMIN SET MVES.MapVote bReloadMapsOnRequestOnly " $ string(cbReloadMapsOnRequestOnly.bChecked));
			GetPlayerOwner().ConsoleCommand("ADMIN SET MVES.MapVote bUseExcludeFilter " $ string(cbUseExcludeFilter.bChecked));
			for ( i=0; i<ArrayCount(cbCustGame); i++ )
			{
				if ( cbCustGame[i].bChecked )
				{
					CustString=CustString $ "1";
				} else {
					CustString=CustString $ "0";
				}
			}
			GetPlayerOwner().ConsoleCommand("Mutate BDBMAPVOTE CUSTSETTING" @ CustString);
			GetPlayerOwner().ClientMessage("Settings saved!");
			break;
			case ReloadMapsButton:
			GetPlayerOwner().ConsoleCommand("MUTATE BDBMAPVOTE RELOADMAPS");
			ParentWindow.ParentWindow.ParentWindow.Close();
			break;
			case cbLoadDM:
			if ( cbLoadDM.bChecked )
			{
				cbAutoDetect.bChecked=False;
			}
			break;
			case cbLoadLMS:
			if ( cbLoadLMS.bChecked )
			{
				cbAutoDetect.bChecked=False;
			}
			break;
			case cbLoadTDM:
			if ( cbLoadTDM.bChecked )
			{
				cbAutoDetect.bChecked=False;
			}
			break;
			case cbLoadAS:
			if ( cbLoadAS.bChecked )
			{
				cbAutoDetect.bChecked=False;
			}
			break;
			case cbLoadCTF:
			if ( cbLoadCTF.bChecked )
			{
				cbAutoDetect.bChecked=False;
			}
			break;
			case cbLoadDOM:
			if ( cbLoadDOM.bChecked )
			{
				cbAutoDetect.bChecked=False;
			}
			break;
			case cbAutoDetect:
			if ( cbAutoDetect.bChecked )
			{
				cbLoadDM.bChecked=False;
				cbLoadLMS.bChecked=False;
				cbLoadTDM.bChecked=False;
				cbLoadAS.bChecked=False;
				cbLoadCTF.bChecked=False;
				cbLoadDOM.bChecked=False;
			}
			break;
			default:
		}
		break;
		case 1:
		switch (C)
		{
            case sldVoteTimeLimit:
               lblVoteTimeLimit.SetText(String(int(sldVoteTimeLimit.Value)) $ " sec");
               break;
            case sldKickPercent:
               lblKickPercent.SetText(String(int(sldKickPercent.Value)) $ " %");
               break;
            case sldScoreBoardDelay:
               lblScoreBoardDelay.SetText(String(int(sldScoreBoardDelay.Value)) $ " sec");
               break;
            case sldMidGameVotePercent:
               lblMidGameVotePercent.SetText(String(int(sldMidGameVotePercent.Value)) $ " %");
               break;
			default:
		}
		break;
		default:
	}
}

function MapVoteClientConfig GetConfig()
{
	if (MapVoteClientConfig == None) 
	{
		MapVoteClientConfig = class'MapVoteClientConfig'.static.GetInstance();
	}
	return MapVoteClientConfig;
}

function Paint (Canvas C, float MouseX, float MouseY)
{
	Super.Paint(C,MouseX,MouseY);
	C.DrawColor = GetConfig().BackgroundColor;
	DrawStretchedTexture(C,0.0,0.0,WinWidth,WinHeight,Texture'BackgroundTexture');
	C.DrawColor.R = 0;
	C.DrawColor.G = 255;
	C.DrawColor.B = 0;
	//DrawStretchedTexture(C,10.0,20.0,380.0,2.0,Texture'ListsBoxBackground');
	//DrawStretchedTexture(C,420.0,20.0,200.0,2.0,Texture'ListsBoxBackground');
	//DrawStretchedTexture(C,10.0,120.0,380.0,2.0,Texture'ListsBoxBackground');
	//DrawStretchedTexture(C,10.0,220.0,380.0,2.0,Texture'ListsBoxBackground');
	//DrawStretchedTexture(C,10.0,320.0,380.0,2.0,Texture'ListsBoxBackground');
	//DrawStretchedTexture(C,405.0,20.0,2.0,490.0,Texture'ListsBoxBackground');
}

final simulated function UWindowCheckbox GetcbCustGame( int Idx)
{
	return cbCustGame[Idx];
}

final simulated function UMenuLabelControl GetlblCustGame( int Idx)
{
	return lblCustGame[Idx];
}

defaultproperties
{
      cbLoadDM=None
      cbLoadLMS=None
      cbLoadTDM=None
      cbLoadAS=None
      cbLoadDOM=None
      cbLoadCTF=None
      cbAutoDetect=None
      cbCheckOtherGameTie=None
      cbReloadMapsOnRequestOnly=None
      cbCustGame(0)=None
      cbCustGame(1)=None
      cbCustGame(2)=None
      cbCustGame(3)=None
      cbCustGame(4)=None
      cbCustGame(5)=None
      cbCustGame(6)=None
      cbCustGame(7)=None
      cbCustGame(8)=None
      cbCustGame(9)=None
      cbCustGame(10)=None
      cbCustGame(11)=None
      cbCustGame(12)=None
      cbCustGame(13)=None
      cbCustGame(14)=None
      cbCustGame(15)=None
      cbCustGame(16)=None
      cbCustGame(17)=None
      cbCustGame(18)=None
      cbCustGame(19)=None
      cbCustGame(20)=None
      cbCustGame(21)=None
      cbCustGame(22)=None
      cbCustGame(23)=None
      cbCustGame(24)=None
      cbCustGame(25)=None
      cbCustGame(26)=None
      cbCustGame(27)=None
      cbCustGame(28)=None
      cbCustGame(29)=None
      cbCustGame(30)=None
      cbCustGame(31)=None
      cbCustGame(32)=None
      cbCustGame(33)=None
      cbCustGame(34)=None
      cbCustGame(35)=None
      cbCustGame(36)=None
      cbCustGame(37)=None
      cbCustGame(38)=None
      cbCustGame(39)=None
      cbCustGame(40)=None
      cbCustGame(41)=None
      cbCustGame(42)=None
      cbCustGame(43)=None
      cbCustGame(44)=None
      cbCustGame(45)=None
      cbCustGame(46)=None
      cbCustGame(47)=None
      cbCustGame(48)=None
      cbCustGame(49)=None
      cbCustGame(50)=None
      cbCustGame(51)=None
      cbCustGame(52)=None
      cbCustGame(53)=None
      cbCustGame(54)=None
      cbCustGame(55)=None
      cbCustGame(56)=None
      cbCustGame(57)=None
      cbCustGame(58)=None
      cbCustGame(59)=None
      cbCustGame(60)=None
      cbCustGame(61)=None
      cbCustGame(62)=None
      cbCustGame(63)=None
      cbCustGame(64)=None
      cbCustGame(65)=None
      cbCustGame(66)=None
      cbCustGame(67)=None
      cbCustGame(68)=None
      cbCustGame(69)=None
      cbCustGame(70)=None
      cbCustGame(71)=None
      cbCustGame(72)=None
      cbCustGame(73)=None
      cbCustGame(74)=None
      cbCustGame(75)=None
      cbCustGame(76)=None
      cbCustGame(77)=None
      cbCustGame(78)=None
      cbCustGame(79)=None
      cbCustGame(80)=None
      cbCustGame(81)=None
      cbCustGame(82)=None
      cbCustGame(83)=None
      cbCustGame(84)=None
      cbCustGame(85)=None
      cbCustGame(86)=None
      cbCustGame(87)=None
      cbCustGame(88)=None
      cbCustGame(89)=None
      cbCustGame(90)=None
      cbCustGame(91)=None
      cbCustGame(92)=None
      cbCustGame(93)=None
      cbCustGame(94)=None
      cbCustGame(95)=None
      cbCustGame(96)=None
      cbCustGame(97)=None
      cbCustGame(98)=None
      cbCustGame(99)=None
      RemoteSaveButton=None
      ReloadMapsButton=None
      CloseButton=None
      ListCrashButton=None
      ClearCrashButton=None
      sldVoteTimeLimit=None
      lblVoteTimeLimit=None
      sldKickPercent=None
      lblKickPercent=None
      txtRepeatLimit=None
      txtMinMapCount=None
      sldMidGameVotePercent=None
      cboMode=None
      txtServerInfoURL=None
      txtMapInfoURL=None
      cboMapVoteHistoryType=None
      lblMidGameVotePercent=None
      lblGameTypeSection=None
      lblMiscSection=None
      lblOtherClass=None
      lblLimitsLabel=None
      lblMapPreFixOverRide=None
      lblRepeatLimit=None
      lblMinMapCount=None
      lblAdvancedSection=None
      lblServerInfoURL=None
      lblMapInfoURL=None
      lblASClass=None
      lblActGame=None
      lblActPrefix=None
      lblCustGame(0)=None
      lblCustGame(1)=None
      lblCustGame(2)=None
      lblCustGame(3)=None
      lblCustGame(4)=None
      lblCustGame(5)=None
      lblCustGame(6)=None
      lblCustGame(7)=None
      lblCustGame(8)=None
      lblCustGame(9)=None
      lblCustGame(10)=None
      lblCustGame(11)=None
      lblCustGame(12)=None
      lblCustGame(13)=None
      lblCustGame(14)=None
      lblCustGame(15)=None
      lblCustGame(16)=None
      lblCustGame(17)=None
      lblCustGame(18)=None
      lblCustGame(19)=None
      lblCustGame(20)=None
      lblCustGame(21)=None
      lblCustGame(22)=None
      lblCustGame(23)=None
      lblCustGame(24)=None
      lblCustGame(25)=None
      lblCustGame(26)=None
      lblCustGame(27)=None
      lblCustGame(28)=None
      lblCustGame(29)=None
      lblCustGame(30)=None
      lblCustGame(31)=None
      lblCustGame(32)=None
      lblCustGame(33)=None
      lblCustGame(34)=None
      lblCustGame(35)=None
      lblCustGame(36)=None
      lblCustGame(37)=None
      lblCustGame(38)=None
      lblCustGame(39)=None
      lblCustGame(40)=None
      lblCustGame(41)=None
      lblCustGame(42)=None
      lblCustGame(43)=None
      lblCustGame(44)=None
      lblCustGame(45)=None
      lblCustGame(46)=None
      lblCustGame(47)=None
      lblCustGame(48)=None
      lblCustGame(49)=None
      lblCustGame(50)=None
      lblCustGame(51)=None
      lblCustGame(52)=None
      lblCustGame(53)=None
      lblCustGame(54)=None
      lblCustGame(55)=None
      lblCustGame(56)=None
      lblCustGame(57)=None
      lblCustGame(58)=None
      lblCustGame(59)=None
      lblCustGame(60)=None
      lblCustGame(61)=None
      lblCustGame(62)=None
      lblCustGame(63)=None
      lblCustGame(64)=None
      lblCustGame(65)=None
      lblCustGame(66)=None
      lblCustGame(67)=None
      lblCustGame(68)=None
      lblCustGame(69)=None
      lblCustGame(70)=None
      lblCustGame(71)=None
      lblCustGame(72)=None
      lblCustGame(73)=None
      lblCustGame(74)=None
      lblCustGame(75)=None
      lblCustGame(76)=None
      lblCustGame(77)=None
      lblCustGame(78)=None
      lblCustGame(79)=None
      lblCustGame(80)=None
      lblCustGame(81)=None
      lblCustGame(82)=None
      lblCustGame(83)=None
      lblCustGame(84)=None
      lblCustGame(85)=None
      lblCustGame(86)=None
      lblCustGame(87)=None
      lblCustGame(88)=None
      lblCustGame(89)=None
      lblCustGame(90)=None
      lblCustGame(91)=None
      lblCustGame(92)=None
      lblCustGame(93)=None
      lblCustGame(94)=None
      lblCustGame(95)=None
      lblCustGame(96)=None
      lblCustGame(97)=None
      lblCustGame(98)=None
      lblCustGame(99)=None
      lblTemp=None
      cbUseMapList=None
      cbAutoOpen=None
      cbKickVote=None
      cbEntryWindows=None
      sldScoreBoardDelay=None
      lblScoreBoardDelay=None
      cbSortWithPreFix=None
      cbDebugMode=None
      txtList1Title=None
      txtList2Title=None
      txtList3Title=None
      txtList4Title=None
      txtMapVoteTitle=None
      txtList1Priority=None
      txtList2Priority=None
      txtList3Priority=None
      txtList4Priority=None
      txtASClass=None
      cbRemoveCrashedMaps=None
      cbUseExcludeFilter=None
}
