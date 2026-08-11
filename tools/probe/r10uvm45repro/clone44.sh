#!/bin/bash
# r10uvm45 — re-namespace pass 44's drivers into this pass's /tmp namespace so a
# sibling worktree cannot clobber a measurement mid-pass.
#
# *** THE PASS-44 DEFECT THIS SCRIPT EXISTS TO NOT REPEAT ***  clone43.sh did
# `sed s/r10uvm43/r10uvm44/g`, which also rewrote the PROBE BINARY names
# (`/tmp/r10uvm43_r10uvm43cp` -> `/tmp/r10uvm45_r10uvm45cp`, a file that never
# exists), and cp.sh then reported `golden=0 ours=0 diff=0` for every test —
# A DRIVER THAT CANNOT FIND ITS PROBE REPORTS PERFECTION.  A probe binary keeps
# its BIRTH-pass name forever; ONLY the /tmp namespace prefix moves.  So the sed
# here is anchored to the prefix `/tmp/r10uvm44_` and nothing else, and the
# script VERIFIES afterwards that every `V=` a driver names actually exists once
# probebuild.sh has run (run it with --check after probebuild).
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
SRC=$HERE/../r10uvm44repro
if [ "${1:-}" = "--check" ]; then
  rc=0
  for f in "$HERE"/*.sh; do
    for v in $(grep -hoE '^V=/tmp/r10uvm45_[A-Za-z0-9_]+' "$f" | cut -d= -f2); do
      if [ -x "$v" ]; then echo "OK   $(basename "$f") -> $v"
      else echo "MISS $(basename "$f") -> $v"; rc=1; fi
    done
  done
  exit $rc
fi
for f in gate.sh uvm4.sh res.sh panel.sh listdirect.sh ldrows.sh cp.sh \
         cpclass.sh tsinst.sh simpleuvm.sh byteverify.sh ls.sh gold.sh \
         detcheck4.sh probebuild.sh csvdiff.sh; do
  sed -e 's|/tmp/r10uvm44_|/tmp/r10uvm45_|g' \
      -e '1,3s|^# r10uvm44 |# r10uvm45 (cloned from pass 44) |' \
      "$SRC/$f" > "$HERE/$f"
  chmod +x "$HERE/$f"
  echo "$f"
done
