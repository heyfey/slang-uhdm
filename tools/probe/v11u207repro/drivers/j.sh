#!/bin/bash
# v11u207: judge one case dir with the pristine and law binaries in one view.
# usage: j.sh <case dir>   env: ELAB=1 for -elabuhdm; PB LB binaries; OFFCHK=1 also R11U207_OFF=1 on LB
set -u
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/env.sh" || exit 3
D=$(cd "$1" && pwd)
for f in $FENCED; do grep -qw "$f" <<< "$D" && { echo "fenced path refused" >&2; exit 3; }; done
: "${PB:=/tmp/v11u207_bin/pris.bin}" "${LB:=/tmp/v11u207_bin/law.bin}"
SRC=dut.sv; [ -f "$D/args" ] && SRC=$(cat "$D/args"); [ -f "$D/top.v" ] && [ ! -f "$D/args" ] && SRC=top.v
K=$(cd "$D" && find . -type f ! -name LAW | sort | xargs md5sum | md5sum | cut -c1-16); G=/tmp/v11u207_gold/$K${ELAB:+_elab}
SLE=; OUE=; [ -n "${ELAB:-}" ] && { SLE=-elabuhdm; OUE=--elabuhdm; }
SVF=-sv; [ -f "$D/nosv" ] && SVF=
if [ ! -s "$G/golden.uhdm" ]; then mkdir -p "$G/w"; ( cd "$D" && "$SURELOG" -parse $SLE -nobuiltin -nocache $SVF $SRC -mt 0 -mp 0 -o "$G/w" > "$G/sl.log" 2>&1 )
  u=$(find "$G/w" -name '*.uhdm' | head -1); [ -n "$u" ] && cp "$u" "$G/golden.uhdm"; rm -rf "$G/w"; fi
[ -s "$G/golden.uhdm" ] || { echo "$1 SURELOG_FAIL"; exit 1; }
O=/tmp/v11u207_run/$(echo "$D${ELAB:+_elab}" | md5sum | cut -c1-12); mkdir -p $O; rm -f $O/*
cp $G/golden.uhdm $O/g.uhdm
run() { # bin out extra-env
  rm -f $O/$2.uhdm; ( cd "$D" && env $3 "$1" $SRC --single-unit --nobuiltin $OUE -o "$O/$2.uhdm" > "$O/$2.log" 2>&1; echo "rc=$?" >> "$O/$2.log" )
  [ -s $O/$2.uhdm ] || { echo "FAIL($(tail -1 $O/$2.log))"; return; }
  "$UHDM_CMP" $O/g.uhdm $O/$2.uhdm > $O/$2.cmp 2>&1; c=$?
  "$SCMP" --max 30 --dump-a $O/$2.a.rec --dump-b $O/$2.b.rec $O/g.uhdm $O/$2.uhdm > $O/$2.strict 2>&1
  if [ $c -ne 0 ]; then echo "NOT_EQUAL"; elif grep -q '^STRICT_EQUAL' $O/$2.strict; then echo EQUAL; else echo "SNE:$(awk '/^STRICT_NOTEQUAL/{f=$2} /^fields:/{for(i=2;i<=NF;i++) if($i ~ /^objects_differing=/){split($i,a,"=");o=a[2]}} END{print f "(" o ")"}' $O/$2.strict)"; fi
}
p=$(run $PB p ""); l=$(run $LB l "")
rcp=$(grep -o 'rc=[0-9]*' $O/p.log); rcl=$(grep -o 'rc=[0-9]*' $O/l.log)
same=$(cmp -s $O/p.uhdm $O/l.uhdm && echo same || echo moved)
off=""; if [ -n "${OFFCHK:-}" ]; then run $LB o "R11U207_OFF=1" >/dev/null; cmp -s $O/p.uhdm $O/o.uhdm && off="OFF=pristine" || off="OFF=DIFF"; fi
obd() { diff <(norm $O/g.uhdm) <(norm $O/$1.uhdm) | grep -c '^[<>]'; }
norm() { "$UHDM_DUMP" $1 2>/dev/null | sed -E 's/, id:[0-9]+//; s#file:[^,]*/##; s#/tmp/v11u207_run/[^ ,]*##g' | sed 1,3d | sort; }
dp=-; dl=-; [ -s $O/p.uhdm ] && dp=$(obd p); [ -s $O/l.uhdm ] && dl=$(obd l)
printf "%s\t%s\t%s\t%s\t%s/%s\t%s\t%s\t%s\n" "$1" "$([ -n "${ELAB:-}" ] && echo elab || echo parse)" "$p" "$l" "$rcp" "$rcl" "$same" "$off" "ob=$dp->$dl"
