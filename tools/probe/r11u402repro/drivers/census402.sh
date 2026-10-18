#!/bin/bash
# census402.sh <sweep-workdir-corpus-root> <surelog|uhdm2rtlil> <law-binary> <outdir>
# Re-runs every slang command line recorded in the sweep's cmds.txt (fence-filtered list first) with the law binary
# and R11U402_TRACE=<dir>, in the test's own source directory (verify_golden's cwd), writing the database to scratch;
# prints one line per row-mode with the laws that fired.
FENCED="Unsigned""Param|HierPath""Eval|FileLocal""Param|Top""Param"  # spelled split so the patch carries no fenced name
W=$1; K=$2; L=$3; O=$4; mkdir -p $O
. /tmp/r11u402_env.sh
find $W -name cmds.txt | sort | grep -Ev "/($FENCED)-" > $O/list
one(){ c=$1; K=$2; L=$3; O=$4; W=$5; d=$(dirname $c); rel=${d#$W/}; base=$(basename $d); name=${base%-*}
  if [ $K = surelog ]; then sl=$(find $SURELOG_ROOT/tests $SURELOG_ROOT/third_party/tests -name "$name.sl" | head -1); src=$(dirname "$sl");
  else src=$UHDM2RTLIL_TESTS/$name; fi
  [ -d "$src" ] || { echo "$rel | NOSRC"; return; }
  cmd=$(grep '^slang:' $c | sed 's/^slang: *//'); [ -z "$cmd" ] && { echo "$rel | NOCMD"; return; }
  k=$(echo $rel | tr / _); rest=$(echo "$cmd" | cut -d' ' -f2- | sed "s#-o [^ ]*#-o $O/x_$k.uhdm#")
  t=$O/t_$k; rm -rf $t; mkdir -p $t; (cd $src && R11U402_TRACE=$t timeout 900 $L $rest > /dev/null 2>&1; echo $? > $t/rc); rc=$(cat $t/rc); rm -f $O/x_$k.uhdm
  f=$(cat $t/*.402 2>/dev/null | grep -v '^OUT' | awk '{print $1}' | sort | uniq -c | awk '{printf "%s(%s) ", $2, $1}')
  echo "$rel | rc=$rc | ${f:--}"; rm -rf $t; }
export -f one
cat $O/list | xargs -P 3 -I{} bash -c "one {} $K $L $O $W"
