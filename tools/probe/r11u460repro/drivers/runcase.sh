#!/bin/bash
# runcase.sh <bin> <tag> <casedir>...: Surelog golden and ours under
# /tmp/r11u460_runs/<full case path>/; prints exit code, uhdm-cmp lines,
# strict verdict and md5 of ours.  Pass explicit case DIRECTORIES only.
source ${ENVFILE:-/tmp/r11u460_env.sh} || exit 1
B=$1; T=$2; shift 2
[ -x "$B" ] || { echo "no binary $B"; exit 1; }
for c in "$@"; do
  [ -d "$c" ] || { echo "skip non-dir $c"; continue; }
  c=$(realpath "$c")
  W=/tmp/r11u460_runs$c; mkdir -p "$W"
  if [ ! -f "$W/sl/slpp_all/surelog.uhdm" ]; then
    (cd "$c" && $SURELOG -parse -nopython -nonote -noinfo -nowarning -sverilog dut.sv -o "$W/sl" > "$W/sl.log" 2>&1 </dev/null)
  fi
  rm -f "$W/$T.uhdm"; (cd "$c" && "$B" dut.sv -o "$W/$T.uhdm" > "$W/$T.log" 2>&1 </dev/null); rc=$?
  n=$($UHDM_CMP "$W/sl/slpp_all/surelog.uhdm" "$W/$T.uhdm" 2>&1 | wc -l)
  st=$($STRICTCMP "$W/sl/slpp_all/surelog.uhdm" "$W/$T.uhdm" 2>&1 | tail -1)
  echo "${c#*/r11u460repro/cases/} rc=$rc cmp=$n $st md5=$(md5sum < "$W/$T.uhdm" | cut -c1-8)"
done
