class MapOverridesConfig extends MV_Util config(MVE_Config);

const CurrentVersion = 1;
const MapOverridesCount = 64;

var() config int MapOverridesVersion;
var() config string MapOverrides[64];

function RunMigration()
{
	if (MapOverridesVersion == CurrentVersion)
	{
		return; // we're good to go!
	}
	if (MapOverridesVersion > CurrentVersion)
	{
		Err("unknown MapOverrides version, MapOverrides may not function correctly");
		return;
	}
	if (MapOverridesVersion <= 0)
	{
		Nfo("initializing MapOverrides with examples, check and modify if necesary");
		MapOverridesVersion=1;
		MapOverrides[0]="DM-LevelNameGoesHere?Song=Organic.Organic";
	}
	SaveConfig();
}

defaultproperties
{
      MapOverridesVersion=0
      MapOverrides(0)=""
      MapOverrides(1)=""
      MapOverrides(2)=""
      MapOverrides(3)=""
      MapOverrides(4)=""
      MapOverrides(5)=""
      MapOverrides(6)=""
      MapOverrides(7)=""
      MapOverrides(8)=""
      MapOverrides(9)=""
      MapOverrides(10)=""
      MapOverrides(11)=""
      MapOverrides(12)=""
      MapOverrides(13)=""
      MapOverrides(14)=""
      MapOverrides(15)=""
      MapOverrides(16)=""
      MapOverrides(17)=""
      MapOverrides(18)=""
      MapOverrides(19)=""
      MapOverrides(20)=""
      MapOverrides(21)=""
      MapOverrides(22)=""
      MapOverrides(23)=""
      MapOverrides(24)=""
      MapOverrides(25)=""
      MapOverrides(26)=""
      MapOverrides(27)=""
      MapOverrides(28)=""
      MapOverrides(29)=""
      MapOverrides(30)=""
      MapOverrides(31)=""
      MapOverrides(32)=""
      MapOverrides(33)=""
      MapOverrides(34)=""
      MapOverrides(35)=""
      MapOverrides(36)=""
      MapOverrides(37)=""
      MapOverrides(38)=""
      MapOverrides(39)=""
      MapOverrides(40)=""
      MapOverrides(41)=""
      MapOverrides(42)=""
      MapOverrides(43)=""
      MapOverrides(44)=""
      MapOverrides(45)=""
      MapOverrides(46)=""
      MapOverrides(47)=""
      MapOverrides(48)=""
      MapOverrides(49)=""
      MapOverrides(50)=""
      MapOverrides(51)=""
      MapOverrides(52)=""
      MapOverrides(53)=""
      MapOverrides(54)=""
      MapOverrides(55)=""
      MapOverrides(56)=""
      MapOverrides(57)=""
      MapOverrides(58)=""
      MapOverrides(59)=""
      MapOverrides(60)=""
      MapOverrides(61)=""
      MapOverrides(62)=""
      MapOverrides(63)=""
}
