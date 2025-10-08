// Fixes update server / masterserver
// Permission granted by Bugge to be included into MVE
// Source: ut99.org/viewtopic.php?t=15965
class MVFixNetNews expands Object;

var bool bFixApplied;

static simulated function FixNetNews() 
{
	// Low effort guard
	if ( class'MVFixNetNews'.Default.bFixApplied ) 
	{
		return;
	}
	else
	{
		class'MVFixNetNews'.Default.bFixApplied = True;
	}

	ApplyFixNetNews();
}

static simulated function ApplyFixNetNews() 
{
	local string before, after;

	before = class'UBrowserUpdateServerLink'.Default.UpdateServerAddress;
	after = "oldunreal.com";

	if ( InStr(before, "epicgames") != -1 ) 
	{
		class'UBrowserUpdateServerLink'.Default.UpdateServerAddress = after;
		class'UBrowserUpdateServerLink'.Static.StaticSaveConfig();
		Log("FixNetNews applied. Restart the game for the changes to take effect.");
		Log(" - UpdateServerAddress was "$before$" patched to "$after);
	}
}
