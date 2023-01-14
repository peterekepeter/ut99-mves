# `2f-v1`  Jan 14, 2023

 - **EXPERIMENTAL**: New gametype evaluation and setup code. For now everything
   similarly to before. I'm working on new features here but still not decided.

 - `MVES.MapVote` can now be installed as ServerActor instead of Mutator.

 - MVE window can always be opened, if data is not loaded it should show a 
   loading message with a percentage.

 - Corrected the number of maps shown in the MVE popup window title bar.
   
 - Always load client config from same section regardless of package name. 
   While this version will still break client configs, from this version on
   the client configs will not reset when the client package is updated.

 - Travel variables moved to separate file `MVE_Travel.ini`, this file is
   rewritten every time a MVE switches to a new map. Having it in separate
   file is cleaner and allows editing config file without accidental 
   overwrites while the server is running.

 - Automatically set GameName for scoreboard. This is enabled by default 
   because it helps keep track of what gametype was loaded. It can be 
   overwritten per gametype if needed.

    ```ini
    [MVES.MapVote]
    bAutoSetGameName=True
    CustomGame[0]=(Settings="FragLimit=30,GameName=Awesome Deathmatch")
    ```

 - Updated MVE_Config with a more practical example:
   - Added example logo texture
   - Added premade example to MVE_Config.ini
   - Added example gametype configurations

 - Sort and deduplicate scanned maps. 
   - Can be skipped for faster reloads
   - Map names will be sorted alphabetically (not case sensitive)
   - Duplicate entries if found are removed
   - Premade lists not affected, they stay as defined in config
 
 - INI option to reload, fullscan, saveconfig on next run. These options can be
   useful when editing the configuration. I've been using `bReloadOnEveryRun` 
   whenever I'm working on  the map reload & filtering logic. Removed 
   `bFirstRun`, instead `bSaveConfigOnNextRun=True` can be used.

    ```ini
    [MVES.MapVote]
    bReloadOnEveryRun=True
    bReloadOnNextRun=False
    bSaveConfigOnNextRun=False
    bFullscanOnNextRun=False
    ```

 - Fallback for players without watcher. In case players are not part of the 
   voter list, they get added when they try to access mapvote screen.

 - Tweaked player detector, now checks for valid player name.

 - Changed the server code name to UT-Server, when adding as "none" we need to 
   use command for reloading MVE, admins can open the window and possible to 
   reload.

 - Map cooldowns check on server side, cannot be bypassed with mutate command.

 - Remove version from info tab.
   
 - Optimized map list transfer. If you have a lot of gametypes the map list 
   should load a bit faster than before.

 - Map string validaton returns reason for which the maps string is not valid   

 - Improved error messages when map list not loaded.

## ⚠ Known Issues

 - Maps that are on cooldown are not shown in red.

 - Map listing still has some bugs, occasionally you can see duplicates maps. 

 - Map list might fail to load on first try, but it always works on second try.


# `2e-v3`  Jul 23, 2022

### 1. Extended countdown until first vote

Sometimes when a match ends people start talking chatting or just need a few seconds of break. Because of this 
a lot of time we ended up not voting and getting a random gametype with random map. 

In order for players to have extra time the voting time window will now be extended by an extra `VoteTimeLimit` seconds until the first vote is received. When the first vote is received there are `VoteTimeLimit` seconds until the map switch. So if players are decided and vote fast, there is no extra delay.


### 2. Reset voting if a voted map failed to load.

I've implemented a check, before loading a map MVE will test if the map can be loaded.
If the map cannot be loaded then the voting will be reset. 

Instead of a server crash, players are given a chance to vote for another map. 

### 3. Reset assault game on every map switch

Previosly assault game was only reset at the end of the 2nd round of an Assault game,
because of this if mid-game voting was started it was possible to not have a correctly
reset Assault game. This fixes that by applying the assault reset every time MVE switches to a new map.


### 4. Fullscan - new admin command

There is as new admin command called fullscan. This is same as a reload but
MapVote will test every map to see if they can be loaded. This can be used
to track down maps that have missing packages. This is meant as a helper
tool for admins to batch verify that the maps have been correctly installed.

Command:

```cmd
mutate bdbmapvote fullscan
```

Check the server logs for output, you'll see a huge list of scanned maps:

```log
[MVE] Scan `MH-WaterGodTemple.unr`: OK!
[MVE] Scan `MH-Wolf3Dv4.unr`: OK!
[MVE] Scan `MH-ZenithCity.unr`: OK!
Failed to load "MonsterMatch": Can't find file for package "MonsterMatch"..
Failed to load "MM-SpireVillage": Can't find file for package "MonsterMatch"..
Failed to load "PlayerStart unr.PlayerStart0": Can't find file for package "MonsterMatch"..
[MVE] Scan `MM-SpireVillage.unr`: failed to load! Skipping maps that fail to load!
[MVE] Scan `Morose.unr`: OK!
```

### 5. Restore last voted map 

When MapVote starts up it will now perform a check to see what the current map is
and if its not the map that was voted then it will instantly switch to the voted map.

This enhancement aims to ensure that the correct map with the correct gametype and
all the necessary packages are loaded. It also helps a lot when you're testing a setup
since because of this you can tweak the config and when you restart the same server
you get the same map and gametype when it was turned off.

When this feature kicks in it looks like the following:

