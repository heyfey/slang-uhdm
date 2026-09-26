#!/bin/bash
# attrib.sh <sweep workdir> <out.txt> <row dir>... : re-run a mover row's recorded slang command (cmds.txt) in its test
# directory (found by the sha1 the harness keys the row dir on) with R11U176_TRACE=1 on the final binary, and once
# per switch; prints the firing trace and the switches whose single drop restores the pristine sweep's bytes.
# Fail-closed on $FENCED; a fenced row is refused.
set -u; [ "$(echo $FENCED | wc -w)" = 4 ] || { echo "attrib.sh: export FENCED" >&2; exit 2; }
W=$1 O=$2; shift 2
SW="R11U175_FSPAN_OFF R11U176_CASTCLONE_OFF R11U176_PROGLCLOC_OFF R11U176_PROGMPDEF_OFF R11U176_GENMPLOC_OFF R11U176_GENPLAINLOC_OFF R11U176_GENPLAINVARS_OFF R11U176_PROGVIEW_OFF R11U176_QUALFORMAL_OFF R11U176_CLSMETHOD_OFF R11U176_DEFTOPSPLIT_OFF R11U176_TDKEY_OFF R11U176_TDTIE_OFF R11U176_UDPLV_OFF R11U176_ELSEBEGIN_OFF R11U176_GENARR_OFF"
T=/tmp/r11u176_scratch/attrib; mkdir -p $T; : > $O
for rd in "$@"; do
  n=$(basename $rd); name=${n%-*}; h=${n##*-}
  for f in $FENCED; do [ "$f" = "$name" ] && { echo "$rd fenced refused" >> $O; continue 2; }; done
  dir=""; lname=$(echo $name | tr A-Z a-z); for c in $SURELOG_ROOT/tests/$name $SURELOG_ROOT/third_party/tests/$name $SURELOG_ROOT/third_party/tests/$lname $UHDM2RTLIL_TESTS/$name; do
    [ -d $c ] && [ "$(printf %s $c | sha1sum | cut -c1-8)" = "$h" ] && dir=$c; done
  [ -z "$dir" ] && { echo "$rd nodir" >> $O; continue; }
  cmd=$(grep '^slang:' $W/$rd/cmds.txt | sed 's/^slang: *//')
  set -- $cmd; shift; args=("$@"); args=("${args[@]/#-o/-o}")
  # replace the output path (the arg after -o)
  out=$T/$n.uhdm; a2=(); skip=0; for a in "${args[@]}"; do if [ $skip = 1 ]; then a2+=("$out"); skip=0; elif [ "$a" = "-o" ]; then a2+=("-o"); skip=1; else a2+=("$a"); fi; done
  pris=/tmp/r11u176_swP/$rd/slang.uhdm
  rm -f $out; (cd $dir && R11U176_TRACE=1 timeout 900 /tmp/r11u176_bin/final4.bin "${a2[@]}" > /dev/null 2> $T/$n.trace </dev/null)
  tr=$(grep -o '^R11U176 [A-Z]*' $T/$n.trace | sort | uniq -c | awk '{printf "%s:%s ", $3, $1}')
  r=""; for s in $SW; do rm -f $out; (cd $dir && env $s=1 timeout 900 /tmp/r11u176_bin/final4.bin "${a2[@]}" > /dev/null 2>&1 </dev/null); cmp -s $out $pris && r="$r $s"; done
  echo "$rd trace: ${tr:-none} restores:${r:- none}" >> $O
done
