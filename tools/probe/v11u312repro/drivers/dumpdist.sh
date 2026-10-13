#!/bin/bash
# v11u312 dumpdist.sh <movers file (MOVER <case> <view>: ...)> <cases root> <pristine> <law>: for each mover, the
# uhdm-dump line distance golden->pristine and golden->law (diff lines, parents included, which the strict walk does
# not key on): `<case> <view> dump P=<n> L=<n> <TOWARD|AWAY|SAME>`.  Fail-closed on $FENCED.
[ -n "$FENCED" ] && [ "$(echo $FENCED | wc -w)" = 4 ] || { echo "dumpdist: FENCED unset" >&2; exit 2; }
[ -x "$UHDM_DUMP" ] || { echo "dumpdist: UHDM_DUMP" >&2; exit 2; }
H=$(cd "$(dirname "$0")" && pwd); M=$1; CR=$(cd "$2" && pwd); P=$3; L=$4; T=/tmp/v11u312_dd.$$; mkdir -p $T
grep '^MOVER' $M | while read -r _ c v _; do v=${v%:}; d=$CR/$c
  for n in $FENCED; do echo "$d" | grep -qw "$n" && { echo "fenced" >&2; exit 2; }; done
  rm -f $T/p.uhdm $T/l.uhdm
  KEEP=$T/p.uhdm bash $H/case.sh $d $P $v >/dev/null; KEEP=$T/l.uhdm bash $H/case.sh $d $L $v >/dev/null
  h=$( (cd $d && find . -maxdepth 1 -type f \( -name '*.sv' -o -name '*.svh' -o -name '*.v' \) | sort | xargs cat) | md5sum | cut -c1-16)$v
  g=${R312_GOLD:-/tmp/v11u312_gold}/$h/g.uhdm
  [ -s $g ] && [ -s $T/p.uhdm ] && [ -s $T/l.uhdm ] || { echo "$c $v dump MISSING"; continue; }
  $UHDM_DUMP $g > $T/g.txt 2>/dev/null; $UHDM_DUMP $T/p.uhdm > $T/p.txt 2>/dev/null; $UHDM_DUMP $T/l.uhdm > $T/l.txt 2>/dev/null
  a=$(diff $T/g.txt $T/p.txt | grep -c '^[<>]'); b=$(diff $T/g.txt $T/l.txt | grep -c '^[<>]')
  r=SAME; [ $b -lt $a ] && r=TOWARD; [ $b -gt $a ] && r=AWAY
  echo "$c $v dump P=$a L=$b $r"
done
rm -rf $T
