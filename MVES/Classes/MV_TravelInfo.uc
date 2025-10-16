class MV_TravelInfo expands Info config(MVE_Travel);

var() config string TravelString; // Used to load the next map!
var() config int TravelIdx; // Use to load game settings & mutators for next map
var() config string TravelGame;
var() config string TravelRule;
var() config int RestoreTryCount;
var() config bool bIsIdle;
var() config int EmptyMinutes;

function int GetTravelIdx(MapVote M)
{
	local int i;
	if ( TravelIdx < 0 ) 
	{
		// represents crash
		return TravelIdx;
	}
	if ( M.GameName(TravelIdx) == TravelGame && 
		M.RuleName(TravelIdx) == TravelRule )
	{
		return TravelIdx;
	}

	// index mismatch, gametypes have shifted, find by name/rule
	if ( TravelGame != "" && TravelRule != "" )
	{
		for ( i = 0; i < M.MaxGametypes; i+=1 )
		{
			if ( M.GameName(i) == TravelGame &&
				M.RuleName(i) == TravelRule )
			{
				Log("[MVE] Detected customGame index shift"@TravelIdx@"->"@i);
				return i;
			}
		}
	}
	// fallback I guess
	Log("[MVE] ERROR: Did not match MVE_Travel to existing CustomGame from MVE_Config!!");
	return TravelIdx;
}

function SetTravelIdx(MapVote M, int idx) 
{
	TravelIdx = idx;
	if ( idx < 0 || idx >= M.MaxGametypes )
	{
		TravelGame = "";
		TravelRule = "";
	}
	else 
	{
		TravelGame = M.GameName(idx);
		TravelRule = M.RuleName(idx);
	}
}

function SaveIdleState(bool isIdle, int minutes) 
{
	EmptyMinutes = minutes;
	bIsIdle = isIdle;
	SaveConfig();
}
