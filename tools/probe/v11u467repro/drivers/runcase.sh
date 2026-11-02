#!/bin/bash
# runcase.sh <bin> <tag> <casedir>...: Surelog golden (check_probe.py's flags) and ours
# (dut.sv --single-unit --nobuiltin) under /tmp/v11u467_runs/<full case path>/;
# prints exit code, uhdm-cmp lines, strict verdict and md5 of ours.  Explicit case DIRECTORIES only.
source /tmp/v11u467_env.sh || exit 1
STRICTCMP=${STRICTCMP:-/tmp/wt_v11u467/build/uhdm-strictcmp}
B=$1; T=$2; shift 2
for v in "$B" "$SURELOG" "$UHDM_CMP" "$STRICTCMP"; do [ -x "$v" ] || { echo "no tool $v"; exit 1; }; done
for c in "$@"; do
  [ -d "$c" ] || { echo "skip non-dir $c"; continue; }
  c=$(realpath "$c")
  W=/tmp/v11u467_runs$c; mkdir -p "$W"
  if [ ! -f "$W/sl/slpp_all/surelog.uhdm" ] || [ "$c/dut.sv" -nt "$W/sl/slpp_all/surelog.uhdm" ]; then
    rm -rf "$W/sl"
    (cd "$c" && $SURELOG -parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0 -o "$W/sl" > "$W/sl.log" 2>&1 </dev/null); echo "surelog rc=$?" > "$W/sl.rc"
  fi
  rm -f "$W/$T.uhdm"; (cd "$c" && "$B" dut.sv --single-unit --nobuiltin -o "$W/$T.uhdm" > "$W/$T.log" 2>&1 </dev/null); rc=$?
  echo "$B dut.sv --single-unit --nobuiltin -o $W/$T.uhdm" > "$W/$T.cmd"
  n=$($UHDM_CMP "$W/sl/slpp_all/surelog.uhdm" "$W/$T.uhdm" 2>&1 | wc -l)
  st=$($STRICTCMP "$W/sl/slpp_all/surelog.uhdm" "$W/$T.uhdm" 2>&1 | tail -1)
  echo "${c#*/cases/} rc=$rc $(cat $W/sl.rc) cmp=$n $st md5=$(md5sum < "$W/$T.uhdm" | cut -c1-8)"
done
