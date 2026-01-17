// AdminTabWindow wraps AdminWindow inside a tab
class AdminTabWindow extends UWindowScrollingDialogClient;

function Created ()
{
	ClientClass = Class'AdminWindow';
	FixedAreaClass = None;
	Super.Created();
}
