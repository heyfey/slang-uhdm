#!/bin/bash
# rowrun.sh <bin name> <corpus> <row> <tag> [VAR=1 ...] : one row both modes through verify_golden; refuses fenced
. "$(dirname "$0")/env.sh" || exit 3
B=$1; C=$2; R=$3; T=$4; shift 4
for f in $FENCED; do [ "$R" = "$f" ] && { echo "fenced row refused" >&2; exit 3; }; done
W=/tmp/v11u193_rows/$T/$R; rm -rf $W; mkdir -p $W
cd $REPO && env "$@" SLANG_UHDM=$V193_BIN/$B.bin python3 scripts/verify_golden.py --corpus $C --mode both --jobs 2 --filter "^$R\$" --out $W/o.csv --workdir $W/$C > $W/log 2>&1
grep -v '^name,' $W/o.csv | sed "s/^/$T /"
