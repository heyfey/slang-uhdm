#!/bin/bash
# run.sh <dir>: Surelog (sv-tests recipe, UVM) + pristine on the sv-tests file list in <dir>/FILES; print this_t instances
source /tmp/wt_r11u474/tools/probe/r11u474repro/drivers/env.sh || exit 1
export LD_LIBRARY_PATH=~/.local/lib64:~/.local/lib
D=$(realpath $1); B=${B:-/tmp/r11u474_bin/pristine}
U=/home/heyfey/git-repos/slang-uhdm/third_party/Surelog/third_party/UVM/1800.2-2017-1.0/src
F=$(cat $D/FILES)
cd $D
if [ ! -f $D/sl/slpp_all/surelog.uhdm ] || [ -n "$FORCE" ]; then rm -rf $D/sl; $SURELOG -nopython -parse -nonote -noinfo -nowarning -I$U -I$D/sfr_agent -I$D/sfr_test_pkg $U/uvm_pkg.sv $F -noprecompiledcache -mt 0 -mp 0 -o $D/sl > $D/sl.log 2>&1 </dev/null; echo "sl rc=$?"; fi
rm -f $D/ours.uhdm; $B -I$U -I$D/sfr_agent -I$D/sfr_test_pkg $U/uvm_pkg.sv $F --single-unit -o $D/ours.uhdm > $D/ours.log 2>&1 </dev/null; echo "ours rc=$?"
for c in ${CLS:-sfr_agent sfr_config_object}; do
 echo "G $(/tmp/r11u474_tools/thist $D/sl/slpp_all/surelog.uhdm $c this_t | head -1 | grep -o 'inst=[^ ]*')  O $(/tmp/r11u474_tools/thist $D/ours.uhdm $c this_t | head -1 | grep -o 'inst=[^ ]*') $c"
done
