#!/usr/bin/env bash
# r10uvm92 — run ct92cen over golden AND ours for every row-mode in a
# verify_golden workdir.  MEASUREMENT-ONLY.
#   usage: cen89.sh <workdir> <outdir> [mode-flag]
# The golden path is read out of the workdir's OWN cmds.txt and the cache
# DIRECTORY is turned into .../golden.uhdm (handing the tool a directory reads
# nothing).  A missing side prints SKIP-NOFILE and is COUNTED.
set -u
WD=${1:?workdir}; OUT=${2:?outdir}; FLAG=${3:---brk}
CEN=${CT92CEN:-/tmp/r10uvm92_ct92cen}
mkdir -p "$OUT"; miss=0; ok=0
for m in default testflags; do
  for d in "$WD/$m"/*/; do
    [ -d "$d" ] || continue
    n=$(basename "$d"); n=${n%-*}
    G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$d/cmds.txt" 2>/dev/null | head -1)
    [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
    O=$d/slang.uhdm
    if [ -z "$G" ] || [ ! -f "$G" ] || [ ! -f "$O" ]; then
      echo "SKIP-NOFILE ${m}_${n} g=${G:-none}"; miss=$((miss+1)); continue
    fi
    "$CEN" "$G" "$FLAG" > "$OUT/${m}_${n}.g" 2> "$OUT/${m}_${n}.g.err"
    "$CEN" "$O" "$FLAG" > "$OUT/${m}_${n}.o" 2> "$OUT/${m}_${n}.o.err"
    printf "%-26s G=%-8s O=%-8s %s | %s\n" "${m}_${n}" \
      "$(wc -l < "$OUT/${m}_${n}.g")" "$(wc -l < "$OUT/${m}_${n}.o")" \
      "$(tr -d '\n' < "$OUT/${m}_${n}.g.err")" \
      "$(tr -d '\n' < "$OUT/${m}_${n}.o.err")"
    ok=$((ok+1))
  done
done
echo "-- measured=$ok SKIP-NOFILE=$miss"
