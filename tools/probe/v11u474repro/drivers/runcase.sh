#!/bin/bash
# runcase.sh <bin> <tag> <casedir>...: upstream slang rc, Surelog golden, ours under
# /tmp/v11u474_runs/<absolute case path>/; prints rc, uhdm-cmp lines, strict verdict, dump distance, md5.
source $(dirname "$0")/env.sh || exit 1
B=$1; T=$2; shift 2
[ -x "$B" ] || { echo "no binary $B"; exit 1; }
for c in "$@"; do
  [ -d "$c" ] || { echo "skip non-dir $c"; continue; }
  c=$(realpath "$c"); W=/tmp/v11u474_runs$c; mkdir -p "$W"
  F=dut.sv; [ -f "$c/FILES" ] && F=$(cat "$c/FILES")
  if [ ! -f "$W/sl/slpp_all/surelog.uhdm" ] || [ "$c/dut.sv" -nt "$W/sl/slpp_all/surelog.uhdm" ]; then
    rm -rf "$W/sl"
    (cd "$c" && $SURELOG -parse -nobuiltin -nocache -sv $F -mt 0 -mp 0 -o "$W/sl" > "$W/sl.log" 2>&1 </dev/null)
    (cd "$c" && $UPSLANG $F --single-unit -q > "$W/up.log" 2>&1 </dev/null); echo $? > "$W/up.rc"
    $UHDM_DUMP "$W/sl/slpp_all/surelog.uhdm" > "$W/sl.dump" 2>&1
  fi
  rm -f "$W/$T.uhdm"; (cd "$c" && "$B" $F --single-unit --nobuiltin -o "$W/$T.uhdm" > "$W/$T.log" 2>&1 </dev/null); rc=$?
  $UHDM_CMP "$W/sl/slpp_all/surelog.uhdm" "$W/$T.uhdm" > "$W/$T.cmp" 2>&1; n=$(wc -l < "$W/$T.cmp")
  st=$($STRICTCMP "$W/sl/slpp_all/surelog.uhdm" "$W/$T.uhdm" 2>&1 | tail -1)
  $UHDM_DUMP "$W/$T.uhdm" > "$W/$T.dump" 2>&1
  dd=$(diff <(sed 's#/tmp/[^ ]*/##g' "$W/sl.dump") <(sed 's#/tmp/[^ ]*/##g' "$W/$T.dump") | grep -c '^[<>]')
  echo "${c#*/cases/} up=$(cat $W/up.rc) rc=$rc cmp=$n dd=$dd $st md5=$(md5sum < "$W/$T.uhdm" | cut -c1-8)"
done
