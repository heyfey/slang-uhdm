#!/usr/bin/env bash
# v65 verifier arm runner: golden + both frozen binaries, BOTH views, rc recorded.
set -u
SL=$HOME/git-repos/Surelog/build/bin/surelog
CMP=$HOME/git-repos/UHDM/build/bin/uhdm-cmp
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
PAT=${PATBIN:-/tmp/v65_pat_bin}; PRIS=/tmp/v65_pris_bin
CEN=/tmp/v65_tools/vcen65
f=$1; view=$2
key=$(basename "$f" .sv)_$view
d=/tmp/v65_armrun/$key; rm -rf "$d"; mkdir -p "$d"; cp "$f" "$d/"
b=$(basename "$f")
case $view in
  plain) SLFLAGS="-parse -nobuiltin -nocache -sv -d uhdm"; OFLAGS="";;
  elab)  SLFLAGS="-parse -nobuiltin -nocache -sv -elabuhdm -d uhdm"; OFLAGS="--elabuhdm";;
esac
( cd "$d" && $SL $SLFLAGS "$b" >sl.log 2>&1 </dev/null ); slrc=$?
G="$d/slpp_all/surelog.uhdm"
( cd "$d" && $PRIS $OFLAGS "$b" -o pris.uhdm >pris.log 2>&1 </dev/null ); prc=$?
( cd "$d" && $PAT  $OFLAGS "$b" -o pat.uhdm  >pat.log  2>&1 </dev/null ); qrc=$?
echo "ARM $key slrc=$slrc prisrc=$prc patrc=$qrc golden=$([ -f "$G" ] && echo yes || echo NO)"
[ -f "$G" ] || exit 0
[ -f "$d/pris.uhdm" ] && [ -f "$d/pat.uhdm" ] || { echo "  NO_DB"; exit 0; }
R65_INST=1 $CEN "$G"          | sort > "$d/g.cen"
R65_INST=1 $CEN "$d/pris.uhdm"| sort > "$d/o.cen"
R65_INST=1 $CEN "$d/pat.uhdm" | sort > "$d/p.cen"
$CMP "$G" "$d/pris.uhdm" > "$d/cmp_pris.log" 2>&1; pcmp=$?
$CMP "$G" "$d/pat.uhdm"  > "$d/cmp_pat.log"  2>&1; qcmp=$?
$DUMP "$d/pris.uhdm" 2>/dev/null | sed '1d' | sed "s#$d#WD#g" > "$d/pris.dump"
$DUMP "$d/pat.uhdm"  2>/dev/null | sed '1d' | sed "s#$d#WD#g" > "$d/pat.dump"
dl=$(diff "$d/pris.dump" "$d/pat.dump" | grep -c '^[<>]'; true)
echo "  cmp: pris rc=$pcmp heads=$(grep -c '^LHS:' "$d/cmp_pris.log"; true) lines=$(wc -l < "$d/cmp_pris.log") | pat rc=$qcmp heads=$(grep -c '^LHS:' "$d/cmp_pat.log"; true) lines=$(wc -l < "$d/cmp_pat.log")"
echo "  dump A/B differing lines=$dl"
echo "  score: $(python3 /tmp/v65_tools/vscore.py "$d/g.cen" "$d/o.cen" "$d/p.cen")"
