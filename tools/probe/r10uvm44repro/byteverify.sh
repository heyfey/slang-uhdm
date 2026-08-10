#!/bin/bash
# r10uvm44 BYTE VERIFIER — the whole-row CSV diff is BLIND inside the 27 rows
# that are already CMP_NOTEQUAL, so prove byte identity of every database the
# both-modes sweep emits.  BOTH runs write to the SAME workdir path (the
# database path is part of what we are comparing) and the HEAD half doubles as
# a baseline-validity check.
#
# *** SCOREBOARD IS EXCLUDED FROM ANY IDENTITY CLAIM. ***  Pass 41 measured
# `Scoreboard`'s `default` database as NONDETERMINISTIC run-to-run on EVERY
# binary with --jobs 1 (two alternating hashes over 4 runs each): the recorded
# macro-buffer SourceLocation flake, PRE-EXISTING.  So this driver reports the
# comparison with Scoreboard's rows split out, and a Scoreboard byte difference
# is NEVER evidence of a change.
#   usage: byteverify.sh <workdir> <head-binary> <csv-head> <csv-post>
set -u
ROOT=$(cd "$(dirname "$0")"/../../.. && pwd)
cd "$ROOT" || exit 1
WD=${1:?}
HEADBIN=${2:?}
CSVH=${3:?}
CSVP=${4:?}
POSTBIN=$ROOT/build/slang-uhdm
P=/tmp/r10uvm44_bv

run() { # $1 = binary, $2 = csv
  SLANG_UHDM=$1 python3 scripts/verify_golden.py --corpus surelog --mode both \
    --out "$2" --workdir "$WD" --jobs 4 2>&1 | tail -8
}
manifest() { # $1 = outfile
  find "$WD" -name slang.uhdm -type f -printf '%P\n' | sort | while read -r p; do
    printf '%s  %s\n' "$(sha256sum "$WD/$p" | cut -d' ' -f1)" "$p"
  done > "$1"
  echo "  databases: $(wc -l < "$1")"
}

echo "=== HEAD run ($HEADBIN)"
run "$HEADBIN" "$CSVH"
manifest ${P}_head.txt
echo "=== POST run ($POSTBIN)"
run "$POSTBIN" "$CSVP"
manifest ${P}_post.txt
echo "=== byte comparison"
join -j 2 -o 1.2,1.1,2.1 <(sort -k2 ${P}_head.txt) <(sort -k2 ${P}_post.txt) \
     > ${P}_join.txt
echo "  paired:    $(wc -l < ${P}_join.txt)"
awk '$2==$3' ${P}_join.txt > ${P}_same.txt
awk '$2!=$3' ${P}_join.txt > ${P}_diff.txt
echo "  identical: $(wc -l < ${P}_same.txt)"
echo "  DIFFER:    $(wc -l < ${P}_diff.txt)"
cut -d' ' -f1 ${P}_diff.txt
echo "  (Scoreboard rows above are NOT evidence — see the header note.)"
