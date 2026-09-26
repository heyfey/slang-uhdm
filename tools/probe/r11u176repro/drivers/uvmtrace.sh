#!/bin/bash
# uvmtrace.sh <sweep workdir> <out.txt> <row dir>... : the big UVM movers: one traced run of the final binary
# (R11U176_TRACE=1, law firing counts) and one run with R11U176_OFF=1 R11U175_OFF=1 compared with the pristine sweep's
# database byte-wise and ORDER-BLIND (uhdm-dump lines, path-normalised, sorted: the known UINT/vpiDecompile order
# coin shows as byte-only).  Fail-closed on $FENCED.
set -u; [ "$(echo $FENCED | wc -w)" = 4 ] || { echo "uvmtrace.sh: export FENCED" >&2; exit 2; }
W=$1 O=$2; shift 2; T=/tmp/r11u176_scratch/uvmtrace; mkdir -p $T; : > $O
for rd in "$@"; do
  n=$(basename $rd); name=${n%-*}; h=${n##*-}
  for f in $FENCED; do [ "$f" = "$name" ] && { echo "$rd fenced refused" >> $O; continue 2; }; done
  dir=""; lname=$(echo $name | tr A-Z a-z); for c in $SURELOG_ROOT/tests/$name $SURELOG_ROOT/third_party/tests/$name $SURELOG_ROOT/third_party/tests/$lname $UHDM2RTLIL_TESTS/$name; do
    [ -d $c ] && [ "$(printf %s $c | sha1sum | cut -c1-8)" = "$h" ] && dir=$c; done
  [ -z "$dir" ] && { echo "$rd nodir" >> $O; continue; }
  set -- $(grep '^slang:' $W/$rd/cmds.txt | sed 's/^slang: *//'); shift
  a2=(); skip=0; for a in "$@"; do if [ $skip = 1 ]; then a2+=("$T/$n.uhdm"); skip=0; elif [ "$a" = "-o" ]; then a2+=("-o"); skip=1; else a2+=("$a"); fi; done
  rm -f $T/$n.uhdm; (cd $dir && R11U176_TRACE=1 timeout 1800 /tmp/r11u176_bin/final4.bin "${a2[@]}" > /dev/null 2> $T/$n.trace </dev/null)
  tr=$(grep -o '^R11U176 [A-Z]*' $T/$n.trace | sort | uniq -c | awk '{printf "%s:%s ", $3, $1}')
  rm -f $T/$n.uhdm; (cd $dir && R11U176_OFF=1 R11U175_OFF=1 timeout 1800 /tmp/r11u176_bin/final4.bin "${a2[@]}" > /dev/null 2>&1 </dev/null)
  if cmp -s $T/$n.uhdm /tmp/r11u176_swP/$rd/slang.uhdm; then off=BYTES-EQUAL; else
    ob=$(comm -3 <($UHDM_DUMP $T/$n.uhdm 2>/dev/null | sed 's|/[^ ,]*/||g' | sort) <($UHDM_DUMP /tmp/r11u176_swP/$rd/slang.uhdm 2>/dev/null | sed 's|/[^ ,]*/||g' | sort) | grep -v 'Restored design' | wc -l); off="bytes-differ orderblind-lines=$ob"; fi
  echo "$rd trace: ${tr:-none} alloff: $off" >> $O
done
