#!/bin/bash
# r11u227: det16.sh <binary> <tag> <draws> <sweep workdir> [ENV=VAL ...]: <draws> runs of the binary per row-mode on
# Earlgrey_0_1 and the UVM rows (MiniAmiq SeqDriver SimpleUVM BuildUVMPkg, and Scoreboard default), 4 concurrent,
# each with the harness's own command line (the `slang:` line of <sweep workdir>'s cmds.txt, binary and -o replaced)
# in the test's directory (the harness's cwd); prints the md5 histogram per row-mode. Fence fail-closed.
[ -n "$FENCED" ] && [ -n "$S" ] || { echo "det16.sh: source drivers/env.sh" >&2; exit 2; }
BIN=$1; TAG=$2; N=$3; W=$4; shift 4; ENVX="$*"
T="${DET_TESTS:-Earlgrey_0_1 MiniAmiq SeqDriver SimpleUVM BuildUVMPkg Scoreboard}"
for t in $T; do for f in $FENCED; do [ "$f" = "$t" ] && { echo "det16.sh: fenced"; exit 2; }; done; done
O=$S/det16_$TAG; rm -rf $O; mkdir -p $O
jobs=$O/jobs.txt; : > $jobs
for m in default testflags; do for t in $T; do
  c=$(ls $W/surelog/$m/$t-*/cmds.txt 2>/dev/null | head -1); [ -n "$c" ] || continue
  grep -q '^slang:' $c || continue
  sl=$(find $SURELOG_ROOT/tests $SURELOG_ROOT/third_party/tests -maxdepth 3 -name "$t.sl" | head -1)  # the harness's cwd: the .sl file's directory
  d=$(dirname "$sl")
  [ -d "$d" ] || continue
  a=$(grep -m1 '^slang:' $c | sed 's/^slang: *//' | cut -d' ' -f2- | sed 's/ -o [^ ]*$//')
  for i in $(seq 1 $N); do echo "$m $t $i|$d|$a" >> $jobs; done
done; done
export BIN O ENVX
cat $jobs | xargs -P4 -d '\n' -I{} bash -c 'j="{}"; k=${j%%|*}; r=${j#*|}; d=${r%%|*}; a=${r#*|}; set -- $k; o=$O/$1_$2_$3.uhdm; rm -f $o; (cd "$d" && eval env $ENVX timeout 900 $BIN $a -o $o > /dev/null 2>&1); echo "$1 $2 $3 $?"' > $O/rc.txt
for m in default testflags; do for t in $T; do
  ls $O/${m}_${t}_*.uhdm > /dev/null 2>&1 || continue
  echo "$TAG $t/$m $(md5sum $O/${m}_${t}_*.uhdm | cut -c1-12 | sort | uniq -c | tr '\n' ' ') rc:$(awk -v m=$m -v t=$t '$1==m && $2==t {print $4}' $O/rc.txt | sort | uniq -c | tr '\n' ' ')"
done; done