```log
[MVE] PostBeginPlay!.
[MVE] ServerPackages are correctly set up!.
[MVE] Current map `DM-NRMC-Trident-v3` does not match the travel map `DM-NRMC-OutreachIV`.
[MVE] Will attempt to switch to `DM-NRMC-OutreachIV`.
[MVE] Goto `DM-NRMC-OutreachIV:54`` TryCount: `1`.
[MVE] -> TravelString: `DM-NRMC-OutreachIV?Game=Botpack.DeathMatchPlus`.
[MVE] -> GameIdx: `54`.
[MVE] 3 map override rules were loaded!.
[MVE] -> ServerPackages: `("SoldierSkins","CommandoSkins","FCommandoSkins","SGirlSkins","BossSkins","Botpack","multimesh","epiccustommodels","tcowmeshskins","tnalimeshskins","tskmskins","SkeletalChars","SkeletalCharsFix313","fnn166","BP1H166","BP4H166","SBU3","UP2","fsb21","UTChat22e","IntroCUT99.uax","FFNLogoTexV3","UTSAccuBeta4_2_9","SendTo_v07c","FastCap","ClassicCrotchshotv1_1","CountryFlags3ffn","MVE2e","cache-mvss-l56ip47a","FFNLogoTexV3")`.
[MVE] -> TickRate: `65`.
```

In case something goes wrong, the restore will be retried 3 times after which it will stop trying. 


### 6. Map list summary and error detection on reload

The stats printed at the end of a reload has been improved. From now MVE will print the number
of scanned maps, the number of maps that have been matched by filters and the number 
of active gametypes. If any of these values are off, advice is given.

This is meant to help admins have a better understanding of what's happening and to 
easier debug if something went wrong.

```cmd
mutate bdbmapvote reload
```

```log
[MVE] Scanning all map files, this might take a while
[MVE] Remove old + add new maps...
[MVE] Checking premade lists...
[MVE] Matched 0 maps to 0 gametypes from 1 scanned maps.
[MVE]
[MVE] [ERROR] No maps were loaded!
[MVE]
[MVE] [ERROR] No gametypes were detected!
[MVE]
[MVE] -> enabled gametypes with `bEnabled=True`
[MVE] -> make sure the gametype's VotePriority > 0
[MVE] -> the gametype's GameClass, GameName, RuleName must not be empty
[MVE]
[MVE]
[MVE] [WARNING] Unusually low number of maps were found on filesystem!
[MVE]
[MVE] -> make sure you have maps in your map folders
[MVE] -> verify map folders is are to Paths `Paths=../Maps/*.unr`
[MVE]
[MVE] Map list has been reloaded, check results in the `MVE_MapList.ini
```

### 7. Update defaults and examples

The game config defaults and examples were updated to have VotePriority defaulted to 1.0
Having VotePriority set to 0.0 disables the gametype. This can be super confusing and frustrating to debug
if you don't know about the VotePriority.




# `2e-v2`  Jul 9, 2022

Fixes bug when players vote the incorrect game-type was printed in chat.


# `2e-v1`  Jul 3, 2022

### Green background for players that voted

Players that vote receive a green background. This was a broken feature. 
Players did receive the green background but only when mapvote window 
opens. Now with the fixes applied the player background should switch to
green as soon as they vote.

### Logo Texture 

A logo texture can now be configured and shown. The mapvote will instruct
all windows to show this texture initially before players select a map.

Example:

```ini
[MVES.MapVote]
ClientLogoTexture=Botpack.ASMDAlt_a00
``` 

### Fixes & Other

- fixed some typos in some string messages
- when trying to vote the same map you get a prettier message
- cleaned up what remained of gametypes 100+, this fixes a bunch of error logs on client side
- improved loading and display of level information
- logo/screenshot displayed will respect the aspect ratio of the texture instead of stretching it across a rectangle


# `2d-v1`  May 26, 2022
 
### Reduced gametype count to 100

 - this improves peformance 
 - this was the supported count in MVE2c as well, using gametypes 100-511 broke MVES
 - I manually tested gametype slot 99 and works just fine!

### Simplified New Maps list

- only shows each new map once! this way it's indeed a map list and it's easier to understand what it is
- voting it will vote the first gametype the map is used in
  - if you want another gametype you'll have to search for the map under that specific gametype
- text only shows mapname without the gametype prefix


# `2c-v3`  May 22, 2022

- hotfix map history array access


# `2c-v2`  Apr 3, 2022 

- fix issues.
- finally return lost changes.
- clear defaults.


# `2c-v1`  Apr 3, 2022

### Difference from original 2a:

1. GameConfigs count raised to 512 from 63. Unfortunately there many hardcode about two digits, so really usable only first 99 of it. Possible need reduce limit to it.
Possible issue:
2. Admin tab blowed up with 512 items on it.
3. Add option Tickrate for each GameConfig. And DefaultTickRate globally. But not sure if change on fly tickrate applied on map change. Anyway be request of it.
4. Add option ServerActors for each GameConfig, which allow spawn some actors, without try add it to Mutator list, as do option Mutators.
5. Add option bAvoidRandom for each GameConfig. Done in really dumb way. Random still same, but if pick game mode which forbidden random restart. Up to 1024 times. 
6. Map vote track found maps (list of 16384 maps) and use this for determine which maps add last. After that 32 of last map appear on list, visible by default. So if add some new maps on server, it is good promoted.

### Possible this stuff bugged. Known possible issues:

1. if you use some filtration of map list, wrong list of new maps.
2. If you turn this option on, map vote not able know what maps is last, so you need reorder M array manually if you want proper order for previous data.
3. Config files really huge.