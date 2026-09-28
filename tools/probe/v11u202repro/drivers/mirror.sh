#!/bin/bash
# v11u202: hard-link every corpus slang.uhdm of a sweep workdir into a mirror, skipping any path naming a fenced test (fail closed)
source "$(dirname "$0")/env.sh" || exit 3
W=$1; M=$2; rm -rf $M; mkdir -p $M; n=0; s=0
while read -r p; do
  if echo "$p" | grep -Pq "$FENCERE"; then s=$((s+1)); continue; fi
  mkdir -p "$M/$(dirname $p)"; ln "$W/$p" "$M/$p"; n=$((n+1))
done < <(cd $W && find surelog uhdm2rtlil -name slang.uhdm | sort)
echo "mirrored=$n fenced_skipped=$s"
