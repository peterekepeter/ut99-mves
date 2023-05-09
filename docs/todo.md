 
 - populate/patch server mutators string
 - inject CLIENT_VERSION and SERVER_VERSION
 - test the release package with a clean UT99 to see if it works
 - ALL map switch attempts by MVE should be logged
 - MVES on boot should print version so that server admins know that it started

## Map Groups

In the map list have the maps groupped by section.
For example BT maps groupped by difficulty.
Tournament maps groupped by size.

## Idle Switch

```ini
    bSwitchToRandomMapOnIdle=True
    bSwitchToDefaultMapOnIdle=False
    ServerIdleAfterMinutes=60
```

Fix random map to exclude game configs with bAvoidRandom

accept !vote as command, more explicit

## Priority List

- switch to a default map/gametype when server empty (configurable threshold 5mins 10mins 15mins)
- limit the gametype randomness when nobody votes
- render screenshot with better filtering
- maintain view of last map when window reopens
- map search on client side
- extra URL arguments per gametype
- custom map folders
- find a way do not replicate map list after map list is loaded



## Cleanup Aliases

Alias structure recommended by [rev]rato.skt!

```ini
    Alias[0]=(Name="<NewnetClassic>",Details="fnn170.NewNetServer,SmartSB112d.SmartSB,ComboImpressive.cwMut")
    Alias[1]=(Name="",Details="")
    Alias[2]=(Name="",Details="")
```

 - Recursive resolve?

 - Use case for grouping comonly used mutators

 - Use case for version control of mods


## Path Management

 - sometimes 2 maps refer to 2 packages that have the same name but are different,
 see if its possible to find a way to containerize them,.

    - [rev]rato.skt example: sometimes we have an MH-map and a CTF-BT map that have the same music name or texture but they are different.. so if one of the two archive were replaced, one map it will not work!

## Server Customization

 - edit the text of string labels for 
    - "Game Mode", "Rule", 
    - "Player Name", "Kick Vote", "Votes", "Player"
    - new label above screenshot in center
    - allows server admins to translate the text for their native country language
    - requested by [rev]rato.skt

 - server side color theme
   - players don't know they can configure colors, server can have a good default
   - there are more players than servers
   - client can override with personal settings
    - requested by [rev]rato.skt