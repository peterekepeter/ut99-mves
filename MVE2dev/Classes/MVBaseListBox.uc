//================================================================================
// DummyListBox.
//================================================================================
class MVBaseListBox extends UWindowListBox;

var bool bShiftDown;
var bool bControlDown;

function KeyDown(int Key, float X, float Y)
{
	local PlayerPawn P;

	P = GetPlayerOwner();

	switch (Key)
	{
		case P.EInputKey.IK_Ctrl: 
			bControlDown = True; 
			break;
		case P.EInputKey.IK_Shift: 
			bShiftDown = True; 
			break;
		default:
			if ( bControlDown )
			{
				if( Key == Asc("c") || Key == Asc("C") )
				{
					EditCopy();
				}

				if( Key == Asc("v") || Key == Asc("V") )
				{
					EditPaste();
				}

				if( Key == Asc("x") || Key == Asc("X") )
				{
					EditCut();
				}
			}
			break;
	}
}

function KeyUp(int Key, float X, float Y)
{
	local PlayerPawn P;

	P = GetPlayerOwner();

	switch (Key)
	{
		case P.EInputKey.IK_Ctrl: 
			bControlDown = False; 
			break;
		case P.EInputKey.IK_Shift: 
			bShiftDown = False; 
			break;
	}
}

function EditCopy() 
{
	
}

function EditCut()
{
	// base implementation may be enough for most cases
	EditCopy();
	EditDelete();
}

function EditPaste()
{

}

function EditDelete()
{

}