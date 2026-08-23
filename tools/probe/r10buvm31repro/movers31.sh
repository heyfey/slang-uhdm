#!/usr/bin/env bash
# r10buvm31repro/movers31.sh — ATTRIBUTE every byteverify mover, order-blind.
# MEASUREMENT ONLY.
#
#   movers31.sh <patched workdir> <pristine control workdir> <out dir> <rel...>
#
# For each named database, dumps BOTH sides, normalises the embedded workdir
# path and the arena ids away, SORTS both dumps and diffs them: an ORDER-BLIND
# diff, which is the only sound attribution for Scoreboard/default (RESUME §9:
# that row is a ~50/50 COIN per invocation, so a raw diff mixes the coin's
# ~92 lines into the law's).  Zero sorted-diff lines therefore means "coin
# only"; a non-zero set must be the law's lines and nothing else.
set -u
PW=$1; CW=$2; OUT=$3; shift 3
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
mkdir -p "$OUT"
for rel in "$@"; do
  key=$(printf '%s' "$rel" | tr '/' '_')
  "$DUMP" "$PW/$rel" 2>&1 | tail -n +2 | sed "s#$PW##g; s#$CW##g; s#, id:[0-9]*##g" | LC_ALL=C sort > "$OUT/$key.pat"
  "$DUMP" "$CW/$rel" 2>&1 | tail -n +2 | sed "s#$PW##g; s#$CW##g; s#, id:[0-9]*##g" | LC_ALL=C sort > "$OUT/$key.pris"
  n=$(diff "$OUT/$key.pris" "$OUT/$key.pat" | grep -c '^[<>]' || true)
  echo "== $rel  sorted-diff lines: $n"
  diff "$OUT/$key.pris" "$OUT/$key.pat" > "$OUT/$key.diff" 2>&1 || true
  grep '^[<>]' "$OUT/$key.diff" | head -40
done
