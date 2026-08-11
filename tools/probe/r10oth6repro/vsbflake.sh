#!/usr/bin/env bash
# Settle the Scoreboard byte-mover question: 4 runs per binary, default mode,
# md5 of the produced database each time.  The brief says Scoreboard's default
# database is intermittently nondeterministic on EVERY binary, and r10oth5's
# README C7 records the same thing (two md5s across 8 runs, BOTH binaries
# emitting BOTH).  If both binaries emit the SAME SET of md5s, the byte
# "mover" is nondeterminism, not this pass's laws.
set -u
cd /home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_f8dfa769-106-2
for tag in patched pristine; do
  if [ "$tag" = patched ]; then
    BIN=/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_f8dfa769-106-2/build/slang-uhdm
  else
    BIN=/tmp/r10oth6_bin/slang-uhdm-pristine
  fi
  echo "=== $tag  $(md5sum "$BIN" | cut -d' ' -f1) ==="
  for i in 1 2 3 4; do
    W=/tmp/r10oth6_sb_${tag}_$i
    rm -rf "$W"
    SLANG_UHDM="$BIN" python3 scripts/verify_golden.py --corpus surelog \
      --mode default --jobs 2 --filter '^Scoreboard$' \
      --out /tmp/r10oth6_sb_${tag}_$i.csv --workdir "$W" >/dev/null 2>&1
    f=$(find "$W" -name slang.uhdm | head -1)
    if [ -z "$f" ]; then echo "  run $i: UNMEASURED(no database)"; else
      echo "  run $i: $(md5sum "$f" | cut -c1-12)"
    fi
  done
done
