#!/usr/bin/env bash
# r10buvm9repro/grid9.sh — the THREE-WAY cell table for ONE arm: golden vs
# PRISTINE vs PATCHED, one row per LISTED, NAMED typespec, printed as the
# vpiInstance VIEW each side gives it (ELAB / DEF / NONE / other).  A cell that
# reads `NONE NONE NONE` is untouched; `NONE DEF NONE` is CONVERTED; anything
# where patched moves AWAY from golden is an OVER-FIRE and is labelled so.
#
#   usage: PRISTINE=... PATCHED=... grid9.sh <file.sv>
#
# Both binaries and Surelog run in the SAME directory (a UHDM database records
# the source file's absolute path).
set -u
: "${PRISTINE:?}"; : "${PATCHED:?}"
SRC=${1:?file.sv}
SL=$HOME/git-repos/Surelog/build/bin/surelog
CEN=/tmp/r10buvm9cen
[ -x "$CEN" ] || { echo "FATAL no census $CEN"; exit 3; }
B=$(basename "$SRC" .sv)
W=$(mktemp -d /tmp/r10buvm9_grid_XXXXXX)
cp "$SRC" "$W/$B.sv"; cd "$W" || exit 3
"$SL" -parse "$B.sv" -mt 0 -mp 0 -nocache > sl.log 2>&1
G=slpp_all/surelog.uhdm
[ -f "$G" ] || { echo "SURELOG_FAIL $B"; exit 4; }
"$PRISTINE" "$B.sv" -o p.uhdm > p.log 2>&1
"$PATCHED"  "$B.sv" -o q.uhdm > q.log 2>&1
[ -s p.uhdm ] && [ -s q.uhdm ] || { echo "SLANG_REJECT $B (p=$( [ -s p.uhdm ] && echo ok || echo no) q=$( [ -s q.uhdm ] && echo ok || echo no))"; exit 5; }
one() { # $1=db $2=tag -> key<TAB>view
  "$CEN" "$1" "$2" > "$2.txt" 2>&1
  ep=$(awk -v t="$2" '$1=="PKG" && $2==t && $3=="ELAB"{print $5; exit}' "$2.txt"); ep=${ep#id=}
  awk -v t="$2" -v ep="$ep" '$1=="TS" && $2==t {
      iv=""; ls="";
      for(i=1;i<=NF;i++){ if($i ~ /^inst=/) iv=substr($i,6); if($i ~ /^listed=/) ls=substr($i,8) }
      if (ls=="-" || $4=="<anon>") next
      v="OTHER"; if (iv=="-") v="NONE";
      else if (ep!="" && iv ~ ("\\" ep "$")) v="ELAB";
      else if (iv ~ /^package:/) v="DEF";
      else { split(iv,q,":"); v=q[1] }
      print $3"|"$4"|"ls"\t"v }' "$2.txt" | LC_ALL=C sort -u
}
one "$G" G > gk.txt; one p.uhdm P > pk.txt; one q.uhdm Q > qk.txt
echo "== grid $B   wd=$W"
LC_ALL=C join -t$'\t' -a1 -a2 -e MISSING -o 0,1.2,2.2 -j1 gk.txt pk.txt > gp.txt
LC_ALL=C join -t$'\t' -a1 -a2 -e MISSING -o 0,1.2,1.3,2.2 -j1 gp.txt qk.txt |
awk -F'\t' '{
  verdict = ($2==$3 && $3==$4) ? "same" :
            ($2!=$3 && $2==$4) ? "CONVERTED" :
            ($2==$3 && $2!=$4) ? "OVER-FIRE" :
            ($2!=$3 && $2!=$4 && $3!=$4) ? "MOVED-STILL-WRONG" : "residue";
  printf "%-18s %-64s G=%-8s P=%-8s Q=%s\n", verdict, $1, $2, $3, $4;
  c[verdict]++ } END { printf "-- "; for (k in c) printf "%s=%d ", k, c[k]; printf "\n" }'
