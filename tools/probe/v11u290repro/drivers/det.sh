#!/bin/bash
# v11u290 det.sh <wd> <binary> <outdir> <row>...: three CONCURRENT draws per row-mode (default, testflags) with
# drivers/rerow.sh; prints the distinct md5s per row-mode and the md5 of <wd>'s own database. Fail-closed on $FENCED.
[ -n "$FENCED" ] && [ "$(echo $FENCED | wc -w)" = 4 ] || { echo "det.sh: source drivers/env.sh" >&2; exit 2; }
D=$(cd "$(dirname "$0")" && pwd); wd=$1; b=$2; o=$3; shift 3; mkdir -p $o
for r in "$@"; do
  for n in $FENCED; do [ "$r" = "$n" ] && { echo "det.sh: fenced refused" >&2; exit 2; }; done
  for m in default testflags; do
    ls -d $wd/surelog/$m/$r-* >/dev/null 2>&1 || continue
    for k in 1 2 3; do bash $D/rerow.sh $wd $r $m $b $o/$r.$m.$k.uhdm > $o/$r.$m.$k.rc & done; wait
    sw=$(md5sum < $(ls -d $wd/surelog/$m/$r-*)/slang.uhdm 2>/dev/null | cut -c1-12)
    echo "$r $m draws: $(for k in 1 2 3; do [ -s $o/$r.$m.$k.uhdm ] && md5sum < $o/$r.$m.$k.uhdm | cut -c1-12 || echo none; done | sort | uniq -c | tr '\n' ' ') sweep: ${sw:-none} rcs: $(cat $o/$r.$m.*.rc | tr '\n' ' ')"
  done
done
