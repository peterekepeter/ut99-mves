class MV_TravelInfo expands Info config(MVE_Travel);

var() config string TravelString; // Used to load the next map!
var() config int TravelIdx; // Use to load game settings & mutators for next map
var() config int RestoreTryCount;
var() config bool bIsIdle;
var() config int EmptyMinutes;
