#!/bin/bash
# r11u47 — ORDER-BLIND whole-dump residue (golden vs ours), path-normalised,
# with the `it_t` sub-count.  Arg1: sweep workdir, arg2: tag.
W=$1; TAG=$2
D=/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump
for d in "$W"/default/*/; do
  [ -f "$d/slang.uhdm" ] || continue
  G=$(grep -o 'golden cache hit [^)]*' "$d/cmds.txt" | awk '{print $4}')
  [ -n "$G" ] || continue
  n=$(basename "$d"); n=${n%-*}
  "$D" "$G/golden.uhdm" 2>/dev/null | sed 's#/tmp/[^ ,]*##g; s#[0-9]\+#N#g' | sort > /tmp/r11u47_rg.$$
  "$D" "$d/slang.uhdm"  2>/dev/null | sed 's#/tmp/[^ ,]*##g; s#[0-9]\+#N#g' | sort > /tmp/r11u47_ro.$$
  tot=$(diff /tmp/r11u47_rg.$$ /tmp/r11u47_ro.$$ | grep -c '^[<>]'; true)
  itt=$(diff /tmp/r11u47_rg.$$ /tmp/r11u47_ro.$$ | grep '^[<>]' | grep -c 'it_t'; true)
  echo "$TAG $n total=$tot it_t-lines=$itt"
done
rm -f /tmp/r11u47_rg.$$ /tmp/r11u47_ro.$$
