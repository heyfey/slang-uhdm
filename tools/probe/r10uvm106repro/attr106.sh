#!/bin/bash
# attr106.sh <ship-workdir> <pristine-workdir> [names...] : ORDER-BLIND,
# path- and id-normalised whole-dump attribution for every moved database.
# Partial-dump safe (dumps are re-read to byte-stability by uhdm-dump itself).
set -u
S=${1:?ship wd}; P=${2:?pris wd}; shift 2
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
norm() { sed -E -e 's/id:[0-9]+//g' -e 's#/tmp/[^ ,)]*##g' -e 's/, line:[0-9:]+, endln:[0-9:]+//' ; }
for mode in default testflags; do
  for d in "$S/$mode"/*/; do
    n=$(basename "$d"); o="$P/$mode/$n"
    [ -f "$d/slang.uhdm" ] && [ -f "$o/slang.uhdm" ] || continue
    cmp -s "$d/slang.uhdm" "$o/slang.uhdm" && continue
    if [ $# -gt 0 ]; then case " $* " in *" ${n%%-*} "*) ;; *) continue;; esac; fi
    "$DUMP" "$o/slang.uhdm" 2>/dev/null | norm | sort > ${TMPDIR:-/tmp}/r10uvm106_attr.p.$$
    "$DUMP" "$d/slang.uhdm" 2>/dev/null | norm | sort > ${TMPDIR:-/tmp}/r10uvm106_attr.s.$$
    echo "=== $mode/$n"
    diff ${TMPDIR:-/tmp}/r10uvm106_attr.p.$$ ${TMPDIR:-/tmp}/r10uvm106_attr.s.$$ | grep -E '^[<>]' | sort | uniq -c | sort -rn
    rm -f ${TMPDIR:-/tmp}/r10uvm106_attr.p.$$ ${TMPDIR:-/tmp}/r10uvm106_attr.s.$$
  done
done
