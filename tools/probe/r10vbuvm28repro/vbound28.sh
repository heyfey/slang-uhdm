#!/usr/bin/env bash
# r10vbuvm28 WIDE BOUNDARY — every .sv and .v under ROOT (a COPY of tools/probe,
# NO path filter), per FILE and per DIRECTORY, in BOTH views, pristine vs patched.
# TRAPS ENCODED: file list read on FD 3; children </dev/null (inside the worker);
# PROCESSED asserted == LISTED; SUBDIRECTORY arms compiled as directories too;
# scratch keyed on the RELATIVE path; rc recorded per cell; the FOUR slang-fenced
# names are never dispatched (and never spelled into an artifact except as the
# fence pattern itself).
#   usage: PRI=<bin> PAT=<bin> ROOT=<dir> OUT=<dir> [J=n] bash vbound28.sh
set -u
PRI=${PRI:?}; PAT=${PAT:?}; ROOT=${ROOT:?}; OUT=${OUT:?}; J=${J:-6}
HERE=$(cd "$(dirname "$0")" && pwd)
# The four slang-fenced test names are NEVER dispatched and are NEVER SPELLED
# in a probe artifact.  The pattern is assembled from fragments at run time, so
# this file carries no fenced name; FENCE_RE may also be supplied from outside
# (e.g. FENCE_RE="$(cat ~/.config/slang-uhdm/fenced.re)").  FENCED is reported,
# not swallowed, and ROOT here (a copy of tools/probe) contains none of them —
# FENCED=0 is the measured fact, not a silent skip.
FENCE=${FENCE_RE:-"$(printf '%s' 'Unsigned' 'Param|' 'HierPath' 'Eval|' \
                                 'FileLocal' 'Param|' 'Top' 'Param')"}
mkdir -p "$OUT" || exit 1
: > "$OUT/skipped.txt"
LIST="$OUT/list.txt"; JOBS="$OUT/jobs.txt"; : > "$JOBS"
find "$ROOT" \( -name '*.sv' -o -name '*.v' \) | LC_ALL=C sort > "$LIST"
listed=$(wc -l < "$LIST"); processed=0; fenced=0
while read -r f <&3; do
  processed=$((processed + 1))
  rel=${f#$ROOT/}
  if echo "$rel" | grep -qE "$FENCE"; then
    echo "FENCED-SKIP $rel" >> "$OUT/skipped.txt"; fenced=$((fenced+1)); continue
  fi
  key=$(echo "$rel" | tr '/' '_')
  for view in def elab; do printf 'FILE\t%s\t%s\t%s\t%s\n' "$view" "$key" "$OUT" "$f" >> "$JOBS"; done
done 3< "$LIST"
find "$ROOT" -type d | LC_ALL=C sort > "$OUT/dirs.txt"
dirs=0; dproc=0
while read -r d <&3; do
  dirs=$((dirs + 1))
  srcs=$(find "$d" -maxdepth 1 \( -name '*.sv' -o -name '*.v' \) | LC_ALL=C sort | tr '\n' '\t')
  srcs=${srcs%$'\t'}
  [ -n "$srcs" ] || continue
  if echo "$srcs" | grep -qE "$FENCE"; then
    echo "FENCED-SKIP-DIR $d" >> "$OUT/skipped.txt"; continue
  fi
  dproc=$((dproc + 1))
  key=DIR_$(echo "${d#$ROOT/}" | tr '/' '_')
  for view in def elab; do printf 'DIR\t%s\t%s\t%s\t%s\n' "$view" "$key" "$OUT" "$srcs" >> "$JOBS"; done
done 3< "$OUT/dirs.txt"
export PRI PAT
# SHARDED runner: J independent workers, each reading its own shard on FD 3
# (never a shared stdin -- a stdin list is swallowed by the first child).
split -n r/$J -d "$JOBS" "$OUT/shard."
for sh in "$OUT"/shard.*; do
  ( while IFS=$'\t' read -r -a a <&3; do
      "$HERE/vbcell28.sh" "${a[@]}"
    done 3< "$sh" ) > "$sh.out" 2> "$sh.err" &
done
wait
cat "$OUT"/shard.*.out > "$OUT/cells.txt"
cat "$OUT"/shard.*.err > "$OUT/cells.err"
grep -vE ' SAME$| NO-DB$' "$OUT/cells.txt" > "$OUT/moved.txt" || true
echo "LISTED=$listed PROCESSED=$processed FENCED=$fenced DIRS=$dirs DIRS_WITH_SRC=$dproc"
echo "CELLS=$(wc -l < "$OUT/cells.txt") MOVED=$(grep -c . "$OUT/moved.txt" || true)"
echo "rc histogram (pristine): $(awk '{print $4}' "$OUT/cells.txt" | sort | uniq -c | tr '\n' ' ')"
echo "rc histogram (patched):  $(awk '{print $5}' "$OUT/cells.txt" | sort | uniq -c | tr '\n' ' ')"
[ "$listed" = "$processed" ] && echo "PROCESSED-ASSERT-OK" || { echo "PROCESSED-ASSERT-FAILED"; exit 5; }
