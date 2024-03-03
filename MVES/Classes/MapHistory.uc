class MapHistory expands Object
	config(MVE_MapHistory);

struct MapElement
{
	var() config string Map;          
	var() config string GameName;
	var() config string RuleName;
	var() config int Acc; //Accumulated points
};
	
var() config MapElement Elements[512];
var() config int ElementCount;

var MapElement DefaultMapElement;

function NewMapPlayed(MV_Result r, int MapCostAddPerLoad)
{
	local int i, lastSmaller;
	lastSmaller = -1;

	for ( i = 0 ; i < ElementCount ; i += 1 )
	{
		while ( --Elements[i].Acc <= 0 )
		{
			PopList(i);
		}
		if ( Elements[i].Map < r.Map ) 
		{
			lastSmaller = i;
		}
	}

	i = lastSmaller + 1;

	if ( i < ElementCount && Elements[i].Map == r.Map ) 
	{
		// update existing
		Elements[i].Acc += MapCostAddPerLoad + 1;
	}
	else 
	{
		// insert new
		PushList(i);
		Elements[i].Map = r.Map;
		Elements[i].Acc = MapCostAddPerLoad;
	}

	Elements[i].GameName = r.GameName;
	Elements[i].RuleName = r.RuleName;
}

function PopList( int idx )
{
	local int i;
	ElementCount -= 1;
	for ( i = idx; i < ElementCount; i += 1 )
	{
		Elements[i] = Elements[i + 1];
	}
	Elements[ElementCount] = DefaultMapElement;
}

function PushList( int idx )
{
	local int i;
	for ( i = ElementCount;  i > idx; i -= 1 )
	{
		Elements[i] = Elements[i - 1];
		i -- ;
	}
	ElementCount += 1;
}

function bool IsExcluded( string map, int MapCostMaxAllow )
{
	local int i;
	for ( i = 0; i < ElementCount; i += 1 )
	{
		if ( Elements[i].Map == map )
		{
			return Elements[i].Acc > MapCostMaxAllow; 
		}
	}
	return False; // not found
}

function DebugPrintHistory() 
{
	local int i, acc;
	local string name;
	for ( i = 0; i < ElementCount; i+=1 )
	{
		name = Elements[i].Map;
		acc = Elements[i].Acc;
		Log(i$" : "$name$" "$acc);
	}
}
