#!/bin/bash
# v11u215: judge case dirs with pris.bin, law.bin and law.bin under R11U215_OFF=1 (+ EXTRA="NAME:ENV=1 ...").
# usage: grid.sh <root dir holding case dirs> <tag>   (ELAB=1 for the elaborated form) -> tsv on stdout
. "$(dirname "${BASH_SOURCE[0]:-$0}")/env.sh" || exit 3
ROOT=$(cd "$1" && pwd); TAG=$2
V() { awk '{ if ($1=="SLANG_FAIL"||$1=="SURELOG_FAIL") print $1; else if ($3=="STRICT_EQUAL") print "EQUAL"; else if ($3=="NOT_EQUAL") print "NOT_EQUAL"; else print $3":"$4 }'; }
one() { c=$1; r=${c#$ROOT/}; line="$r"; W=/tmp/v11u215_grid_${TAG}${ELAB:+_elab}
  for spec in pris:pris.bin: law:law.bin: off:law.bin:R11U215_OFF=1 $EXTRA; do
    n=${spec%%:*}; rest=${spec#*:}; b=${rest%%:*}; e=${rest#*:}; [ "$b" = "$rest" ] && e=
    o=$W/$n/$r
    v=$(env $e SLANG_UHDM=$B/$b bash $V215/case.sh $c $o 2>/dev/null | V)
    k=$(grep -o 'objects_differing=[0-9]*' $o/strict.txt 2>/dev/null | cut -d= -f2); [ -n "$k" ] && v="$v($k)"
    rc=$(tail -1 $o/slang.log 2>/dev/null)
    m=$(md5sum < $o/ours.uhdm 2>/dev/null | cut -c1-6)
    line="$line	$n=$v[$m,$rc]"; done
  echo "$line"; }
export -f one V; export ROOT TAG ELAB EXTRA
find $ROOT -type f \( -name dut.sv -o -name args \) -printf '%h\n' | sort -u | while read d; do for f in $FENCED; do grep -qw "$f" <<< "$d" && { echo "fenced $d" >&2; exit 3; }; done; echo $d; done | xargs -P3 -I{} bash -c 'one {}' | sort
