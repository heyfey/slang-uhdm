#!/bin/bash
# r10bbp7diff: diff a sweep CSV against its committed baseline (status column
# only — the detail column carries ids/lines that churn harmlessly).
W=/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_512b5480-e53-1
cd "$W" || exit 1
NEW=$1
BASE=$2
cut -d, -f1-3 "$NEW" | sort > /tmp/r10bbp7_new.txt
cut -d, -f1-3 "$BASE" | sort > /tmp/r10bbp7_base.txt
echo "== status-only diff (< new, > baseline) =="
diff /tmp/r10bbp7_new.txt /tmp/r10bbp7_base.txt
echo "== counts new =="
cut -d, -f3 "$NEW" | sort | uniq -c
echo "== counts baseline =="
cut -d, -f3 "$BASE" | sort | uniq -c
