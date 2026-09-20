#!/usr/bin/env bash
# order-blind attribution of one mover: sorted, path-normalised uhdm-dump diff
set -u
A=$1; B=$2; TAG=$3
D=/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump
timeout 600 $D "$A" | sed -E 's#/tmp/[a-z0-9_]+/#/WD/#g' | LC_ALL=C sort > /tmp/v11u68_at_a.txt
timeout 600 $D "$B" | sed -E 's#/tmp/[a-z0-9_]+/#/WD/#g' | LC_ALL=C sort > /tmp/v11u68_at_b.txt
n=$(diff /tmp/v11u68_at_a.txt /tmp/v11u68_at_b.txt | grep -cE '^[<>]' || true)
echo "$TAG order-blind diff lines: $n"
if [ "$n" != "0" ]; then
  diff /tmp/v11u68_at_a.txt /tmp/v11u68_at_b.txt | grep -E '^[<>]' | head -12
  echo "  vpiSize lines: $(diff /tmp/v11u68_at_a.txt /tmp/v11u68_at_b.txt | grep -cE '^[<>].*vpiSize:' || true)"
  echo "  vpiConstType lines: $(diff /tmp/v11u68_at_a.txt /tmp/v11u68_at_b.txt | grep -cE '^[<>].*vpiConstType:' || true)"
fi
