#!/bin/bash
# runuvm.sh <bin> <tag> <casedir>...: like runcase.sh, with Surelog's bundled UVM 1800.2-2017 as a source
# (the sv-tests uvm recipe: -I<uvm>/src <uvm>/src/uvm_pkg.sv dut.sv; Surelog -noprecompiledcache).
source $(dirname "$0")/env.sh || exit 1
B=$1; T=$2; shift 2
[ -x "$B" ] || { echo "no binary $B"; exit 1; }
U=/home/heyfey/git-repos/slang-uhdm/third_party/Surelog/third_party/UVM/1800.2-2017-1.0/src
for c in "$@"; do
  [ -d "$c" ] || { echo "skip non-dir $c"; continue; }
  c=$(realpath "$c")
  W=/tmp/r11u470_runs$c; mkdir -p "$W"
  if [ ! -f "$W/sl/slpp_all/surelog.uhdm" ] || [ "$c/dut.sv" -nt "$W/sl/slpp_all/surelog.uhdm" ]; then
    rm -rf "$W/sl"
    (cd "$c" && $SURELOG -nopython -parse -nonote -noinfo -nowarning -I$U $U/uvm_pkg.sv dut.sv -noprecompiledcache -mt 0 -mp 0 -o "$W/sl" > "$W/sl.log" 2>&1 </dev/null)
  fi
  rm -f "$W/$T.uhdm"; (cd "$c" && "$B" -I$U $U/uvm_pkg.sv dut.sv --single-unit -o "$W/$T.uhdm" > "$W/$T.log" 2>&1 </dev/null); rc=$?
  n=$($UHDM_CMP "$W/sl/slpp_all/surelog.uhdm" "$W/$T.uhdm" 2>&1 | wc -l)
  st=$($STRICTCMP "$W/sl/slpp_all/surelog.uhdm" "$W/$T.uhdm" 2>&1 | tail -1)
  echo "${c#*/cases/} rc=$rc cmp=$n $st md5=$(md5sum < "$W/$T.uhdm" | cut -c1-8)"
done
