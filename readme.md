
# MVE - Map Vote Extended 

[![ci](../../workflows/ci/badge.svg)](../../actions/workflows/ci.yml)


MapVote lets players to choose the next gametype and map when a match ends.

![Screeshot of MapVote](./docs/map-vote-screen.png)

Map management:
 - include/exclude filters
 - map prefix filter
 - map tags filter
 - premade lists

Compatible with:
 - Assault (including LeagueAssault)
 - Jailbreak (fixed spectator bug)
 - Coop campaigns with fixed map order
 - DeathMatch, CTF & Domination
 - MonsterHunt
 - BunnyTrack

Important Features:
 - ServerPackages set per gametype, players only download what's needed for 
   the current gametype.
 - Mutators, ServerActors, settings are all configurable individually 
   for every gametype.


## Installation

To install, grab one of the [latest release](../../releases/latest) and follow the readme 
from the that comes with the release. You should be able to find an 
[installation guide](./ReleaseFiles/MVE2dev/Help/Map%20Vote%20Extended.txt)
inside the Help folder.


## Development

To build a release you will need to rename MVE2dev to MVE2myversion. To rename 
use your code editor with replace-all tool to find all matches of MVE2dev.

To package a release, make the neccesay changes inside `./ReleaseFiles` then 
copy the built *.u files to the System folder inside `./ReleaseFiles`, package
this all together.

Recommended development environment:
 - editor [VsCodium](https://vscodium.com/) or [VsCode](https://code.visualstudio.com/)
 - language support [ucx](https://marketplace.visualstudio.com/search?term=ucx&target=VSCode)
 - build tool [ucx](https://www.npmjs.com/package/ucx) (link contains instrallation steps)
 - [tasks.json](.vscode/tasks.json) comes with preconfigured tasks to build & run
 I map run task to keyboard shortcut so I can quickly run from code editor.
 - [nodemon](https://nodemon.io/) is needed for watch tasks to work

Alternatively what I recommend is to grab the release archive and extract the code
from the release packages. That way you can still modify and debug, but if you
plan on submittin a PR then you will have to re-apply your local changes on
top of this repository.

The project uses unit tests. These must always be green to ensure the correct
function of logic classes. The test code can be found in separate packages.
To run the tests you need to run [TestMVE.TestAll.TestMain()](TestMVE/Classes/TestAll.uc)
This can be done by running `ucc TestMVE.TestAll`

MVE has a long history of development with contributions from many people.

Each author retains copyright to their code.
