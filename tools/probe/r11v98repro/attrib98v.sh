#!/usr/bin/env bash
# v11u93 boundary attribution: for every MOVED arm, (a) does the law trace name
# a site, (b) does R11U98_OFF=1 reproduce the pristine database byte for byte,
# (c) does the PRISTINE binary disagree with ITSELF over three runs.
set -u
P=/tmp/v11u93_pris.bin; L=/tmp/v11u93_vfix.bin
cd /tmp/wt_v11u93
i=0
while read -r d; do
  i=$((i+1))
  w=/tmp/v11u93_att/w$i; mkdir -p $w
  srcs=$(cd "$d" && ls *.sv *.v 2>/dev/null | tr '\n' ' ')
  tr=$( (cd "$d" && R11U98_NETDBG=1 $L $srcs --single-unit --nobuiltin -o $w/t.uhdm 2>&1 </dev/null) | grep -o '^R11U98[A-Z]*' | sort -u | tr '\n' '+' )
  ( cd "$d" && $P $srcs --single-unit --nobuiltin -o $w/p1.uhdm >/dev/null 2>&1 </dev/null )
  ( cd "$d" && R11U98_OFF=1 $L $srcs --single-unit --nobuiltin -o $w/off.uhdm >/dev/null 2>&1 </dev/null )
  rev=NO
  cmp -s $w/p1.uhdm $w/off.uhdm && rev=YES
  coin=NO
  if [ "$rev" = NO ]; then
    ( cd "$d" && $P $srcs --single-unit --nobuiltin -o $w/p2.uhdm >/dev/null 2>&1 </dev/null )
    ( cd "$d" && $P $srcs --single-unit --nobuiltin -o $w/p3.uhdm >/dev/null 2>&1 </dev/null )
    cmp -s $w/p1.uhdm $w/p2.uhdm && cmp -s $w/p1.uhdm $w/p3.uhdm || coin=YES
  fi
  echo "$d trace=${tr:-NONE} off_reverts=$rev pris_self_disagrees=$coin"
done < /tmp/v11u93_movers.txt
