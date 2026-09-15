#!/bin/bash
# r11u44repro/sharedhead.sh — PROVE (or refute) that two rows carry ONE head.
#
# A cluster claim of a SHARED face is worth nothing without the two heads under
# it as the same text.  This prints both heads blinded and their md5, and says
# IDENTICAL or DIFFERS.  What is blinded, and why:
#
#   id:N                  arena serial numbers — per build, never a fact
#   line:/endln:/col:/file:/vpiRef{File,LineNo,ColumnNo,EndLineNo,EndColumnNo}
#                         NO generated Compare reads a source location
#                         (RESUME.md 9); two rows on the same construct in two
#                         different files must still read as one head
#   the DESIGN's own name  each test names its own top module; `work@dut.level`
#                         and `work@genvar_pow_index.level` are the same object
#                         in two designs.  Pass the names to blind as $NAMES.
#
# vpiFullName is NOT blinded here (facediff.py blinds it): a cluster claim that
# survives the full name is stronger than one that needs it hidden.
#
#   usage: NAMES="dut genvar_pow_index" sharedhead.sh <a.cmp> <b.cmp> [...]
set -u
NAMES=${NAMES:-}
blind() {
  sed -E 's/id:[0-9]+/id:#/g; s/line:[0-9]+:[0-9]+/line:#/g; s/endln:[0-9]+:[0-9]+/endln:#/g;
          s/col:[0-9]+/col:#/g; s#file:[^,]*#file:#; s/vpiRef(File|LineNo|ColumnNo|EndLineNo|EndColumnNo):.*/vpiRef\1:#/' "$1" \
  | { p=cat; for n in $NAMES; do p="$p | sed -E \"s/\\b$n\\b/<DESIGN>/g\""; done; eval "$p"; }
}
first=""; ref=""
for f in "$@"; do
  b=$(blind "$f"); m=$(printf '%s' "$b" | md5sum | cut -c1-12)
  echo "---- $(basename "$f")   md5=$m   lines=$(printf '%s\n' "$b" | grep -c .)"
  if [ -z "$first" ]; then first=$f; ref=$m; printf '%s\n' "$b" | sed 's/^/    /'
  elif [ "$m" = "$ref" ]; then echo "    IDENTICAL to $(basename "$first") (blinded)"
  else echo "    DIFFERS from $(basename "$first"):"; diff <(blind "$first") <(printf '%s\n' "$b") | sed 's/^/    /'
  fi
done
