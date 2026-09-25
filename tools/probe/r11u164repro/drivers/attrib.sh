#!/bin/bash
# attrib.sh <law sweep> <pristine sweep> <corpus/mode/test>...: per corpus byte mover, rerun the law binary with the
# row's own command line (from its cmds.txt) plain, with R11U164_OFF=1 R11U161_OFF=1 (the whole landing off) and with
# each switch alone; print whether the rerun is deterministic, whether landing-off gives the pristine bytes, and
# which switches change the law bytes.  (after r11u160repro/drivers/attrib.sh)  Fail-closed on $FENCED.
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "attrib.sh: source drivers/env.sh" >&2; exit 2; }
L=$1; P=$2; shift 2; T=${TMPD:-/tmp/r11u164_attr}; mkdir -p $T
SW="R11U164_RANGEQ_OFF R11U164_RANGEQSIZE_OFF R11U164_CADELAY_OFF R11U164_DLYPARAMELAB_OFF R11U164_PVMPDEF_OFF R11U164_PVSHARE_OFF R11U164_SELBASELEAF_OFF R11U164_BINDPATHNAME_OFF R11U164_GENNDAHP_OFF R11U161_ROUTE_OFF R11U161_SPAN_OFF R11U161_NAME_OFF R11U161_PORT_OFF R11U161_ALIAS_OFF R11U161_FILE_OFF"
for m in "$@"; do
  c=${m%%/*}; rest=${m#*/}; md=${rest%%/*}; n=${rest#*/}
  for f in $FENCED; do [ "$f" = "$n" ] && { echo "$m fenced, skipped"; continue 2; }; done
  d=$(ls -d $L/$c/$md/$n-*); pd=$(ls -d $P/$c/$md/$n-*)
  if [ $c = uhdm2rtlil ]; then cwd=$UHDM2RTLIL_TESTS/$n
  else cwd=$(dirname $(find $SURELOG_ROOT/tests $SURELOG_ROOT/third_party/tests -maxdepth 3 -name "$n.sl" | head -1)); fi
  cmd=$(grep '^slang:' $d/cmds.txt | head -1 | sed 's/^slang: *//')
  argv=$(echo "$cmd" | sed "s#^[^ ]*##; s# -o [^ ]*\$##")
  run() { rm -f $T/o.uhdm; (cd $cwd && eval env "$@" $LAW $argv -o $T/o.uhdm > /dev/null 2>&1 </dev/null); }
  run; cp $T/o.uhdm $T/law.uhdm 2>/dev/null
  det=$(cmp -s $T/law.uhdm $d/slang.uhdm && echo det || echo NONDET)
  run R11U164_OFF=1 R11U161_OFF=1; off=$(cmp -s $T/o.uhdm $pd/slang.uhdm && echo pristine || echo DIFF)
  con=""; for s in $SW; do run $s=1; cmp -s $T/o.uhdm $T/law.uhdm || con="$con ${s}"; done
  echo "$m | law-rerun:$det | OFF:$off | contributing:${con:- none}"
done
