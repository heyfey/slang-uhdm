#!/bin/bash
# r11v102 corpus sweep driver: u2r testflags + default, then surelog --mode both,
# --jobs 3, into its OWN workdir.  usage: TREE=<base worktree> sweep94.sh <4-char tag> <frozen binary>
# Every cmds.txt must then name <frozen binary> by path (audit it).
set -u
TAG=${1:?tag}; BIN=${2:?binary}
TREE=${TREE:?set TREE to a checkout of the base commit}
W=${WD:-/tmp/v11u94_sw_$TAG}
mkdir -p "$W"
export SLANG_UHDM=$BIN
unset GOLDEN_DEFER
cd "$TREE"
python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode testflags --jobs 3 --out $W/u2r_tf.csv --workdir $W/u2r > $W/u2r_tf.log 2>&1; echo "u2r_tf rc=$?" >> $W/rc.txt
python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode default --jobs 3 --out $W/u2r_def.csv --workdir $W/u2r > $W/u2r_def.log 2>&1; echo "u2r_def rc=$?" >> $W/rc.txt
python3 scripts/verify_golden.py --corpus surelog --mode both --jobs 3 --out $W/sl.csv --workdir $W/sl > $W/sl.log 2>&1; echo "sl rc=$?" >> $W/rc.txt
echo DONE >> $W/rc.txt
