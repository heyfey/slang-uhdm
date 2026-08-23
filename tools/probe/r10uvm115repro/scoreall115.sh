#!/usr/bin/env bash
# r10uvm115repro/scoreall115.sh — run score115.py over EVERY byte mover of a
# sweep pair.  MEASUREMENT ONLY.  LHS is ALWAYS golden (Surelog).
#
#   scoreall115.sh <pristine workdir> <patched workdir> [<scratch dir>]
#
# GUARDS: the golden path is read out of each test's OWN cmds.txt and the cache
# DIRECTORY is turned into .../golden.uhdm (handing a directory to uhdm-dump
# reads nothing); a test whose golden or database is missing prints SKIP and is
# COUNTED; every dump is path-normalised for its own workdir before scoring.
set -u
P=${1:?pristine workdir}; Q=${2:?patched workdir}; O=${3:-/tmp/r10uvm115_score}
HERE=$(cd "$(dirname "$0")" && pwd)
mkdir -p "$O"
n=0; skip=0
for rel in $(cd "$Q" && find . -name slang.uhdm | sort); do
  a="$P/$rel"; b="$Q/$rel"
  [ -f "$a" ] && [ -f "$b" ] || { echo "SKIP-NOFILE $rel"; skip=$((skip+1)); continue; }
  cmp -s "$a" "$b" && continue
  d=$(dirname "$Q/$rel")
  G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$d/cmds.txt" | head -1)
  [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
  if [ -z "$G" ] || [ ! -f "$G" ]; then echo "SKIP-NOGOLDEN $rel"; skip=$((skip+1)); continue; fi
  key=$(printf '%s' "$rel" | sed 's#^\./##; s#/#__#g')
  uhdm-dump "$G" 2>&1 > "$O/$key.g.txt"
  uhdm-dump "$a" 2>&1 | sed "s#$P##g" > "$O/$key.p.txt"
  uhdm-dump "$b" 2>&1 | sed "s#$Q##g" > "$O/$key.q.txt"
  echo "== $rel"
  python3 "$HERE/score115.py" "$O/$key.g.txt" "$O/$key.p.txt" "$O/$key.q.txt"
  n=$((n+1))
done
echo "-- scored=$n SKIP=$skip"
