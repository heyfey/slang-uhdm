#!/bin/bash
# r10imex gates.  gate.sh u2r | gate.sh sl
W=$(cd "$(dirname "$0")/../../.." && pwd)
export SLANG_UHDM=${SLANG_UHDM:-$W/build/slang-uhdm}
cd "$W" || exit 1
case "$1" in
  u2r) python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode testflags \
         --out /tmp/r10imex_gate.csv --workdir /tmp/r10imex_gatew --jobs 3 ;;
  sl)  python3 scripts/verify_golden.py --corpus surelog --mode both \
         --out /tmp/r10imex_sl.csv --workdir /tmp/r10imex_slw --jobs 3 \
         --timeout 240 ;;
esac
