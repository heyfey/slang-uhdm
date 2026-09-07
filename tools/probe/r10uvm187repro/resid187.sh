#!/usr/bin/env bash
# r10uvm187 — THE WIDER-FAMILY RESIDUE SCAN.  MEASUREMENT ONLY; the official
# uhdm-cmp is the judge.  LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
# Every gate dropped except "golden mints a per-declaration NAMED typespec clone
# with a Typedef_alias and we disagree", over every view and every typespec kind,
# so the family this pass closes one face of can be counted whole.
#   usage: resid187.sh <workdir> <outfile>
set -u
WD=$(readlink -f "$1"); OUT=$2
# r10v187: the CEN path is taken from the ENVIRONMENT and hard-guarded.
# It used to be a hard-coded /tmp scratch path belonging to this pass's own
# session; on any other machine the census binary is absent, every `"$CEN"`
# call fails into 2>/dev/null, the join reads nothing and the scan prints
# "residue cells: 0" -- a driver that REACHED NOTHING reading green.  The
# SCANNED/JOINED counters below make that impossible to miss.
CEN=${CEN:?path to ct187cen}
[ -x "$CEN" ] || { echo "FATAL: no ct187cen at $CEN"; exit 3; }
: > "$OUT"
scanned=0; joined=0; skipped=0
for d in "$WD"/*/*/; do
  [ -f "$d/cmds.txt" ] || continue
  scanned=$((scanned+1))
  mode=$(basename "$(dirname "$d")"); name=$(basename "$d"); name=${name%-*}
  G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$d/cmds.txt" | head -1)
  [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
  { [ -z "$G" ] || [ ! -f "$G" ] || [ ! -f "$d/slang.uhdm" ]; } && { skipped=$((skipped+1)); continue; }
  joined=$((joined+1))
  "$CEN" "$G" 2>/dev/null | awk -F'\t' '{print $1"|"$2"|"$3"|"$4"|"$5"\t"$6}' | sort > /tmp/.r187g.$$
  "$CEN" "$d/slang.uhdm" 2>/dev/null | awk -F'\t' '{print $1"|"$2"|"$3"|"$4"|"$5"\t"$6}' | sort > /tmp/.r187o.$$
  join -t$'\t' -j1 /tmp/.r187g.$$ /tmp/.r187o.$$ |
    awk -F'\t' -v n="$name" -v m="$mode" '
      $2 != $3 && $2 ~ /\[alias->/ && $2 ~ /apar=parameter/ &&
      substr($2,index($2,"(")+1,index($2,")")-index($2,"(")-1) !~ /::/ &&
      substr($2,index($2,"(")+1,index($2,")")-index($2,"(")-1) != "" {
        split($1,a,"|"); k=substr($2,1,index($2,"(")-1);
        print n "\t" m "\t" a[1] "\t" k }' >> "$OUT"
  rm -f /tmp/.r187g.$$ /tmp/.r187o.$$
done
echo "-- SCANNED=$scanned JOINED=$joined SKIP=$skipped"
[ "$joined" -gt 0 ] || { echo "FATAL: the scan joined NOTHING -- a zero here is not a result"; exit 4; }
echo "-- residue cells: $(wc -l < "$OUT")"
sort "$OUT" | awk -F'\t' '{print $3"\t"$4}' | sort | uniq -c | sort -rn
echo "-- tests:"; cut -f1 "$OUT" | sort -u | tr '\n' ' '; echo
