#!/bin/bash
# switchcheck.sh <pristine> <law> <verified> <casedir>...: per case dir the exit codes,
# whether verified == law, R11U464_OFF on verified == pristine (bytes and rc),
# R11V464_OFF on verified == law, the firing laws (R11U464_TRACE) and which single
# law switch alone restores pristine's bytes when the case moved.
A=$1; L=$2; B=$3; shift 3
SW="R11U464_UNITIMPTRANS_OFF R11U464_UNITTFDEDUP_OFF R11U464_UNITCLSBASE_OFF R11U464_CLSSRALIAS_OFF R11U464_CLSNESTUNSIZED_OFF R11U464_CLSINNERELEM_OFF"
for c in "$@"; do
  [ -d "$c" ] || continue
  c=$(realpath "$c")
  W=/tmp/v11u464_sc$c; mkdir -p $W/tr; rm -f $W/*.uhdm $W/tr/*
  F=dut.sv; [ -f $c/FILES ] && F=$(cat $c/FILES)
  (cd $c && "$A" $F --single-unit --nobuiltin -o $W/p.uhdm >/dev/null 2>&1 </dev/null); rp=$?
  (cd $c && "$L" $F --single-unit --nobuiltin -o $W/l.uhdm >/dev/null 2>&1 </dev/null); rl=$?
  (cd $c && R11U464_TRACE=$W/tr "$B" $F --single-unit --nobuiltin -o $W/v.uhdm >/dev/null 2>&1 </dev/null); rv=$?
  (cd $c && R11U464_OFF=1 "$B" $F --single-unit --nobuiltin -o $W/o.uhdm >/dev/null 2>&1 </dev/null); ro=$?
  (cd $c && R11V464_OFF=1 "$B" $F --single-unit --nobuiltin -o $W/f.uhdm >/dev/null 2>&1 </dev/null)
  fires=$(cat $W/tr/* 2>/dev/null | grep -v '^OUT' | awk '{print $1}' | sort -u | tr '\n' ',')
  moved=same; cmp -s $W/p.uhdm $W/v.uhdm || moved=MOVED
  vl=$(cmp -s $W/l.uhdm $W/v.uhdm && echo ver=law || echo ver!=law)
  off=$(cmp -s $W/p.uhdm $W/o.uhdm && [ $rp = $ro ] && echo off=pristine || echo off=DIFF)
  voff=$(cmp -s $W/l.uhdm $W/f.uhdm && echo voff=law || echo voff=DIFF)
  own=""
  if [ $moved = MOVED ]; then
    for s in $SW; do
      rm -f $W/s.uhdm
      (cd $c && env $s=1 "$B" $F --single-unit --nobuiltin -o $W/s.uhdm >/dev/null 2>&1 </dev/null)
      cmp -s $W/p.uhdm $W/s.uhdm && own="$own ${s#R11U464_}"
    done
  fi
  echo "${c#*/tools/probe/} rc $rp/$rl/$rv $moved $vl $off $voff fires=$fires restored-by:${own:- none-alone}"
done
