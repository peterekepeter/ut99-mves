//================================================================================
// MapVoteClientConfig.
//================================================================================

class MapVoteClientConfig extends Object
	config(MVE_ClientConfig) perobjectconfig;

var() config color BackgroundColor;
var() config color BoxesColor;
var() config int BoxesTextColor;
var() config int GameModTitleColor;
var() config int RuleTitleColor;
var() config int MapTitleColor;
var() config int KickVoteTitleColor;
var() config int PlayerTitleColor;
var() config int MapVoteTitleColor;

var config float MsgTimeOut;
var config bool bUseMsgTimeout;
var config bool bLoadScreenShot;

var MapVoteClientConfigColors Util;

static function MapVoteClientConfig GetInstance()
{
	// ensures config is read from same ini section regardless of package name
	return new (class'MVE_ClientConfig', 'MapVoteClientConfig') class'MapVoteClientConfig';
}

defaultproperties
{
	BackgroundColor=(R=75,G=0,B=0,A=0)
	BoxesColor=(R=255,G=255,B=255,A=0)
	BoxesTextColor=10
	GameModTitleColor=2
	RuleTitleColor=3
	MapTitleColor=4
	KickVoteTitleColor=5
	PlayerTitleColor=6
	MapVoteTitleColor=7
	MsgTimeOut=8.000000
	bLoadScreenShot=True
}

function Color GetColorOfBoxesTextColor()
{
	return GetColorUtil().GetColorByIndex(BoxesTextColor);
}

function Color GetColorOfGameModTitleColor()
{
	return GetColorUtil().GetColorByIndex(GameModTitleColor);
}

function Color GetColorOfRuleTitleColor()
{
	return GetColorUtil().GetColorByIndex(RuleTitleColor);
}

function Color GetColorOfMapTitleColor()
{
	return GetColorUtil().GetColorByIndex(MapTitleColor);
}

function Color GetColorOfKickVoteTitleColor()
{
	return GetColorUtil().GetColorByIndex(KickVoteTitleColor);
}

function Color GetColorOfPlayerTitleColor()
{
	return GetColorUtil().GetColorByIndex(PlayerTitleColor);
}

function Color GetColorOfMapVoteTitleColor()
{
	return GetColorUtil().GetColorByIndex(MapVoteTitleColor);
}

function String GetNameOfBoxesTextColor()
{
	return GetColorUtil().GetNameByIndex(BoxesTextColor);
}

function String GetNameOfGameModTitleColor()
{
	return GetColorUtil().GetNameByIndex(GameModTitleColor);
}

function String GetNameOfRuleTitleColor()
{
	return GetColorUtil().GetNameByIndex(RuleTitleColor);
}

function String GetNameOfMapTitleColor()
{
	return GetColorUtil().GetNameByIndex(MapTitleColor);
}

function String GetNameOfKickVoteTitleColor()
{
	return GetColorUtil().GetNameByIndex(KickVoteTitleColor);
}

function String GetNameOfPlayerTitleColor()
{
	return GetColorUtil().GetNameByIndex(PlayerTitleColor);
}

function String GetNameOfMapVoteTitleColor()
{
	return GetColorUtil().GetNameByIndex(MapVoteTitleColor);
}

function MapVoteClientConfigColors GetColorUtil()
{
	if (Util == None)
	{
		Util = new class'MapVoteClientConfigColors';
	}
	return Util;
}