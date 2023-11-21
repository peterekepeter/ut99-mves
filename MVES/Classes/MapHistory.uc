//================================================================================
// MapHistory.
//================================================================================
class MapHistory expands Object
	config(MVE_MapHistory);

var MV_MapList MapList;

struct MapElement
{
	var() config string Map;          
	var() config string GameName;
	var() config string RuleName;
	var() config int Acc; //Accumulated points
};

var() config MapElement Elements[512];
var() config int ElementCount;

//Validation checks already passed
//Map indexes are ALWAYS sorted
function NewMapPlayed(MV_Result r)
{
	local int i;
	local int costAdd;

	costAdd = MapList.Mutator.MapCostAddPerLoad;

	For ( i=0 ; i<ElementCount ; i++ )
	{
		if ( --Elements[i].Acc <= 0 )
		{
			ClearElement( i);
		}
	}
	i=0;
	While ( i<ElementCount )
	{
		if ( Elements[i].Map == r.Map ) //FOUND EXISTING ENTRY!
		{
			Elements[i].Acc += costAdd + 1;
			Goto END;
		}
		if ( Elements[i].Map > r.Map ) //This one is one slot after, perform push and use this slot instead
		{
			PushList( i);
			Goto SET;
		}
		i++;
	}
	//This happens if we went through all list and see we're last
	ElementCount++;	
	SET:	
	Elements[i].Map = r.Map;
	Elements[i].Acc = costAdd;
	END:
	Elements[i].GameName = r.GameName;
	Elements[i].RuleName = r.RuleName;
	SaveConfig();
}

//Delete element and keep order
function ClearElement( int idx)
{
	local int i;
	i = idx+1;
	While ( (i < ElementCount) && (i < ArrayCount(Elements)) )
	{
		Elements[i-1] = Elements[i];
		i++;
	}
	ElementCount--;
}

//Push list one place up, let idx slot ready to replace
function PushList( int idx)
{
	local int i;
	i = ElementCount++;
	While ( i > idx )
	{
		Elements[i] = Elements[i-1];
		i--;
	}
}

function bool IsExcluded( string map )
{
	local int i;
	for ( i = 0; i < ElementCount; i += 1 )
	{
		if (Elements[i].Map == map)
		{
			return Elements[i].Acc > MapList.Mutator.MapCostMaxAllow; 
		}
	}
	return False; // not found
}
