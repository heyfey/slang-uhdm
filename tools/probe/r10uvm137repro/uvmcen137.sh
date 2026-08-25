#!/usr/bin/env bash
# r10uvm137 — the FOREACH census over the NAMED ROWS of two
# verify_golden workdirs (pristine and patched), scored against each row's OWN
# golden.  MEASUREMENT ONLY; the official uhdm-cmp is the judge.
#
#   CEN=<ct137cen> uvmcen137.sh <prisWD> <patWD> <outdir> <name> [<name> ...]
#
# The golden path comes out of each row's OWN cmds.txt, so this script cannot
# compare against the wrong golden; a missing side prints SKIP-NOFILE and is
# COUNTED; every rc is recorded.
set -u
HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
CEN=${CEN:?set CEN=<ct137cen binary>}
PW=${1:?prisWD}; QW=${2:?patWD}; OUT=${3:?outdir}
shift 3
mkdir -p "$OUT"
miss=0; done_=0
for n in "$@"; do
  for mode in default testflags; do
    for d in "$PW/$mode/$n"-*/; do
      [ -d "$d" ] || continue
      rel=${d#"$PW"/}; q="$QW/$rel"
      G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$d/cmds.txt" 2>/dev/null | head -1)
      [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
      if [ -z "$G" ] || [ ! -f "$G" ] || [ ! -f "$d/slang.uhdm" ] || [ ! -f "$q/slang.uhdm" ]; then
        echo "$n $mode SKIP-NOFILE"; miss=$((miss+1)); continue
      fi
      "$CEN" "$G"             > "$OUT/$n.$mode.g.cen"    2>/dev/null </dev/null; rg=$?
      "$CEN" "$d/slang.uhdm"  > "$OUT/$n.$mode.pris.cen" 2>/dev/null </dev/null; rp=$?
      "$CEN" "$q/slang.uhdm"  > "$OUT/$n.$mode.pat.cen"  2>/dev/null </dev/null; rq=$?
      echo "== $n $mode (rc g=$rg pris=$rp pat=$rq)"
      python3 "$HERE/score137.py" "$OUT/$n.$mode.g.cen" "$OUT/$n.$mode.pris.cen" \
              "$OUT/$n.$mode.pat.cen" > "$OUT/$n.$mode.score" 2>&1
      head -8 "$OUT/$n.$mode.score"
      done_=$((done_+1))
    done
  done
done
echo "-- scored=$done_ SKIP-NOFILE=$miss"
