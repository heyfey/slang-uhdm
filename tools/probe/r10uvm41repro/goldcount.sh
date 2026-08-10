#!/bin/bash
# r10uvm41 — goldens PASS/FAIL count with SLANG_UHDM pinned to THIS worktree.
set -u
ROOT=$(cd "$(dirname "$0")"/../../.. && pwd)
cd "$ROOT" || exit 1
SLANG_UHDM=$ROOT/build/slang-uhdm bash tests/check_goldens.sh > /tmp/r10uvm41_goldens.txt 2>&1
echo "rc=$?"
echo "PASS: $(grep -c '^PASS' /tmp/r10uvm41_goldens.txt)"
echo "FAIL: $(grep -c '^FAIL' /tmp/r10uvm41_goldens.txt)"
grep -v '^PASS' /tmp/r10uvm41_goldens.txt | tail -5
