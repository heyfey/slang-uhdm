#!/bin/bash
# v11u215: judge the wide-control movers with pris and law (case.sh), then chain-keyed and raw full-name away censuses.
# usage: judgemv.sh <wide output> <tag>   (ELAB=1 for the elaborated view)
. "$(dirname "${BASH_SOURCE[0]:-$0}")/env.sh" || exit 3
V() { awk '{ if ($1=="SLANG_FAIL"||$1=="SURELOG_FAIL") print $1; else if ($3=="STRICT_EQUAL") print "EQUAL"; else if ($3=="NOT_EQUAL") print "NOT_EQUAL"; else print $3":"$4 }'; }
one() { c=$1; k=$(echo "$c" | md5sum | cut -c1-12); W=/tmp/v11u215_jmv_$TAG${ELAB:+_elab}/$k; line="${c#$WT/tools/probe/}"
  for b in pris law; do v=$(SLANG_UHDM=$B/$b.bin bash $V215/case.sh $c $W/$b 2>/dev/null | V); n=$(grep -o 'objects_differing=[0-9]*' $W/$b/strict.txt 2>/dev/null | cut -d= -f2); [ -n "$n" ] && v="$v($n)"; line="$line	$b=$v"; done
  if [ -s $W/pris/ours.uhdm ] && [ -s $W/law/ours.uhdm ]; then
    line="$line	$(SCMP=$SCMP python3 $V215/awaychain.py $W/pris/golden.uhdm $W/pris/ours.uhdm $W/law/ours.uhdm)	$(python3 $V215/fnaway.py $W/pris/g.dump $W/pris/o.dump $W/law/o.dump)"; fi
  echo "$line"; }
export -f one V; export TAG ELAB
grep ' MOVED ' $1 | awk '{print $1}' | xargs -P3 -I{} bash -c 'one {}' | sort
