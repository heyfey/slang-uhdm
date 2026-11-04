#!/bin/bash
# runcase <bin> <tag> <casedir>...
source $(dirname "$0")/env.sh
for v in SURELOG UHDM_CMP UHDM_DUMP STRICTCMP; do [ -x "${!v}" ] || { echo "missing $v"; exit 1; }; done
B=$1; T=$2; shift 2
[ -x "$B" ] || { echo "no binary $B"; exit 1; }
for c in "$@"; do
  c=$(realpath "$c"); W=/tmp/v11u485_runs$c; mkdir -p "$W"
  F=dut.sv; [ -f "$c/FILES" ] && F=$(cat "$c/FILES")
  if [ ! -f "$W/sl/slpp_all/surelog.uhdm" ]; then
    rm -rf "$W/sl"; (cd "$c" && $SURELOG -parse -nobuiltin -nocache -sv $F -mt 0 -mp 0 -o "$W/sl" > "$W/sl.log" 2>&1 </dev/null); echo $? > "$W/sl.rc"
  fi
  rm -f "$W/$T.uhdm"; (cd "$c" && "$B" $F --single-unit --nobuiltin -o "$W/$T.uhdm" > "$W/$T.log" 2>&1 </dev/null); rc=$?
  if [ -f "$W/sl/slpp_all/surelog.uhdm" ] && [ -f "$W/$T.uhdm" ]; then
    n=$($UHDM_CMP "$W/sl/slpp_all/surelog.uhdm" "$W/$T.uhdm" 2>&1 | wc -l)
    st=$($STRICTCMP "$W/sl/slpp_all/surelog.uhdm" "$W/$T.uhdm" 2>&1 | tail -1)
    $UHDM_DUMP "$W/sl/slpp_all/surelog.uhdm" 2>/dev/null | sed 's#/tmp/v11u485_runs[^ ]*/sl/#SL/#g' > "$W/sl.dump"
    $UHDM_DUMP "$W/$T.uhdm" 2>/dev/null > "$W/$T.dump"
    dd=$(diff "$W/sl.dump" "$W/$T.dump" | grep -c '^[<>]')
  else n=NA; st=NOGOLDEN; dd=NA; fi
  echo "${c#*/v11u485_cases/} rc=$rc slrc=$(cat $W/sl.rc) cmp=$n dist=$dd $st md5=$(md5sum < "$W/$T.uhdm" 2>/dev/null | cut -c1-8)"
done
