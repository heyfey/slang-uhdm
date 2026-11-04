#!/bin/bash
# runcase.sh <binary> <tag> <casedir>...: the Surelog golden (check_probe.py's flags, cached per
# case under /tmp/v11u476_runs/<full case path>/sl, rebuilt when a source is newer) and ours
# (dut.sv --single-unit --nobuiltin); prints exit code, uhdm-cmp lines, the strict verdict's last
# line, the path-normalized dump distance to golden and ours' md5. Explicit case DIRECTORIES only.
source /tmp/v11u476_env.sh || exit 1
B=$1; T=$2; shift 2
[ -x "$B" ] || { echo "no binary $B"; exit 1; }
[ -x "$STRICTCMP" ] || { echo "no strictcmp"; exit 1; }
for c in "$@"; do
  [ -d "$c" ] || { echo "skip non-dir $c"; continue; }
  c=$(realpath "$c")
  W=/tmp/v11u476_runs$c; mkdir -p "$W"
  newest=$(find "$c" -type f -newer "$W/sl/slpp_all/surelog.uhdm" 2>/dev/null | head -1)
  if [ ! -f "$W/sl/slpp_all/surelog.uhdm" ] || [ -n "$newest" ]; then
    rm -rf "$W/sl"
    (cd "$c" && $SURELOG -parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0 -o "$W/sl" > "$W/sl.log" 2>&1 </dev/null)
    echo "slrc=$?" > "$W/sl.rc"
    $UHDM_DUMP "$W/sl/slpp_all/surelog.uhdm" 2>/dev/null | sed -E 's#[^ ,:]*/##g' > "$W/sl.dump"
  fi
  rm -f "$W/$T.uhdm"; (cd "$c" && env $EXTRA "$B" dut.sv --single-unit --nobuiltin -o "$W/$T.uhdm" > "$W/$T.log" 2>&1 </dev/null); rc=$?
  n=$($UHDM_CMP "$W/sl/slpp_all/surelog.uhdm" "$W/$T.uhdm" 2>&1 | wc -l)
  st=$($STRICTCMP "$W/sl/slpp_all/surelog.uhdm" "$W/$T.uhdm" 2>&1 | tail -1)
  $UHDM_DUMP "$W/$T.uhdm" 2>/dev/null | sed -E 's#[^ ,:]*/##g' > "$W/$T.dump"
  dd=$(diff "$W/sl.dump" "$W/$T.dump" | grep -c '^[<>]')
  echo "${c#*/cases/} $T rc=$rc $(cat $W/sl.rc) cmp=$n $st dd=$dd md5=$(md5sum < "$W/$T.uhdm" | cut -c1-8)"
done
