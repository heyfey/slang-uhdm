#!/bin/bash
# runcase.sh <bin> <tag> <casedir>...: build golden (cached in casedir/sl) and ours, print exit code, uhdm-cmp lines, strict verdict
source ${ENVFILE:-/tmp/r11u454_env.sh}
B=$1; T=$2; shift 2
for c in "$@"; do
  [ -d "$c" ] || continue
  cd "$c" || continue
  [ -f sl/slpp_all/surelog.uhdm ] || $SURELOG -parse -nopython -nonote -noinfo -nowarning -sverilog dut.sv -o sl > /dev/null 2>&1
  rm -f $T.uhdm; "$B" dut.sv -o $T.uhdm > $T.log 2>&1; rc=$?
  n=$($UHDM_CMP sl/slpp_all/surelog.uhdm $T.uhdm 2>&1 | wc -l)
  st=$(/home/heyfey/git-repos/slang-uhdm/build/uhdm-strictcmp sl/slpp_all/surelog.uhdm $T.uhdm 2>&1 | tail -1)
  echo "$c rc=$rc cmp=$n $st md5=$(md5sum < $T.uhdm | cut -c1-8)"
done
