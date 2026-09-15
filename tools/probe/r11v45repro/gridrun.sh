#!/bin/bash
# r11u31 grid runner — one arm = one .sv file.  Golden = Surelog v1.87 -parse,
# ours = the binary named by $BIN (never defaulted).  EVERY arm records rc on
# BOTH sides; an arm whose compile fails teaches error-recovery, not golden.
#   usage: gridrun.sh <dir-with-*.sv> [name ...]
set -u
D=${1:?dir}; shift || true
BIN=${BIN:?set BIN to the slang-uhdm binary}
[ -x "$BIN" ] || { echo "FATAL: no BIN $BIN"; exit 3; }
SL=$HOME/git-repos/Surelog/build/bin/surelog
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
CMP=$HOME/.local/bin/uhdm-cmp
for f in "$D"/*.sv; do
  n=$(basename "$f" .sv)
  if [ $# -gt 0 ]; then case " $* " in *" $n "*) ;; *) continue;; esac; fi
  w="$D/out_$n"; rm -rf "$w"; mkdir -p "$w"
  ( cd "$w" && "$SL" -parse -nobuiltin -nocache -nowritecache "$f" > sl.log 2>&1 ); slrc=$?
  g="$w/slpp_all/surelog.uhdm"
  "$BIN" "$f" --single-unit --nobuiltin -o "$w/ours.uhdm" > "$w/ours.log" 2>&1; orc=$?
  gd=-; od=-; heads=-; lines=-
  if [ -f "$g" ]; then "$DUMP" "$g" > "$w/gold.dump" 2>&1; gd=$(wc -l < "$w/gold.dump"); fi
  if [ -f "$w/ours.uhdm" ]; then "$DUMP" "$w/ours.uhdm" > "$w/ours.dump" 2>&1; od=$(wc -l < "$w/ours.dump"); fi
  if [ -f "$g" ] && [ -f "$w/ours.uhdm" ]; then
    "$CMP" "$g" "$w/ours.uhdm" > "$w/cmp.txt" 2>&1
    lines=$(wc -l < "$w/cmp.txt"); heads=$(grep -c '^LHS:' "$w/cmp.txt"; true)
  fi
  printf "%-32s slrc=%-4s ourrc=%-4s golddump=%-6s ourdump=%-6s cmplines=%-6s heads=%s\n" \
     "$n" "$slrc" "$orc" "$gd" "$od" "$lines" "$heads"
done
