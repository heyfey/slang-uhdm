#!/bin/bash
# linkcensus.sh <casedir>...: call-link multiset distance (golden-only + ours-only link lines) for pristine and law
L=/tmp/v11u460_tools/links; [ -x "$L" ] || { echo "no links tool"; exit 1; }
for c in "$@"; do
  c=$(realpath "$c"); W=/tmp/v11u460_runs$c
  $L $W/sl/slpp_all/surelog.uhdm 2>/dev/null | sort > $W/lk_g.txt
  out="${c#*/cases/}"
  for t in pris law ver; do [ -f $W/$t.uhdm ] || continue;
    [ -f $W/$t.uhdm ] || continue
    $L $W/$t.uhdm 2>/dev/null | sort > $W/lk_$t.txt
    out="$out $t: g-only=$(comm -23 $W/lk_g.txt $W/lk_$t.txt | wc -l) o-only=$(comm -13 $W/lk_g.txt $W/lk_$t.txt | wc -l)"
  done
  echo "$out total=$(wc -l < $W/lk_g.txt)"
done
