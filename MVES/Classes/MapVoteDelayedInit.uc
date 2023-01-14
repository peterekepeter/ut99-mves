class MapVoteDelayedInit expands Info;


var MapVote MapVote;

event InitializeDelayedInit(MapVote mutator)
{
	MapVote = mutator;
	SetTimer(0.5, False);
}

event Timer()
{
	EnsureSingleMapVoteMutatorIsActive();
	EnsureScoreboardUpdated();
	Destroy();
}

function EnsureSingleMapVoteMutatorIsActive()
{
	local Mutator M;
	local bool bIsThisRegistered, bIsAnotherRegistered;

	// Check if mutator was added to GameInfo
	for ( M = Level.Game.BaseMutator; M != None; M = M.NextMutator )
	{
		if (M == MapVote) 
		{
			bIsThisRegistered = True;
		}
		else if (M.IsA('MapVote'))
		{
			bIsAnotherRegistered = True;
		}
	}
	if (bIsAnotherRegistered)
	{
		Err("Detected multiple instances of MapVote");
		Err("Please use Mapvote either as ServerActor or Mutator");
		Err("Never add it as both ServerActor and Mutator at the same time");
		return;
	}
	if (bIsThisRegistered)
	{
		Nfo("MapVote mutator is active");
	}
	else
	{
		Level.Game.BaseMutator.AddMutator(MapVote);
		Nfo("Added MapVote mutator");
	}
}

function EnsureScoreboardUpdated()
{
	Level.Game.InitGameReplicationInfo();
}

static function Err(coerce string message)
{
	class'MV_Util'.static.Err(message);
}

static function Nfo(coerce string message)
{
	class'MV_Util'.static.Nfo(message);
}
