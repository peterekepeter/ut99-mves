class MapVoteTabWindow extends UWindowDialogClientWindow;

var UMenuPageControl Pages;
var MapVoteClientWindow MapWindow;
var ConfigWindow ConfigWindow;
var AdminTabWindow AdminWindow;
var ServerInfoWindow InfoWindow;
var string PrevSelectedMap;
var string PrevSelectedPlayer;
var int MapCount;
var string InfoServerAddress;
var int InfoServerPort;
var string InfoFilePath;
var string ServerInfoFile;

function Created ()
{
	local UWindowPageControlPage PageControl;

	Super.Created();
	
	Pages = UMenuPageControl(CreateWindow(Class'MapVotePageControl', -1.5,0.0,WinWidth + 3.0,WinHeight + 4.0));
	Pages.SetMultiLine(True);
	PageControl = Pages.AddPage("Maps/Kick",Class'MapVoteClientWindow');
	MapWindow = MapVoteClientWindow(PageControl.Page);
	PageControl = Pages.AddPage("Config",Class'ConfigWindow');
	ConfigWindow = ConfigWindow(PageControl.Page);
	PageControl = Pages.AddPage("Info",Class'ServerInfoWindow');
	InfoWindow = ServerInfoWindow(PageControl.Page);
}

function AddMapName (int listNum, string MapName)
{
	local UMenuMapVoteList i;
	local MapVoteListBox L;

	L = MapWindow.GetMapVoteList(listNum);
	L.Count ++ ;
	i = UMenuMapVoteList(L.Items.Append(Class'UMenuMapVoteList'));
	i.MapName = MapName;
	if ( listNum < 0 )
		i.CGNum = -listNum;
}

function AddGameMode (int listNum, string MapName)
{
	local UMenuGameModeVoteList i;
	local GameModeListBox L;

	L = MapWindow.GMListBox;
	i = UMenuGameModeVoteList(L.Items.Append(Class'UMenuGameModeVoteList'));
	i.MapName = MapName;
	i.listNum = listNum;
}

function AddGameRule (int listNum, string MapName, int RuleNum)
{
	local UMenuRuleVoteList i;
	local RuleListBox L;

	L = MapWindow.GetRListBox(listNum);
	i = UMenuRuleVoteList(L.Items.Append(Class'UMenuRuleVoteList'));
	i.MapName = MapName;
	i.listNum = RuleNum;
}

function FinishSetRuleListAndVoteList()
{
	MapWindow.RestoreSelection();
}

function ClearList (int listNum)
{
	local MapVoteListBox L;

	L = MapWindow.GetMapVoteList(listNum);
	L.Items.Clear();
}

function AddPlayerName (string PlayerName, bool bHasVoted)
{
	local PlayerVoteListItem i;
	local UWindowList Item;
	local int j;

	for( Item = MapWindow.PlayerListBox.Items;Item != None;Item = Item.Next )
	{
		if ( PlayerVoteListItem(Item).PlayerName == PlayerName )
			return;
	}
	i = PlayerVoteListItem(MapWindow.PlayerListBox.Items.Append(Class'PlayerVoteListItem'));
	i.PlayerName = PlayerName;
	i.bHasVoted = bHasVoted;
}

function ClearPlayerList ()
{
	MapWindow.PlayerListBox.Items.Clear();
}

function UpdateIsAdmin(bool bAdmin)
{	
	local UWindowPageControlPage PageControl;

	if ( bAdmin && AdminWindow == None )
	{
		PageControl = Pages.AddPage("Admin",Class'AdminTabWindow');
		AdminWindow = AdminTabWindow(PageControl.Page);
	}

	MapWindow.UpdateIsAdmin(bAdmin);
}

function RemovePlayerName (string PlayerID)
{
	local UWindowList Item;

	for( Item = MapWindow.PlayerListBox.Items;Item != None;Item = Item.Next )
	{
		if ( Mid(PlayerVoteListItem(Item).PlayerName,1,3) == PlayerID )
		{
			Item.Remove();
			return;
		}
	}
}

function UpdatePlayerVoted (string PlayerID)
{
	local UWindowList Item;

	for( Item = MapWindow.PlayerListBox.Items;Item != None;Item = Item.Next )
	{
		if ( Mid(PlayerVoteListItem(Item).PlayerName,1,3) == PlayerID )
		{
			PlayerVoteListItem(Item).bHasVoted = True;
			return;
		}
	}
}

