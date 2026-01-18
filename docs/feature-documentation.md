
# Map Vote Extended Manual


## Known Limitations

 - **MAX** maps: 4096
 - **MAX** gametypes: 100

**This document is incomplete, but it does document some of the features!**

**For more information also check the changelog, it may be liste there**

Installation/troubleshooting is covered in the separate "Quickstart" file.


## Configuration

Your configuration only file is `MVE_Config.ini`. You will need to familiarize
yourself with `MVE_Config.ini` as it's the only way to configure MapVote. 
You'll need to learn and undestand how it's structured.

Use your favorite text editor and possible one that has syntax highlighting
for `ini` files. For example VsCode(ium) works out of the box. If you're using
notepad++ you may use the custom syntax provided with this MapVote which 
enhances ini highlighting for UT99. This can help avoid mistakes and typos
which are unfortunately silent errors when running UT99.

It's good pracitce to make backups of this file once you have a working 
configuration make a copy of it and give it a name.

A good workflow is:

1. Close server
2. Edit MVE_Config.ini
3. Restart server
4. Test the changes

It's recommended to make small changes and to test them often. Once you start
gain a bit of understanding, you'll be able to make larger changes with 
confidence, but until then make the smallest changes and see what it does. 


## Map Lists (aka FilterCode)

Every gametype you configure requires a list of maps. The list of maps to be 
used for a gametype is specified via the `FilterCode` property. 

```ini
CustomGame[19]=(GameName="DeathMatch",FilterCode="DMlist", ... )
CustomGame[20]=(GameName="Assault",FilterCode="ASlist", ... )
```

If you want two gametypes with the same list of maps, use the same FilterCode.

```ini
CustomGame[19]=(RuleName="Low Grav",FilterCode="DMlist", ... )
CustomGame[20]=(RuleName="InstaGib",FilterCode="DMlist", ... )
```

There are multiple types of filters which can be combined together.
MapVote supports having multiple include and exclude filters on the same
FilterCode and filters can be a simple wildcard file match or a combination 
of tags. There is also a special mode when you want very specific manual 
control over the order of the maps.


## Map Wildcard Filter

The simple-est way to use MapVote is with wildcard file prefix filters. 
You can just set up which maps to grab based on how the filename starts.
Since UT99 maps are prefixed with the gametype this is super simple to set 
up multiple gametypes.


```ini
MapFilters[0]=DMlist DM-*
MapFilters[1]=ASlist AS-*
MapFilters[2]=DOMlist DOM-*
MapFilters[3]=CTFlist CTF-*
```

Using this workflow, whenever you need to add new maps to the server, you need
to install the new files and run the map reload command and they will be 
instantly picked up.


## Map Tag Filters

In order to add more flexibility to the way map lists are built, it's also
possible to tag specific maps. You can assign multiple tags per map.

For example `DM-CliffyB4:RA` could mean that the map DM-CliffyB4 is suitable
for rocket arena and that `CTF-Whatever:LG:SNI` is suitable for lowgrav and
sniper matches. What the tags are and what they mean are up to the user.

Filters have been extended to support tags. This way maps with specific
tag can be added or removed from map lists using the filters.

To enable this feature you need to set `bEnableMapTags` to true in the
`[MVES.MapVote]` section of `MVE_Config.ini`

Configuration example follows, note the following features:
 - both maps and filters have multiple tags at the same time
 - dm1on1 filter matches maps that are both :SMALL and :DM
 - dmlowgrav filter matches maps that are both :LG and :DM
 - dmsniper is either :LARGE:DM maps or :LG:DM maps
 - dmnolowgrav contans all DM-* maps excluding maps tagged :LG

```ini
[MVES.MapVote]
bEnableMapTags=True
CustomGame[0]=(RuleName="Normal",FilterCode="dmnolowgrav", ...)
CustomGame[1]=(RuleName="1on1",FilterCode="dm1on1", ...)
CustomGame[2]=(RuleName="Low Gravity",FilterCode="dmlowgrav", ...)
CustomGame[3]=(RuleName="Sniper",FilterCode="dmsniper", ...)
CustomGame[4]=(RuleName="Medium Sized",FilterCode="dmmedium", ...)
MapFilters[0]=dm1on1 :SMALL:DM
MapFilters[1]=dmlowgrav :LG:DM
MapFilters[2]=dmsniper :LARGE:DM
MapFilters[3]=dmsniper :LG:DM
MapFilters[4]=dmmedium :MEDIUM:DM
MapFilters[5]=dmnolowgrav DM-*
ExcludeFilters[0]=dmnolowgrav :LG

[MVES.MapTagsConfig]
MapTagsVersion=1
MapTags[0]=DM-Fractal:DM:SMALL
MapTags[1]=DM-Morbias][:DM:SMALL
MapTags[2]=DM-HyperBlast:DM:SMALL
MapTags[3]=DM-Stalwart:DM:SMALL
MapTags[4]=DM-Deck16][:DM:MEDIUM
MapTags[5]=DM-Crane:DM:LARGE
MapTags[6]=DM-Morpheus:DM:MEDIUM:LG
```

