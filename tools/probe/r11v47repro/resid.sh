#!/bin/bash
# order-blind, path/number-normalised whole-dump residue + it_t line count
WD=${1:?}; shift
D=/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump
for m in default testflags; do
for t in "$@"; do
  d=$(ls -d "$WD/$m/$t-"* 2>/dev/null | head -1)
  [ -n "$d" ] || { echo "$m/$t NOFILE"; continue; }
  G=$(grep -o '/home/heyfey/.cache/slang-uhdm-goldens/[0-9a-f]*' "$d/cmds.txt" | head -1)
  [ -n "$G" ] || { echo "$m/$t NOGOLD"; continue; }
  timeout 900 $D "$G/golden.uhdm" 2>/dev/null | sed 's#/[^ ,]*/##g; s#[0-9]\+#N#g' | sort > /tmp/v11u47_rg.$$
  timeout 900 $D "$d/slang.uhdm"  2>/dev/null | sed 's#/[^ ,]*/##g; s#[0-9]\+#N#g' | sort > /tmp/v11u47_ro.$$
  tot=$(diff /tmp/v11u47_rg.$$ /tmp/v11u47_ro.$$ | grep -c '^[<>]'; true)
  itt=$(diff /tmp/v11u47_rg.$$ /tmp/v11u47_ro.$$ | grep '^[<>]' | grep -c 'it_t'; true)
  echo "$m/$t total=$tot it_t=$itt"
done
done
rm -f /tmp/v11u47_rg.$$ /tmp/v11u47_ro.$$
