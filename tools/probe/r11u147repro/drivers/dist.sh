#!/bin/bash
# dist.sh <pristine wd> <law wd> <rows file>: order-blind uhdm-dump distance to golden (lines of the
# sorted-dump symmetric difference, file paths reduced to basenames) for pristine and law.
source /tmp/r11u147_env.sh
P=$1; L=$2; T=$(mktemp -d /tmp/r11u147_dist.XXXX)
norm(){ $UHDM_DUMP "$1" 2>/dev/null | sed -E 's#(file:)[^,]*/#\1#; s#/[^ ,]*/([^/ ,]+\.(sv|v|svh|vh))#\1#g' | sort; }
while read -r r; do
  c=${r%%/*}; rest=${r#*/}; m=${rest%%/*}; t=${rest#*/}; t=${t%-*}
  set -- $($(dirname $0)/rowpaths.sh $P $c $m $t); g=$1; p=$2
  set -- $($(dirname $0)/rowpaths.sh $L $c $m $t); l=$2
  norm $g > $T/g; norm $p > $T/p; norm $l > $T/l
  dp=$(diff $T/g $T/p | grep -c '^[<>]'); dl=$(diff $T/g $T/l | grep -c '^[<>]'); dd=$(diff $T/p $T/l | grep -c '^[<>]')
  v=SAME; [ $dl -lt $dp ] && v=TOWARD; [ $dl -gt $dp ] && v=AWAY
  echo "$c/$m/$t pristine_dist=$dp law_dist=$dl moved_lines=$dd $v"
done < $3
rm -rf $T
