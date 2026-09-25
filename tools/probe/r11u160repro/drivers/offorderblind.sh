#!/bin/bash
# offorderblind.sh <law sweep> <pristine sweep> <corpus/mode/dir>...: for the order-coin rows, rerun
# the law binary with R11U160_OFF=1 and count the ORDER-BLIND dump lines (sorted uhdm-dump, ids and
# workdir paths normalised) that differ from the pristine database.  Fail-closed on $FENCED.
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "offorderblind.sh: export FENCED" >&2; exit 2; }
L=$1; P=$2; shift 2; LAW=${LAW:-/tmp/r11u160_bin/law.bin}; T=${TMPD:-/tmp/r11u160_ob}; mkdir -p $T
for m in "$@"; do
  c=${m%%/*}; rest=${m#*/}; md=${rest%%/*}; d=${rest#*/}; n=${d%-*}
  for f in $FENCED; do [ "$f" = "$n" ] && { echo "$m fenced, skipped"; continue 2; }; done
  if [ -d $SURELOG_ROOT/tests/$n ]; then cwd=$SURELOG_ROOT/tests/$n; else cwd=$SURELOG_ROOT/third_party/tests/$n; fi
  [ $c = uhdm2rtlil ] && cwd=$UHDM2RTLIL_TESTS/$n
  cmd=$(grep '^slang:' $L/$c/$md/$d/cmds.txt | head -1 | sed 's/^slang: *//')
  argv=$(echo "$cmd" | sed "s#^[^ ]*##; s# -o [^ ]*\$##")
  rm -f $T/o.uhdm; (cd $cwd && eval env R11U160_OFF=1 $LAW $argv -o $T/o.uhdm > /dev/null 2>&1)
  norm() { $UHDM_DUMP $1 2>/dev/null | sed -e "s#$L#WD#g; s#$P#WD#g; s#$T/o.uhdm#WD#g; s#, id:[0-9]*##g" | sort; }
  norm $T/o.uhdm > $T/off; norm $P/$c/$md/$d/slang.uhdm > $T/pr
  echo "$m | OFF vs pristine, order-blind differing lines: $(comm -3 $T/off $T/pr | wc -l)"
done
