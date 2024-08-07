class MapVoteDelayedInit expands Info;


var MapVote MapVote;

event InitializeDelayedInit(MapVote mutator)
{
	MapVote = mutator;
	SetTimer(0.5, False);
}

event Timer()
{
	ApplyFixForMutatorsQueryLagSpikes();
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

function ApplyFixForMutatorsQueryLagSpikes() 
{
	if ( !MapVote.bFixMutatorsQueryLagSpikes ) 
	{
		return; // fix is disabled
	}
	// fixes common issue of server query DDOS-ing the game engine
	// https://ut99.org/viewtopic.php?p=142091
	Level.Game.GetRules();
	if ( Level.Game.EnabledMutators == "" ) 
	{
		Level.Game.EnabledMutators = "MapVote "$MapVote.ClientPackageInternal;
	}
}

static function Err(coerce string message)
{
	class'MV_Util'.static.Err(message);
}

static function Nfo(coerce string message)
{
	class'MV_Util'.static.Nfo(message);
}
