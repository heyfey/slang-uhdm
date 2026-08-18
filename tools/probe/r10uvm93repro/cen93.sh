#!/usr/bin/env bash
# r10uvm93 census driver — golden-vs-ours over the seven UVM row-modes +
# BuildUVMPkg (both modes).  Reads the PRISTINE control workdir for our side and
# the golden CACHE (named by each row's own cmds.txt) for golden's.  Streams the
# dumps through cen93.py; no multi-GB dump files are kept.
set -u
CTL=${CTL:?control workdir, e.g. /tmp/ctl_wd_sl_b1a0447}
OUT=${OUT:?output dir}
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
PY=$(dirname "$0")/cen93.py
mkdir -p "$OUT"
for m in default testflags; do
  for r in SeqDriver SimpleUVM Scoreboard MiniAmiq BuildUVMPkg; do
    d=$(ls -d "$CTL/$m/$r"-* 2>/dev/null | head -1)
    [ -n "$d" ] && [ -f "$d/slang.uhdm" ] || { echo "SKIP-NOFILE $m/$r"; continue; }
    g=$(grep -o 'golden cache hit [^)]*' "$d/cmds.txt" | awk '{print $4}')/golden.uhdm
    [ -f "$g" ] || { echo "SKIP-NOGOLDEN $m/$r"; continue; }
    "$DUMP" "$g"             2>/dev/null | sed 1d | python3 "$PY" > "$OUT/$r.$m.golden.txt"
    "$DUMP" "$d/slang.uhdm"  2>/dev/null | sed 1d | python3 "$PY" > "$OUT/$r.$m.ours.txt"
    echo "DONE $m/$r  golden=$(grep -c . "$OUT/$r.$m.golden.txt") ours=$(grep -c . "$OUT/$r.$m.ours.txt")"
  done
done
