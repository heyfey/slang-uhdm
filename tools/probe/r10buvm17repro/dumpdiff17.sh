#!/usr/bin/env bash
# r10buvm17repro/dumpdiff17.sh — ATTRIBUTE every byte mover to its dump LINES,
# pristine -> patched, path-normalised and reported BOTH raw and ORDER-BLIND.
#
#   usage: dumpdiff17.sh <pristine_workdir> <patched_workdir> [name ...]
#
# GUARDS:
#   * dump paths embed the workdir, so both sides are normalised before diffing
#     (a raw diff otherwise reports the header line of every database).
#   * the campaign's documented ORDER COIN (svunit_pkg's vpiTaskFunc listing
#     order, macro-buffer SourceLocation ordering under slang's parallel parse)
#     makes RAW side counts run-specific; the SORTED count is the attributable
#     one and both are printed, never just the raw one.
set -u
P=${1:?pristine workdir}; Q=${2:?patched workdir}; shift 2
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
[ -x "$DUMP" ] || { echo "FATAL no uhdm-dump at $DUMP"; exit 3; }
T=$(mktemp -d /tmp/r10buvm17_dd_XXXXXX)
for c in "$P"/*/*/cmds.txt; do
  d=$(dirname "$c"); t=$(basename "$d"); m=$(basename "$(dirname "$d")")
  if [ $# -gt 0 ]; then hit=0; for n in "$@"; do case "$t" in $n*) hit=1;; esac; done; [ $hit = 1 ] || continue; fi
  a="$d/slang.uhdm"; b="$Q/$m/$t/slang.uhdm"
  [ -f "$a" ] && [ -f "$b" ] || continue
  cmp -s "$a" "$b" && continue
  "$DUMP" "$a" 2>/dev/null | sed -e "s#$P##g" -e "s#$Q##g" > "$T/a"
  "$DUMP" "$b" 2>/dev/null | sed -e "s#$P##g" -e "s#$Q##g" > "$T/b"
  raw=$(diff "$T/a" "$T/b" | grep -c '^[<>]'; true)
  sort "$T/a" > "$T/as"; sort "$T/b" > "$T/bs"
  srt=$(diff "$T/as" "$T/bs" | grep -c '^[<>]'; true)
  add=$(diff "$T/as" "$T/bs" | grep -c '^>'; true)
  rem=$(diff "$T/as" "$T/bs" | grep -c '^<'; true)
  echo "== $m/$t  rawsides=$raw sortedsides=$srt  added=$add removed=$rem"
  diff "$T/as" "$T/bs" | grep '^[<>]' | sed -e 's/^\(.\) *\\*_*/\1 /' -e 's/, *line.*//' \
    | sort | uniq -c | sort -rn | head -12
done
rm -rf "$T"
