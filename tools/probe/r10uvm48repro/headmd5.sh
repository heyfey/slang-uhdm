#!/bin/bash
# r10uvm48 — the id-NORMALISED md5 of each cmp head file, so "the three tests
# share ONE head" is a measurement and not an impression.  LHS is ALWAYS
# golden(Surelog), RHS is ALWAYS ours — the files come from cmp4.sh, which
# invokes uhdm-cmp as (golden.uhdm, ours.uhdm).
# POSITIVE CONTROL: a file that is missing or holds no `^LHS:` line at column 0
# prints NOHEAD, never a hash that could be mistaken for a shared head.
#   usage: headmd5.sh <cmp-file>...
set -u
for f in "$@"; do
  if [ ! -s "$f" ]; then echo "NOHEAD(missing) $f"; continue; fi
  n=$(grep -c '^LHS:' "$f")
  if [ "$n" = 0 ]; then echo "NOHEAD(no ^LHS: at col 0) $f"; continue; fi
  m=$(sed 's/id:[0-9][0-9]*/id:N/g' "$f" | md5sum | cut -c1-12)
  echo "heads=$n lines=$(wc -l < "$f") md5=$m $f"
done
