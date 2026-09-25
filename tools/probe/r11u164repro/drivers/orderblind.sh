#!/bin/bash
# orderblind.sh <law sweep> <pristine sweep> <corpus/mode/test>...: order-blind uhdm-dump diff (sorted lines, workdir
# paths normalised) between the two sweeps' databases of each row; prints the line count and the first lines.
# Fail-closed on $FENCED.
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "orderblind.sh: source drivers/env.sh" >&2; exit 2; }
L=$1; P=$2; shift 2; T=/tmp/r11u164_ob; mkdir -p $T
for m in "$@"; do
  c=${m%%/*}; r=${m#*/}; md=${r%%/*}; n=${r#*/}
  for f in $FENCED; do [ "$f" = "$n" ] && { echo "$m fenced, skipped"; continue 2; }; done
  a=$(ls -d $L/$c/$md/$n-*); b=$(ls -d $P/$c/$md/$n-*)
  $UHDM_DUMP $a/slang.uhdm 2>/dev/null | sed 1d | sed "s#$L#W#g" | sort > $T/a
  $UHDM_DUMP $b/slang.uhdm 2>/dev/null | sed 1d | sed "s#$P#W#g" | sort > $T/b
  d=$(diff $T/a $T/b | grep -c '^[<>]'); echo "$m orderblind_lines=$d"; diff $T/a $T/b | grep '^[<>]' | head -${SHOW:-6}
done
