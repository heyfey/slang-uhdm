#!/usr/bin/env bash
# r10rgg10/predictdb10.sh — DATABASE-LEVEL prediction, run on the PRISTINE
# (base) workdir BEFORE the patched sweep is read.  For each named test it
# censuses the GOLDEN database (read out of the workdir's own cmds.txt, so it
# cannot compare against the wrong golden) and the BASE database, and prints
# every ELAB gen_scope parameter row where GOLDEN carries the bare loc-less
# logic_typespec and OURS does not.  Those rows -- and only those -- are what
# § genLpPortConnRead10 can move.
#
#   usage: predictdb10.sh <base-workdir> <outfile> <test> [<test> ...]
set -u
WD=${1:?workdir}; OUT=${2:?outfile}; shift 2
CEN=/tmp/r10rgg10_pcensus
[ -x "$CEN" ] || { echo "FATAL: no $CEN"; exit 3; }
: > "$OUT"
hits=0; miss=0; seen=0
for n in "$@"; do
  found=0
  for mode in default testflags; do
    for d in "$WD/$mode/$n"-*/; do
      [ -d "$d" ] || continue
      found=1; seen=$((seen+1))
      C=$d/cmds.txt; O=$d/slang.uhdm
      G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$C" 2>/dev/null | head -1)
      [ -n "$G" ] && G=$G/golden.uhdm
      if [ -z "${G:-}" ] || [ ! -f "$G" ] || [ ! -f "$O" ]; then
        echo "SKIP-NOFILE $n/$mode (g=${G:-none})" >> "$OUT"; miss=$((miss+1)); continue
      fi
      "$CEN" "$G" > /tmp/r10rgg10_pd_g.txt 2>/dev/null
      "$CEN" "$O" > /tmp/r10rgg10_pd_o.txt 2>/dev/null
      join -t $'\t' <(sort /tmp/r10rgg10_pd_g.txt) <(sort /tmp/r10rgg10_pd_o.txt) -o 0,1.2,2.2 2>/dev/null |
        awk -F'\t' -v t="$n" -v m="$mode" '
          $1 ~ /^ELAB\|/ {
            split($1,k,"|");
            gc=$2; sub(/.* C=/,"",gc); sub(/ RHS=.*/,"",gc);
            oc=$3; sub(/.* C=/,"",oc); sub(/ RHS=.*/,"",oc);
            if (gc ~ /^logic_typespec\/LOCLESS/ && oc != gc)
              printf "PREDICT %s/%s %s %s\n   golden %s\n   ours   %s\n", t, m, k[3], $1, gc, oc;
          }' >> "$OUT"
    done
  done
  [ "$found" = 0 ] && echo "UNKNOWN-NAME $n" >> "$OUT"
done
hits=$(grep -c '^PREDICT ' "$OUT"; true)
echo "-- tests-scanned=$seen PREDICTED-ROWS=$hits SKIP-NOFILE=$miss UNKNOWN=$(grep -c '^UNKNOWN-NAME' "$OUT"; true)" | tee -a "$OUT"
