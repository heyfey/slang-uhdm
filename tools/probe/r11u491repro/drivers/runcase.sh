#!/bin/bash
# runcase.sh <bin> <tag> <casedir>...: golden + ours, rc, uhdm-cmp lines, strict, md5, dump distance
source /tmp/r11u491_drv/env.sh || exit 1
B=$1; T=$2; shift 2
[ -x "$B" ] || { echo "no binary $B"; exit 1; }
for c in "$@"; do
  c=$(realpath "$c"); W=/tmp/r11u491_runs$c; mkdir -p "$W"
  F=dut.sv
  if [ ! -f "$W/sl/slpp_all/surelog.uhdm" ] || [ "$c/dut.sv" -nt "$W/sl/slpp_all/surelog.uhdm" ]; then
    rm -rf "$W/sl"; (cd "$c" && $SURELOG -parse -nobuiltin -nocache -sv $F -mt 0 -mp 0 -o "$W/sl" > "$W/sl.log" 2>&1 </dev/null)
    $UHDM_DUMP "$W/sl/slpp_all/surelog.uhdm" 2>/dev/null | sed 1d | sed 's#file:[^,]*,#file:,#g' > "$W/sl.dump"
  fi
  rm -f "$W/$T.uhdm"; (cd "$c" && env $RCENV "$B" $F --single-unit --nobuiltin -o "$W/$T.uhdm" > "$W/$T.log" 2>&1 </dev/null); rc=$?
  n=$($UHDM_CMP "$W/sl/slpp_all/surelog.uhdm" "$W/$T.uhdm" 2>&1 | wc -l)
  st=$($STRICTCMP "$W/sl/slpp_all/surelog.uhdm" "$W/$T.uhdm" 2>&1 | tail -1 | cut -c1-60)
  $UHDM_DUMP "$W/$T.uhdm" 2>/dev/null | sed 1d | sed 's#file:[^,]*,#file:,#g' > "$W/$T.dump"
  dd=$(diff "$W/sl.dump" "$W/$T.dump" | grep -c '^[<>]')
  echo "${c#*/cases/} rc=$rc cmp=$n dist=$dd $st md5=$(md5sum < "$W/$T.uhdm" | cut -c1-8)"
done
