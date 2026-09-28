#!/bin/bash
# mirror.sh <sweep workdir> <mirror root>: hard-link every corpus slang.uhdm (surelog, uhdm2rtlil) and probe out db,
# leaving out paths naming a fenced test (word boundary, fail closed). Only path names are read.
. "$(dirname "$0")/env.sh" || exit 2
W=$1; M=$2; rm -rf $M; mkdir -p $M
fre=$(echo $FENCED | sed 's/ /|/g'); n=0; s=0
while read -r p; do
  if echo "$p" | grep -Eqw "$fre"; then s=$((s+1)); continue; fi
  mkdir -p "$M/$(dirname $p)"; ln "$W/$p" "$M/$p"; n=$((n+1))
done < <(cd $W && find surelog uhdm2rtlil -name slang.uhdm | sort)
echo "mirrored=$n fenced_skipped=$s"
