#!/bin/bash
# dumpdist.sh <law sweep> <pristine sweep> <corpus/mode/dir>...: order-blind uhdm-dump distance to
# golden (sorted dump lines not in golden, workdir paths normalised) for pristine and law, and the
# order-blind pristine-vs-law line count.  Fail-closed on $FENCED.
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "dumpdist.sh: export FENCED" >&2; exit 2; }
L=$1; P=$2; shift 2; T=${TMPD:-/tmp/r11u160_dd}; mkdir -p $T
for m in "$@"; do
  c=${m%%/*}; rest=${m#*/}; md=${rest%%/*}; d=${rest#*/}; n=${d%-*}
  for f in $FENCED; do [ "$f" = "$n" ] && { echo "$m fenced, skipped"; continue 2; }; done
  g=$(grep -o 'golden cache hit [^)]*' $L/$c/$md/$d/cmds.txt | awk '{print $4}')/golden.uhdm
  norm() { $UHDM_DUMP $1 2>/dev/null | sed -e "s#$L#WD#g; s#$P#WD#g; s#, id:[0-9]*##g" | sort; }
  norm $g > $T/g; norm $P/$c/$md/$d/slang.uhdm > $T/p; norm $L/$c/$md/$d/slang.uhdm > $T/l
  dp=$(comm -13 $T/g $T/p | wc -l); dl=$(comm -13 $T/g $T/l | wc -l); pl=$(comm -3 $T/p $T/l | wc -l)
  echo "$m | not-in-golden: pristine=$dp law=$dl | pristine-vs-law lines=$pl"
done
