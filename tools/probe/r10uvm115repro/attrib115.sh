#!/usr/bin/env bash
# r10uvm115repro/attrib115.sh — ORDER-BLIND, PATH-NORMALISED attribution of
# every byte mover.  MEASUREMENT ONLY.  LHS is ALWAYS golden (Surelog);
# this script compares OUR pristine against OUR patched database and does not
# read golden at all — the golden direction is scored by fence115.sh.
#
#   attrib115.sh <pristine workdir> <patched workdir> [<out dir>]
#
# Scoreboard/default is a ~50/50 COIN per invocation (RESUME §9), so the diff
# MUST be order-blind: both dumps are path-normalised and SORTED before diff.
# A coin flip then reads as 0 differing lines and only the law's lines survive.
set -u
P=${1:?pristine workdir}; Q=${2:?patched workdir}; O=${3:-/tmp/r10uvm115_attrib}
mkdir -p "$O"
tot_rm=0; tot_add=0
for rel in $(cd "$Q" && find . -name slang.uhdm | sort); do
  a="$P/$rel"; b="$Q/$rel"
  [ -f "$a" ] && [ -f "$b" ] || { echo "SKIP-NOFILE $rel"; continue; }
  cmp -s "$a" "$b" && continue
  key=$(printf '%s' "$rel" | sed 's#^\./##; s#/#__#g')
  uhdm-dump "$a" 2>&1 | sed "s#$P##g; s#$Q##g; s#, id:[0-9]*##g" | LC_ALL=C sort > "$O/$key.p.txt"
  uhdm-dump "$b" 2>&1 | sed "s#$P##g; s#$Q##g; s#, id:[0-9]*##g" | LC_ALL=C sort > "$O/$key.q.txt"
  rm_n=$(diff "$O/$key.p.txt" "$O/$key.q.txt" | grep -c '^<' || true)
  ad_n=$(diff "$O/$key.p.txt" "$O/$key.q.txt" | grep -c '^>' || true)
  diff "$O/$key.p.txt" "$O/$key.q.txt" > "$O/$key.diff.txt" || true
  echo "MOVER $rel  removed=$rm_n added=$ad_n"
  echo "   -- removed line KINDS:"; grep '^<' "$O/$key.diff.txt" | sed 's/^< *//; s/[:(].*//' | sort | uniq -c | sed 's/^/      /'
  echo "   -- added   line KINDS:"; grep '^>' "$O/$key.diff.txt" | sed 's/^> *//; s/[:(].*//' | sort | uniq -c | sed 's/^/      /'
  tot_rm=$((tot_rm+rm_n)); tot_add=$((tot_add+ad_n))
done
echo "TOTAL removed=$tot_rm added=$tot_add"
