#!/bin/bash
# (copy of r11u171repro/drivers/bvmirror.sh)
# (copy of r11u159verify/drivers/bvmirror.sh via r11u161gen) bvmirror.sh <sweep workdir> <mirror root>: hard-link every corpus slang.uhdm of a gate sweep into a mirror
# tree, leaving out every path that names a fenced test (word boundary, from $FENCED; fail closed), so that
# tools/probe/r11v75repro/byteverify.sh never opens a fenced row's database.  Only path names are read here.
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "bvmirror.sh: export FENCED (drivers/env.sh)" >&2; exit 2; }
W=$1; M=$2; rm -rf $M; mkdir -p $M
fre=$(echo $FENCED | sed 's/ /|/g')
n=0; s=0
while read -r p; do
  if echo "$p" | grep -Eqw "$fre"; then s=$((s+1)); continue; fi
  mkdir -p "$M/$(dirname $p)"; ln "$W/$p" "$M/$p"; n=$((n+1))
done < <(cd $W && find surelog uhdm2rtlil -name slang.uhdm | sort)
echo "mirrored=$n fenced_skipped=$s"
