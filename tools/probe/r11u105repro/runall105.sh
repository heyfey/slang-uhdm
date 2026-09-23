#!/usr/bin/env bash
# r11u105 grid driver.  usage: G=<scratch dir> REPO=<tree> runall105.sh <binary> <tag> [ENV=VAL ...]
# Copies every grid (r11u105 + the nine committed control grids) into $G once,
# builds each arm's golden once (pinned Surelog, rr103.sh), then runs <binary>
# under <tag> with the given environment, three grids at a time.
# Writes $G/<grid>.<tag>.txt (one line per arm, both rc values recorded).
set -u
BIN=${1:?binary}; TAG=${2:?tag}; shift 2
G=${G:?set G to a scratch dir}; REPO=${REPO:?set REPO}
RR=$REPO/tools/probe/r11u103repro/rr103.sh
GRIDS=${GRIDS:-"r11u105repro r11u103repro v11u93repro r11u101repro r11u99repro r11u98repro r11v98repro r11u95repro r11v95repro r11u93repro"}
mkdir -p $G
for g in $GRIDS; do
  [ -d $G/$g ] || cp -r $REPO/tools/probe/$g/grid $G/$g
done
export RR G BIN TAG
export ENVS="$*"
printf '%s\n' $GRIDS | xargs -P 3 -I{} bash -c 'env $ENVS GRID=$G/{} bash $RR $BIN $TAG > $G/{}.$TAG.txt 2>&1'
