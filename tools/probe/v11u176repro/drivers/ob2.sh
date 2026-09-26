#!/bin/bash
# ob2.sh <abs case dir>: for tags P and L, record ob (strict) or dump ob (stage 1)
source /tmp/v11u176_env.sh
C=$(readlink -f $1); N=$(echo $C | sed 's|/tmp/v11u176_cases/||; s|.*/tools/probe/||'); K=$(echo $N | sed 's|/|__|g')
FILES=$( [ -f $C/files ] && cat $C/files || echo dut.sv )
KEY=$(cd $C && cat $FILES | sha1sum | cut -c1-16)-$(echo "$FILES" | tr '\n' ' ' | sha1sum | cut -c1-6); G=/tmp/v11u176_gold/$KEY/golden.uhdm
norm(){ sed -E 's/, id:[0-9]+//; s#/[^ ,:]*/([^/ ,:]+\.s?v)#\1#g; s/^ +//' ; }
out="$N"
for t in P L; do O=/tmp/v11u176_scr/caseout/$K.$t
  if [ -f $O/a.rec ]; then ob=$(comm -3 <(cut -f2- $O/a.rec | sort) <(cut -f2- $O/b.rec | sort) | wc -l); kind=rec
  else [ -f $O/gold.dump ] || $UHDM_DUMP $G 2>/dev/null | norm | sort > $O/gold.dump
       $UHDM_DUMP $O/ours.uhdm 2>/dev/null | norm | sort > $O/ours.dump
       ob=$(comm -3 $O/gold.dump $O/ours.dump | wc -l); kind=dump; fi
  out="$out $t:$kind:cmp=$(wc -l < $O/cmp.txt):ob=$ob"
done
echo $out
