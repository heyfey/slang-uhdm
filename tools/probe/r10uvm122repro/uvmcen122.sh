#!/usr/bin/env bash
# r10uvm122 — the CORPUS census of § localBlockStmtSelBinds122's population:
# every `ref_obj` and the object its `vpiActual` names, golden vs PRISTINE vs
# PATCHED, over the named rows of two verify_golden workdirs.
# MEASUREMENT ONLY; the official uhdm-cmp is the judge.  LHS is ALWAYS golden.
#
#   uvmcen122.sh <pristine-workdir> <patched-workdir> <outdir> <name> ...
#
# The golden path is read out of each row's OWN cmds.txt, so this can never
# compare against the wrong golden, and a missing side is printed and COUNTED.
set -u
HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
WP=${1:?pristine workdir}; WQ=${2:?patched workdir}; OUT=${3:?outdir}
shift 3
DUMP=${DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
mkdir -p "$OUT"
miss=0; done_=0
for n in "$@"; do
  for mode in default testflags; do
    for d in "$WP/$mode/$n"-*/; do
      [ -d "$d" ] || continue
      q=$(echo "$WQ/$mode/$n"-*/)
      G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$d/cmds.txt" | head -1)
      [ -n "$G" ] && G=$G/golden.uhdm
      if [ -z "$G" ] || [ ! -f "$G" ] || [ ! -f "$d/slang.uhdm" ] ||
         [ ! -f "$q/slang.uhdm" ]; then
        echo "$n.$mode SKIP-NOFILE"; miss=$((miss+1)); continue
      fi
      for w in g:"$G" pris:"$d/slang.uhdm" pat:"$q/slang.uhdm"; do
        tag=${w%%:*}; f=${w#*:}
        [ -f "$OUT/$n.$mode.$tag.cells" ] && continue
        "$DUMP" "$f" 2>/dev/null </dev/null > "$OUT/$n.$mode.$tag.dump"
        rc=$?
        python3 "$HERE/cells122.py" "$OUT/$n.$mode.$tag.dump" \
          > "$OUT/$n.$mode.$tag.cells" 2>"$OUT/$n.$mode.$tag.err"
        echo "dump_rc_$tag=$rc" >> "$OUT/$n.$mode.rcs"
        rm -f "$OUT/$n.$mode.$tag.dump"
      done
      python3 "$HERE/score122.py" "$OUT/$n.$mode.g.cells" \
        "$OUT/$n.$mode.pris.cells" "$OUT/$n.$mode.pat.cells" "$n.$mode" \
        > "$OUT/$n.$mode.score" 2>&1
      head -1 "$OUT/$n.$mode.score"
      done_=$((done_+1))
    done
  done
done
echo "-- scored=$done_ SKIP-NOFILE=$miss"
