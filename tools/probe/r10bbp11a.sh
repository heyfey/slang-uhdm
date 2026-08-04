#!/bin/bash
# r10bbp11a: resolve raw backtrace() addresses printed by temporary in-emitter
# instrumentation into file:line through addr2line.  Use when the question is
# "WHICH of the ~30 call sites built this object" and the state flags at the
# site cannot tell them apart.
#
# MEASURED: this does NOT work against the default Release build — every frame
# comes back `?? ??:0` because the binary carries no debug info and is PIE, so
# the raw addresses do not map.  To use it, rebuild the worktree with
# -DCMAKE_BUILD_TYPE=RelWithDebInfo first (full rebuild, ~10 min).  The cheaper
# alternative, which is what r10bbp11 actually used, is to bisect the candidate
# builders with env-gated fprintf probes keyed on the object's own fields
# (line/col, decompile, raw bound text) — see the § foldedMemberBoundMetaLogic
# note in TypeEmit.cpp for the four sites that had to be eliminated.
#   usage: r10bbp11a.sh <dbg.txt>
W=${W:-/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_03807e90-423-1}
F=${1:-/tmp/r10bbp11_dbg4.txt}
while read -r line; do
  case "$line" in
    P9*) echo "$line" ;;
    *BT*) a=$(echo "$line" | awk '{print $3}')
          echo "   $(addr2line -f -C -e "$W/build/slang-uhdm" "$a" | tr '\n' ' ')" ;;
  esac
done < "$F"
