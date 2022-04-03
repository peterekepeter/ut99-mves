//================================================================================
// MapVoteClientWindow.
//================================================================================
class MapVoteClientWindow extends UWindowPageWindow;

#exec TEXTURE IMPORT FILE=TEXTURES\BackgroundTexture.pcx MIPS=OFF
#exec TEXTURE IMPORT FILE=TEXTURES\ListsBoxBackground.pcx MIPS=OFF

const VOTE_WAIT = 0.625;

var GameModeListBox GMListBox;
var DummyListBox RListDummy;
var RuleListBox RListBox[512];
var MapVoteListBox MapVoteListDummy;
var MapVoteListBox MapListBox[ArrayCount(RListBox)];
var UWindowSmallButton CloseButton;
var UWindowSmallButton VoteButton;
var UWindowSmallButton InfoButton;
var PlayerVoteListBox PlayerListBox;
var UWindowSmallButton KickVoteButton;
var MapStatusListBox lstMapStatus;
var KickStatusListBox lstKickStatus;
var UWindowCheckbox cbLoadScreenShot;
var UMenuLabelControl lblStatusTitles1;
var UMenuLabelControl lblStatusTitles2;
var UMenuLabelControl lblStatusTitles3;
var UMenuLabelControl lblStatusTitles4;
var UMenuLabelControl lblStatusTitles5;
var UMenuLabelControl lblKickVote1;
var UMenuLabelControl lblKickVote2;
var UMenuLabelControl lblTitle1;
var UMenuLabelControl lblTitle2;
var UMenuLabelControl lblTitle3;
var UMenuLabelControl lblTitle4;
var UMenuLabelControl lblTitle5;
var UMenuLabelControl lblTitle6;
var UMenuLabelControl lblTitle;
var UMenuLabelControl lblMaptxt1;
var UMenuLabelControl lblMaptxt2;
var UMenuLabelControl lblMaptxt3;
var UMenuLabelControl lblPriority1;
var UMenuLabelControl lblPriority2;
var UMenuLabelControl lblPriority3;
var UMenuLabelControl lblPriority4;
var UMenuLabelControl lblMapCount;
var UWindowEditControl txtFind;
var UWindowSmallButton SendButton;
var UWindowEditControl txtMessage;
var UMenuLabelControl lblMode;
var bool bKickVote;
var Texture Screenshot;
var string MapTitle;
var string MapAuthor;
var string IdealPlayerCount;
var float LastVoteTime;
var float SelectionTime;
var string LogoTexture;
var int MapListwidth;
var int PlayerListwidth;
var int ListHeight;
var bool bMapAlreadySet;
var string PrefixDictionary;
var MapVoteClientConfig ClientConf;
var Color RedColor;
var Color PurpleColor;
var Color LightBlueColor;
var Color TurquoiseColor;
var Color GreenColor;
var Color OrangeColor;
var Color YellowColor;
var Color PinkColor;
var Color WhiteColor;
var Color DeepBlueColor;
var Color BlackColor;
/* 
/////////////////////////////////////////////////////////////////////
var UWindowEditControl txtSearch;
var UWindowSmallButton btnNext, btnPrev;
var int SelectedSearchIndex;
var UMenuLabelControl lblSearch;
var float SearchOffset;
var int TotalSearchItems;
var string CurrentMapName;

struct ST_MapvoteList
{
  var UMenuMapVoteList Item;
  var byte Column;
};

var ST_MapvoteList SearchList[ArrayCount(RListBox)];

function NextSearchItem(optional bool bPrev)
{
  if(SelectedSearchIndex > 0)
  {
    if(bPrev)
    {
      SelectedSearchIndex--;
      if(SelectedSearchIndex < 1) SelectedSearchIndex = TotalSearchItems;    
    }
    else
    {       
      SelectedSearchIndex++;    
      if(SelectedSearchIndex > TotalSearchItems) SelectedSearchIndex = 1; 
    }    
    
    SelectMapFromSearch(SelectedSearchIndex);                   
    //lbSelectedMap.SetText("Selected Map:" $ CurrentMapName);
    lblSearch.SetText(SelectedSearchIndex$"/"$TotalSearchItems);
  }
  //else
    //lbSelectedMap.SetText("");
  
  if(len(txtSearch.GetValue()) >= 3) 
    lblSearch.SetText(SelectedSearchIndex$"/"$TotalSearchItems);
  else
    lblSearch.SetText("");
}


function ClearSearch()
{
   for(TotalSearchItems = 1; TotalSearchItems < ArrayCount(SearchList) && SearchList[TotalSearchItems].Item != None; TotalSearchItems++ )
   {
     SearchList[TotalSearchItems].Item = None;
     SearchList[TotalSearchItems].Column = -1;
   }
   
   TotalSearchItems = 0;
}


function FindMap(string SearchText)
{
   local UMenuMapVoteList MapItem;
   local int i;  

   //Clear first.
   ClearSearch();
   
   for(i = 0; i < ArrayCount(MapListBox); i++)
   {
     for(MapItem=UMenuMapVoteList(MapListBox[i].Items); MapItem != None; MapItem=UMenuMapVoteList(MapItem.Next) )
     {
        if(InStr( Caps(MapItem.MapName), Caps(SearchText) ) != -1 && TotalSearchItems < ArrayCount(SearchList))
        {
           SearchList[++TotalSearchItems].Item = MapItem;
           SearchList[TotalSearchItems].Column = i;
        }
     }
   }
   
   if(TotalSearchItems > 0)
    SelectMapFromSearch(1);
}


function SelectMapFromSearch(int Index)
{
  if(SearchList[Index].Item != None) 
   {
     MapListBox[SearchList[Index].Column].SetSelectedItem(SearchList[Index].Item);     
     CurrentMapName = SearchList[Index].Item.MapName;
   }    
}
/////////////////////////////////////////////////////////////////////
 */
