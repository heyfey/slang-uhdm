. /tmp/wt_r11u203/tools/probe/r11u203map/drivers/env.sh
run(){ t=$1; m=$2; s=$3; d=$(ls -d /tmp/intr11u196/surelog/$m/$t-*); args=$(grep '^slang:' $d/cmds.txt | sed 's/^slang:\s*//; s#^\S*slang-uhdm ##; s# -o \S*$##'); cwd=$(cd /tmp/wt_r11u203 && python3 -c "import sys; sys.path.insert(0,'scripts'); import verify_golden as vg; print(vg.discover_surelog(None)['$t'][0])"); o=/tmp/r11u203_sw/${t}_${m}_$s.uhdm; rm -f $o; (cd $cwd && env $s=1 /tmp/r11u203_bin/slang-uhdm.law200 $args -o $o > $o.log 2>&1; echo rc=$? >> $o.log); g=$(grep -o 'golden cache [a-z]* [^)]*' $d/cmds.txt | awk '{print $4}')/golden.uhdm; /tmp/r11u203_bin/strictcmp_x --max 50 --dump-a $o.a --dump-b $o.b $g $o > $o.out 2>&1; }
run Earlgrey_0_1 default R11U200_PORTPACKED_OFF &
run Scoreboard default R11U200_CLASSTDRET_OFF &
wait; echo SWDONE
