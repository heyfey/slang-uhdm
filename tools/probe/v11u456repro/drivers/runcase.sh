#!/bin/bash
# runcase.sh <bin> <tag> <casedir>...: Surelog golden and ours under
# /tmp/v11u456_runs/<full case path>/; prints the case, exit code, uhdm-cmp
# lines, strict verdict and the md5 of ours.  Explicit case DIRECTORIES only.
source ${ENVFILE:-/tmp/v11u456_env.sh} || exit 1
B=$1; T=$2; shift 2
[ -x "$B" ] || { echo "no binary $B"; exit 1; }
[ -x "$STRICTCMP" ] || { echo "no strictcmp"; exit 1; }
for c in "$@"; do
  [ -d "$c" ] || { echo "skip non-dir $c"; continue; }
  c=$(realpath "$c")
  W=/tmp/v11u456_runs$c; mkdir -p "$W"
  if [ ! -f "$W/sl/slpp_all/surelog.uhdm" ]; then
    (cd "$c" && $SURELOG -parse -nopython -nonote -noinfo -nowarning -sverilog dut.sv -o "$W/sl" > "$W/sl.log" 2>&1 </dev/null)
  fi
  rm -f "$W/$T.uhdm"; (cd "$c" && "$B" dut.sv -o "$W/$T.uhdm" > "$W/$T.log" 2>&1 </dev/null); rc=$?
  n=$($UHDM_CMP "$W/sl/slpp_all/surelog.uhdm" "$W/$T.uhdm" 2>&1 | wc -l)
  st=$($STRICTCMP "$W/sl/slpp_all/surelog.uhdm" "$W/$T.uhdm" 2>&1 | tail -1)
  echo "${c#*/repro/cases/} rc=$rc cmp=$n $st md5=$(md5sum < "$W/$T.uhdm" | cut -c1-8)" | sed 's#^.*/cases/##'
done
