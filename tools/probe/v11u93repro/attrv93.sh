#!/usr/bin/env bash
# v11u93 mover attribution.  usage: PRIS=<bin> LAW=<bin> [S=<scratch>] attrv93.sh <arm-dir>...
# pristine x3 (SELF-NONDET), law with the R11U101 trace, law with R11U101_OFF=1
# (off==law hash => the move is the BINARY IMAGE, not the law), order-blind sorted dump diff.
set -u
PRIS=${PRIS:?pristine binary}; LAW=${LAW:?law binary}; S=${S:-/tmp/v11u93_attr}
D=/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump
for d in "$@"; do
  s=$S/$(echo $d | md5sum | cut -c1-8); mkdir -p $s
  srcs=$(cd "$d" && ls *.sv *.v 2>/dev/null | tr '\n' ' ')
  for k in 1 2 3; do ( cd "$d" && $PRIS $srcs --single-unit --nobuiltin -o $s/p$k.uhdm > /dev/null 2>&1 </dev/null ); done
  ( cd "$d" && R11U101_NETDBG=1 $LAW $srcs --single-unit --nobuiltin -o $s/f.uhdm > $s/f.log 2>&1 </dev/null )
  ( cd "$d" && $LAW $srcs --single-unit --nobuiltin -o $s/f2.uhdm > /dev/null 2>&1 </dev/null )
  ( cd "$d" && R11U101_OFF=1 $LAW $srcs --single-unit --nobuiltin -o $s/o.uhdm > /dev/null 2>&1 </dev/null )
  h() { md5sum < $1 | cut -c1-8; }
  ps="$(h $s/p1.uhdm) $(h $s/p2.uhdm) $(h $s/p3.uhdm)"; np=$(echo $ps | tr ' ' '\n' | sort -u | wc -l)
  tr=$(grep -c R11U101NEST $s/f.log; true)
  $D $s/p1.uhdm 2>/dev/null | sed "s#$s/p1.uhdm##" | sort > $s/p.srt; $D $s/f2.uhdm 2>/dev/null | sed "s#$s/f2.uhdm##" | sort > $s/f.srt
  ob=$(diff $s/p.srt $s/f.srt | grep -c '^[<>]'; true)
  cls=$(diff $s/p.srt $s/f.srt | grep '^[<>]' | sed 's/^[<>] *//; s/:.*//' | sort | uniq -c | tr -s ' ' | tr '\n' ';')
  vals=$(diff $s/p.srt $s/f.srt | grep '^[<>] *|UINT' | sed 's/^\([<>]\).*UINT:/\1/' | tr '\n' ' ' | cut -c1-80)
  echo "${d} pris3=[$ps] distinct=$np fixd=$(h $s/f2.uhdm) off=$(h $s/o.uhdm) trace=$tr orderblind=$ob [$cls] $vals"
done
