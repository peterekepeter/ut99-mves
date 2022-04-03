//================================================================================
// MapVoteClientConfig.
//================================================================================

class MapVoteClientConfig extends Object
	config(MVE_ClientConfig);

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
      bUseMsgTimeout=False
      bLoadScreenShot=True
}
