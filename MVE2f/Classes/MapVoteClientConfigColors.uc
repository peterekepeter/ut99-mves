class MapVoteClientConfigColors extends Object;

var String ColorCol[11];
var Color ColorDef[11];
var Color WhiteColor, BlackColor;
var Color RedColor;
var Color PurpleColor;
var Color LightBlueColor;
var Color TurquoiseColor;
var Color GreenColor;
var Color OrangeColor;
var Color YellowColor;
var Color PinkColor;
var Color DeepBlueColor;

function String GetNameByIndex(int n)
{
	return ColorCol[n];
}

function Color GetColorByIndex(int n)
{
	return ColorDef[n];
}

defaultproperties
{
	ColorCol(0)="Red"
	ColorCol(1)="Purple"
	ColorCol(2)="Light Blue"
	ColorCol(3)="Turquoise"
	ColorCol(4)="Green"
	ColorCol(5)="Orange"
	ColorCol(6)="Yellow"
	ColorCol(7)="Pink"
	ColorCol(8)="White"
	ColorCol(9)="Deep Blue"
	ColorCol(10)="Black"
	ColorDef(0)=(R=255,G=0,B=0,A=0)
	ColorDef(1)=(R=128,G=0,B=128,A=0)
	ColorDef(2)=(R=0,G=100,B=255,A=0)
	ColorDef(3)=(R=0,G=255,B=255,A=0)
	ColorDef(4)=(R=0,G=255,B=0,A=0)
	ColorDef(5)=(R=255,G=120,B=0,A=0)
	ColorDef(6)=(R=255,G=255,B=0,A=0)
	ColorDef(7)=(R=255,G=0,B=255,A=0)
	ColorDef(8)=(R=255,G=255,B=255,A=0)
	ColorDef(9)=(R=0,G=0,B=255,A=0)
	ColorDef(10)=(R=0,G=0,B=0,A=0)
}
