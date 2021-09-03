//================================================================================
// MapHistory.
//================================================================================
class MapHistory expands Object
	config(MVE_MapHistory);

var MV_MapList MapList;

struct MapElement
{
	var() config int mIdx;
	var() config byte gIdx;
	var() config int Acc; //Accumulated points
};

var() config MapElement Elements[512];
var() config int iMe;

//Validation checks already passed
//Map indexes are ALWAYS sorted
function NewMapPlayed( int mIdx, int gIdx, int CostAdd)
{
	local int i;

	For ( i=0 ; i<iMe ; i++ )
	{
		if ( --Elements[i].Acc <= 0 )
			ClearElement( i);
	}
	i=0;
	While ( i<iMe )
	{
		if ( (Elements[i].mIdx == mIdx) && (Elements[i].gIdx == gIdx) ) //FOUND EXISTING ENTRY!
		{
			Elements[i].Acc += CostAdd + 1;
			Goto END;
		}
		if ( Elements[i].mIdx > mIdx ) //This one is one slot after, perform push and use this slot instead
		{
			PushList( i);
			Goto SET;
		}
		i++;
	}
	//This happens if we went through all list and see we're last
	iMe++;	
	SET:	
	Elements[i].mIdx = mIdx;
	Elements[i].gIdx = gIdx;
	Elements[i].Acc = CostAdd;
	END:
	SaveConfig();
	Log("History Saved");
}

//Delete element and keep order
function ClearElement( int idx)
{
	local int i;
	i = idx+1;
	While ( (i < iMe) && (i < ArrayCount(Elements)) )
	{
		Elements[i-1] = Elements[i];
		i++;
	}
	iMe--;
}

//Push list one place up, let idx slot ready to replace
function PushList( int idx)
{
	local int i;
	i = iMe++;
	While ( i > idx )
	{
		Elements[i] = Elements[i-1];
		i--;
	}
}


function bool IsExcluded( int idx)
{	return Elements[idx].Acc > MapList.Mutator.MapCostMaxAllow;	}

function int GameIdx( int idx)
{	return Elements[idx].gIdx;	}

function int MapIdx( int idx)
{	return Elements[idx].mIdx;	}

defaultproperties
{
	Elements(0)=(mIdx=205,gIdx=3,Acc=3)
	Elements(1)=(mIdx=251,gIdx=3,Acc=4)
	Elements(2)=(mIdx=258,gIdx=3,Acc=5)
	Elements(3)=(mIdx=215,gIdx=3,Acc=2)
	Elements(4)=(mIdx=215,gIdx=3,Acc=4)
	Elements(5)=(mIdx=99,Acc=3)
}