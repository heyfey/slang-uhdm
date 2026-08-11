#!/usr/bin/env bash
# r10oth8 — run EVERY arm and print EVERY arm table, both sides, own depth.
#
#   usage: SLANG_UHDM=/path/to/build/slang-uhdm ./ct8all.sh <tag>
#
# <tag> names the workdir root (`/tmp/r10oth8_<tag>_<arm>`), so the SAME script
# produces the pristine and the patched readings and the two can never come from
# differently-built instruments.  LHS is ALWAYS golden (Surelog); RHS is ALWAYS
# ours.  Every table restricts field comparison to the array_var's OWN CHILD
# DEPTH and reports nested fields in their own column; a cell that cannot be
# resolved prints UNMEASURED.
set -u
: "${SLANG_UHDM:?set SLANG_UHDM to the build under test}"
HERE=$(cd "$(dirname "$0")" && pwd)
TAG=${1:?tag (e.g. pri or fin)}
# arm : name-prefix(es) to tabulate
run() {  # <src> <prefix>...
  local src=$1; shift
  local b=${src%.*}
  local wd=/tmp/r10oth8_${TAG}_${b%%_*}
  echo "############ $src  ->  $wd"
  bash "$HERE/ct8arm.sh" "$src" "$wd" || { echo "ARM FAILED: $src"; return 1; }
  for p in "$@"; do
    echo "---- $src cells '$p*'"
    python3 "$HERE/ct8grid.py" "$wd/g.dump" "$wd/o.dump" vpiSigned "$p"
  done
}
run a1_class.sv    a
run a2_module.sv   a
run a3_elemkind.sv c
run a4_modelem.sv  c
run a5_written.sv  d e
run a6_kindgate.sv f g
run a7_fixedtd.sv  h
run a8_pkgtd.sv    k m
run a9_scope.sv    p n
# VERIFIER-ADDED (finding F1), wired in by the master at integration: the packed
# wrapper over a TYPEDEF NAME.  Without this arm the predicate's clause (b) reads
# green on 122 cells while piercing a typedef through a `[3:0]` — the exact
# behaviour the pass exists to remove.  `v02`/`w02` are the POSITIVE control.
run v1_pkarrtd.sv  v w
echo "############ md5 of the instrument under test"
md5sum "$SLANG_UHDM"
