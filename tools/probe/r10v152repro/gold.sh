set -u
SL=$HOME/git-repos/Surelog/build/bin/surelog
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
for f in /tmp/v152_arms/v152_*.sv; do
  n=$(basename $f .sv); D=/tmp/v152_wd/$n; mkdir -p $D; cp $f $D/
  ( cd $D && $SL -parse -nobuiltin -nocache -sv $n.sv >sl.log 2>&1 </dev/null ); echo "$n SL rc=$?"
  for c in slpp_all slpp_unit; do [ -f "$D/$c/surelog.uhdm" ] && cp "$D/$c/surelog.uhdm" "$D/g.uhdm"; done
  rm -rf $D/slpp_all $D/slpp_unit
  ( cd $D && $SL -parse -elabuhdm -nobuiltin -nocache -sv $n.sv >sle.log 2>&1 </dev/null ); echo "$n SLe rc=$?"
  for c in slpp_all slpp_unit; do [ -f "$D/$c/surelog.uhdm" ] && cp "$D/$c/surelog.uhdm" "$D/ge.uhdm"; done
  $DUMP $D/g.uhdm > $D/g.dump 2>/dev/null; $DUMP $D/ge.uhdm > $D/ge.dump 2>/dev/null
  echo "$n gdump=$(wc -l < $D/g.dump) gedump=$(wc -l < $D/ge.dump)"
done
