#!/bin/bash
# r10uvm41 BYTE VERIFIER — the whole-row CSV diff is BLIND inside the 27 rows
# that are already CMP_NOTEQUAL, so prove byte identity of every database the
# both-modes sweep emits.  BOTH runs write to the SAME workdir path (the
# database path is part of what we are comparing) and the HEAD half doubles as
# a baseline-validity check.
#   usage: byteverify.sh <workdir> <head-binary> <csv-head> <csv-post>
set -u
ROOT=$(cd "$(dirname "$0")"/../../.. && pwd)
cd "$ROOT" || exit 1
WD=${1:?}
HEADBIN=${2:?}
CSVH=${3:?}
CSVP=${4:?}
POSTBIN=$ROOT/build/slang-uhdm

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
manifest /tmp/r10uvm41_man_head.txt
echo "=== POST run ($POSTBIN)"
run "$POSTBIN" "$CSVP"
manifest /tmp/r10uvm41_man_post.txt
echo "=== byte comparison"
join -j 2 -o 1.2,1.1,2.1 <(sort -k2 /tmp/r10uvm41_man_head.txt) \
     <(sort -k2 /tmp/r10uvm41_man_post.txt) > /tmp/r10uvm41_man_join.txt
echo "  paired:    $(wc -l < /tmp/r10uvm41_man_join.txt)"
awk '$2==$3' /tmp/r10uvm41_man_join.txt > /tmp/r10uvm41_man_same.txt
awk '$2!=$3' /tmp/r10uvm41_man_join.txt > /tmp/r10uvm41_man_diff.txt
echo "  identical: $(wc -l < /tmp/r10uvm41_man_same.txt)"
echo "  DIFFER:    $(wc -l < /tmp/r10uvm41_man_diff.txt)"
cut -d' ' -f1 /tmp/r10uvm41_man_diff.txt
