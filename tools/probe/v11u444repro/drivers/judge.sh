#!/bin/bash
# judge.sh <relative .sv path>: fresh Surelog golden (-odir under scratch) for a census unit, then per tag p/l/v:
# uhdm-cmp line count, strict verdict, dump distance. Units and outputs as census.sh.
REPO=/home/heyfey/git-repos/slang-uhdm; f=$1; d=$REPO/$(dirname $f); b=$(basename $f)
key=$(echo $f | sed 's|/|_|g'); o=/tmp/v11u444_scr/cen/$key; g=/tmp/v11u444_scr/cengold/$key
SL=/home/heyfey/git-repos/Surelog/build/bin/surelog; CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp
SC=/tmp/v11u444_bin/uhdm-strictcmp; DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
[ -x $SL ] && [ -x $CMP ] && [ -x $SC ] && [ -x $DUMP ] || { echo "missing tool"; exit 2; }
SRC=$b; ST=
if [ $b = dut.sv ]; then [ -f $d/FILES ] && SRC=$(cat $d/FILES); [ -f $d/TOP ] && ST="--top-module $(cat $d/TOP)"; fi
if [ ! -f $g/slpp_all/surelog.uhdm ]; then rm -rf $g; mkdir -p $g; (cd $d && timeout 300 $SL -parse -nobuiltin -nocache -sv $ST $SRC -odir $g > $g/sl.log 2>&1); fi
G=$g/slpp_all/surelog.uhdm
[ -f $G ] || { echo "$f NOGOLDEN"; exit; }
norm(){ $DUMP $1 2>/dev/null | sed 's/, id:[0-9]*//; s|file:[^,]*/|file:|; s|\(vpi[A-Za-z]*File\):.*/|\1:|' | tail -n +2; }
line="$f"
for t in ${TAGS:-p l v}; do
  U=$o/$t.uhdm; [ -s $U ] || { line="$line | $t NOUHDM"; continue; }
  n=$($CMP $G $U 2>&1 | wc -l); s=$($SC $G $U 2>&1 | tail -1); dd=$(diff <(norm $G) <(norm $U) | grep -c '^[<>]')
  line="$line | $t cmp=$n $s dist=$dd"
done
echo "$line"
