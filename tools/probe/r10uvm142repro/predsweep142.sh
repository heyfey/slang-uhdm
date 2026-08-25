#!/usr/bin/env bash
# r10uvm142 — A-PRIORI corpus-wide MOVER PREDICTION over a whole verify_golden
# workdir, from the PRISTINE databases only.  MEASUREMENT ONLY.
#
#   CEN=<ct142cen> [OUT=<dir>] predsweep142.sh <workdir> [<workdir> ...]
#
# For every row that has BOTH a golden (read out of that row's OWN cmds.txt,
# with the cache DIRECTORY turned into .../golden.uhdm) and a slang.uhdm, runs
# ct142cen on both and pred142.py on the pair.  Prints one line per row:
#     PRED <mode>/<row> <n>
# and every rc.  A row missing a side prints SKIP-NOFILE and is COUNTED.
set -u
HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
CEN=${CEN:?set CEN=<ct142cen binary>}
OUT=${OUT:-/tmp/r10uvm142_pred}
mkdir -p "$OUT"
miss=0; done_=0; movers=0
for WD in "$@"; do
  [ -d "$WD" ] || { echo "FATAL: no workdir $WD"; exit 3; }
  for mode in default testflags; do
    [ -d "$WD/$mode" ] || continue
    for d in "$WD/$mode"/*/; do
      [ -d "$d" ] || continue
      b=$(basename "$d")
      O=$d/slang.uhdm; C=$d/cmds.txt; G=""
      [ -f "$C" ] && G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$C" | head -1)
      [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
      if [ -z "$G" ] || [ ! -f "$G" ] || [ ! -f "$O" ]; then
        echo "SKIP-NOFILE $mode/$b (g=${G:-none})"; miss=$((miss+1)); continue
      fi
      "$CEN" "$G" > "$OUT/g.cen" 2>/dev/null </dev/null; rg=$?
      "$CEN" "$O" > "$OUT/p.cen" 2>/dev/null </dev/null; rp=$?
      n=$(python3 "$HERE/pred142.py" "$OUT/g.cen" "$OUT/p.cen" > "$OUT/last.txt"; \
          sed -n 's/^TOTAL=//p' "$OUT/last.txt")
      echo "PRED $mode/$b $n rc_g=$rg rc_o=$rp"
      if [ "${n:-0}" != 0 ]; then
        movers=$((movers+1)); cp "$OUT/last.txt" "$OUT/cells.$mode.$b.txt"
      fi
      done_=$((done_+1))
    done
  done
done
echo "-- rows=$done_ SKIP-NOFILE=$miss PREDICTED-MOVERS=$movers"
