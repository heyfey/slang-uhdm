#!/bin/bash
# vgrid.sh <casedir>...: pristine / law / verified (frozen under /tmp/v11u455_bin) per case:
# rc, uhdm-cmp lines, strict verdict, md5, and the call-link census against golden
# (matched links lost / gained vs pristine; links.cpp multiset).
D=$(cd $(dirname $0) && pwd); L=/tmp/v11u455_tools/links
[ -x $L ] || { echo "no links tool"; exit 2; }
for c in "$@"; do
  cc=$(cd $c && pwd); h=$(cat $(ls -d $cc/* | sort) | md5sum | cut -c1-12)
  g=/tmp/v11u455_scr/gold/$h/slpp_all/surelog.uhdm; k=$(echo $cc | sed "s|.*/tools/probe/||; s|/|_|g")
  line="$(echo $c | sed 's|.*cases/||')"
  for b in pristine law ver; do
    [ -x /tmp/v11u455_bin/$b ] || continue
    r=$($D/run1.sh $c /tmp/v11u455_bin/$b $b | cut -d' ' -f2-)
    o=/tmp/v11u455_scr/out/$k/$b/ours.uhdm
    if [ -f $g ] && [ -s $o ]; then $L $g | sort > /tmp/v11u455_vg_g.$$; $L $o | sort > /tmp/v11u455_vg_$b.$$
      comm -12 /tmp/v11u455_vg_g.$$ /tmp/v11u455_vg_$b.$$ > /tmp/v11u455_vg_m$b.$$
      if [ $b = pristine ]; then ex=""; else ex=" lost=$(comm -23 /tmp/v11u455_vg_mpristine.$$ /tmp/v11u455_vg_m$b.$$ | wc -l) gained=$(comm -13 /tmp/v11u455_vg_mpristine.$$ /tmp/v11u455_vg_m$b.$$ | wc -l)"; fi
      r="$r links-g-only=$(comm -23 /tmp/v11u455_vg_g.$$ /tmp/v11u455_vg_$b.$$ | wc -l)$ex"; fi
    line="$line | $b: $r"
  done
  rm -f /tmp/v11u455_vg_*.$$
  echo "$line"
done
