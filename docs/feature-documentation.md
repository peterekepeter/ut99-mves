
# Map Vote Extended Documentation

## Known Limitations

 - **MAX** maps: 4096
 - **MAX** gametypes: 100


## Premade lists

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


## Green background for players that voted

Players that vote recieve a green background. This was a broken feature. 
Players did receive the green background but only when mapvote window 
opens. Now with the fixes applied the player background shouls switch to
green as soon as they vote.


## Logo Texture 

A logo texture can now be configured and shown. The mapvote will instruct
all windows to show this texture initially before players select a map.

Example:

```ini
[MVES.MapVote]
ClientLogoTexture=Botpack.ASMDAlt_a00
```


## Populate ServerPackages for Known Properties [EXPERIMENTAL]

When `bOverrideServerPackages` is enabled then mapvote will automatically 
detect and populate packages from the following properties:

 - ClientLogoTexture
 - ClientScreenshotPackage
 - ClientPackage

This means you dont have to manually set these server packages. But currently
the changes to take place need a new map to be voted through mapvote.


## Screenshot Bundle [EXPERIMENTAL]

In order to have screenshot and level summary for every level in the map,
there is an experimental feature in place that allows players to load 
screenshots from a dedicated package which contains all screenshots for 
the levels.


## Map Tags Feature [EXPERIMENTAL]

In order to add more flexibility to the way map lists are built, it's now
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

## Gametype Limit Increased

The limit of 63 gametypes was lifted. It's now possible to have more gametypes.
Currently 100 gametypes work properly. The gametype array has length of 512 but
only the first 100 work properly without issues.'

Having more than 100 gametypes currently crashes MVE.

## New Maps Feature

When new maps are scanned by MVE they get added to a special map list which is
shown initially instead of the empty list. This way the new maps are more 
visibile to players and are easier to discover.

## Extended Gametype Configuration

- Added option Tickrate for each GameConfig. Also added DefaultTickRate globally. 
But not sure if change on fly tickrate applied on map change. Anyway be request of it.

- Added option ServerActors for each GameConfig, which allow spawn some actors,
without try add it to Mutator list, as do option Mutators.

- Added option bAvoidRandom for each GameConfig. Done in really dumb way. Random 
still same, but if pick game mode which forbidden random restart. Up to 1024 times.


## MapOverrides

Map overrides feature can be used to configure map specific rules, currently the
only supported property is `Song`, it can be used to override the song played on
the map.

To enable this feature you need to set `bEnableMapOverrides` to true in the
`[MVES.MapVote]` section of `MVE_Config.ini`

`bOverrideServerPackages` should be enabled to allow `ServerPackages` to be
automatically populated with the referenced song packages. Otherwise you need to
manually add all used packages to `ServerPackages` in the `[Engine.GameEngine]`
section of `UnrealTournament.ini`

Configuration Example:

```ini
[MVES.MapOverridesConfig]
MapOverridesVersion=1
MapOverrides[0]=DM-Deck16][?Song=Organic.Organic
MapOverrides[1]=DM-Gothic?Song=Mannodermaus-20200222.20200222
MapOverrides[2]=Song==Phantom.Phantom?Song=X-void_b.X-void_b
```

## Fast Player Detection

I've added a fast player detection that triggers on the same tick when the
player joins the server, instead of waiting for the imter interval to pass.

The timer interval is still there as a safety net for gametypes that have custom
player ID assignment.


## Improved PlayerPawn filtering

Mapvote needs to discrimate between bots and players of variou sorts. Previosely
the mapvote logic allowed non real human players to join mapvote, and vote on
map. Since these were not real players there would be no way for them to
actually vote.

The logic improvement improves calculation of vote percentages as it should now
only consider real human players. (sorry bots)


## Don't broadcast already voted map

Players voting the same map twice won't broadcast to all players. This was
previosely abused by players to spam the chat. Instead of broadcast the voter
gets a message that they already voted so they know their vote was already
registered.


## Improved Assault compatibility

The 2 parts of assault matches now work. Part 1 red team attacks blue team
defends and part 2 the attack defend roles as swapped.

This is done by letting the assault gametype control the ending of the match.
Mapvote will then reset the assault properties so the next match can start
cleanly.

⚠ If assault game is interrupted, the next assault game will not be properly
reset and a dummy game must be played for assault to work properly again.

Subclasses of `Botpack.Assault` (such ass league assault) are supported.

### Always handle MonsterHunt end

Fixed a bug where was a bug where MapVote interface would never show up at the
end of MonsterHunt games. The issue here was MapVote wrongly checking for tie
between players in monster hunt games.


## Improved JailBreak compatibility

Players that rejoined during a JailBreak could not vote because of how the
player detection was implemented. This is now fixed by having player detection
run in a timer loop, so at fixed intervals the server checks and adds players to
the mapvote who were previosely not added. This ensures that all players can
vote.


## Configurable Shutdown on travel

When the match ends and the next match is being set up by MapVote, there is now
an option for MapVote to exit the server process. This can be used for more
advanced server control script to essentially have 1 process per match and
allows logs to be separated by match.
