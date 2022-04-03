class MV_Util expands Object abstract;
 
const LogToken = "[MVE]";

static function Err(coerce string message)
{
	Log(LogToken$" [ERROR] "$message$"!!!");
}

static function Nfo(coerce string message)
{
	Log(LogToken$" "$message$".");
}