function EnableKickWindow ()
{
	if( MapWindow.KickVoteButton != None )
	{
		MapWindow.KickVoteButton.bDisabled = False;
		MapWindow.KickVoteButton.Text = "Kick";
	}
	MapWindow.PlayerListBox.bDisabled = False;
}

simulated function UpdateMapVoteResults (string Text, int i)
{
	local UWindowList Item;
	local string MapName;
	local string GameModeName;
	local string RuleName;
	local int pos;
	local float C;
	local int CGNum;

	if ( Text == "Clear" )
	{
		if ( MapWindow.lstMapStatus.SelectedItem != None )
			PrevSelectedMap = MapStatusListItem(MapWindow.lstMapStatus.SelectedItem).MapName;
		MapWindow.lstMapStatus.Items.Clear();
		return;
	}
	pos = InStr(Text,",");
	if ( pos > 0 )
	{
		CGNum = int(Left(Text,pos));
		Text = Mid(Text,pos + 1);
	}
	pos = InStr(Text,",");
	if ( pos > 0 )
	{
		MapName = Left(Text,pos);
		Text = Mid(Text,pos + 1);
	}
	pos = InStr(Text,",");
	if ( pos > 0 )
	{
		GameModeName = Left(Text,pos);
		Text = Mid(Text,pos + 1);
	}
	pos = InStr(Text,",");
	if ( pos > 0 )
	{
		RuleName = Left(Text,pos);
		C = float(Mid(Text,pos + 1));
	}
	
	
	for( Item = MapWindow.lstMapStatus.Items;Item != None;Item = Item.Next )
	{
		if ( (MapStatusListItem(Item).MapName == MapName) && (MapStatusListItem(Item).CGNum == CGNum) )
		{
			if ( MapStatusListItem(Item).rank > i + 1 )
				MapStatusListItem(Item).rank = i + 1;

			if ( MapStatusListItem(Item).VoteCount < C )
				MapStatusListItem(Item).VoteCount = C;
			return;
		}
	}
	Item = MapStatusListItem(MapWindow.lstMapStatus.Items.Append(Class'MapStatusListItem'));
	MapStatusListItem(Item).rank = i + 1;
	MapStatusListItem(Item).MapName = MapName;
	MapStatusListItem(Item).GameModeName = GameModeName;
	MapStatusListItem(Item).RuleName = RuleName;
	MapStatusListItem(Item).CGNum = CGNum;
	MapStatusListItem(Item).VoteCount = C;

	if ( PrevSelectedMap == MapName )
		MapWindow.lstMapStatus.SelectMap(PrevSelectedMap);
}

simulated function UpdateKickVoteResults (string Text, int i)
{
	local UWindowList Item;
	local string PlayerName;
	local int C;
	local int pos;

	if ( Text == "" )
	{
		return;
	}
	if ( Text == "Clear" )
	{
		if ( MapWindow.lstKickStatus.SelectedItem != None )
			PrevSelectedPlayer = KickStatusListItem(MapWindow.lstKickStatus.SelectedItem).PlayerName;
            
		MapWindow.lstKickStatus.Items.Clear();
		return;
	}
	pos = InStr(Text,",");
	if ( pos > 0 )
	{
		PlayerName = Left(Text,pos);
		C = int(Mid(Text,pos + 1));
	}
	if ( MapWindow.lstKickStatus.Items != None )
	{
		for( Item = MapWindow.lstKickStatus.Items;Item != None;Item = Item.Next )
		{
			if ( KickStatusListItem(Item).PlayerName == PlayerName )
			{
				KickStatusListItem(Item).VoteCount = C;
				return;
			}
		}
	}
	Item = KickStatusListItem(MapWindow.lstKickStatus.Items.Append(Class'KickStatusListItem'));
	KickStatusListItem(Item).PlayerName = PlayerName;
	KickStatusListItem(Item).VoteCount = C;
	if ( (PrevSelectedPlayer != "") && (PrevSelectedPlayer == PlayerName) )
		MapWindow.lstKickStatus.SelectPlayer(PrevSelectedPlayer);
}

defaultproperties
{
}