function MapVoteListBox GetMapVoteList(int Num)
{
	if (Num < 0)
		return MapVoteListDummy;
    return MapListBox[Num];
}

function int GetMapVoteListNum(MapVoteListBox MLB)
{
    local int i;
    if (MLB == MapVoteListDummy) {
    	return UMenuMapVoteList(MapVoteListDummy.SelectedItem).CGNum;
    }

    for (i = 0; i < ArrayCount(MapListBox); ++ i)
    {
        if (MLB == MapListBox[i])
            return i;
    }
}

function Created ()
{
	local Color TextColor;
	local Color MainTitleColor;
	local Color TitleColor;
	local Color GameModTitleColor;
	local Color RuleTitleColor;
	local Color MapTitleColor;
	local Color KickVoteTitleColor;
	local Color PlayerTitleColor;
	local Color MapVoteTitleColor;
	local Color TitleColor1;
	local Color TitleColor2;
	local Color TitleColor3;
	local Color TitleColor4;
	local Color TitleColor5;
	local Color TitleColor6;
	local Color TextColorTitles;
	local Color TextColorTitle;
	local int LowSectionStart;
	local int RightSectionStart;
	local int i;
	//local float XL;

	Super.Created();
	ClientConf = new (class'MapVoteClientConfig', 'MapVoteClientConfig') class'MapVoteClientConfig';

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

	TextColor.R=171;
	TextColor.G=171;
	TextColor.B=171;
	TextColorTitles.R=255;
	TextColorTitles.G=10;
	TextColorTitles.B=10;
	TextColorTitle.R=255;
	TextColorTitle.G=255;
	TextColorTitle.B=10;

	MapListwidth = 120;
	PlayerListwidth = 120;
	ListHeight = 324;
	LowSectionStart = ListHeight + 81;
	RightSectionStart = 400;
	/* 
	XL = 20.0;
	btnNext = UWindowSmallButton(CreateControl(Class'UWindowSmallButton',WinWidth - XL,0.0,20.0,20.0));
	btnNext.bAlwaysOnTop = True;
	btnNext.Text = ">";
	btnNext.bDisabled = False;
	XL += 20;
	btnPrev = UWindowSmallButton(CreateControl(Class'UWindowSmallButton',WinWidth - XL,0.0,20.0,20.0));
	btnPrev.bAlwaysOnTop = True;
	btnPrev.Text = "<";
	btnPrev.bDisabled = False;
	XL += 200;
	txtSearch = UWindowEditControl(CreateControl(Class'UWindowEditControl',WinWidth - XL,0.0,200.0,20.0));
	txtSearch.bAlwaysOnTop = True;
	txtSearch.SetNumericOnly(False);
	txtSearch.SetHistory(True);
	txtSearch.SetMaxLength(150);
	lblSearch = UMenuLabelControl(CreateControl(Class'UMenuLabelControl',WinWidth - XL,0.0,60.0,20.0));
	lblSearch.SetText("Search");
	lblSearch.SetFont(0);
	lblSearch.SetTextColor(TextColor);
	*/
	GMListBox = GameModeListBox(CreateControl(Class'GameModeListBox',10.0,26.0,MapListwidth,ListHeight / 2));
	GMListBox.Items.Clear();
	RListDummy = DummyListBox(CreateControl(Class'DummyListBox',20.0 + MapListwidth,26.0,MapListwidth,ListHeight / 2));
	MapVoteListDummy = MapVoteListBox(CreateControl(Class'MapVoteListBox',40.0 + 2 * MapListwidth + PlayerListwidth,26.0,MapListwidth * 2 + 10,ListHeight + 12));
	MapVoteListDummy.CW = self;
	
	for ( i = 0; i < ArrayCount(RListBox); i++ )
	{
		RListBox[i] = RuleListBox(CreateControl(Class'RuleListBox',20.0 + MapListwidth,26.0,0.0,0.0));
		RListBox[i].Items.Clear();
		MapListBox[i] = MapVoteListBox(CreateControl(Class'MapVoteListBox',40.0 + 2 * MapListwidth + PlayerListwidth,26.0,0.0,0.0));
		MapListBox[i].Items.Clear();
	}
	
	VoteButton = UWindowSmallButton(CreateControl(Class'UWindowSmallButton',40.0 + 2 * MapListwidth + PlayerListwidth,ListHeight + 46,MapListwidth * 2 + 10,21.0));
	VoteButton.DownSound=Sound'Click';
	VoteButton.Text = "Vote";
	VoteButton.bDisabled = False;
	PlayerListBox = PlayerVoteListBox(CreateControl(Class'PlayerVoteListBox',30.0 + 2 * MapListwidth,219.0,PlayerListwidth,-180.0 + ListHeight));
	PlayerListBox.Items.Clear();
	PlayerListBox.bDisabled = True;
	KickVoteButton = UWindowSmallButton(CreateControl(Class'UWindowSmallButton',30.0 + 2 * MapListwidth,ListHeight + 46,PlayerListwidth,18.0));
	KickVoteButton.DownSound=Sound'Click';
	
	if ( bKickVote || GetPlayerOwner().PlayerReplicationInfo.bAdmin )
	{
		KickVoteButton.Text = "Kick";
		KickVoteButton.bDisabled = True;
	} else {
		KickVoteButton.Text = "";
		KickVoteButton.bDisabled = False;
	}
	
	lblKickVote1 = UMenuLabelControl(CreateControl(Class'UMenuLabelControl',10.0,217.0,60,60.0));
	lblKickVote1.SetText("Player Name");
	lblKickVote1.SetFont(0);
	lblKickVote1.SetTextColor(TextColor);
	lblKickVote2 = UMenuLabelControl(CreateControl(Class'UMenuLabelControl',220.0,217.0,25,60.0));
	lblKickVote2.SetText("Votes");
	lblKickVote2.SetFont(0);
	lblKickVote2.SetTextColor(TextColor);
	lblStatusTitles1 = UMenuLabelControl(CreateControl(Class'UMenuLabelControl',10.0,LowSectionStart - 3,60.0,10.0));
	lblStatusTitles1.SetText("Rank");
	lblStatusTitles1.SetFont(0);
	lblStatusTitles1.SetTextColor(TextColor);
	lblStatusTitles2 = UMenuLabelControl(CreateControl(Class'UMenuLabelControl',28.0 + 10,LowSectionStart - 3,60.0,10.0));
	lblStatusTitles2.SetText("Map Name");
	lblStatusTitles2.SetFont(0);
	lblStatusTitles2.SetTextColor(TextColor);
	lblStatusTitles3 = UMenuLabelControl(CreateControl(Class'UMenuLabelControl',188.50 + 10,LowSectionStart - 3,60.0,10.0));
	lblStatusTitles3.SetText("Game Mode");
	lblStatusTitles3.SetFont(0);
	lblStatusTitles3.SetTextColor(TextColor);
	lblStatusTitles4 = UMenuLabelControl(CreateControl(Class'UMenuLabelControl',349.50 + 10,LowSectionStart - 3,60.0,10.0));
	lblStatusTitles4.SetText("Rule");
	lblStatusTitles4.SetFont(0);
	lblStatusTitles4.SetTextColor(TextColor);
	lblStatusTitles5 = UMenuLabelControl(CreateControl(Class'UMenuLabelControl',521.00,LowSectionStart - 3,60.0,10.0));
	lblStatusTitles5.SetText("Votes");
	lblStatusTitles5.SetFont(0);
	lblStatusTitles5.SetTextColor(TextColor);
	lstMapStatus = MapStatusListBox(CreateControl(Class'MapStatusListBox',10.0,LowSectionStart + 12,550.0,84.0));
	lstMapStatus.bAcceptsFocus = False;
	lstMapStatus.Items.Clear();
	lstKickStatus = KickStatusListBox(CreateControl(Class'KickStatusListBox',10.0,231.0,MapListwidth * 2 + 10,-192.0 + ListHeight));
	lstKickStatus.bAcceptsFocus = False;
	lstKickStatus.Items.Clear();
	lblMaptxt1 = UMenuLabelControl(CreateControl(Class'UMenuLabelControl',30.0 + 2 * MapListwidth,140.0,PlayerListwidth,10.0));
	lblMaptxt1.SetTextColor(TextColor);
	lblMaptxt1.Align=TA_Center;
	lblMaptxt2 = UMenuLabelControl(CreateControl(Class'UMenuLabelControl',30.0 + 2 * MapListwidth,149.0,PlayerListwidth,10.0));
	lblMaptxt2.SetTextColor(TextColor);
	lblMaptxt2.Align=TA_Center;
	lblMaptxt3 = UMenuLabelControl(CreateControl(Class'UMenuLabelControl',30.0 + 2 * MapListwidth,158.0,PlayerListwidth,10.0));
	lblMaptxt3.SetTextColor(TextColor);
	lblMaptxt3.Align=TA_Center;
	lblTitle1 = UMenuLabelControl(CreateControl(Class'UMenuLabelControl',0.0,10.0,MapListwidth + 20,20.0));
	lblTitle1.SetFont(1);
	lblTitle1.Align=TA_Center;
	lblTitle1.SetTextColor(TextColorTitles);
	lblTitle1.SetText("Game Mode");
	lblTitle1.SetTextColor(TitleColor1);
	lblTitle2 = UMenuLabelControl(CreateControl(Class'UMenuLabelControl',10.0 + MapListwidth,10.0,MapListwidth + 20,20.0));
	lblTitle2.SetFont(1);
	lblTitle2.Align=TA_Center;
	lblTitle2.SetTextColor(TextColorTitles);
	lblTitle2.SetText("Rule");
	lblTitle2.SetTextColor(TitleColor2);
	lblTitle = UMenuLabelControl(CreateControl(Class'UMenuLabelControl',15.0 + 2 * MapListwidth,10.0,PlayerListwidth + 30,20.0));
	lblTitle.SetFont(1);
	lblTitle.Align=TA_Center;
	lblTitle.SetTextColor(TextColorTitle);
	lblTitle3 = UMenuLabelControl(CreateControl(Class'UMenuLabelControl',30.0 + 2.5 * MapListwidth + PlayerListwidth,10.0,MapListwidth + 20,20.0));
	lblTitle3.SetFont(1);
	lblTitle3.Align=TA_Center;
	lblTitle3.SetTextColor(TextColorTitles);
	lblTitle3.SetText("New Maps");
	lblTitle3.SetTextColor(TitleColor3);
	lblTitle4 = UMenuLabelControl(CreateControl(Class'UMenuLabelControl',15.0 + 2 * MapListwidth,197.0,PlayerListwidth + 30,20.0));
	lblTitle4.SetFont(1);
	lblTitle4.Align=TA_Center;
	lblTitle4.SetTextColor(TextColorTitles);
	lblTitle4.SetText("Player");
	lblTitle4.SetTextColor(TitleColor5);
	lblTitle5 = UMenuLabelControl(CreateControl(Class'UMenuLabelControl',(10.0 + MapListwidth) / 2,197.0,PlayerListwidth + 30,20.0));
	lblTitle5.SetFont(1);
	lblTitle5.Align=TA_Center;
	lblTitle5.SetTextColor(TextColorTitles);
	lblTitle5.SetText("Kick Vote");
	lblTitle5.SetTextColor(TitleColor4);
	lblTitle6 = UMenuLabelControl(CreateControl(Class'UMenuLabelControl',(10.0 + MapListwidth) / 2,ListHeight + 70,PlayerListwidth + 30,20.0));
	lblTitle6.SetFont(1);
	lblTitle6.Align=TA_Center;
	lblTitle6.SetTextColor(TextColorTitles);
	lblTitle6.SetText("Map Vote");
	lblTitle6.SetTextColor(TitleColor6);
	lblPriority1 = UMenuLabelControl(CreateControl(Class'UMenuLabelControl',0.0,ListHeight + 30,MapListwidth + 20,20.0));
	lblPriority1.Align=TA_Center;
	lblPriority1.SetTextColor(TextColor);
	lblPriority2 = UMenuLabelControl(CreateControl(Class'UMenuLabelControl',10.0 + MapListwidth,ListHeight + 30,MapListwidth + 20,20.0));
	lblPriority2.Align=TA_Center;
	lblPriority2.SetTextColor(TextColor);
	lblPriority3 = UMenuLabelControl(CreateControl(Class'UMenuLabelControl',30.0 + 2 * MapListwidth + PlayerListwidth,ListHeight + 30,MapListwidth + 20,20.0));
	lblPriority3.Align=TA_Center;
	lblPriority3.SetTextColor(TextColor);
	lblPriority4 = UMenuLabelControl(CreateControl(Class'UMenuLabelControl',40.0 + 3 * MapListwidth + PlayerListwidth,ListHeight + 30,MapListwidth + 20,20.0));
	lblPriority4.Align=TA_Center;
	lblPriority4.SetTextColor(TextColor);
	cbLoadScreenShot = UWindowCheckbox(CreateControl(Class'UWindowCheckbox',30.0 + 2 * MapListwidth,175.0,70.0,20.0));
	cbLoadScreenShot.SetText("Screenshot");
	cbLoadScreenShot.Align=TA_Right;
	cbLoadScreenShot.SetFont(0);
	cbLoadScreenShot.SetTextColor(TextColor);
	cbLoadScreenShot.bChecked = ClientConf.bLoadScreenShot;
	txtMessage = UWindowEditControl(CreateControl(Class'UWindowEditControl',-3.41 * MapListwidth / 2 + 10,ListHeight + 46,3.41 * MapListwidth,20.0));
	txtMessage.SetNumericOnly(False);
	txtMessage.SetHistory(True);
	txtMessage.SetMaxLength(150);
	SendButton = UWindowSmallButton(CreateControl(Class'UWindowSmallButton',20.0 + 2 * MapListwidth - 40,ListHeight + 46,40.0,20.0));
	SendButton.DownSound=Sound'Click';
	SendButton.Text = "Send";
	SendButton.bDisabled = False;
}

