#!/usr/bin/env bash
# r10earl32 — THE SOURCE-DERIVED MOVER FENCE, computed from the corpus SOURCES
# alone and BEFORE the patched sweeps are read.
#
# § fcArgPkgParamValueFolds32 can only change a database that contains a
# SUBROUTINE CALL WHOSE ARGUMENT NAMES A PACKAGE PARAMETER.  Neither half of
# that is decidable without a compiler, so this computes a deliberately LOOSE
# UPPER BOUND from two necessary textual conditions:
#
#   A  a `::`-qualified name inside a call's argument list
#      (the only way to write the QUALIFIED spelling at all)
#   B  a wildcard package import in the file
#      (the only way to reach the BARE spelling)
#
# It cannot tell a package parameter from an enum literal, a type name or a
# module localparam, and it does not parse.  That is the point: it is
# FALSIFIABLE.  EVERY measured byte mover must be inside the candidate set, and
# a mover outside it refutes the law's stated reach.
#
#   usage: pred32.sh
set -u
U2R=$HOME/git-repos/uhdm2rtlil/test
SLT=$HOME/git-repos/Surelog/tests
SL3=$HOME/git-repos/Surelog/third_party/tests

# A: an identifier immediately followed by '(' whose argument text carries '::'
A_RE='[A-Za-z_][A-Za-z_0-9]*[[:space:]]*\([^();]*[A-Za-z_][A-Za-z_0-9]*::[A-Za-z_][A-Za-z_0-9]*'
# B: a wildcard import
B_RE='import[[:space:]]+[A-Za-z_][A-Za-z_0-9]*::\*'

scan() {
  local root=$1 name=$2 depth=$3
  local files a b
  files=$(find "$root" -type f \( -name '*.sv' -o -name '*.svh' -o -name '*.v' \) 2>/dev/null | wc -l)
  a=$(grep -rlE "$A_RE" --include='*.sv' --include='*.svh' --include='*.v' "$root" 2>/dev/null | wc -l)
  b=$(grep -rlE "$B_RE" --include='*.sv' --include='*.svh' --include='*.v' "$root" 2>/dev/null | wc -l)
  echo "$name: files=$files  A(qualified-in-call)=$a  B(wildcard-import)=$b"
  { grep -rlE "$A_RE" --include='*.sv' --include='*.svh' --include='*.v' "$root" 2>/dev/null
    grep -rlE "$B_RE" --include='*.sv' --include='*.svh' --include='*.v' "$root" 2>/dev/null
  } | sed "s|^$root/||" | cut -d/ -f1-"$depth" | sort -u > "/tmp/e32/pred_$name.txt"
  echo "$name: candidate test dirs = $(wc -l < "/tmp/e32/pred_$name.txt")"
}

mkdir -p /tmp/e32
scan "$U2R" u2r 1
scan "$SLT" sltests 1
scan "$SL3" sl3rd 1
echo
echo "candidate lists written to /tmp/e32/pred_*.txt"
echo "FALSIFIER: every byte mover reported by GATE 5 must appear in one of them."
