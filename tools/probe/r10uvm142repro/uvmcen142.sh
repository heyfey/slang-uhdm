#!/usr/bin/env bash
# r10uvm142 — CORPUS CLASS_TYPESPEC CENSUS over the named rows of a sweep
# pair.  MEASUREMENT ONLY (the official uhdm-cmp is the judge).
#
# For each row present in BOTH workdirs, censuses golden / pristine / patched
# with ct142cen and scores them with score142.py.  The golden path is read out
# of the row's OWN cmds.txt (so the census cannot silently compare against the
# wrong golden) and the cache DIRECTORY is turned into .../golden.uhdm.
# Every rc is recorded; a row missing any side prints SKIP-NOFILE and is counted.
#
#   PRIS=<pristine workdir> PAT=<patched workdir> CEN=<ct142cen> \
#       [OUT=<dir>] uvmcen139.sh <row> …
set -u
PRIS=${PRIS:?set PRIS=<pristine sweep workdir>}
PAT=${PAT:?set PAT=<patched sweep workdir>}
CEN=${CEN:?set CEN=<ct142cen binary>}
OUT=${OUT:-/tmp/r10uvm142_uvmcen}
mkdir -p "$OUT"
miss=0; done_=0
for n in "$@"; do
  for mode in default testflags; do
    for d in "$PRIS/$mode/$n"-*/; do
      [ -d "$d" ] || continue
      b=$(basename "$d")
      a=$PRIS/$mode/$b/slang.uhdm; c=$PAT/$mode/$b/slang.uhdm; C=$PRIS/$mode/$b/cmds.txt
      G=""
      [ -f "$C" ] && G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$C" | head -1)
      [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
      if [ -z "$G" ] || [ ! -f "$G" ] || [ ! -f "$a" ] || [ ! -f "$c" ]; then
        echo "== $n.$mode SKIP-NOFILE (g=${G:-none})"; miss=$((miss+1)); continue
      fi
      o=$OUT/$n.$mode; mkdir -p "$o"
      "$CEN" "$G" > "$o/g.cen"    2>"$o/g.err"    </dev/null; echo "rc_cen_g=$?"    > "$o/rcs"
      "$CEN" "$a" > "$o/pris.cen" 2>"$o/pris.err" </dev/null; echo "rc_cen_pris=$?" >> "$o/rcs"
      "$CEN" "$c" > "$o/pat.cen"  2>"$o/pat.err"  </dev/null; echo "rc_cen_pat=$?"  >> "$o/rcs"
      echo "== $n.$mode  $(tr '\n' ' ' < "$o/rcs") gcells=$(wc -l < "$o/g.cen")"
      python3 "$(dirname "${BASH_SOURCE[0]}")/score142.py" "$o/g.cen" "$o/pris.cen" "$o/pat.cen"
      done_=$((done_+1))
    done
  done
done
echo "-- scored=$done_ SKIP-NOFILE=$miss"
