#!/usr/bin/env bash
# r10earl33 — THE SOURCE-DERIVED MOVER FENCE, computed from the corpus SOURCES
# alone and BEFORE the patched sweeps are read.  r10earl32's pred32.sh with the
# ONE extra condition this pass's gate adds.
#
# § genCaArgPkgParamValueFolds33 fires only where ALL THREE hold in one file:
#
#   A  a `::`-QUALIFIED name inside a call's argument list.  The gate lives in
#      emitSyntaxExpr's ScopedName arm, so the BARE spelling cannot reach it at
#      all (a bare name is an IdentifierName) — which is why pred32.sh's
#      condition B (a wildcard import) is NOT a sufficient trigger here and is
#      printed only for comparison with that pass.
#   C  a GENERATE construct — `generate`, `for (genvar`, or a `begin :` label —
#      because the flag the gate reads (`inDefGenCaExpr`) is set only by the
#      def-view generate-block cont-assign loop.
#   D  a CONTINUOUS ASSIGN (`assign`).  A generate-block PROCESS goes through
#      emitProcess/emitExpr and is not this arm.
#
# It cannot tell a package parameter from an enum literal, a type name or a
# module localparam, it cannot tell whether the assign is INSIDE the generate,
# and it does not parse.  That is deliberate: it is a LOOSE UPPER BOUND and it
# is FALSIFIABLE.  EVERY measured byte mover must be inside the candidate set;
# a mover outside it refutes the stated reach.
#
#   usage: pred33.sh [outdir]
set -u
U2R=$HOME/git-repos/uhdm2rtlil/test
SLT=$HOME/git-repos/Surelog/tests
SL3=$HOME/git-repos/Surelog/third_party/tests
OUT=${1:-/tmp/e33}

A_RE='[A-Za-z_][A-Za-z_0-9]*[[:space:]]*\([^();]*[A-Za-z_][A-Za-z_0-9]*::[A-Za-z_][A-Za-z_0-9]*'
B_RE='import[[:space:]]+[A-Za-z_][A-Za-z_0-9]*::\*'
C_RE='(generate|for[[:space:]]*\([[:space:]]*genvar|begin[[:space:]]*:)'
D_RE='(^|[^A-Za-z_0-9])assign[^A-Za-z_0-9]'

INC=(--include='*.sv' --include='*.svh' --include='*.v')

scan() {
  local root=$1 name=$2 depth=$3
  local files a b c d
  files=$(find "$root" -type f \( -name '*.sv' -o -name '*.svh' -o -name '*.v' \) 2>/dev/null | wc -l)
  grep -rlE "$A_RE" "${INC[@]}" "$root" 2>/dev/null | sort -u > "$OUT/A_$name"
  grep -rlE "$B_RE" "${INC[@]}" "$root" 2>/dev/null | sort -u > "$OUT/B_$name"
  grep -rlE "$C_RE" "${INC[@]}" "$root" 2>/dev/null | sort -u > "$OUT/C_$name"
  grep -rlE "$D_RE" "${INC[@]}" "$root" 2>/dev/null | sort -u > "$OUT/D_$name"
  a=$(wc -l < "$OUT/A_$name"); b=$(wc -l < "$OUT/B_$name")
  c=$(wc -l < "$OUT/C_$name"); d=$(wc -l < "$OUT/D_$name")
  comm -12 "$OUT/A_$name" "$OUT/C_$name" > "$OUT/AC_$name"
  comm -12 "$OUT/AC_$name" "$OUT/D_$name" > "$OUT/ACD_$name"
  echo "$name: files=$files  A(qual-in-call)=$a  B(wildcard-import,FYI)=$b  C(generate)=$c  D(assign)=$d  A&C&D=$(wc -l < "$OUT/ACD_$name")"
  sed "s|^$root/||" "$OUT/ACD_$name" | cut -d/ -f1-"$depth" | sort -u \
    > "$OUT/pred_$name.txt"
  echo "$name: candidate test dirs = $(wc -l < "$OUT/pred_$name.txt")"
}

mkdir -p "$OUT"
scan "$U2R" u2r 1
scan "$SLT" sltests 1
scan "$SL3" sl3rd 1
echo
echo "candidate lists written to $OUT/pred_*.txt"
echo "FALSIFIER: every byte mover reported by GATE 5 must appear in one of them."
