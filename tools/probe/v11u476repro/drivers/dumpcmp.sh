#!/bin/bash
# dumpcmp.sh <name>: path-normalized uhdm-dump of the law and control probe db, prints name if differ
source /tmp/v11u476_env.sh >/dev/null || exit 1
n=$1
a=$($UHDM_DUMP /tmp/v11u476_lw/probe/$n 2>/dev/null | sed -E 's#[^ ,:]*/##g' | tail -n +2 | md5sum)
b=$($UHDM_DUMP /tmp/intr11u474/probe/$n 2>/dev/null | sed -E 's#[^ ,:]*/##g' | tail -n +2 | md5sum)
[ "$a" = "$b" ] || echo "DIFF $n"
