#!/bin/bash
# r10uvm158 — THE FAMILY CENSUS over the MOVED DATABASES, three ways
# (golden vs pristine vs patched).  MEASUREMENT ONLY; the official uhdm-cmp is
# the judge.  LHS/G is ALWAYS golden.
#
#   usage: CEN=<ct158cen> SCORE=<score158.py> scoreall158.sh <pris workdir> <pat workdir> <rel> [<rel> ...]
#
# <rel> is a workdir-relative row path (e.g. default/SimpleUVM-1dc93a62).  The
# golden path is read out of the row's OWN cmds.txt, so the census cannot
# silently compare against the wrong golden; a row missing either side prints
# SKIP-NOFILE and is COUNTED.
set -u
CEN=${CEN:?ct158cen}; SCORE=${SCORE:?score158.py}
A=${1:?pristine workdir}; B=${2:?patched workdir}; shift 2
T=$(mktemp -d /tmp/r10uvm158_cen_XXXXXX) || exit 1
for rel in "$@"; do
  if [ ! -f "$A/$rel/slang.uhdm" ] || [ ! -f "$B/$rel/slang.uhdm" ]; then
    echo "SKIP-NOFILE $rel"; continue
  fi
  G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$A/$rel/cmds.txt" | head -1)
  [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
  if [ -z "$G" ] || [ ! -f "$G" ]; then echo "SKIP-NOFILE $rel (no golden)"; continue; fi
  "$CEN" "$G"                 G > "$T/g.tsv" 2>/dev/null
  "$CEN" "$A/$rel/slang.uhdm" O > "$T/a.tsv" 2>/dev/null
  "$CEN" "$B/$rel/slang.uhdm" O > "$T/b.tsv" 2>/dev/null
  for r in BLK DECL; do
    printf '%-34s %-5s ' "$rel" "$r"
    python3 "$SCORE" "$T/g.tsv" "$T/a.tsv" "$T/b.tsv" --rows $r --nospan | tail -1
  done
  for r in BLK DECL; do
    python3 "$SCORE" "$T/g.tsv" "$T/a.tsv" "$T/b.tsv" --rows $r --nospan \
      | grep -vE '^-- ' | sed "s#^#$rel\t$r\t#"
  done > "$T/detail.$$" 2>/dev/null
  cat "$T/detail.$$" >> "${CENDETAIL:-/dev/null}"
done
rm -rf "$T"
