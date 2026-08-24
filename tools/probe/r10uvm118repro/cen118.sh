#!/usr/bin/env bash
# r10uvm118 — the OPERATION-TYPESPEC census, golden vs ours, per named database.
# Prints the ours-only / golden-only / both split on the reduced key
# (OPT/NOPS/SPAN/PAR — see join118.py and ct118cen.cpp for why HOME/REGION are
# key-unsafe across a change that INSERTS an object), and the family split by
# REGION and MACRO for the OURS-ONLY rows.
#   usage: cen118.sh <workdir> <ct118cen> <join118.py> <outdir> <name> [<name>...]
# Golden is read from the workdir's own cmds.txt; a missing side prints
# SKIP-NOFILE and is counted.
set -u
WD=${1:?}; CEN=${2:?}; JOIN=${3:?}; OUT=${4:?}; shift 4
mkdir -p "$OUT"
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-}:$HOME/.local/lib64:$HOME/.local/lib
red() { awk -F'\t' '{split($0,a,"\t\\|\\|\t"); k=""; n=split(a[1],f,"\t");
        for(i=1;i<=n;i++) if(f[i] ~ /^(OPT|NOPS|SPAN|PAR)=/) k=k f[i] "\t";
        print k "||\t" a[2]}' "$1" | sort; }
miss=0
for n in "$@"; do
  for mode in default testflags; do
    for d in "$WD/$mode/$n"-*/; do
      [ -d "$d" ] || continue
      O=$d/slang.uhdm; C=$d/cmds.txt; G=""
      [ -f "$C" ] && G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$C" | head -1)
      [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
      if [ ! -f "$O" ] || [ -z "$G" ] || [ ! -f "$G" ]; then
        echo "== $n/$mode  SKIP-NOFILE"; miss=$((miss+1)); continue
      fi
      "$CEN" "$G" --ts > "$OUT/$n.$mode.g.ts" 2>/dev/null
      "$CEN" "$O" --ts > "$OUT/$n.$mode.o.ts" 2>/dev/null
      red "$OUT/$n.$mode.g.ts" > "$OUT/$n.$mode.g.k"
      red "$OUT/$n.$mode.o.ts" > "$OUT/$n.$mode.o.k"
      echo "== $n/$mode"
      python3 "$JOIN" "$OUT/$n.$mode.g.k" "$OUT/$n.$mode.o.k" --detail \
        > "$OUT/$n.$mode.join" 2>&1
      sed -n '1,4p' "$OUT/$n.$mode.join" | sed 's/^/   /'
      echo "   OURS-ONLY by REGION/MACRO:"
      grep '^OURS-ONLY' "$OUT/$n.$mode.join" | sed 's/.*SPAN=/SPAN=/' \
        | sed 's/\t/ /g' | sed 's/^/     /' ; true
      # the family split needs the FULL-key census rows for the ours-only spans
      grep 'TS=logic_typespec.*TSLOC=0.*TSNAME=-' "$OUT/$n.$mode.o.ts" \
        | awk -F'\t' '{for(i=1;i<=NF;i++) if($i ~ /^(REGION|MACRO|PAR|HOME)=/) printf "%s ", $i; print ""}' \
        | sort | uniq -c | sed 's/^/     FAM /' ; true
    done
  done
done
echo "-- SKIP-NOFILE=$miss"
