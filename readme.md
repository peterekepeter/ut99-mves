
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
[installation guide](./ReleaseFiles/MVE2h/Help/Map%20Vote%20Extended.txt)
inside the Help folder.


## Development

I use the following setup for development:
 - editor [VsCodium](https://vscodium.com/) or [VsCode](https://code.visualstudio.com/)
 - language support [ucx](https://marketplace.visualstudio.com/search?term=ucx&target=VSCode)
 - build tool [ucx](https://www.npmjs.com/package/ucx)
 - [tasks.json](.vscode/tasks.json) comes with preconfigured tasks to build & run
 I map run task to keyboard shortcut so I can quickly run from code editor.
 - I use [nodemon](https://nodemon.io/) to auto launch tasks when source code
 changes. I use this mostly for TDD

If you clone the repo I recommend following this way, as the build tool makes
use of source code transpilation.

Otherwise what I recommend is to grab the release archive and extract the code
from the release packages. That way you can still modify and debug, but if you
plan on submittin a PR then you will have to re-apply your local changes on
top of this repository.

The project uses unit tests. These must always be green to ensure the correct
function of logic classes. The test code can be found in separate packages.
To run the tests you need to run [TestMVE.TestAll.TestMain()](TestMVE/Classes/TestAll.uc)


MVE has a long history of development with contributions from many people.

Each author retains copyright to their code.
