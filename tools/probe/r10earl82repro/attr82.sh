#!/usr/bin/env bash
# r10earl82 — ATTRIBUTE A BOUNDARY MOVER.  MEASUREMENT ONLY.
#
#   usage: PATCHED_BIN=.. PRISTINE_BIN=.. attr82.sh <file.sv> <view> <outdir>
#
# Three questions, in this order, because they are not the same question:
#   1. IS IT THIS LAW?   patched with `R10E82_OFF=1` (the NEUTRAL) vs pristine.
#      Byte-identical => the law is not the cause; a nondeterminism or a
#      build-layout artefact is.
#   2. IS IT DETERMINISTIC?  the SAME binary run twice from its own directory.
#      A binary that disagrees with ITSELF cannot be evidence about the other.
#   3. WHAT CHANGED?      the normalised dump diff, first 40 lines.
set -u
PAT=${PATCHED_BIN:?}; PRIS=${PRISTINE_BIN:?}
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
F=$(readlink -f "$1"); VIEW=${2:-plain}; OUT=$(readlink -f "$3"); B=$(basename "$F")
case $VIEW in elab) FLAGS=--elabuhdm;; *) FLAGS="";; esac
mkdir -p "$OUT"
run() { # <tag> <binary> <env>
  d="$OUT/$1"; mkdir -p "$d"; cp "$F" "$d/"
  ( cd "$d" && env $3 "$2" $FLAGS "$B" -o slang.uhdm >slang.log 2>&1 </dev/null )
  echo "  $1 rc=$?"
  [ -f "$d/slang.uhdm" ] &&
    "$DUMP" "$d/slang.uhdm" 2>/dev/null | sed '1d' | sed "s#$d#WD#g" > "$d/o.norm"
}
run patchedA "$PAT"  R10E82_X=0
run patchedB "$PAT"  R10E82_X=0
run neutral  "$PAT"  R10E82_OFF=1
run pristineA "$PRIS" R10E82_X=0
run pristineB "$PRIS" R10E82_X=0
say() { cmp -s "$OUT/$1/o.norm" "$OUT/$2/o.norm" && echo "  $1 == $2" || echo "  $1 != $2"; }
echo "-- self-repeat (is the file even deterministic?)"; say patchedA patchedB; say pristineA pristineB
echo "-- law on/off"; say neutral pristineA; say patchedA pristineA
echo "-- first differences (patched vs pristine)"
diff "$OUT/pristineA/o.norm" "$OUT/patchedA/o.norm" | head -40
