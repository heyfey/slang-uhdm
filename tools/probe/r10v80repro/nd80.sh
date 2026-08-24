#!/usr/bin/env bash
# r10v80 — NONDETERMINISM ADJUDICATOR for a per-directory boundary mover.
# For a directory D and a view: run the PRISTINE binary N times and the PATCHED
# binary N times, and report (a) the raw normalised-dump hash per run,
# (b) the ORDER-BLIND (sorted) dump hash per run, (c) the param_assign census
# hash per run.  MEASUREMENT ONLY.
set -u
D=$1; VIEW=$2; N=${3:-3}
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
CEN=/tmp/v80_arms/vpacen80
case $VIEW in plain) F="";; elab) F="--elabuhdm";; esac
for side in PRIS PATC; do
  case $side in PRIS) BIN=/tmp/v80_bin/pris_f00c80b5.bin;; PATC) BIN=/tmp/v80_bin/patc_d25629a1.bin;; esac
  for i in $(seq 1 $N); do
    w=/tmp/v80_nd/$(basename $D)_${VIEW}_${side}_$i; rm -rf $w; mkdir -p $w
    cp "$D"/*.sv "$w/" 2>/dev/null; cp "$D"/*.v "$w/" 2>/dev/null
    ( cd $w && $BIN $F $(ls *.sv *.v 2>/dev/null) -o slang.uhdm >slang.log 2>&1 </dev/null )
    [ -f $w/slang.uhdm ] || { echo "$side/$i NO_DB"; continue; }
    $DUMP $w/slang.uhdm 2>/dev/null | sed '1d' | sed "s#$w#WD#g" > $w/o.norm
    raw=$(md5sum < $w/o.norm | cut -c1-10)
    srt=$(sort $w/o.norm | md5sum | cut -c1-10)
    $CEN $w/slang.uhdm 2>/dev/null | sort > $w/pa
    pa=$(md5sum < $w/pa | cut -c1-10)
    echo "$side/$i raw=$raw sorted=$srt pa=$pa"
    rm -f $w/slang.uhdm
  done
done