function DeSelectAllOtherMapListBoxItems (MapVoteListBox selListBox, int listNum)
{
	local int i;

	for( i = 0; i < ArrayCount(MapListBox); i++)
	{
		if(listnum != i)
		{
			if(MapListBox[i].SelectedItem != None)
			{
				MapListBox[i].SelectedItem.bSelected = False;
				MapListBox[i].SelectedItem = None;
			}
		}
	}
	if(listNum >= 0 && listnum < ArrayCount(RListBox))  
		selListBox.MakeSelectedVisible();
}

function UWindowListBoxItem getSelectedItem(optional out int CGNum)
{
    local int i;
	
    for( i = 0; i < ArrayCount(MapListBox); i++)
    {
        if(MapListBox[i].SelectedItem != none)
        {
            CGNum = i;
            return MapListBox[i].SelectedItem;
        }
    }
}

function Notify (UWindowDialogControl C, byte E)
{
	local int listNum;
	local int i;

	Super.Notify(C,E);
	switch (E)
	{
        case DE_Change:
            switch(C)
            {
				default:
			}
			break;
				
		case DE_DoubleClick:
			switch (C)
			{
				case MapVoteListBox(C):
				
					if ( MapVoteListBox(C).SelectedItem == None )
						return;
					listNum = GetMapVoteListNum(MapVoteListBox(C));
					if ( GetPlayerOwner().Level.TimeSeconds > LastVoteTime + 0.625 )
					{
						if ( (Left(UMenuMapVoteList(MapVoteListBox(C).SelectedItem).MapName,3) != "[X]") || GetPlayerOwner().PlayerReplicationInfo.bAdmin )
						{
							GetPlayerOwner().ConsoleCommand("MUTATE BDBMAPVOTE MAP " $ UMenuMapVoteList(MapVoteListBox(C).SelectedItem).MapName $ ":" $ string(listNum));
							LastVoteTime = GetPlayerOwner().Level.TimeSeconds;
						}
					}
					SelectionTime = GetPlayerOwner().Level.TimeSeconds;
					DeSelectAllOtherMapListBoxItems(MapVoteListBox(C),listNum);
					break;
					
				case lstMapStatus:
				
					if ( MapStatusListItem(lstMapStatus.SelectedItem) == None )
						return;
					listNum = MapStatusListItem(lstMapStatus.SelectedItem).CGNum;
					DeSelectAllOtherMapListBoxItems(MapListBox[0],0);
					MapListBox[listNum].SelectMap(MapStatusListItem(lstMapStatus.SelectedItem).MapName);
					if ( GetPlayerOwner().Level.TimeSeconds > LastVoteTime + 0.625 )
					{
						GetPlayerOwner().ConsoleCommand("MUTATE BDBMAPVOTE MAP " $ MapStatusListItem(lstMapStatus.SelectedItem).MapName $ ":" $ string(MapStatusListItem(lstMapStatus.SelectedItem).CGNum));
						LastVoteTime = GetPlayerOwner().Level.TimeSeconds;
					}
					SelectionTime = GetPlayerOwner().Level.TimeSeconds;
					break;
					
				case PlayerListBox:
				
					if ( PlayerVoteListItem(PlayerListBox.SelectedItem) == None )
						return;
					if ( GetPlayerOwner().Level.TimeSeconds > LastVoteTime + 0.625 )
					{
						GetPlayerOwner().ConsoleCommand("MUTATE BDBMAPVOTE KICK " $ PlayerVoteListItem(PlayerListBox.SelectedItem).PlayerName);
						LastVoteTime = GetPlayerOwner().Level.TimeSeconds;
					}
					break;
					
				case lstKickStatus:
				
					if ( PlayerVoteListItem(PlayerListBox.SelectedItem) == None )
						return;
					PlayerListBox.SelectPlayer(KickStatusListItem(lstKickStatus.SelectedItem).PlayerName);
					Log("Select Player:" @ KickStatusListItem(lstKickStatus.SelectedItem).PlayerName);
					if ( GetPlayerOwner().Level.TimeSeconds > LastVoteTime + 0.625 )
					{
						GetPlayerOwner().ConsoleCommand("MUTATE BDBMAPVOTE KICK " $ PlayerVoteListItem(PlayerListBox.SelectedItem).PlayerName);
						LastVoteTime = GetPlayerOwner().Level.TimeSeconds;
					}
					break;
				default:
			}
			break;
		
		case DE_Click:
			switch (C)
			{
				case GMListBox:
				
					if ( UMenuGameModeVoteList(GMListBox.SelectedItem) == None )
						return;
					listNum = UMenuGameModeVoteList(GMListBox.SelectedItem).listNum;
					RListDummy.WinWidth = 0.0;
					RListDummy.WinHeight = 0.0;
					RListDummy.Resized();
					MapVoteListDummy.WinWidth = MapListwidth * 2 + 10;
					MapVoteListDummy.WinHeight = ListHeight + 12;
					MapVoteListDummy.Resized();
					lblTitle3.SetText("New maps");
					
					for ( i = 0; i < ArrayCount(RListBox); i++ )
					{
						if ( MapListBox[i].SelectedItem != None )
						{
							MapListBox[i].SelectedItem.bSelected = False;
						}
						MapListBox[i].SelectedItem = None;
						MapListBox[i].WinWidth = 0.0;
						MapListBox[i].WinHeight = 0.0;
						MapListBox[i].Resized();
						if ( RListBox[i].SelectedItem != None )
						{
							RListBox[i].SelectedItem.bSelected = False;
						}
						RListBox[i].SelectedItem = None;
						RListBox[i].WinWidth = 0.0;
						RListBox[i].WinHeight = 0.0;
						RListBox[i].Resized();
					}
					RListBox[listNum].WinWidth = MapListwidth;
					RListBox[listNum].WinHeight = ListHeight / 2;
					RListBox[listNum].Resized();
					break;
					
				case RuleListBox(C):
				
					if ( UMenuRuleVoteList(RuleListBox(C).SelectedItem) == None )
						return;
					listNum = UMenuRuleVoteList(RuleListBox(C).SelectedItem).listNum;
					MapVoteListDummy.WinWidth = 0.0;
					MapVoteListDummy.WinHeight = 0.0;
					MapVoteListDummy.Resized();
					
					for ( i = 0; i < 63; i++ )
					{
						if ( MapListBox[i].SelectedItem != None )
						{
							MapListBox[i].SelectedItem.bSelected = False;
						}
						MapListBox[i].SelectedItem = None;
						MapListBox[i].WinWidth = 0.0;
						MapListBox[i].WinHeight = 0.0;
						MapListBox[i].Resized();
					}
					MapListBox[listNum].WinWidth = MapListwidth * 2 + 10;
					MapListBox[listNum].WinHeight = ListHeight + 12;
					MapListBox[listNum].Resized();
					lblTitle3.SetText(string(MapListBox[listNum].Count) @ "Map / Priority=" $ Mid(string(MapListBox[listNum].VotePriority),0,3));
					break;
					
				case SendButton:
				
					if ( txtMessage.GetValue() != "" )
					{
						GetPlayerOwner().ConsoleCommand("SAY " $ txtMessage.GetValue());
						txtMessage.SetValue("");
					}
					break;
					
				case VoteButton:
				
					if ( GetPlayerOwner().Level.TimeSeconds > LastVoteTime + 0.625 )
					{
						if ( getSelectedItem(listNum) != None )
						{
							if ( (Left(UMenuMapVoteList(getSelectedItem()).MapName,3) != "[X]") || GetPlayerOwner().PlayerReplicationInfo.bAdmin )
							{
								if ( UMenuMapVoteList(getSelectedItem()).MapName != "" )
								{
									GetPlayerOwner().ConsoleCommand("MUTATE BDBMAPVOTE MAP " $ UMenuMapVoteList(getSelectedItem()).MapName $ ":" $ string(listNum));
								}
								LastVoteTime = GetPlayerOwner().Level.TimeSeconds;
							}
						}
					}
					break;
					
				case CloseButton:
				
					ParentWindow.ParentWindow.Close();
					break;
					
				case MapVoteListBox(C):
				
					if ( MapVoteListBox(C).SelectedItem == None )
						return;
					listNum = GetMapVoteListNum(MapVoteListBox(C));
					SelectionTime = GetPlayerOwner().Level.TimeSeconds;
					DeSelectAllOtherMapListBoxItems(MapVoteListBox(C),listNum);
					break;
					
				case lstMapStatus:
				
					if ( MapStatusListItem(lstMapStatus.SelectedItem) == None )
						return;
					listNum = MapStatusListItem(lstMapStatus.SelectedItem).CGNum;
					DeSelectAllOtherMapListBoxItems(MapListBox[0],0);
					MapListBox[listNum].SelectMap(MapStatusListItem(lstMapStatus.SelectedItem).MapName);
					SelectionTime = GetPlayerOwner().Level.TimeSeconds;
					break;
					
				case KickVoteButton:
					if ( PlayerVoteListItem(PlayerListBox.SelectedItem) == None )
						return;
					if ( GetPlayerOwner().Level.TimeSeconds > LastVoteTime + 0.625 )
					{
						GetPlayerOwner().ConsoleCommand("MUTATE BDBMAPVOTE KICK " $ PlayerVoteListItem(PlayerListBox.SelectedItem).PlayerName);
						LastVoteTime = GetPlayerOwner().Level.TimeSeconds;
					}
					break;
					
				case lstKickStatus:
				
					if ( KickStatusListItem(lstKickStatus.SelectedItem) == None )
						return;
					PlayerListBox.SelectPlayer(KickStatusListItem(lstKickStatus.SelectedItem).PlayerName);
					break;
				default:
			}
			break;
			
		case DE_EnterPressed:
			switch(C)
			{
				case txtMessage:
					if ( txtMessage.GetValue() != "" )
					{
						GetPlayerOwner().ConsoleCommand("SAY " $ txtMessage.GetValue());
						txtMessage.SetValue("");
						txtMessage.FocusOtherWindow(SendButton);
					}
					break;
			}
	default:
	}
}

