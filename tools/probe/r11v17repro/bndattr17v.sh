#!/usr/bin/env bash
# v11u17: for one boundary MOVER file build the REAL v1.87 golden and score
# the DIRECTION with the ref census (judge-reachable elaborated section).
set -u
F=${1:?sv file}
SL=/home/heyfey/git-repos/Surelog/build/bin/surelog
DUMP=/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump
CEN=/tmp/v11u17_grid/refcen.py
key=$(echo "$F" | sed 's#[/.]#_#g')
D=/tmp/v11u17_bndwide/$key
W=/tmp/v11u17_bndg/$key; rm -rf "$W"; mkdir -p "$W"
cp "$F" "$W/dut.sv"
( cd "$W" && $SL -parse -nobuiltin -nocache -sv dut.sv > sl.log 2>&1; echo "golden_rc=$?" > rc.txt )
[ -f "$W/slpp_all/surelog.uhdm" ] || { echo "$F  NO-GOLDEN $(cat $W/rc.txt)"; exit 0; }
$DUMP "$W/slpp_all/surelog.uhdm" > "$W/gold.dump" 2>&1
sect(){ f=$1; o=$2; n=$(grep -n '^|uhdmtopModules:' "$f" | head -1 | cut -d: -f1); n=${n:-1};
  awk -v n=$n 'NR>=n' "$f" > "$o.elab"
  w=$(grep -n '^\\_weaklyReferenced:' "$o.elab" | head -1 | cut -d: -f1)
  if [ -n "$w" ]; then awk -v n=$w 'NR<n' "$o.elab" > "$o"; else cp "$o.elab" "$o"; fi; }
sect "$W/gold.dump" "$W/gold.main"
for t in pris law; do $DUMP "$D/$t.uhdm" > "$W/$t.dump" 2>&1; sect "$W/$t.dump" "$W/$t.main"; done
p=$(python3 $CEN "$W/gold.main" "$W/pris.main" | tail -1)
l=$(python3 $CEN "$W/gold.main" "$W/law.main" | tail -1)
echo "$F"
echo "     pris: $p"
echo "     law : $l"
