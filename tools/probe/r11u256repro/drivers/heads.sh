#!/bin/bash
# (r11u256: copied from r11u254repro/drivers)
# (r11u254: copied from r11u255repro/drivers)
# (r11u255: copied from r11u253repro/drivers)
# heads.sh <workdir> <max> <row>... : uhdm-strictcmp --max <max> of each named row-mode's slang.uhdm against the
# golden its cmds.txt names. Fail-closed on $FENCED: a fenced row name is refused before any path is built.
[ -n "$FENCED" ] && [ "$(echo $FENCED | wc -w)" = 4 ] || { echo "heads.sh: FENCED unset" >&2; exit 2; }
SC=${STRICT_CMP:-$STRICTCMP}; [ -x "$SC" ] || { echo "heads.sh: comparator not executable" >&2; exit 2; }
wd=$1; mx=$2; shift 2
for r in "$@"; do
  for f in $FENCED; do [ "$f" = "$r" ] && { echo "heads.sh: fenced row refused" >&2; exit 2; }; done
  for m in default testflags; do
    d=$(ls -d $wd/$m/$r-* 2>/dev/null | head -1); [ -n "$d" ] && [ -s $d/slang.uhdm ] || continue
    g=$(sed -n 's/^surelog: (golden cache hit \(.*\))$/\1/p' $d/cmds.txt | head -1)
    gu=$(ls $g/*.uhdm 2>/dev/null | head -1); [ -z "$gu" ] && gu=$(find $g -name '*.uhdm' | head -1)
    [ -s "$gu" ] || { echo "$r/$m NOGOLDEN"; continue; }
    echo "== $r/$m"; timeout 900 "$SC" --max $mx "$gu" $d/slang.uhdm 2>&1 | tail -n $((mx*4+3))
  done
done