function int getListNum(string MapName, int CGNum)
{
    local int i;

    i = 0;
    J0x07:
    // End:0x40 [Loop If]
    if(i < 63)
    {
        // End:0x36
        if(MapListBox[i].isMapInList(MapName))
        {
            return i;
        }
        ++ i;
        // [Loop Continue]
        goto J0x07;
    }
}

function Tick(float DeltaTime)
{
    local string MapName;
	
    Super(UWindowWindow).Tick(DeltaTime);
	
	if ( (SelectionTime != 0) && (GetPlayerOwner().Level.TimeSeconds > SelectionTime + 1) && (getSelectedItem() != None) )
    {
        MapName = UMenuMapVoteList(getSelectedItem()).MapName;
        SetMap(MapName);
        SelectionTime = 0.0;
    }
	Super.Tick(DeltaTime);
}

function SetMap(string MapName)
{
    local int i, pos;
    local string Prefix, RealPreFix, RealMapName;
    local LevelSummary L;
	
	if ( !cbLoadScreenShot.bChecked )
		return;
	
    bMapAlreadySet = true;
    i = InStr(Caps(MapName), ".UNR");
	
    if(i != -1)
		MapName = Left(MapName, i);
	
    RealMapName = GetRealMapname(MapName);
    Screenshot = Texture(DynamicLoadObject(RealMapName $ ".Screenshot", class'Texture'));
    L = LevelSummary(DynamicLoadObject(RealMapName $ ".LevelSummary", class'LevelSummary'));
	
    if(Left(MapName, 3) == "[X]")
    {
        MapTitle = "You can not";
        MapAuthor = "vote for this map.";
        IdealPlayerCount = "";
    }
    else
    {
        if(L != none)
        {
            MapTitle = L.Title;
            MapAuthor = L.Author;
            IdealPlayerCount = L.IdealPlayerCount;
        }
        else
        {
            MapTitle = "Download";
            MapAuthor = "Required";
            IdealPlayerCount = "";
        }
    }
}

