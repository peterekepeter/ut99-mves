//================================================================================
// MapVoteReport.
//================================================================================
class MapVoteReport extends Info;

var string ReportText;
var int X;
var MapVoteWRI MVWRI;
var bool bSendResults;
var MapVoteHistory History;

function RunRport (string ReportType, PlayerPawn Sender, Class<MapVoteHistory> MapVoteHistoryClass)
{
	foreach AllActors(Class'MapVoteWRI',MVWRI)
	{
		if ( Sender == MVWRI.Owner )
		break;
	}
	if ( MVWRI == None )
	{
		Log("Failed to find MVWRI");
		Destroy();
		return;
	}
	MVWRI.SendReportText("<html><body bgcolor=#000000><br><br><br><center><b>Please Wait.....</b></center></body></html>");
	MVWRI.SendReportText("");
	History=Spawn(MapVoteHistoryClass);
	if ( History == None )
	{
		Log("Failed to spawn MapVoteHistory");
		Destroy();
		return;
	}
	History.MapReport(ReportType,self);
}

function Tick (float DeltaTime)
{
	if ( bSendResults )
	{
		if ( MVWRI == None )
		{
			History.Destroy();
			Destroy();
			return;
		}
		if ( X > Len(ReportText) )
		{
			MVWRI.SendReportText("");
			bSendResults=False;
			History.Destroy();
			Destroy();
		} else {
			MVWRI.SendReportText(Mid(ReportText,X,250));
			X=X + 250;
			if ( X < Len(ReportText) )
			{
				MVWRI.SendReportText(Mid(ReportText,X,250));
				X=X + 250;
			}
		}
	}
}

defaultproperties
{
      ReportText=""
      X=0
      MVWRI=None
      bSendResults=False
      History=None
}