The downsides of this is that if you use this was to configure map lists,
every time you want to add a map to the list you need to add an entry to 
`MVE_Config.ini` to that the map. Map lists built with tags require more
maintenance.


## Premade Map Lists

For coop campagins or for any other gametype where the order of maps needs
to be manually set up, premade lists can be used. When you make a premade
the number and order of the maps will be exactly as you set them up in the
configuration file. 

You will first need a gametype, let's call it Coop, but it can be anything else
and create a new FilterCode. The filter code can be customized but it must
start with `premade`, so for example `premadeRTNP` or `premadeDK` are fine,
in this example we'll go with `premadeA`.

```ini
CustomGame[33]=(GameName="Coop",FilterCode="premadeA",bHasRandom=False,...)
```

Next, in the map filters, you will need to list the maps you want in the premade
list.

```ini
MapFilters[20]=
MapFilters[21]=premadeA DM-Malevolence
MapFilters[22]=premadeA DM-Liandri
MapFilters[23]=premadeA DM-StalwartXL
MapFilters[24]=
MapFilters[25]=
```

As long as the convention above is respected, they will be picked up by the 
special premade filter in the order given in the config file, and will not
be sorted alphabetically.


## MapOverrides

Map overrides feature can be used to configure things that happen when a 
specific map is voted. Currently supported properties are:

- `Song` - you can override the song of a level if you don't like it or the
  if the author forgot to add one (happens to the best of us). For example you can
  use the secret song `?Song=Organic.Organic`

- `MutatorList` - you can add extra mutators which spawn only when a map is 
  voted, you can use this for example to alter the gravity of some maps by 
  spawning `?MutatorList=Botpack.LowGrav`

To enable this feature you first need to set `bEnableMapOverrides` to true in the
`[MVES.MapVote]` section of `MVE_Config.ini`


```ini
bEnableMapOverrides=True
```

Recommended to also have `bOverrideServerPackages` set to True so that MVES can 
take control over `ServerPackages` to be automatically populated with the 
referenced song packages. Otherwise you need to manually add all necessary packages 
to `ServerPackages` in the `[Engine.GameEngine]` section of `UnrealTournament.ini`

Configuration Example:

```ini
[MVES.MapOverridesConfig]
MapOverridesVersion=1
MapOverrides[0]=DM-Deck16][?Song=Organic.Organic?MutatorList=Botpack.LowGrav
MapOverrides[1]=DM-Gothic?Song=Mannodermaus-20200222.20200222
MapOverrides[2]=Song==Phantom.Phantom?Song=X-void_b.X-void_b
```

## Random Gametype/Rule aka Random Random

To enable this configure GameName or RuleName property to "Random" and 
recommended to also have bHasRandom=True this will make it possible for 
players to select a random game with random rule with random map. 

```ini
CustomGame[48]=(bEnabled=True,GameName="Random",RuleName="Random",GameClass="Botpack.DeathMatchPlus",FilterCode="xrandom",bHasRandom=True,VotePriority=1.000000,MutatorList="",Settings="",Packages="",TickRate=100,ServerActors="",Extends="",UrlParameters="",ExcludeMutators="",ExcludeActors="")
```

After this
option gets voted mapvote will first randomly pick a random game then inside 
the game a random rule is selected then a random map is selected.


## Configuration reuse via aliases

When configuring a lot of gametypes you'll notice that you're repeating the 
same configuration over and over again. You can reduce the repetition by 
reusing parts of configuration. This can be done using aliases.

Aliases are basically shorthands that get replaced with a longer definition.
You can reference an alias from the MutatorList.

When the configuration is loaded, the alias will be substituted based on the 
alias definition. Please note that this is basic text substitution and you 
will have to ensure that the commas are in the right place after substitution.

```ini
CustomGame[7]=(GameName="CTF",MutatorList="<lgsniper>",...)
CustomGame[8]=(GameName="DM",MutatorList="<lgsniper>",...)
Aliases[0]=<lgsniper>=Botpack.LowGrav,BotPack.SniperArena
```

The configuration above is same as manually typing out all the mutators as 
seen in the configuration below:

```ini
CustomGame[7]=(GameName="CTF",MutatorList="Botpack.LowGrav,BotPack.SniperArena",...)
CustomGame[8]=(GameName="DM",MutatorList="Botpack.LowGrav,BotPack.SniperArena",...)
```

