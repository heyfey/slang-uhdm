#!/bin/bash
# bvmirror.sh <sweep workdir> <mirror root>: hard-link corpus slang.uhdm into a mirror, leaving out fenced paths (fail closed)
. "$(dirname "$0")/env.sh" || exit 2
W=$1; M=$2; rm -rf $M; mkdir -p $M
fre=$(echo $FENCED | sed 's/ /|/g'); [ -n "$fre" ] || exit 2
n=0; s=0
while read -r p; do
  if echo "$p" | grep -Eqw "$fre"; then s=$((s+1)); continue; fi
  mkdir -p "$M/$(dirname $p)"; ln "$W/$p" "$M/$p"; n=$((n+1))
done < <(cd $W && find surelog uhdm2rtlil -name slang.uhdm | sort)
echo "mirrored=$n fenced_skipped=$s"
