#!/bin/bash
source $(dirname "${BASH_SOURCE[0]}")/env.sh
W=$1; M=$2; rm -rf $M; mkdir -p $M
n=0; s=0
while read -r p; do
  if echo "$p" | grep -qP "$FENCED_RE"; then s=$((s+1)); continue; fi
  mkdir -p "$M/$(dirname $p)"; ln "$W/$p" "$M/$p"; n=$((n+1))
done < <(cd $W && find surelog uhdm2rtlil -name slang.uhdm | sort)
echo "mirrored=$n fenced_skipped=$s"
