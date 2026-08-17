#!/usr/bin/env bash
# r10rgg4/foldbnd.sh — the FOLD-LAW FAMILY boundary: every committed probe source
# of r10earl49/51/52/55 (the adjustSize + typespec-PRESENCE laws § earl52 names
# as ADJACENT) run through BOTH binaries, dumps compared BYTE FOR BYTE.
#
#   usage: BASE=<bin> PAT=<bin> ./foldbnd.sh
#
# `attrib.py`-style scoring would be blind here: these arms are about param
# folds, not ranges.  A whole-dump byte compare is the widest possible net and
# the right one for a boundary: § sizeDimOvrChain4 must move NOTHING in them.
#
# GUARDS: (1) a source that produces NO database on either side prints NO-DB and
# is COUNTED; (2) uhdm-dump's first line is the DATABASE PATH and always differs,
# so it is stripped on both sides; (3) a POSITIVE CONTROL (`CTRL=1`) compares
# each PAT dump against the WRONG source's BASE dump and must flag every pair.
set -u
BASE=${BASE:?}; PAT=${PAT:?}
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
here=$(cd "$(dirname "$0")" && pwd)
P=$(cd "$here/.." && pwd)
wd=/tmp/r10rgg5_foldbnd; rm -rf $wd; mkdir -p $wd
n=0; mov=0; nodb=0
for g in r10earl49repro r10earl51repro r10earl52repro r10earl55repro; do
  for f in $P/$g/*.sv; do
    [ -f "$f" ] || continue
    c=$g-$(basename "$f" .sv)
    mkdir -p $wd/$c && cd $wd/$c
    ok=1
    for tag in b p; do
      bin=$BASE; [ $tag = p ] && bin=$PAT
      "$bin" --single-unit --elabuhdm "$f" -o o_$tag.uhdm > o_$tag.log 2>&1
      if [ ! -s o_$tag.uhdm ]; then ok=0; continue; fi
      "$DUMP" o_$tag.uhdm 2>&1 | sed 1d > d_$tag.txt
    done
    n=$((n+1))
    if [ $ok -eq 0 ]; then echo "NO-DB   $c"; nodb=$((nodb+1)); continue; fi
    if ! cmp -s d_b.txt d_p.txt; then
      echo "MOVER   $c  ($(diff d_b.txt d_p.txt | grep -c '^[<>]') dump line-sides)"
      mov=$((mov+1))
    fi
  done
done
echo "FOLD-BOUNDARY: sources=$n movers=$mov no-database=$nodb"
if [ "${CTRL:-0}" = 1 ]; then
  # POSITIVE CONTROL: cross-compare each PAT dump with a DIFFERENT source's BASE.
  cells=$(cd $wd && ls -d */ | tr -d /); arr=($cells); k=${#arr[@]}; flagged=0; cmp_n=0
  for i in $(seq 0 $((k-1))); do
    j=$(( (i+1) % k ))
    a=$wd/${arr[$i]}/d_p.txt; b=$wd/${arr[$j]}/d_b.txt
    [ -f "$a" ] && [ -f "$b" ] || continue
    cmp_n=$((cmp_n+1)); cmp -s "$a" "$b" || flagged=$((flagged+1))
  done
  echo "CTRL (each PAT dump vs the NEXT source's BASE dump): $flagged / $cmp_n flagged"
fi
