#!/bin/bash
# (copy of r11u181repro/drivers/bvmirror.sh, with the downstream lane and the probe databases added)
# bvmirror.sh <sweep workdir> <mirror root> [subdirs]: hard-link every slang.uhdm of a gate sweep (the subdirs,
# default "surelog uhdm2rtlil"; "downstream" for the downstream lane, mirrored apart because a downstream database
# can be byte-identical to its corpus twin and byteverify's self-check assumes one duplicate at most) into a mirror tree, leaving out every path that names a fenced test (word boundary, from $FENCED;
# fail closed), so that tools/probe/r11v75repro/byteverify.sh never opens a fenced row's database.  Only path
# names are read here.
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "bvmirror.sh: export FENCED (drivers/env.sh)" >&2; exit 2; }
W=$1; M=$2; SUB=${3:-surelog uhdm2rtlil}; rm -rf $M; mkdir -p $M
fre=$(echo $FENCED | sed 's/ /|/g')
n=0; s=0
while read -r p; do
  if echo "$p" | grep -Eqw "$fre"; then s=$((s+1)); continue; fi
  mkdir -p "$M/$(dirname $p)"; ln "$W/$p" "$M/$p"; n=$((n+1))
done < <(cd $W && find $SUB -name slang.uhdm | sort)
echo "mirrored=$n fenced_skipped=$s"
