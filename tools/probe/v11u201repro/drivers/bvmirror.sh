#!/bin/bash
# bvmirror.sh <sweep wd> <mirror dir> : symlink every slang.uhdm of the surelog + uhdm2rtlil stages into a mirror,
# leaving out the fenced tests (test dir = <name>-<hash>; fail closed on $FENCED)
. "$(cd "$(dirname "$0")" && pwd)/env.sh" || exit 3
S=$1; M=$2; rm -rf "$M"; mkdir -p "$M"; skipped=0; n=0
while read -r p; do t=$(echo "$p" | awk -F/ '{print $4}'); nm=${t%-*}
  fen=0; for f in $FENCED; do [ "$nm" = "$f" ] && fen=1; done
  if [ $fen = 1 ]; then skipped=$((skipped+1)); continue; fi
  mkdir -p "$M/$(dirname $p)"; ln -s "$S/$p" "$M/$p"; n=$((n+1))
done < <(cd "$S" && find ./surelog ./uhdm2rtlil -name slang.uhdm | sort)
echo "mirrored=$n fenced_skipped=$skipped"
