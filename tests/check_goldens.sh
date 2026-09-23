#!/usr/bin/env bash
# Regression check: slang-uhdm output must match committed golden dumps.
# Goldens were produced by Surelog cbdbea458c / UHDM 5523dfc; the corpus path
# inside them is spelled $CORPUS so the check is clone-independent.
# Every location resolves relative to this repository; override by env.
set -u
DIR=$(dirname "$(realpath "$0")")
ROOT=$(dirname "$DIR")
SLANG_UHDM=${SLANG_UHDM:-$ROOT/build/slang-uhdm}
SURELOG_ROOT=${SURELOG_ROOT:-$ROOT/third_party/Surelog}
UHDM_DUMP=${UHDM_DUMP:-$SURELOG_ROOT/build/third_party/UHDM/bin/uhdm-dump}
CORPUS=${CORPUS:-$ROOT/third_party/uhdm2rtlil/test}
for t in "$SLANG_UHDM" "$UHDM_DUMP"; do
    [ -x "$t" ] || { echo "missing tool: $t (see tests/README.md)"; exit 2; }
done
[ -d "$CORPUS" ] || { echo "missing corpus: $CORPUS (git submodule update --init)"; exit 2; }
fail=0
for g in "$DIR"/golden/*.dump; do
    t=$(basename "$g" .dump)
    W=$(mktemp -d)
    "$SLANG_UHDM" "$CORPUS/$t/dut.sv" --nobuiltin -o "$W/slang.uhdm" >/dev/null 2>&1
    "$UHDM_DUMP" "$W/slang.uhdm" 2>/dev/null | sed '1d' | sed "s|$CORPUS/|\$CORPUS/|g" > "$W/slang.dump"
    if diff -q "$g" "$W/slang.dump" >/dev/null; then
        echo "PASS $t"
    else
        echo "FAIL $t (diff $g $W/slang.dump)"
        fail=1
    fi
    [ $fail -eq 0 ] && rm -rf "$W"
done
exit $fail
