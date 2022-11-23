class MV_Sort expands MV_Util;

const MAX_ITEMS = 7999;

var string Items[8000];
var string ItemsCaps[8000];
var int ItemCount;
var int DuplicatesRemoved;

function Clear()
{
	ItemCount = 0;
	DuplicatesRemoved = 0;
}

function AddItem(string item)
{
	Items[ItemCount] = item;
	ItemsCaps[ItemCount] = Caps(item);
	ItemCount += 1;
}

function Sort()
{
	if (ItemCount < 2)
	{
		return;
	}
	SortStep(0, ItemCount - 1);
}


function SortStep(int start, int end)
{
	local int length, mid, i, j, p;
	local string temp;
	length = end - start;
	if (length < 1) 
	{
	}
	else if (length == 1) 
	{
		if (CompareLessThan(end, start))
		{
			Swap(start, end);
		}
	}
	else
	{
		mid = (start + end) / 2;
		p = ItemCount; // use slot after list
		Copy(mid, p);
		i = start; 
		j = end;
		while (i < j) 
		{
			while (i < j && CompareLessThan(i, p))
			{
				i += 1;
			}
			while (i < j && CompareLessThan(p, j))
			{
				j -= 1;
			}
			if (i < j)
			{
				Swap(i, j);
				i += 1;
				j -= 1;
			}
		}
		SortStep(start, j);
		SortStep(i, end);
	}
}

function SortAndDeduplicate()
{
	local int i, j;

	Sort();

	for (i = 1; i < ItemCount; i += 1)
	{
		if (!CompareLessThan(i - 1, i))
		{
			break;
		}
	}

	for (j = i + 1; j < ItemCount; j += 1)
	{
		if (CompareLessThan(j - 1, j))
		{
			Copy(j, i);
			i += 1;
		}
	}

	DuplicatesRemoved += ItemCount - i;
	ItemCount = i;
}

function bool CompareLessThan(int i, int j)
{
	return ItemsCaps[i] < ItemsCaps[j];
}

function Swap(int i, int j)
{
	local string temp;
	temp = Items[j];
	Items[j] = Items[i];
	Items[i] = temp;
	temp = ItemsCaps[j];
	ItemsCaps[j] = ItemsCaps[i];
	ItemsCaps[i] = temp;
}

function Copy(int i, int j)
{
	Items[j] = Items[i];
	ItemsCaps[j] = ItemsCaps[i];
}

function DebugPrint()
{
	local string s;
	local int i;
	for (i = 0; i < ItemCount; i += 1)
	{
		s = s$Items[i]$" ";
	}
	Nfo(s);
}