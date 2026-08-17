#!/usr/bin/env bash
# r10buvm10repro/grid10.sh — THE THREE-WAY CELL TABLE for one arm, keyed on the
# TYPEDEF-ALIAS question this pass owns: for every ref_typespec EDGE, does the
# object it names carry a vpiTypedefAlias, and to what?
#
#   usage: PRISTINE=<bin> PATCHED=<bin> grid10.sh <file.sv>
#
# Cell value:  A:<alias target name>  |  N (no alias)  |  - (edge absent)
# Verdicts:    same / CONVERTED (P wrong, Q == G) / OVER-FIRE (P right, Q wrong)
#              / MOVED-STILL-WRONG / residue (G != P == Q, untouched)
#
# GUARDS, each an ops trap this campaign has paid for:
#   * Surelog AND BOTH binaries run in the SAME directory — a UHDM database
#     records the source file's ABSOLUTE path, so two CWDs make every object
#     differ (buvm8's bndarms trap).
#   * a missing/empty database is FATAL, never silently "no differences": an arm
#     that reaches nothing must not read as perfection.
#   * the key is ID-BLIND and ADDRESS-BLIND (every #id is stripped), so nothing
#     in it can depend on allocation order.
set -u
: "${PRISTINE:?PRISTINE=<pristine slang-uhdm>}"
: "${PATCHED:?PATCHED=<patched slang-uhdm>}"
SRC=${1:?file.sv}
SL=$HOME/git-repos/Surelog/build/bin/surelog
CEN=/tmp/r10buvm10cen
[ -x "$CEN" ] || { echo "FATAL no census $CEN (run build10.sh)"; exit 3; }
[ -x "$PRISTINE" ] || { echo "FATAL no PRISTINE $PRISTINE"; exit 3; }
[ -x "$PATCHED" ]  || { echo "FATAL no PATCHED $PATCHED"; exit 3; }
B=$(basename "$SRC" .sv)
W=$(mktemp -d /tmp/r10buvm10_grid_XXXXXX)
cp "$SRC" "$W/$B.sv"
cd "$W" || exit 3
"$SL" -parse "$B.sv" -mt 0 -mp 0 -nocache -d coveruhdm > sl.log 2>&1
G=slpp_all/surelog.uhdm
[ -s "$G" ] || { echo "SURELOG_FAIL $B (wd=$W)"; tail -5 sl.log; exit 4; }
"$PRISTINE" "$B.sv" -o p.uhdm > p.log 2>&1
"$PATCHED"  "$B.sv" -o q.uhdm > q.log 2>&1
[ -s p.uhdm ] || { echo "SLANG_REJECT(pristine) $B (wd=$W)"; tail -5 p.log; exit 5; }
[ -s q.uhdm ] || { echo "SLANG_REJECT(patched) $B (wd=$W)"; tail -5 q.log; exit 5; }
one() { # $1=db $2=tag -> key<TAB>cell
  "$CEN" "$1" "$2" > "$2.txt" 2>&1
  grep -c "^RESTORE_FAIL" "$2.txt" > /dev/null && { echo "FATAL restore $1" >&2; exit 6; }
  # alias TARGET name per typespec id, so the cell can name what it points at
  awk -v t="$2" '
    $1=="TS" && $2==t {
      id=""; al="";
      for(i=1;i<=NF;i++){ if($i ~ /^id=/) id=substr($i,4); if($i ~ /^alias=/) al=substr($i,7) }
      sub(/:#[0-9]+$/,"",al); tgt[id]=al; next }
    $1=="REF" && $2==t {
      ts=""; ha=""; rf=""; ch="";
      for(i=1;i<=NF;i++){
        if($i ~ /^ts=/)       ts=substr($i,4);
        else if($i ~ /^hasalias=/) ha=substr($i,10);
        else if($i ~ /^reffull=/)  rf=substr($i,9);
        else if($i ~ /^chain=/)    { ch=substr($i,7); for(j=i+1;j<=NF;j++) ch=ch" "$j; }
      }
      id=ts; sub(/^.*:#/,"",id); sub(/:#[0-9]+$/,"",ts);
      gsub(/#[0-9]+/,"",ch); gsub(/#[0-9]+/,"",rf);
      cell = (ha=="1") ? ("A:" tgt[id]) : "N";
      print ts "|" rf "|" ch "\t" cell }' "$2.txt" | LC_ALL=C sort -u
}
one "$G" G > gk.txt; one p.uhdm P > pk.txt; one q.uhdm Q > qk.txt
echo "== grid $B   wd=$W   goldenEdges=$(wc -l < gk.txt) pristine=$(wc -l < pk.txt) patched=$(wc -l < qk.txt)"
LC_ALL=C join -t$'\t' -a1 -a2 -e - -o 0,1.2,2.2 -j1 gk.txt pk.txt > gp.txt
LC_ALL=C join -t$'\t' -a1 -a2 -e - -o 0,1.2,1.3,2.2 -j1 gp.txt qk.txt |
awk -F'\t' '{
  v = ($2==$3 && $3==$4) ? "same" :
      ($2!=$3 && $2==$4) ? "CONVERTED" :
      ($2==$3 && $2!=$4) ? "OVER-FIRE" :
      ($2!=$3 && $2!=$4 && $3!=$4) ? "MOVED-STILL-WRONG" : "residue";
  c[v]++;
  if (v!="same") printf "%-18s %-76s G=%-16s P=%-16s Q=%s\n", v, substr($1,1,76), $2, $3, $4 }
  END { printf "-- "; for (k in c) printf "%s=%d ", k, c[k]; printf "\n" }'
