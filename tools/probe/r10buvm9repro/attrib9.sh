#!/usr/bin/env bash
# r10buvm9repro/attrib9.sh — ATTRIBUTE ONE MOVER: the golden ↔ pristine ↔
# patched three-way join over LISTED, NAMED typespecs and their vpiInstance
# view, with a verdict per cell.
#
#   usage: attrib9.sh <patched_wd> <pristine_wd> <relpath-of-slang.uhdm>
#
# The golden is read out of the PATCHED workdir's own cmds.txt (a cache
# DIRECTORY is turned into .../golden.uhdm; handing uhdm-cmp or the census a
# directory measures nothing).  Verdicts:
#   CONVERTED          golden != pristine, patched == golden
#   OVER-FIRE          golden == pristine, patched != golden   (a REGRESSION)
#   MOVED-STILL-WRONG  all three differ
#   residue            golden != pristine == patched, or an object one side lacks
#   same               all three agree
set -u
A=${1:?patched workdir}
B=${2:?pristine workdir}
R=${3:?relative path to slang.uhdm}
CEN=/tmp/r10buvm9cen
[ -x "$CEN" ] || { echo "FATAL no census $CEN"; exit 3; }
[ -f "$A/$R" ] || { echo "FATAL no patched db $A/$R"; exit 3; }
[ -f "$B/$R" ] || { echo "FATAL no pristine db $B/$R"; exit 3; }
C=$(dirname "$A/$R")/cmds.txt
G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$C" | head -1)
[ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
[ -f "$G" ] || { echo "FATAL: no golden for $R (cmds.txt=$C)"; exit 4; }
W=$(mktemp -d /tmp/r10buvm9_attr_XXXXXX)
one() { "$CEN" "$1" "$2" > "$W/$2.txt" 2>&1
  ep=$(awk -v t="$2" '$1=="PKG" && $2==t && $3=="ELAB"{print $5; exit}' "$W/$2.txt"); ep=${ep#id=}
  awk -v t="$2" -v ep="$ep" '$1=="TS" && $2==t {
      iv=""; ls="";
      for(i=1;i<=NF;i++){ if($i ~ /^inst=/) iv=substr($i,6); if($i ~ /^listed=/) ls=substr($i,8) }
      if (ls=="-" || $4=="<anon>") next
      v="OTHER"; if (iv=="-") v="NONE";
      else if (ep!="" && iv ~ ("\\" ep "$")) v="ELAB";
      else if (iv ~ /^package:/) v="DEF";
      else { split(iv,q,":"); v=q[1] }
      print $3"|"$4"|"ls"\t"v }' "$W/$2.txt" | LC_ALL=C sort -u; }
one "$G" G > "$W/gk"; one "$B/$R" P > "$W/pk"; one "$A/$R" Q > "$W/qk"
echo "== attrib $R   golden=$G"
LC_ALL=C join -t$'\t' -a1 -a2 -e MISSING -o 0,1.2,2.2 -j1 "$W/gk" "$W/pk" > "$W/gp"
LC_ALL=C join -t$'\t' -a1 -a2 -e MISSING -o 0,1.2,1.3,2.2 -j1 "$W/gp" "$W/qk" |
awk -F'\t' '{
  v = ($2==$3 && $3==$4) ? "same" :
      ($2!=$3 && $2==$4) ? "CONVERTED" :
      ($2==$3 && $2!=$4) ? "OVER-FIRE" :
      ($2!=$3 && $2!=$4 && $3!=$4) ? "MOVED-STILL-WRONG" : "residue";
  if (v!="same") printf "%-18s %-70s G=%-8s P=%-8s Q=%s\n", v, $1, $2, $3, $4;
  c[v]++ } END { printf "-- "; for (k in c) printf "%s=%d ", k, c[k]; printf "\n" }'
