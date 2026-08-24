#!/usr/bin/env bash
# r10earl81 — ATTRIBUTE A BOUNDARY MOVER, with two controls, because RESUME §9
# forbids ASSERTING attribution.  Given one probe directory and one view it
# runs:
#   * the SAME binary TWICE                  -> the NONDETERMINISM test.  If a
#     binary disagrees with ITSELF, a byte comparison is not a valid instrument
#     on that directory and the walk's DIFF there says nothing about any patch.
#   * the patched binary with the law DISABLED (R10E81_OFF=1) -> the LAYOUT
#     test.  If the diff SURVIVES with the law's code path not executed, the law
#     did not cause it (what remains is binary size / address layout).
# The law is convicted only when law-OFF reproduces pristine EXACTLY and law-ON
# is the whole delta.
#
# MEASUREMENT ONLY.  Reads and compiles probe sources; dispatches no corpus test.
#
#   usage: PATCHED_BIN=.. PRISTINE_BIN=.. PROBE_ROOT=.. attr81.sh <reldir> <plain|elab>
set -u
DIR=${1:?relative probe directory}
VIEW=${2:?plain|elab}
PAT=${PATCHED_BIN:?set PATCHED_BIN}
PRIS=${PRISTINE_BIN:?set PRISTINE_BIN}
ROOT=${PROBE_ROOT:?set PROBE_ROOT}
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
OFFVAR=${OFFVAR:-R10E81_OFF}
case $VIEW in
  plain) FLAGS="";;
  elab)  FLAGS="--elabuhdm";;
  *) echo "view must be plain|elab"; exit 2;;
esac
key=$(echo "$DIR" | tr '/' '_')
W=${TMPDIR:-/tmp}/r10earl81_attr/${key}_$VIEW
rm -rf "$W"; mkdir -p "$W"
cp "$ROOT/$DIR"/*.sv "$W"/ 2>/dev/null
cd "$W" || exit 1
files=$(ls *.sv 2>/dev/null | tr '\n' ' ')
[ -z "$files" ] && { echo "$DIR $VIEW: NO_SV"; exit 0; }
run() { # $1=tag $2=binary $3=env assignment
  env "$3" "$2" $FLAGS $files -o "$1.uhdm" > "$1.log" 2>&1 </dev/null
  "$DUMP" "$1.uhdm" 2>/dev/null | sed '1d' | sed "s#$W#WD#g" > "$1.norm"
}
run p1 "$PRIS" IGNORED=1
run p2 "$PRIS" IGNORED=1
run q1 "$PAT"  IGNORED=1
run n1 "$PAT"  "$OFFVAR=1"
run n2 "$PAT"  "$OFFVAR=1"
d() { cmp -s "$1.norm" "$2.norm" && echo SAME || echo DIFF; }
printf '%-24s %-5s  pris-selfrun:%s  patchedOFF-selfrun:%s  pris-vs-patchedON:%s  pris-vs-patchedOFF:%s  patchedOFF-vs-ON:%s\n' \
  "$DIR" "$VIEW" "$(d p1 p2)" "$(d n1 n2)" "$(d p1 q1)" "$(d p1 n1)" "$(d n1 q1)"
