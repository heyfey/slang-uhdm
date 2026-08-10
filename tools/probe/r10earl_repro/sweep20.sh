#!/bin/bash
# sweep19.sh <corpus> <mode> <filter> <tag> [jobs] -- verify_golden wrapper that
# pins SLANG_UHDM to THIS worktree's binary and gives the run its own workdir.
W=/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_7fd8273a-549-1
export SLANG_UHDM=$W/build/slang-uhdm
cd "$W" || exit 1
python3 scripts/verify_golden.py --corpus "$1" --mode "$2" --filter "$3" \
  --out "/tmp/r10earl20_$4.csv" --workdir "/tmp/r10earl20_$4w" \
  --jobs "${5:-1}" --timeout 300
echo "rc=$? -> /tmp/r10earl20_$4.csv  wd=/tmp/r10earl20_$4w"
