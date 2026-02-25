
# MVE - Map Vote Extended

[![ci](../../workflows/ci/badge.svg)](../../actions/workflows/ci.yml)


MapVote lets players to choose the next gametype and map when a match ends.

![Screeshot of MapVote](./docs/map-vote-screen.png)

## Features

This mapvote is mainly focused on enabling multi-gametype servers. There was 
also a lot of work on compatibility so that it can load any gametype, mutator, 
package combination and mapvote itself can be run in multiple ways. 

Important Features:
- ServerPackages set per gametype -> Players only download what's needed for 
  the current gametype, not the whole server.
- Mutators, ServerActors, settings configurable per gametype
- Map overrides allow map specific configuration (limited to a few configuration props)

Map management:
 - Include/exclude filters
 - Map prefix filter
 - Map tags filter
 - Fixed order premade lists

Compatible with gametypes:
 - Assault (including LeagueAssault)
 - Jailbreak (fixed spectator bug)
 - Coop campaigns with fixed map order
 - DeathMatch, CTF & Domination
 - MonsterHunt
 - BunnyTrack

For more info read the [documentation](./docs/feature-documentation.md).
There also have a [changelog](./docs/changelog.md).


## Installation

To install, grab one of the [latest release](../../releases/latest) and follow 
the [quickstarter](./docs/quickstart.txt) readme. Which should be located in
the Help folder of any release package.


## Bugs and feature requests

You can use github issues for this, it will be easy to track the issue that
way. I may not be able to respond immediately. For server setup help please 
contact the UT99 community first as there are many admins familiar with this 
mapvote they may be able to help with your problem before I even read the 
message.

For bugs relevant log and configuration snippets are appreciated without which
it can be hard to guess what's going on.

Feature requests will be weighted based on the fesability and usefulness and
whether it makes sense for it to be withing mapvote.


## Development

To build a release you will need to rename MVE2dev to MVE2myversion. To rename 
use your code editor with replace-all tool to find all matches of MVE2dev.

To package a release, make the neccesay changes inside `./ReleaseFiles` then 
copy the built *.u files to the System folder inside `./ReleaseFiles`, package
this all together.

There is also [release.sh](./scripts/release.sh) which automates this process.

Recommended development environment:
 - editor [VsCodium](https://vscodium.com/) or [VsCode](https://code.visualstudio.com/)
 - language support [ucx](https://marketplace.visualstudio.com/search?term=ucx&target=VSCode)
 - build tool [ucx](https://www.npmjs.com/package/ucx) (link contains instrallation steps)
 - [tasks.json](.vscode/tasks.json) comes with preconfigured tasks to build & run
 I map run task to keyboard shortcut so I can quickly run from code editor.
 - [nodemon](https://nodemon.io/) is needed for watch tasks to work

Alternatively what I recommend is to grab the release archive and extract the code
from the release packages. That way you can still modify and debug.

The project uses unit tests. These must always be green to ensure the correct
function of logic classes. The test code can be found in separate packages.
To run the tests you need to run [TestMVE.TestAll.TestMain()](TestMVE/Classes/TestAll.uc)
This can be done by running `ucc TestMVE.TestAll`


## History, license and forks

MVE has a long history of development with contributions from many people.
The project was copied, decompiled and modified by multiple people which is 
why the code itself is quite the spaghetti monster. I've been doing my best to
clean things up and have rewritten major parts of this software already and I 
hope to continue cleaning it up.

Theoretically each author retains copyright to their code, but as with most
UT99 mutators, things get copied and modified so feel free to do so yourself.
I will not come with pitchfork after you and hopefully neither will my 
prececessors who built layed the foundation pieces for this mapvote. I can also
neither provide any support or warranty of any sorts.

There are probably hundreds of forks floating around of the original mapvote 
anyways and I also know of a few forks of this mapvote too.
