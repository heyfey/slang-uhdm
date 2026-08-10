#!/bin/bash
# r10uvm44 — re-namespace pass 43's drivers into this pass's /tmp namespace so a
# sibling worktree cannot clobber a measurement mid-pass.  Byte-for-byte the
# pass-43 logic with `r10uvm43` -> `r10uvm44`; every behavioural change this
# pass makes to a driver is made AFTER this runs and is visible in git diff.
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
SRC=$HERE/../r10uvm43repro
for f in gate.sh uvm4.sh res.sh panel.sh listdirect.sh ldrows.sh cp.sh \
         cpclass.sh tsinst.sh simpleuvm.sh byteverify.sh; do
  sed 's/r10uvm43/r10uvm44/g' "$SRC/$f" > "$HERE/$f"
  chmod +x "$HERE/$f"
  echo "$f"
done
