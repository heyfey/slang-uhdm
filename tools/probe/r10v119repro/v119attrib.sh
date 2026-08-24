#!/usr/bin/env bash
# r10v119repro — see README.md §"How to re-run". MEASUREMENT ONLY.
set -u
PAT=${PAT:?patched verify_golden workdir root (…/sl)}
PRIS=${PRIS:?pristine verify_golden workdir root (…/sl)}
DUMP=$HOME/.local/bin/uhdm-dump
OUT=${OUT:-/tmp/v119_attrib}
mkdir -p $OUT
for rel in default/BuildUVMPkg default/MiniAmiq default/Scoreboard default/SeqDriver default/SimpleUVM testflags/BuildUVMPkg testflags/MiniAmiq testflags/SeqDriver testflags/SimpleUVM; do
  d=$(ls -d $PAT/${rel}-*/ 2>/dev/null | head -1)
  [ -z "$d" ] && { echo "$rel MISSING"; continue; }
  base=$(basename "$d")
  p="$d/slang.uhdm"; q="$PRIS/${rel%%/*}/$base/slang.uhdm"
  tag=$(echo $rel | tr / .)
  $DUMP "$p" 2>/dev/null | sed "s#$d##g; s#$PAT/##g" | sort > $OUT/$tag.pat.srt
  $DUMP "$q" 2>/dev/null | sed "s#$(dirname $q)/##g; s#$PRIS/##g" | sort > $OUT/$tag.pris.srt
  n=$(diff $OUT/$tag.pris.srt $OUT/$tag.pat.srt | grep -cE '^[<>]' || true)
  add=$(diff $OUT/$tag.pris.srt $OUT/$tag.pat.srt | grep -cE '^>' || true)
  del=$(diff $OUT/$tag.pris.srt $OUT/$tag.pat.srt | grep -cE '^<' || true)
  echo "== $rel  order-blind-diff-lines=$n (added=$add removed=$del)"
  diff $OUT/$tag.pris.srt $OUT/$tag.pat.srt | grep -E '^[<>]' | grep -oE 'line:[0-9]+:[0-9]+' | sort -u > $OUT/$tag.pos
  echo -n "   distinct line: positions touched: "; wc -l < $OUT/$tag.pos
  cat $OUT/$tag.pos | tr '\n' ' '; echo
done
