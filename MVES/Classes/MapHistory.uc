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
	local int i, j;
	local bool bFound;

	// decrement existig and pop when cost is less than 0
	for ( i = 0 ; i < ElementCount ; i += 1 )
	{
		while ( --Elements[i].Acc <= 0 && i < ElementCount ) 
		{
			PopList(i);
		}
		if ( Elements[i].Map == r.Map 
			&& Elements[i].GameName == r.GameName
			&& Elements[i].RuleName == r.RuleName )
		{
			Elements[i].Acc += MapCostAddPerLoad;
			bFound = True;
		}
	}

	if ( bFound ) return;

	if ( ElementCount < 512 )
	{
		i = ElementCount;
		ElementCount += 1;
	}
	else 
	{
		i = FindMinCostIndex();
	}
	
	Elements[i].Map = r.Map;
	Elements[i].GameName = r.GameName;
	Elements[i].RuleName = r.RuleName;
	Elements[i].Acc = MapCostAddPerLoad;

	if ( ElementCount < 512 )
	{
		// cleanup one afer the newly inserted
		Elements[ElementCount] = DefaultMapElement;
	}
}

function int FindMinCostIndex() 
{
	local int i, j;

	if ( ElementCount <= 0 ) 
	{
		return -1;
	}

	j = 0;

	for ( i = 1 ; i < ElementCount ; i += 1 )
	{
		if ( Elements[i].Acc < Elements[j].Acc ) 
		{
			j = i;
		}
	}

	return j;
}

function PopList( int idx )
{
	if ( idx < ElementCount ) 
	{
		ElementCount -= 1;
		Elements[idx] = Elements[ElementCount];
		Elements[ElementCount] = DefaultMapElement;
	}
}

function bool IsExcluded( string map, int MapCostMaxAllow )
{
	local int i, cost;

	for ( i = 0; i < ElementCount; i += 1 )
	{
		if ( Elements[i].Map == map )
		{
			cost += Elements[i].Acc;
		}
	}
	return cost > MapCostMaxAllow; // not found
}

function bool IsAllowed( MV_Result r, int MapCostMax, int RuleCostMax, out string reason)
{
	local int i, mapCost, ruleCost;

	reason = "";

	for ( i = 0; i < ElementCount; i += 1 )
	{
		if ( Elements[i].Map == r.Map )
			mapCost += Elements[i].Acc;
		if ( Elements[i].RuleName == r.RuleName )
			ruleCost += Elements[i].Acc;
	}

	if ( mapCost > MapCostMax )
	{
		reason = "map";
		return False;
	}

	if ( ruleCost > RuleCostMax )
	{
		reason = "rule";
		return False;
	}

	return True;
}

function DebugPrintHistory() 
{
	local int i, acc;
	local string G, R, M;
	for ( i = 0; i < ElementCount; i+=1 )
	{
		G = Elements[i].GameName;
		R = Elements[i].RuleName;
		M = Elements[i].Map;
		acc = Elements[i].Acc;
		Log(i$" : "$G@R@M@acc);
	}
}
