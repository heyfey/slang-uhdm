#!/bin/bash
# runcase.sh <bin> <tag> <casedir>...: Surelog golden (check_probe.py's flags, cached per full case
# path under /tmp/v11u482_runs) and ours (dut.sv --single-unit --nobuiltin); prints exit codes,
# uhdm-cmp lines, strict verdict, path-normalised dump distance (dd), object-census distance (oc,
# r11u482's objcensus + msdist), instance-census distance (ic: r11u482's tsinst lines, multiset)
# and md5.  Explicit case DIRECTORIES only; extra environment passes through.
source /tmp/v11u482_env.sh || exit 1
B=$1; T=$2; shift 2
[ -x "$B" ] || { echo "no binary $B"; exit 1; }
for c in "$@"; do
  [ -d "$c" ] || { echo "skip non-dir $c"; continue; }
  c=$(realpath "$c"); W=/tmp/v11u482_runs$c; mkdir -p "$W"
  if [ ! -f "$W/sl/slpp_all/surelog.uhdm" ] || [ "$c/dut.sv" -nt "$W/sl/slpp_all/surelog.uhdm" ]; then
    rm -rf "$W/sl" "$W/sl.oc" "$W/sl.ti"
    (cd "$c" && "$SURELOG" -parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0 -o "$W/sl" > "$W/sl.log" 2>&1 </dev/null); echo $? > "$W/sl.rc"
    "$UHDM_DUMP" "$W/sl/slpp_all/surelog.uhdm" 2>/dev/null | sed -E 's#[^ ,:]*/##g' > "$W/sl.dump"
  fi
  rm -f "$W/$T.uhdm"; (cd "$c" && "$B" dut.sv --single-unit --nobuiltin -o "$W/$T.uhdm" > "$W/$T.log" 2>&1 </dev/null); rc=$?
  n=$("$UHDM_CMP" "$W/sl/slpp_all/surelog.uhdm" "$W/$T.uhdm" 2>&1 | wc -l)
  st=$("$STRICTCMP" "$W/sl/slpp_all/surelog.uhdm" "$W/$T.uhdm" 2>&1 | tail -1)
  "$UHDM_DUMP" "$W/$T.uhdm" 2>/dev/null | sed -E 's#[^ ,:]*/##g' > "$W/$T.dump"
  dd=$(diff "$W/sl.dump" "$W/$T.dump" | grep -c '^[<>]')
  [ -f "$W/sl.oc" ] || "$OBJCENSUS" "$W/sl/slpp_all/surelog.uhdm" > "$W/sl.oc" 2>/dev/null
  [ -f "$W/sl.ti" ] || "$TSINST" "$W/sl/slpp_all/surelog.uhdm" 2>/dev/null | sort > "$W/sl.ti"
  "$OBJCENSUS" "$W/$T.uhdm" > "$W/$T.oc" 2>/dev/null
  "$TSINST" "$W/$T.uhdm" 2>/dev/null | sort > "$W/$T.ti"
  oc=$(python3 "$MSDIST" "$W/sl.oc" "$W/$T.oc" | awk '{print $NF}')
  ic=$(diff "$W/sl.ti" "$W/$T.ti" | grep -c '^[<>]')
  echo "${c#*/tools/probe/} $T slrc=$(cat $W/sl.rc) rc=$rc cmp=$n $st dd=$dd oc=$oc ic=$ic md5=$(md5sum < "$W/$T.uhdm" | cut -c1-8)"
done