function string GetRealMapname(string VirtualMap)
{
	local string MapName, Dictionary, virt, Real;

	Dictionary = "TDM;DM;LMS;DM;" $ PrefixDictionary;

	if(Left(VirtualMap, 3) ~= "[X]")VirtualMap = Mid(VirtualMap, 3);
		MapName = VirtualMap;

    while(Dictionary != "")
    {
        virt = Left(Dictionary, InStr(Dictionary, ";"));
        Dictionary = Mid(Dictionary, InStr(Dictionary, ";") + 1);
        Real = Left(Dictionary, InStr(Dictionary, ";"));
        Dictionary = Mid(Dictionary, InStr(Dictionary, ";") + 1);
		
        if((Left(VirtualMap, 4) != "CTF-") && Left(VirtualMap, Len(virt) + 1) ~= (virt $ "-"))
        {
            MapName = Real $ Mid(VirtualMap, Len(virt));
            return MapName;
        }
    }
    return MapName;
}

function Paint (Canvas C, float MouseX, float MouseY)
{
	local int i;
	local int P1;
	local int P2;
	local int pos;
	local string TempText;
	local string textline;
	local float X;
	local float Y;
	local float W;
	local float H;

	Super.Paint(C,MouseX,MouseY);
	
	C.DrawColor = class'MapVoteClientConfig'.Default.BackgroundColor;
	DrawStretchedTexture(C,0.00,0.00,WinWidth,WinHeight,Texture'BackgroundTexture');
	
	if (  !bMapAlreadySet && (LogoTexture != "") && (Screenshot == None) )
	{
		Screenshot=Texture(DynamicLoadObject(LogoTexture,Class'Texture'));
		bMapAlreadySet=True;
	}
	if ( Screenshot != None )
	{
		C.DrawColor.R=255;
		C.DrawColor.G=255;
		C.DrawColor.B=255;
		DrawStretchedTexture(C,30.00 + 2 * MapListwidth,27.00,PlayerListwidth,110.00,Screenshot);
	}
	if ( MapTitle != "" )
	{
		lblMaptxt1.SetText(MapTitle);
	} else {
		lblMaptxt1.SetText("");
	}
	if ( MapAuthor != "" )
	{
		lblMaptxt2.SetText(MapAuthor);
	} else {
		lblMaptxt2.SetText("");
	}
	if ( IdealPlayerCount != "" )
	{
		lblMaptxt3.SetText(IdealPlayerCount @ "Players");
	} else {
		lblMaptxt3.SetText("");
	}
}

function KeyDown (int Key, float X, float Y)
{
	ParentWindow.KeyDown(Key,X,Y);
}

function Close (optional bool bByParent)
{
	local int W;
	local int Mode;

	if ( ClientConf.bLoadScreenShot != cbLoadScreenShot.bChecked )
	{
		ClientConf.bLoadScreenShot = cbLoadScreenShot.bChecked;
		ClientConf.SaveConfig();
	}
	Super.Close(bByParent);
}

defaultproperties
{
    RedColor=(R=255,G=0,B=0,A=0),
    PurpleColor=(R=128,G=0,B=128,A=0),
    LightBlueColor=(R=0,G=100,B=255,A=0),
    TurquoiseColor=(R=0,G=255,B=255,A=0),
    GreenColor=(R=0,G=255,B=0,A=0),
    OrangeColor=(R=255,G=120,B=0,A=0),
    YellowColor=(R=255,G=255,B=0,A=0),
    PinkColor=(R=255,G=0,B=255,A=0),
    WhiteColor=(R=255,G=255,B=255,A=0),
    DeepBlueColor=(R=0,G=0,B=255,A=0),
}