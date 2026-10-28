#!/bin/bash
# path-normalized dump compare of every probe database: law sweep vs master's control
source /tmp/r11u452_env.sh
[ -x "$UHDM_DUMP" ] || exit 2
n=0; m=0
for f in /tmp/intr11u450/probe/*.uhdm; do
  b=$(basename $f); n=$((n+1))
  a=$($UHDM_DUMP $f 2>/dev/null | sed -E 's#/home/heyfey/git-repos/slang-uhdm/##g; s#/tmp/wt_r11u452/##g; s#/tmp/[a-z0-9_]+/##g' | md5sum)
  c=$($UHDM_DUMP /tmp/r11u452swp/probe/$b 2>/dev/null | sed -E 's#/home/heyfey/git-repos/slang-uhdm/##g; s#/tmp/wt_r11u452/##g; s#/tmp/[a-z0-9_]+/##g' | md5sum)
  [ "$a" = "$c" ] || { m=$((m+1)); echo "MOVER $b"; }
done
echo "probe normalized-dump movers $m of $n"
