#!/bin/bash
# r10uvm46 — re-namespace pass 45's drivers into this pass's /tmp namespace so a
# sibling worktree cannot clobber a measurement mid-pass.
#
# INHERITED RULE (pass 44's defect, pass 45's fix): a probe BINARY keeps its
# BIRTH-pass name forever; ONLY the `/tmp/<pass>_` namespace prefix moves.  A
# blanket s/r10uvm45/r10uvm46/ would rewrite `/tmp/r10uvm45_r10uvm44ls` into a
# file that never exists and every driver would then report PERFECTION.  So the
# sed is anchored to the prefix and nothing else, and --check verifies that every
# `V=` a driver names exists once probebuild.sh has run.
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
SRC=$HERE/../r10uvm45repro
if [ "${1:-}" = "--check" ]; then
  rc=0
  for f in "$HERE"/*.sh; do
    for v in $(grep -hoE '/tmp/r10uvm46_[A-Za-z0-9_]+' "$f" | sort -u); do
      case $v in *_r10uvm4[0-9]*|*_w4*) ;; *) continue;; esac
      if [ -x "$v" ]; then echo "OK   $(basename "$f") -> $v"
      else echo "MISS $(basename "$f") -> $v"; rc=1; fi
    done
  done
  exit $rc
fi
for f in gate.sh uvm4.sh res.sh panel.sh listdirect.sh ldrows.sh cp.sh \
         cpclass.sh tsinst.sh simpleuvm.sh byteverify.sh ls.sh gold.sh \
         detcheck4.sh probebuild.sh csvdiff.sh modcls.sh seq.sh armls.sh \
         cpall.sh ifcount.sh; do
  sed -e 's|/tmp/r10uvm45_|/tmp/r10uvm46_|g' \
      -e '1,3s|^# r10uvm45 |# r10uvm46 (cloned from pass 45) |' \
      -e '1,3s|^# r10uvm45 (cloned from pass 44) |# r10uvm46 (cloned from pass 45) |' \
      "$SRC/$f" > "$HERE/$f"
  chmod +x "$HERE/$f"
  echo "$f"
done
