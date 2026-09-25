#!/bin/bash
# attrib.sh <law sweep> <pristine sweep> <corpus/mode/dir>...: per corpus byte mover, rerun the
# law binary with R11U160_OFF=1 and with each switch alone; print whether OFF gives the pristine
# bytes and which switches change the law bytes (the contributing laws).  Fail-closed on $FENCED.
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "attrib.sh: export FENCED" >&2; exit 2; }
L=$1; P=$2; shift 2; LAW=${LAW:-/tmp/r11u160_bin/law.bin}; T=${TMPD:-/tmp/r11u160_attr}; mkdir -p $T
SW="R11U160_CATCH_OFF R11U160_OBJMACROPAREN_OFF R11U160_TPWHOLELHS_OFF R11U160_TPPACKEDVEC_OFF R11U160_BODYTPDEF_OFF R11U160_TPUSEDEF_OFF R11U160_TPUSEUNIT_OFF R11U160_PPINACTIVE_OFF R11U160_PPARGNL_OFF R11U160_PPBUILTIN_OFF R11U160_PPSTRINGIFY_OFF R11U160_PPPASTE_OFF R11U160_PPNESTCOL_OFF R11U160_PPPUSHLINE_OFF R11U160_IMPLBAREPARAM_OFF"
for m in "$@"; do
  c=${m%%/*}; rest=${m#*/}; md=${rest%%/*}; d=${rest#*/}; n=${d%-*}
  for f in $FENCED; do [ "$f" = "$n" ] && { echo "$m fenced, skipped"; continue 2; }; done
  if [ $c = uhdm2rtlil ]; then cwd=$UHDM2RTLIL_TESTS/$n
  elif [ -d $SURELOG_ROOT/tests/$n ]; then cwd=$SURELOG_ROOT/tests/$n
  else cwd=$SURELOG_ROOT/third_party/tests/$n; fi
  cmd=$(grep '^slang:' $L/$c/$md/$d/cmds.txt | head -1 | sed 's/^slang: *//')
  argv=$(echo "$cmd" | sed "s#^[^ ]*##; s# -o [^ ]*\$##")
  run() { rm -f $T/o.uhdm; (cd $cwd && eval env "$@" $LAW $argv -o $T/o.uhdm > /dev/null 2>&1); }
  run; cp $T/o.uhdm $T/law.uhdm 2>/dev/null
  lawsame=$(cmp -s $T/law.uhdm $L/$c/$md/$d/slang.uhdm && echo det || echo NONDET)
  run R11U160_OFF=1; off=$(cmp -s $T/o.uhdm $P/$c/$md/$d/slang.uhdm && echo pristine || echo DIFF)
  contrib=""
  for s in $SW; do run $s=1; cmp -s $T/o.uhdm $T/law.uhdm || contrib="$contrib ${s#R11U160_}"; done
  echo "$m | law-rerun:$lawsame | OFF:$off | contributing:${contrib:- none}"
done
