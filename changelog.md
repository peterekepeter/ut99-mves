# January 2022

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

# December 2021

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

# November 2021

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

# October 2021

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
