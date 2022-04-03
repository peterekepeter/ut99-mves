//================================================================================
// MapVotePageControl.
//================================================================================

class MapVotePageControl extends UMenuPageControl;

function KeyDown (int Key, float X, float Y)
{
  Super.KeyDown(Key,X,Y);
  ParentWindow.KeyDown(Key,X,Y);
}

