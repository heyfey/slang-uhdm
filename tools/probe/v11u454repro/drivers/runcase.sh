#!/bin/bash
# runcase.sh <bin> <tag> <casedir>... : Surelog golden cached in <casedir>/sl (deleted when dut.sv is newer),
# ours to <casedir>/<tag>.uhdm; prints exit code, uhdm-cmp line count, strict verdict, md5.
# A case dir holding files.lst compiles those files in that order (both tools), else dut.sv.
source ${ENVFILE:-/tmp/v11u454_s/env.sh} || exit 1
B=$1; T=$2; shift 2
[ -x "$B" ] || { echo "no binary $B"; exit 1; }
for c in "$@"; do
  [ -d "$c" ] || { echo "skip non-dir $c"; continue; }
  ( cd "$c" || exit
    F=(dut.sv); [ -f files.lst ] && read -r -a F < files.lst
    for f in "${F[@]}"; do [ -f sl/slpp_all/surelog.uhdm ] && [ "$f" -nt sl/slpp_all/surelog.uhdm ] && rm -rf sl; done
    [ -f sl/slpp_all/surelog.uhdm ] || "$SURELOG" -parse -nopython -nonote -noinfo -nowarning -sverilog "${F[@]}" -o sl > sl.log 2>&1
    rm -f "$T.uhdm"; "$B" "${F[@]}" -o "$T.uhdm" > "$T.log" 2>&1; rc=$?
    n=$("$UHDM_CMP" sl/slpp_all/surelog.uhdm "$T.uhdm" 2>&1 | wc -l)
    st=$("$STRICTCMP" sl/slpp_all/surelog.uhdm "$T.uhdm" 2>&1 | tail -1)
    echo "$c rc=$rc cmp=$n $st md5=$(md5sum < "$T.uhdm" | cut -c1-8)" )
done
