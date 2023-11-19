class MapVoteDelayedInit expands Info;


var MapVote MapVote;

event InitializeDelayedInit(MapVote mutator)
{
	MapVote = mutator;
	SetTimer(0.5, False);
}

event Timer()
{
	EnsureMutatorRegistered();
	EnsureScoreboardUpdated();
	Destroy();
}

function EnsureMutatorRegistered()
{
	local Mutator M;

	for ( M = Level.Game.BaseMutator; M != None; M = M.NextMutator )
	{
		if ( M == MapVote ) 
		{
			return; // MapVote already registered
		}
	}
	
	Level.Game.BaseMutator.AddMutator(MapVote);
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