Note: not all properties support aliases, but mutators do.


## Logo Texture 

Since mapvote automatically selects a map this feature is not that important
anymore as in a properly configured mapvote the logo would rarely be 
displayed.

A logo texture can now be configured and shown. The mapvote will instruct
all windows to show this texture initially before players select a map.

Example:

```ini
[MVES.MapVote]
ClientLogoTexture=Botpack.ASMDAlt_a00
```

## Configuring ServerPackages per Gametype

MapVote can take control over managing ServerPackages for you this allows
you to optimize you packages configuration to only make the clients download
what is needed only for the current gametype instead of requiring clients to
preload everything for the whole server. This feature is emabled via the 
`bOverrideServerPackages` flag.

- bOverrideServerPackages=False
  -> You edit ServerPackages inside UnrealTournament.ini

- bOverrideServerPackages=True 
  -> You edit ServerPackages inside MVE_Config.ini

If your MainServerPackages is empty then MapVote will extract the
packages for you from UnrealTournament.ini and populate the list. Otherwise 
you need to make sure the server packages are correcly set up. Here is an
example for a correct value.

```ini
MainServerPackages=("SoldierSkins","CommandoSkins","FCommandoSkins","SGirlSkins","BossSkins","Botpack")
```

Then in each CustomGame you can add additional packages on top which will 
then only be applied when that particular custom game is being played. And then
players would only need to download the additional packages when playing that 
gametype.

```ini
CustomGame[4]=(RuleName="Classic",Packages="", ...)
CustomGame[5]=(RuleName="Relics",Packages="Relics", ... )
```

### Populate ServerPackages for Known Properties

When `bOverrideServerPackages` is enabled then mapvote will automatically 
detect and populate packages from the following properties:

 - ClientLogoTexture
 - ClientScreenshotPackage
 - ClientPackage
 - Package of the GameClass
 - Package of the Song when using MapOverrides

This means you dont have to manually set these server packages. Note that
package changes are applied when a new map is voted through MapVote.

Package changes are logged to server log and you can also check in 
UnrealTournament.ini that they were correctly applied.


<!-- ## Screenshot Bundle [EXPERIMENTAL]

In order to have screenshot and level summary for every level in the map,
there is an experimental feature in place that allows players to load 
screenshots from a dedicated package which contains all screenshots for 
the levels. -->


<!-- ## Extended Gametype Configuration

- Added option Tickrate for each GameConfig. Also added DefaultTickRate globally. 
But not sure if change on fly tickrate applied on map change. Anyway be request of it.

- Added option ServerActors for each GameConfig, which allow spawn some actors,
without try add it to Mutator list, as do option Mutators.

- Added option bAvoidRandom for each GameConfig. Done in really dumb way. Random 
still same, but if pick game mode which forbidden random restart. Up to 1024 times.
 -->

## Configurable Shutdown on travel

When the match ends and the next match is being set up by MapVote, there is now
an option for MapVote to exit the server process. This can be used for more
advanced server control script to essentially have 1 process per match and
allows logs to be separated by match.


## Notes on Compatiblity

There was extensive work on compatibility so that MapVote could basically load
any gametype that exists for UT99


### Coop and HUB level compatibility

Normally MapVote controls and initiates server travel. When players vote a
map MapVote will initiate a server travel with correct parameters then after
the new map loads MapVote applies settings and spawns mutators.

When a travel is initiated outside of MapVote then this should be detected
by MapVote, it would allow the travel to happen and then it re-applies all the
gametype settings from the map before the travel.

This makes it possible to play coop single-player campaigns or any other 
gametype which temporarily needs to apply a server travel. 


### Assault compatibility

In assault during part 1 red team attacks blue team defends and part 2 the 
attack defend roles as swapped. Part 1 and part 2 are separated by a server
travel initiated by the assault gametype.

The two parts of assault matches works throught the same travel detection
mechanism that makes coop work by letting the assault gametype control the 
ending of the match. MapVote will then reset the assault properties so the 
next match can start cleanly.

Subclasses of `Botpack.Assault` (such ass league assault) are supported.


### Always handle MonsterHunt end

Fixed a bug where was a bug where MapVote interface would never show up at the
end of MonsterHunt games. The issue here was MapVote wrongly checking for tie
between players in monster hunt games as MonsterHunt is actually a tem game


### Improved JailBreak compatibility

Players that rejoined during a JailBreak could not vote because of how the
player detection was implemented in older versions of MapVote. This is fixed 
by having player detection run in a timer loop, so at fixed intervals the 
server checks and adds players to the mapvote who were previosely not added.
This ensures that all players can vote.


