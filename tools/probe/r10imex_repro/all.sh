#!/bin/bash
# Runs every r10imex golden in both modes and prints the diff-line count.
R=$(cd "$(dirname "$0")" && pwd)
export SLANG_UHDM=${SLANG_UHDM:-$(cd "$R/../../.." && pwd)/build/slang-uhdm}
for t in "${@:-t1 t2 t3 t4 t5 t6}"; do
  "$R/run.sh" "$t"
  "$R/run.sh" "$t" -elabuhdm
done
