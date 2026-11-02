#!/bin/bash
# runcase.sh <bin> <tag> <casedir>...: Surelog golden and ours under /tmp/v11u466_runs/<full case path>/;
# prints exit code, uhdm-cmp lines, strict verdict, md5.
source $(dirname "$0")/env.sh || exit 1
B=$1; T=$2; shift 2
[ -x "$B" ] || { echo "no binary $B"; exit 1; }
for c in "$@"; do
  [ -d "$c" ] || { echo "skip non-dir $c"; continue; }
  c=$(realpath "$c")
  W=/tmp/v11u466_runs$c; mkdir -p "$W"
  if [ ! -f "$W/sl/slpp_all/surelog.uhdm" ] || [ "$c/dut.sv" -nt "$W/sl/slpp_all/surelog.uhdm" ]; then
    rm -rf "$W/sl"
    (cd "$c" && $SURELOG -parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0 -o "$W/sl" > "$W/sl.log" 2>&1 </dev/null); echo "$?" > "$W/sl.rc"
  fi
  rm -f "$W/$T.uhdm"; (cd "$c" && "$B" dut.sv --single-unit --nobuiltin -o "$W/$T.uhdm" > "$W/$T.log" 2>&1 </dev/null); rc=$?
  echo "$B dut.sv --single-unit --nobuiltin -o $W/$T.uhdm (cwd $c) rc=$rc" >> /tmp/v11u466_cmds.txt
  if [ -f "$W/$T.uhdm" ] && [ -f "$W/sl/slpp_all/surelog.uhdm" ]; then
    n=$($UHDM_CMP "$W/sl/slpp_all/surelog.uhdm" "$W/$T.uhdm" 2>&1 | wc -l)
    st=$($STRICTCMP "$W/sl/slpp_all/surelog.uhdm" "$W/$T.uhdm" 2>&1 | tail -1)
    m=$(md5sum < "$W/$T.uhdm" | cut -c1-8)
  else n=NA; st=NA; m=NA; fi
  echo "${c#*/cases/} rc=$rc slrc=$(cat $W/sl.rc 2>/dev/null) cmp=$n $st md5=$m"
done
