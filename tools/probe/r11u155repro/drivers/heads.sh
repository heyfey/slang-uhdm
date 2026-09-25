#!/bin/bash
# heads.sh <workdir> <corpus> <mode> <name>... : the first strict records of named rows
# (uhdm-strictcmp --max ${MAX:-4}) from a verify_golden workdir.  Fail-closed on $FENCED
# (the four slang-fenced test names, space separated, never spelled here).
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "heads.sh: export FENCED (four names) first" >&2; exit 1; }
WD=$1; C=$2; M=$3; shift 3
SC=${STRICT_CMP:-/tmp/r11u155_bin/uhdm-strictcmp}
for n in "$@"; do
  skip=0; for f in $FENCED; do [ "$f" = "$n" ] && skip=1; done
  [ $skip = 1 ] && { echo "== $n: fenced, skipped"; continue; }
  d=$(ls -d $WD/$C/$M/$n-* 2>/dev/null | head -1)
  [ -n "$d" ] || { echo "== $n: no dir"; continue; }
  g=$(grep -o 'golden cache hit [^)]*' $d/cmds.txt | awk '{print $4}')/golden.uhdm
  [ -f "$g" ] || g=$(ls $d/*.uhdm | grep -v slang.uhdm | head -1)
  echo "== $n ($M)"; $SC --max ${MAX:-4} $g $d/slang.uhdm | tail -$(( ${MAX:-4} * 3 + 2 ))
done
