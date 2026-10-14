#!/bin/bash
# v11u319 dd.sh <ptag> <ltag> <rel>...: the uhdm-dump distance (diff lines against golden's dump) of <ptag> and <ltag>
# under $S/g/<rel>; FARTHER when <ltag>'s is larger. Guarded tool variable; fail-closed on $FENCED.
[ "$(echo $FENCED | wc -w)" = 4 ] && [ -x "$UHDM_DUMP" ] || { echo "dd.sh: source drivers/env.sh" >&2; exit 2; }
pt=$1; lt=$2; shift 2
for rel in "$@"; do
  for n in $FENCED; do echo "$rel" | grep -qw "$n" && { echo "dd.sh: fenced refused" >&2; exit 2; }; done
  w=$S/g/$rel; g=$(ls $w/gold_*/golden.uhdm 2>/dev/null | head -1); [ -s "$g" ] || { echo "$rel nogold"; continue; }
  "$UHDM_DUMP" $g 2>/dev/null | tail -n +2 > $w/g.dump; "$UHDM_DUMP" $w/$pt.uhdm 2>/dev/null | tail -n +2 > $w/$pt.dump; "$UHDM_DUMP" $w/$lt.uhdm 2>/dev/null | tail -n +2 > $w/$lt.dump
  dp=$(diff $w/g.dump $w/$pt.dump | grep -c '^[<>]'); dl=$(diff $w/g.dump $w/$lt.dump | grep -c '^[<>]')
  echo "$rel dumpdist $pt=$dp $lt=$dl $([ $dl -gt $dp ] && echo FARTHER || ([ $dl -lt $dp ] && echo closer || echo same))"
done
