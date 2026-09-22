#!/usr/bin/env bash
# r11u101 boundary-mover attribution.  usage: BND=<bnd101 outdir> PRIS=<bin> LAW=<bin> attr101.sh <arm-dir>
# trace count (R11U101_NETDBG on LAW), pristine self-repeat, R11U101_OFF=1 vs pristine, order-blind dump class
BND=${BND:?boundary outdir}; PRIS=${PRIS:?pristine binary}; LAW=${LAW:?law binary}
d=$1; n=$(grep -nxF "$d" $BND/arms.txt | cut -d: -f1); w=$BND/w$n
srcs=$(cd "$d" && ls *.sv *.v 2>/dev/null | tr '\n' ' ')
tr=$(cd "$d" && R11U101_NETDBG=1 $LAW $srcs --single-unit --nobuiltin -o $w/trace.uhdm 2>&1 </dev/null | grep -c '^R11U101'; true)
( cd "$d" && $PRIS $srcs --single-unit --nobuiltin -o $w/pris2.uhdm >/dev/null 2>&1 </dev/null )
( cd "$d" && R11U101_OFF=1 $LAW $srcs --single-unit --nobuiltin -o $w/off.uhdm >/dev/null 2>&1 </dev/null )
self=$(cmp -s $w/pris.uhdm $w/pris2.uhdm && echo same || echo SELF-NONDET)
offp=$(cmp -s $w/off.uhdm $w/pris.uhdm && echo off==pris || (cmp -s $w/off.uhdm $w/pris2.uhdm && echo off==pris2 || echo off!=pris))
D=/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump
diffl=$(diff <($D $w/pris.uhdm 2>&1 | sed 1d | sort) <($D $w/lawx.uhdm 2>&1 | sed 1d | sort) | grep '^[<>]')
nd=$(printf '%s\n' "$diffl" | grep -c '^[<>]'; true)
cls=$(printf '%s\n' "$diffl" | sed -E 's/^[<>] *//; s/:.*//' | sort | uniq -c | tr -s ' ' | tr '\n' ';')
echo "$(echo $d | sed 's#.*/tools/probe/##') trace=$tr $self $offp orderblind=$nd [$cls]"
printf '%s\n' "$diffl" | head -4 | sed 's/^/     /'
rm -f $w/trace.uhdm
