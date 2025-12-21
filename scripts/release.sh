set -e

# validate args

if [[ "$1" =~ ^MVE2[a-z](RC[0-9]+)?$ ]]; then
    VER=$1
else
    echo "please pass in a valid version name"
    exit 1
fi

# to prevent accidental replacement here we break it up
SHORTNAME=MVE
DEVERSION=2dev
ORIGVER=$SHORTNAME$DEVERSION

SYSTEMDIR=$(dirname $UCC_PATH)
INCLPAT="--include *.uc --include *.txt --include *.int --include *.md --include *.ini"
RELEASEDIR=ReleaseFiles/$VER
RELEASEDIRTEMPLATE=ReleaseFiles/MVE2h
WORKDIR=$(pwd)

cleanup() {
    echo "Cleaning up source tree..."
    cd $WORKDIR
    grep -rl $VER $INCLPAT --exclude $RELEASEDIR | xargs -I '{}' sed -i s/$VER/$ORIGVER/g "{}"
    mv $VER $ORIGVER
}

build () {
    echo "Patching source tree with version..."
    mv $ORIGVER $VER
    grep -rl $ORIGVER $INCLPAT | xargs -I '{}' sed -i s/$ORIGVER/$VER/g "{}"

    echo "Building packages..."
    ucx build $VER
    ucx build MVES
    ucx build TestMVE
    
    echo "Running tests..."
    ucx ucc TestMVE.TestAll

    echo "Preparing release tree..."
    rm -rf $RELEASEDIR
    cp -r $RELEASEDIRTEMPLATE $RELEASEDIR
    mv $SYSTEMDIR/MVES.u $RELEASEDIR/System/
    mv $SYSTEMDIR/$VER.u $RELEASEDIR/System/
    rm $SYSTEMDIR/TestMVE.u

    echo "Archiving..."
    cd ReleaseFiles
    7z a $VER.zip $VER/

    cd $WORKDIR
    rm -rf $RELEASEDIR
}

trap cleanup EXIT

build
