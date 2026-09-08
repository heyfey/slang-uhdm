#!/usr/bin/env bash
# r10v204repro/arms204v.sh — the VERIFIER's five adversarial arms, driven by the
# implementer's own grid204.sh (one REAL Surelog golden per arm, BOTH views,
# BOTH binaries, every command AND ITS BINARY PATH echoed, every rc recorded).
# MEASUREMENT ONLY; the official uhdm-cmp is the sole judge.
#
#   CEN=<ct204cen> arms204v.sh <binA:pristine> <binB:under test> <outdir root>
#
# The arms, and the face each one breaks:
#   v204_n_nested   the INIT FORMS again but every loop inside a NESTED begin
#                   block — the case arm A never tested, and the only case in
#                   which the law MINTS a binding.  class / typedef-ALIAS /
#                   builtin / MULTIPLE declarators / plain assignment / string /
#                   a loop variable shadowing a block local.
#   v204_t_alias    which declared loop-variable KINDS golden binds: direct
#                   class, typedef alias of a class, typedef of a builtin, of a
#                   packed vector, of an enum, of a packed struct.
#   v204_s_shadow   for-in-for redeclaring a name, SIBLING loops sharing a name,
#                   foreach inside for, for inside foreach — all nested.
#   v204_m_module   module `initial`, module task, always_comb and a GENERATE
#                   for loop, with a wildcard-import clone in the same file so
#                   the clone map is non-empty.  None of it may move.
#   v204_c_clones   TWO wildcard-import clone copies of ONE subroutine.
set -u
A=${1:?pristine}; B=${2:?binary under test}; R=${3:?outdir}
CEN=${CEN:?set CEN to the built ct204cen}
HERE=$(cd "$(dirname "$0")" && pwd)
GRID=$HERE/../r10uvm204repro/grid204.sh
[ -f "$GRID" ] || { echo "FATAL: no $GRID"; exit 3; }
mkdir -p "$R"
for f in "$HERE"/arms204v/*.sv; do
  n=$(basename "$f" .sv)
  echo "######## $n"
  CEN=$CEN bash "$GRID" "$f" "$A" "$B" "$R/$n"
done
