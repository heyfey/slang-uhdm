#!/bin/bash
# r11u4 — PROVE the UVM coin family nondeterministic ON THE PRISTINE BINARY.
#   usage: coin.sh <workdir-root> <binary> <runs> <testdir-name>...
# Re-runs the RECORDED slang command line (from the sweep's own cmds.txt), in
# the test's own directory, N times, and prints the md5 of each database plus
# the ORDER-BLIND (sorted, path-normalised) dump delta between run 1 and run N.
# A family whose PRISTINE md5s differ across runs cannot have been moved by any
# source change; a nonzero size delta would still prove a real mover.
set -u
WD=${1:?workdir root}; BIN=${2:?binary}; N=${3:?runs}; shift 3
DUMP=/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump
OUT=$(mktemp -d /tmp/r11u4_coin.XXXXXX)
for t in "$@"; do
  d=$(ls -d "$WD"/default/"$t"-*/ 2>/dev/null | head -1)
  [ -z "$d" ] && { echo "$t NODIR"; continue; }
  cmd=$(sed -n 's/^slang:  *//p' "$d/cmds.txt" | head -1)
  src=$(ls -d "$HOME"/git-repos/Surelog/tests/"$t" \
              "$HOME"/git-repos/Surelog/third_party/tests/"$t" 2>/dev/null | head -1)
  [ -z "$src" ] && { echo "$t NOSRC"; continue; }
  for r in $(seq 1 "$N"); do
    o="$OUT/$t.$r.uhdm"
    ( cd "$src" && eval "${cmd% -o *} -o $o" ) > "$OUT/$t.$r.log" 2>&1
    printf '%-14s run%s rc=%s md5=%s\n' "$t" "$r" "$?" \
        "$(md5sum "$o" 2>/dev/null | cut -c1-12)"
  done
  if [ -f "$OUT/$t.1.uhdm" ] && [ -f "$OUT/$t.$N.uhdm" ]; then
    $DUMP "$OUT/$t.1.uhdm" | tail -n +2 | sed "s#$OUT##g" | sort > "$OUT/$t.a"
    $DUMP "$OUT/$t.$N.uhdm" | tail -n +2 | sed "s#$OUT##g" | sort > "$OUT/$t.b"
    echo "  order-blind sorted-dump delta run1 vs run$N: $(diff "$OUT/$t.a" "$OUT/$t.b" | grep -c '^[<>]'; true) lines"
    diff "$OUT/$t.a" "$OUT/$t.b" | grep '^[<>]' | head -8 | sed 's/^/    /'
  fi
done
echo "scratch: $OUT"
