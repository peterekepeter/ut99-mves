#!/bin/bash

SYSTEMDIR=$(dirname $UCC_PATH)
cd $SYSTEMDIR

for (( ; ; ))
do
    echo "SYSTEM SHELL: Starting server..."
    FALLBACK="TravelString=DM-Deck16][?Mutator=MVES.MapVote"
    GREPRESULT=$(grep TravelString= MVE_Travel.ini || echo $FALLBACK)
    TRAVELSTRING=$(echo $GREPRESULT | cut -d'=' -f2-99)
    # ucc server $TRAVELSTRING
    ucx ucc server $TRAVELSTRING
    echo "SYSTEM SHELL: Server exit code $?"
    # sleep 1
done
