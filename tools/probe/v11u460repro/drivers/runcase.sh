#!/bin/bash
# runcase.sh <bin> <tag> <casedir>...: Surelog golden + ours under /tmp/v11u460_runs/<full case path>/;
# prints rc, uhdm-cmp lines, strict verdict, md5. Pass explicit case DIRECTORIES only.
source /tmp/wt_v11u460/tools/probe/v11u460repro/drivers/env.sh || exit 1
B=$1; T=$2; shift 2
[ -x "$B" ] || { echo "no binary $B"; exit 1; }
for c in "$@"; do
  [ -d "$c" ] || { echo "skip non-dir $c"; continue; }
  c=$(realpath "$c"); W=/tmp/v11u460_runs$c; mkdir -p "$W"
  if [ ! -f "$W/sl/slpp_all/surelog.uhdm" ]; then
    (cd "$c" && $SURELOG -parse -nopython -nonote -noinfo -nowarning -sverilog dut.sv -o "$W/sl" > "$W/sl.log" 2>&1 </dev/null); echo "$?" > "$W/sl.rc"
  fi
  rm -f "$W/$T.uhdm"; (cd "$c" && "$B" dut.sv -o "$W/$T.uhdm" > "$W/$T.log" 2>&1 </dev/null); rc=$?
  echo "$B dut.sv -o $W/$T.uhdm rc=$rc" >> "$W/cmds.txt"
  if [ -f "$W/sl/slpp_all/surelog.uhdm" ] && [ -f "$W/$T.uhdm" ]; then
    n=$($UHDM_CMP "$W/sl/slpp_all/surelog.uhdm" "$W/$T.uhdm" 2>&1 | wc -l)
    st=$($STRICTCMP "$W/sl/slpp_all/surelog.uhdm" "$W/$T.uhdm" 2>&1 | tail -1)
  else n=NA; st=NA; fi
  echo "${c#*/cases/} $T rc=$rc slrc=$(cat $W/sl.rc 2>/dev/null) cmp=$n $st md5=$(md5sum < "$W/$T.uhdm" 2>/dev/null | cut -c1-8)"
done
