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
	// commenting out next line disables prefix for new maps section
  // MapVoteListDummy.CW = self; 
	
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
	if (MapVoteListDummy.SelectedItem != None) {
		CGNum = UMenuMapVoteList(MapVoteListDummy.SelectedItem).CGNum;
		return MapVoteListDummy.SelectedItem;
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
					lblTitle3.SetText("New Maps");
					
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
    if(i < ArrayCount(RListBox))
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

final simulated function RuleListBox GetRListBox( int Idx)
{
	return RListBox[Idx];
}

final simulated function MapVoteListBox GetMapListBox( int Idx)
{
	return MapListBox[Idx];
}
 
simulated function string GetPrefix(int CGNum) {
	local string ret;
	local int i, rule;
	local UMenuRuleVoteList MenuRule;
	local UMenuGameModeVoteList MenuGame;
	
	for ( i = 0; i < ArrayCount(RListBox); i++ ) {
		for (MenuRule = UMenuRuleVoteList(RListBox[i].Items.Next); MenuRule != None; MenuRule = UMenuRuleVoteList(MenuRule.Next)) {
			if (MenuRule.listNum == CGNum) {
				rule = i;
				ret = MenuRule.MapName;
				break;
			}
		}
	}
	
	for (MenuGame = UMenuGameModeVoteList(GMListBox.Items.Next); MenuGame != None; MenuGame = UMenuGameModeVoteList(MenuGame.Next)) {
		if (MenuGame.listNum == rule) {
			ret = MenuGame.MapName @ "-" @ ret;
			break;
		}
	}
		
	return "[" $ ret $ "] ";
}

defaultproperties
{
      GMListBox=None
      RListDummy=None
      RListBox(0)=None
      RListBox(1)=None
      RListBox(2)=None
      RListBox(3)=None
      RListBox(4)=None
      RListBox(5)=None
      RListBox(6)=None
      RListBox(7)=None
      RListBox(8)=None
      RListBox(9)=None
      RListBox(10)=None
      RListBox(11)=None
      RListBox(12)=None
      RListBox(13)=None
      RListBox(14)=None
      RListBox(15)=None
      RListBox(16)=None
      RListBox(17)=None
      RListBox(18)=None
      RListBox(19)=None
      RListBox(20)=None
      RListBox(21)=None
      RListBox(22)=None
      RListBox(23)=None
      RListBox(24)=None
      RListBox(25)=None
      RListBox(26)=None
      RListBox(27)=None
      RListBox(28)=None
      RListBox(29)=None
      RListBox(30)=None
      RListBox(31)=None
      RListBox(32)=None
      RListBox(33)=None
      RListBox(34)=None
      RListBox(35)=None
      RListBox(36)=None
      RListBox(37)=None
      RListBox(38)=None
      RListBox(39)=None
      RListBox(40)=None
      RListBox(41)=None
      RListBox(42)=None
      RListBox(43)=None
      RListBox(44)=None
      RListBox(45)=None
      RListBox(46)=None
      RListBox(47)=None
      RListBox(48)=None
      RListBox(49)=None
      RListBox(50)=None
      RListBox(51)=None
      RListBox(52)=None
      RListBox(53)=None
      RListBox(54)=None
      RListBox(55)=None
      RListBox(56)=None
      RListBox(57)=None
      RListBox(58)=None
      RListBox(59)=None
      RListBox(60)=None
      RListBox(61)=None
      RListBox(62)=None
      RListBox(63)=None
      RListBox(64)=None
      RListBox(65)=None
      RListBox(66)=None
      RListBox(67)=None
      RListBox(68)=None
      RListBox(69)=None
      RListBox(70)=None
      RListBox(71)=None
      RListBox(72)=None
      RListBox(73)=None
      RListBox(74)=None
      RListBox(75)=None
      RListBox(76)=None
      RListBox(77)=None
      RListBox(78)=None
      RListBox(79)=None
      RListBox(80)=None
      RListBox(81)=None
      RListBox(82)=None
      RListBox(83)=None
      RListBox(84)=None
      RListBox(85)=None
      RListBox(86)=None
      RListBox(87)=None
      RListBox(88)=None
      RListBox(89)=None
      RListBox(90)=None
      RListBox(91)=None
      RListBox(92)=None
      RListBox(93)=None
      RListBox(94)=None
      RListBox(95)=None
      RListBox(96)=None
      RListBox(97)=None
      RListBox(98)=None
      RListBox(99)=None
      RListBox(100)=None
      RListBox(101)=None
      RListBox(102)=None
      RListBox(103)=None
      RListBox(104)=None
      RListBox(105)=None
      RListBox(106)=None
      RListBox(107)=None
      RListBox(108)=None
      RListBox(109)=None
      RListBox(110)=None
      RListBox(111)=None
      RListBox(112)=None
      RListBox(113)=None
      RListBox(114)=None
      RListBox(115)=None
      RListBox(116)=None
      RListBox(117)=None
      RListBox(118)=None
      RListBox(119)=None
      RListBox(120)=None
      RListBox(121)=None
      RListBox(122)=None
      RListBox(123)=None
      RListBox(124)=None
      RListBox(125)=None
      RListBox(126)=None
      RListBox(127)=None
      RListBox(128)=None
      RListBox(129)=None
      RListBox(130)=None
      RListBox(131)=None
      RListBox(132)=None
      RListBox(133)=None
      RListBox(134)=None
      RListBox(135)=None
      RListBox(136)=None
      RListBox(137)=None
      RListBox(138)=None
      RListBox(139)=None
      RListBox(140)=None
      RListBox(141)=None
      RListBox(142)=None
      RListBox(143)=None
      RListBox(144)=None
      RListBox(145)=None
      RListBox(146)=None
      RListBox(147)=None
      RListBox(148)=None
      RListBox(149)=None
      RListBox(150)=None
      RListBox(151)=None
      RListBox(152)=None
      RListBox(153)=None
      RListBox(154)=None
      RListBox(155)=None
      RListBox(156)=None
      RListBox(157)=None
      RListBox(158)=None
      RListBox(159)=None
      RListBox(160)=None
      RListBox(161)=None
      RListBox(162)=None
      RListBox(163)=None
      RListBox(164)=None
      RListBox(165)=None
      RListBox(166)=None
      RListBox(167)=None
      RListBox(168)=None
      RListBox(169)=None
      RListBox(170)=None
      RListBox(171)=None
      RListBox(172)=None
      RListBox(173)=None
      RListBox(174)=None
      RListBox(175)=None
      RListBox(176)=None
      RListBox(177)=None
      RListBox(178)=None
      RListBox(179)=None
      RListBox(180)=None
      RListBox(181)=None
      RListBox(182)=None
      RListBox(183)=None
      RListBox(184)=None
      RListBox(185)=None
      RListBox(186)=None
      RListBox(187)=None
      RListBox(188)=None
      RListBox(189)=None
      RListBox(190)=None
      RListBox(191)=None
      RListBox(192)=None
      RListBox(193)=None
      RListBox(194)=None
      RListBox(195)=None
      RListBox(196)=None
      RListBox(197)=None
      RListBox(198)=None
      RListBox(199)=None
      RListBox(200)=None
      RListBox(201)=None
      RListBox(202)=None
      RListBox(203)=None
      RListBox(204)=None
      RListBox(205)=None
      RListBox(206)=None
      RListBox(207)=None
      RListBox(208)=None
      RListBox(209)=None
      RListBox(210)=None
      RListBox(211)=None
      RListBox(212)=None
      RListBox(213)=None
      RListBox(214)=None
      RListBox(215)=None
      RListBox(216)=None
      RListBox(217)=None
      RListBox(218)=None
      RListBox(219)=None
      RListBox(220)=None
      RListBox(221)=None
      RListBox(222)=None
      RListBox(223)=None
      RListBox(224)=None
      RListBox(225)=None
      RListBox(226)=None
      RListBox(227)=None
      RListBox(228)=None
      RListBox(229)=None
      RListBox(230)=None
      RListBox(231)=None
      RListBox(232)=None
      RListBox(233)=None
      RListBox(234)=None
      RListBox(235)=None
      RListBox(236)=None
      RListBox(237)=None
      RListBox(238)=None
      RListBox(239)=None
      RListBox(240)=None
      RListBox(241)=None
      RListBox(242)=None
      RListBox(243)=None
      RListBox(244)=None
      RListBox(245)=None
      RListBox(246)=None
      RListBox(247)=None
      RListBox(248)=None
      RListBox(249)=None
      RListBox(250)=None
      RListBox(251)=None
      RListBox(252)=None
      RListBox(253)=None
      RListBox(254)=None
      RListBox(255)=None
      RListBox(256)=None
      RListBox(257)=None
      RListBox(258)=None
      RListBox(259)=None
      RListBox(260)=None
      RListBox(261)=None
      RListBox(262)=None
      RListBox(263)=None
      RListBox(264)=None
      RListBox(265)=None
      RListBox(266)=None
      RListBox(267)=None
      RListBox(268)=None
      RListBox(269)=None
      RListBox(270)=None
      RListBox(271)=None
      RListBox(272)=None
      RListBox(273)=None
      RListBox(274)=None
      RListBox(275)=None
      RListBox(276)=None
      RListBox(277)=None
      RListBox(278)=None
      RListBox(279)=None
      RListBox(280)=None
      RListBox(281)=None
      RListBox(282)=None
      RListBox(283)=None
      RListBox(284)=None
      RListBox(285)=None
      RListBox(286)=None
      RListBox(287)=None
      RListBox(288)=None
      RListBox(289)=None
      RListBox(290)=None
      RListBox(291)=None
      RListBox(292)=None
      RListBox(293)=None
      RListBox(294)=None
      RListBox(295)=None
      RListBox(296)=None
      RListBox(297)=None
      RListBox(298)=None
      RListBox(299)=None
      RListBox(300)=None
      RListBox(301)=None
      RListBox(302)=None
      RListBox(303)=None
      RListBox(304)=None
      RListBox(305)=None
      RListBox(306)=None
      RListBox(307)=None
      RListBox(308)=None
      RListBox(309)=None
      RListBox(310)=None
      RListBox(311)=None
      RListBox(312)=None
      RListBox(313)=None
      RListBox(314)=None
      RListBox(315)=None
      RListBox(316)=None
      RListBox(317)=None
      RListBox(318)=None
      RListBox(319)=None
      RListBox(320)=None
      RListBox(321)=None
      RListBox(322)=None
      RListBox(323)=None
      RListBox(324)=None
      RListBox(325)=None
      RListBox(326)=None
      RListBox(327)=None
      RListBox(328)=None
      RListBox(329)=None
      RListBox(330)=None
      RListBox(331)=None
      RListBox(332)=None
      RListBox(333)=None
      RListBox(334)=None
      RListBox(335)=None
      RListBox(336)=None
      RListBox(337)=None
      RListBox(338)=None
      RListBox(339)=None
      RListBox(340)=None
      RListBox(341)=None
      RListBox(342)=None
      RListBox(343)=None
      RListBox(344)=None
      RListBox(345)=None
      RListBox(346)=None
      RListBox(347)=None
      RListBox(348)=None
      RListBox(349)=None
      RListBox(350)=None
      RListBox(351)=None
      RListBox(352)=None
      RListBox(353)=None
      RListBox(354)=None
      RListBox(355)=None
      RListBox(356)=None
      RListBox(357)=None
      RListBox(358)=None
      RListBox(359)=None
      RListBox(360)=None
      RListBox(361)=None
      RListBox(362)=None
      RListBox(363)=None
      RListBox(364)=None
      RListBox(365)=None
      RListBox(366)=None
      RListBox(367)=None
      RListBox(368)=None
      RListBox(369)=None
      RListBox(370)=None
      RListBox(371)=None
      RListBox(372)=None
      RListBox(373)=None
      RListBox(374)=None
      RListBox(375)=None
      RListBox(376)=None
      RListBox(377)=None
      RListBox(378)=None
      RListBox(379)=None
      RListBox(380)=None
      RListBox(381)=None
      RListBox(382)=None
      RListBox(383)=None
      RListBox(384)=None
      RListBox(385)=None
      RListBox(386)=None
      RListBox(387)=None
      RListBox(388)=None
      RListBox(389)=None
      RListBox(390)=None
      RListBox(391)=None
      RListBox(392)=None
      RListBox(393)=None
      RListBox(394)=None
      RListBox(395)=None
      RListBox(396)=None
      RListBox(397)=None
      RListBox(398)=None
      RListBox(399)=None
      RListBox(400)=None
      RListBox(401)=None
      RListBox(402)=None
      RListBox(403)=None
      RListBox(404)=None
      RListBox(405)=None
      RListBox(406)=None
      RListBox(407)=None
      RListBox(408)=None
      RListBox(409)=None
      RListBox(410)=None
      RListBox(411)=None
      RListBox(412)=None
      RListBox(413)=None
      RListBox(414)=None
      RListBox(415)=None
      RListBox(416)=None
      RListBox(417)=None
      RListBox(418)=None
      RListBox(419)=None
      RListBox(420)=None
      RListBox(421)=None
      RListBox(422)=None
      RListBox(423)=None
      RListBox(424)=None
      RListBox(425)=None
      RListBox(426)=None
      RListBox(427)=None
      RListBox(428)=None
      RListBox(429)=None
      RListBox(430)=None
      RListBox(431)=None
      RListBox(432)=None
      RListBox(433)=None
      RListBox(434)=None
      RListBox(435)=None
      RListBox(436)=None
      RListBox(437)=None
      RListBox(438)=None
      RListBox(439)=None
      RListBox(440)=None
      RListBox(441)=None
      RListBox(442)=None
      RListBox(443)=None
      RListBox(444)=None
      RListBox(445)=None
      RListBox(446)=None
      RListBox(447)=None
      RListBox(448)=None
      RListBox(449)=None
      RListBox(450)=None
      RListBox(451)=None
      RListBox(452)=None
      RListBox(453)=None
      RListBox(454)=None
      RListBox(455)=None
      RListBox(456)=None
      RListBox(457)=None
      RListBox(458)=None
      RListBox(459)=None
      RListBox(460)=None
      RListBox(461)=None
      RListBox(462)=None
      RListBox(463)=None
      RListBox(464)=None
      RListBox(465)=None
      RListBox(466)=None
      RListBox(467)=None
      RListBox(468)=None
      RListBox(469)=None
      RListBox(470)=None
      RListBox(471)=None
      RListBox(472)=None
      RListBox(473)=None
      RListBox(474)=None
      RListBox(475)=None
      RListBox(476)=None
      RListBox(477)=None
      RListBox(478)=None
      RListBox(479)=None
      RListBox(480)=None
      RListBox(481)=None
      RListBox(482)=None
      RListBox(483)=None
      RListBox(484)=None
      RListBox(485)=None
      RListBox(486)=None
      RListBox(487)=None
      RListBox(488)=None
      RListBox(489)=None
      RListBox(490)=None
      RListBox(491)=None
      RListBox(492)=None
      RListBox(493)=None
      RListBox(494)=None
      RListBox(495)=None
      RListBox(496)=None
      RListBox(497)=None
      RListBox(498)=None
      RListBox(499)=None
      RListBox(500)=None
      RListBox(501)=None
      RListBox(502)=None
      RListBox(503)=None
      RListBox(504)=None
      RListBox(505)=None
      RListBox(506)=None
      RListBox(507)=None
      RListBox(508)=None
      RListBox(509)=None
      RListBox(510)=None
      RListBox(511)=None
      MapVoteListDummy=None
      MapListBox(0)=None
      MapListBox(1)=None
      MapListBox(2)=None
      MapListBox(3)=None
      MapListBox(4)=None
      MapListBox(5)=None
      MapListBox(6)=None
      MapListBox(7)=None
      MapListBox(8)=None
      MapListBox(9)=None
      MapListBox(10)=None
      MapListBox(11)=None
      MapListBox(12)=None
      MapListBox(13)=None
      MapListBox(14)=None
      MapListBox(15)=None
      MapListBox(16)=None
      MapListBox(17)=None
      MapListBox(18)=None
      MapListBox(19)=None
      MapListBox(20)=None
      MapListBox(21)=None
      MapListBox(22)=None
      MapListBox(23)=None
      MapListBox(24)=None
      MapListBox(25)=None
      MapListBox(26)=None
      MapListBox(27)=None
      MapListBox(28)=None
      MapListBox(29)=None
      MapListBox(30)=None
      MapListBox(31)=None
      MapListBox(32)=None
      MapListBox(33)=None
      MapListBox(34)=None
      MapListBox(35)=None
      MapListBox(36)=None
      MapListBox(37)=None
      MapListBox(38)=None
      MapListBox(39)=None
      MapListBox(40)=None
      MapListBox(41)=None
      MapListBox(42)=None
      MapListBox(43)=None
      MapListBox(44)=None
      MapListBox(45)=None
      MapListBox(46)=None
      MapListBox(47)=None
      MapListBox(48)=None
      MapListBox(49)=None
      MapListBox(50)=None
      MapListBox(51)=None
      MapListBox(52)=None
      MapListBox(53)=None
      MapListBox(54)=None
      MapListBox(55)=None
      MapListBox(56)=None
      MapListBox(57)=None
      MapListBox(58)=None
      MapListBox(59)=None
      MapListBox(60)=None
      MapListBox(61)=None
      MapListBox(62)=None
      MapListBox(63)=None
      MapListBox(64)=None
      MapListBox(65)=None
      MapListBox(66)=None
      MapListBox(67)=None
      MapListBox(68)=None
      MapListBox(69)=None
      MapListBox(70)=None
      MapListBox(71)=None
      MapListBox(72)=None
      MapListBox(73)=None
      MapListBox(74)=None
      MapListBox(75)=None
      MapListBox(76)=None
      MapListBox(77)=None
      MapListBox(78)=None
      MapListBox(79)=None
      MapListBox(80)=None
      MapListBox(81)=None
      MapListBox(82)=None
      MapListBox(83)=None
      MapListBox(84)=None
      MapListBox(85)=None
      MapListBox(86)=None
      MapListBox(87)=None
      MapListBox(88)=None
      MapListBox(89)=None
      MapListBox(90)=None
      MapListBox(91)=None
      MapListBox(92)=None
      MapListBox(93)=None
      MapListBox(94)=None
      MapListBox(95)=None
      MapListBox(96)=None
      MapListBox(97)=None
      MapListBox(98)=None
      MapListBox(99)=None
      MapListBox(100)=None
      MapListBox(101)=None
      MapListBox(102)=None
      MapListBox(103)=None
      MapListBox(104)=None
      MapListBox(105)=None
      MapListBox(106)=None
      MapListBox(107)=None
      MapListBox(108)=None
      MapListBox(109)=None
      MapListBox(110)=None
      MapListBox(111)=None
      MapListBox(112)=None
      MapListBox(113)=None
      MapListBox(114)=None
      MapListBox(115)=None
      MapListBox(116)=None
      MapListBox(117)=None
      MapListBox(118)=None
      MapListBox(119)=None
      MapListBox(120)=None
      MapListBox(121)=None
      MapListBox(122)=None
      MapListBox(123)=None
      MapListBox(124)=None
      MapListBox(125)=None
      MapListBox(126)=None
      MapListBox(127)=None
      MapListBox(128)=None
      MapListBox(129)=None
      MapListBox(130)=None
      MapListBox(131)=None
      MapListBox(132)=None
      MapListBox(133)=None
      MapListBox(134)=None
      MapListBox(135)=None
      MapListBox(136)=None
      MapListBox(137)=None
      MapListBox(138)=None
      MapListBox(139)=None
      MapListBox(140)=None
      MapListBox(141)=None
      MapListBox(142)=None
      MapListBox(143)=None
      MapListBox(144)=None
      MapListBox(145)=None
      MapListBox(146)=None
      MapListBox(147)=None
      MapListBox(148)=None
      MapListBox(149)=None
      MapListBox(150)=None
      MapListBox(151)=None
      MapListBox(152)=None
      MapListBox(153)=None
      MapListBox(154)=None
      MapListBox(155)=None
      MapListBox(156)=None
      MapListBox(157)=None
      MapListBox(158)=None
      MapListBox(159)=None
      MapListBox(160)=None
      MapListBox(161)=None
      MapListBox(162)=None
      MapListBox(163)=None
      MapListBox(164)=None
      MapListBox(165)=None
      MapListBox(166)=None
      MapListBox(167)=None
      MapListBox(168)=None
      MapListBox(169)=None
      MapListBox(170)=None
      MapListBox(171)=None
      MapListBox(172)=None
      MapListBox(173)=None
      MapListBox(174)=None
      MapListBox(175)=None
      MapListBox(176)=None
      MapListBox(177)=None
      MapListBox(178)=None
      MapListBox(179)=None
      MapListBox(180)=None
      MapListBox(181)=None
      MapListBox(182)=None
      MapListBox(183)=None
      MapListBox(184)=None
      MapListBox(185)=None
      MapListBox(186)=None
      MapListBox(187)=None
      MapListBox(188)=None
      MapListBox(189)=None
      MapListBox(190)=None
      MapListBox(191)=None
      MapListBox(192)=None
      MapListBox(193)=None
      MapListBox(194)=None
      MapListBox(195)=None
      MapListBox(196)=None
      MapListBox(197)=None
      MapListBox(198)=None
      MapListBox(199)=None
      MapListBox(200)=None
      MapListBox(201)=None
      MapListBox(202)=None
      MapListBox(203)=None
      MapListBox(204)=None
      MapListBox(205)=None
      MapListBox(206)=None
      MapListBox(207)=None
      MapListBox(208)=None
      MapListBox(209)=None
      MapListBox(210)=None
      MapListBox(211)=None
      MapListBox(212)=None
      MapListBox(213)=None
      MapListBox(214)=None
      MapListBox(215)=None
      MapListBox(216)=None
      MapListBox(217)=None
      MapListBox(218)=None
      MapListBox(219)=None
      MapListBox(220)=None
      MapListBox(221)=None
      MapListBox(222)=None
      MapListBox(223)=None
      MapListBox(224)=None
      MapListBox(225)=None
      MapListBox(226)=None
      MapListBox(227)=None
      MapListBox(228)=None
      MapListBox(229)=None
      MapListBox(230)=None
      MapListBox(231)=None
      MapListBox(232)=None
      MapListBox(233)=None
      MapListBox(234)=None
      MapListBox(235)=None
      MapListBox(236)=None
      MapListBox(237)=None
      MapListBox(238)=None
      MapListBox(239)=None
      MapListBox(240)=None
      MapListBox(241)=None
      MapListBox(242)=None
      MapListBox(243)=None
      MapListBox(244)=None
      MapListBox(245)=None
      MapListBox(246)=None
      MapListBox(247)=None
      MapListBox(248)=None
      MapListBox(249)=None
      MapListBox(250)=None
      MapListBox(251)=None
      MapListBox(252)=None
      MapListBox(253)=None
      MapListBox(254)=None
      MapListBox(255)=None
      MapListBox(256)=None
      MapListBox(257)=None
      MapListBox(258)=None
      MapListBox(259)=None
      MapListBox(260)=None
      MapListBox(261)=None
      MapListBox(262)=None
      MapListBox(263)=None
      MapListBox(264)=None
      MapListBox(265)=None
      MapListBox(266)=None
      MapListBox(267)=None
      MapListBox(268)=None
      MapListBox(269)=None
      MapListBox(270)=None
      MapListBox(271)=None
      MapListBox(272)=None
      MapListBox(273)=None
      MapListBox(274)=None
      MapListBox(275)=None
      MapListBox(276)=None
      MapListBox(277)=None
      MapListBox(278)=None
      MapListBox(279)=None
      MapListBox(280)=None
      MapListBox(281)=None
      MapListBox(282)=None
      MapListBox(283)=None
      MapListBox(284)=None
      MapListBox(285)=None
      MapListBox(286)=None
      MapListBox(287)=None
      MapListBox(288)=None
      MapListBox(289)=None
      MapListBox(290)=None
      MapListBox(291)=None
      MapListBox(292)=None
      MapListBox(293)=None
      MapListBox(294)=None
      MapListBox(295)=None
      MapListBox(296)=None
      MapListBox(297)=None
      MapListBox(298)=None
      MapListBox(299)=None
      MapListBox(300)=None
      MapListBox(301)=None
      MapListBox(302)=None
      MapListBox(303)=None
      MapListBox(304)=None
      MapListBox(305)=None
      MapListBox(306)=None
      MapListBox(307)=None
      MapListBox(308)=None
      MapListBox(309)=None
      MapListBox(310)=None
      MapListBox(311)=None
      MapListBox(312)=None
      MapListBox(313)=None
      MapListBox(314)=None
      MapListBox(315)=None
      MapListBox(316)=None
      MapListBox(317)=None
      MapListBox(318)=None
      MapListBox(319)=None
      MapListBox(320)=None
      MapListBox(321)=None
      MapListBox(322)=None
      MapListBox(323)=None
      MapListBox(324)=None
      MapListBox(325)=None
      MapListBox(326)=None
      MapListBox(327)=None
      MapListBox(328)=None
      MapListBox(329)=None
      MapListBox(330)=None
      MapListBox(331)=None
      MapListBox(332)=None
      MapListBox(333)=None
      MapListBox(334)=None
      MapListBox(335)=None
      MapListBox(336)=None
      MapListBox(337)=None
      MapListBox(338)=None
      MapListBox(339)=None
      MapListBox(340)=None
      MapListBox(341)=None
      MapListBox(342)=None
      MapListBox(343)=None
      MapListBox(344)=None
      MapListBox(345)=None
      MapListBox(346)=None
      MapListBox(347)=None
      MapListBox(348)=None
      MapListBox(349)=None
      MapListBox(350)=None
      MapListBox(351)=None
      MapListBox(352)=None
      MapListBox(353)=None
      MapListBox(354)=None
      MapListBox(355)=None
      MapListBox(356)=None
      MapListBox(357)=None
      MapListBox(358)=None
      MapListBox(359)=None
      MapListBox(360)=None
      MapListBox(361)=None
      MapListBox(362)=None
      MapListBox(363)=None
      MapListBox(364)=None
      MapListBox(365)=None
      MapListBox(366)=None
      MapListBox(367)=None
      MapListBox(368)=None
      MapListBox(369)=None
      MapListBox(370)=None
      MapListBox(371)=None
      MapListBox(372)=None
      MapListBox(373)=None
      MapListBox(374)=None
      MapListBox(375)=None
      MapListBox(376)=None
      MapListBox(377)=None
      MapListBox(378)=None
      MapListBox(379)=None
      MapListBox(380)=None
      MapListBox(381)=None
      MapListBox(382)=None
      MapListBox(383)=None
      MapListBox(384)=None
      MapListBox(385)=None
      MapListBox(386)=None
      MapListBox(387)=None
      MapListBox(388)=None
      MapListBox(389)=None
      MapListBox(390)=None
      MapListBox(391)=None
      MapListBox(392)=None
      MapListBox(393)=None
      MapListBox(394)=None
      MapListBox(395)=None
      MapListBox(396)=None
      MapListBox(397)=None
      MapListBox(398)=None
      MapListBox(399)=None
      MapListBox(400)=None
      MapListBox(401)=None
      MapListBox(402)=None
      MapListBox(403)=None
      MapListBox(404)=None
      MapListBox(405)=None
      MapListBox(406)=None
      MapListBox(407)=None
      MapListBox(408)=None
      MapListBox(409)=None
      MapListBox(410)=None
      MapListBox(411)=None
      MapListBox(412)=None
      MapListBox(413)=None
      MapListBox(414)=None
      MapListBox(415)=None
      MapListBox(416)=None
      MapListBox(417)=None
      MapListBox(418)=None
      MapListBox(419)=None
      MapListBox(420)=None
      MapListBox(421)=None
      MapListBox(422)=None
      MapListBox(423)=None
      MapListBox(424)=None
      MapListBox(425)=None
      MapListBox(426)=None
      MapListBox(427)=None
      MapListBox(428)=None
      MapListBox(429)=None
      MapListBox(430)=None
      MapListBox(431)=None
      MapListBox(432)=None
      MapListBox(433)=None
      MapListBox(434)=None
      MapListBox(435)=None
      MapListBox(436)=None
      MapListBox(437)=None
      MapListBox(438)=None
      MapListBox(439)=None
      MapListBox(440)=None
      MapListBox(441)=None
      MapListBox(442)=None
      MapListBox(443)=None
      MapListBox(444)=None
      MapListBox(445)=None
      MapListBox(446)=None
      MapListBox(447)=None
      MapListBox(448)=None
      MapListBox(449)=None
      MapListBox(450)=None
      MapListBox(451)=None
      MapListBox(452)=None
      MapListBox(453)=None
      MapListBox(454)=None
      MapListBox(455)=None
      MapListBox(456)=None
      MapListBox(457)=None
      MapListBox(458)=None
      MapListBox(459)=None
      MapListBox(460)=None
      MapListBox(461)=None
      MapListBox(462)=None
      MapListBox(463)=None
      MapListBox(464)=None
      MapListBox(465)=None
      MapListBox(466)=None
      MapListBox(467)=None
      MapListBox(468)=None
      MapListBox(469)=None
      MapListBox(470)=None
      MapListBox(471)=None
      MapListBox(472)=None
      MapListBox(473)=None
      MapListBox(474)=None
      MapListBox(475)=None
      MapListBox(476)=None
      MapListBox(477)=None
      MapListBox(478)=None
      MapListBox(479)=None
      MapListBox(480)=None
      MapListBox(481)=None
      MapListBox(482)=None
      MapListBox(483)=None
      MapListBox(484)=None
      MapListBox(485)=None
      MapListBox(486)=None
      MapListBox(487)=None
      MapListBox(488)=None
      MapListBox(489)=None
      MapListBox(490)=None
      MapListBox(491)=None
      MapListBox(492)=None
      MapListBox(493)=None
      MapListBox(494)=None
      MapListBox(495)=None
      MapListBox(496)=None
      MapListBox(497)=None
      MapListBox(498)=None
      MapListBox(499)=None
      MapListBox(500)=None
      MapListBox(501)=None
      MapListBox(502)=None
      MapListBox(503)=None
      MapListBox(504)=None
      MapListBox(505)=None
      MapListBox(506)=None
      MapListBox(507)=None
      MapListBox(508)=None
      MapListBox(509)=None
      MapListBox(510)=None
      MapListBox(511)=None
      CloseButton=None
      VoteButton=None
      InfoButton=None
      PlayerListBox=None
      KickVoteButton=None
      lstMapStatus=None
      lstKickStatus=None
      cbLoadScreenShot=None
      lblStatusTitles1=None
      lblStatusTitles2=None
      lblStatusTitles3=None
      lblStatusTitles4=None
      lblStatusTitles5=None
      lblKickVote1=None
      lblKickVote2=None
      lblTitle1=None
      lblTitle2=None
      lblTitle3=None
      lblTitle4=None
      lblTitle5=None
      lblTitle6=None
      lblTitle=None
      lblMaptxt1=None
      lblMaptxt2=None
      lblMaptxt3=None
      lblPriority1=None
      lblPriority2=None
      lblPriority3=None
      lblPriority4=None
      lblMapCount=None
      txtFind=None
      SendButton=None
      txtMessage=None
      lblMode=None
      bKickVote=False
      Screenshot=None
      MapTitle=""
      MapAuthor=""
      IdealPlayerCount=""
      LastVoteTime=0.000000
      SelectionTime=0.000000
      LogoTexture=""
      MapListwidth=0
      PlayerListwidth=0
      ListHeight=0
      bMapAlreadySet=False
      PrefixDictionary=""
      ClientConf=None
      RedColor=(R=255,G=0,B=0,A=0)
      PurpleColor=(R=128,G=0,B=128,A=0)
      LightBlueColor=(R=0,G=100,B=255,A=0)
      TurquoiseColor=(R=0,G=255,B=255,A=0)
      GreenColor=(R=0,G=255,B=0,A=0)
      OrangeColor=(R=255,G=120,B=0,A=0)
      YellowColor=(R=255,G=255,B=0,A=0)
      PinkColor=(R=255,G=0,B=255,A=0)
      WhiteColor=(R=255,G=255,B=255,A=0)
      DeepBlueColor=(R=0,G=0,B=255,A=0)
      BlackColor=(R=0,G=0,B=0,A=0)
}
