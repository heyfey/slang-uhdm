#!/usr/bin/env bash
# CORRECTED: this cd'd into the implementing agent's scratchpad, so the paths
# passed as arguments only resolved inside that one directory.  Arguments are
# now taken as given (absolute or relative to the caller's cwd).
set -u
for f in "$@"; do
  echo "== $f"
  echo -n "  unfolded op  @113:9-13 : "; grep -c "operation: , line:113:9, endln:113:13" "$f"
  echo -n "  folded const @113:9-11 : "; grep -c "constant: , line:113:9, endln:113:11" "$f"
  echo -n "  unfolded op  @112:8-12 : "; grep -c "operation: , line:112:8, endln:112:12" "$f"
  echo -n "  folded const @112:8-10 : "; grep -c "constant: , line:112:8, endln:112:10" "$f"
  echo -n "  unfolded op  @111:8-12 : "; grep -c "operation: , line:111:8, endln:111:12" "$f"
  echo -n "  folded const @111:8-10 : "; grep -c "constant: , line:111:8, endln:111:10" "$f"
done
