#!/usr/bin/env bash
# r11u103 grid differ: per-arm cmp lines, md5 and ours rc for tag A vs tag B (rr103.sh result files <grid>.<tag>.txt); segfault notices from the shell are skipped.
# usage: cmpgrid.sh <tagA> <tagB> <grid-result-prefix>...  per-arm movers (md5) + totals
A=$1; B=$2; shift 2
for g in "$@"; do
  join <(awk '{c="NA";m="NA";r="NA";for(i=1;i<=NF;i++){if($i~/^cmplines=/)c=substr($i,10); if($i~/^md5=/)m=substr($i,5); if(m=="")m="none"; if($i~/^ours_rc=/)r=$i} if($1 !~ /\//) print $1,c,m,r}' $g.$A.txt|sort) \
       <(awk '{c="NA";m="NA";r="NA";for(i=1;i<=NF;i++){if($i~/^cmplines=/)c=substr($i,10); if($i~/^md5=/)m=substr($i,5); if(m=="")m="none"; if($i~/^ours_rc=/)r=$i} if($1 !~ /\//) print $1,c,m,r}' $g.$B.txt|sort) |
  awk -v g=$g '{ta+=$2; tb+=$5; if($3!=$6||$4!=$7){n++; printf "  MOVER %s/%s %s->%s %s->%s\n", g,$1,$2,$5,$4,$7}} END{printf "%s arms=%d %s->%s movers=%d\n", g, NR, ta, tb, n}'
done
