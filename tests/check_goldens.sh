#!/usr/bin/env bash
# Regression check: slang-uhdm output must match committed golden dumps.
# Goldens were produced by Surelog cbdbea458c / UHDM 5523dfc.
set -u
SLANG_UHDM=${SLANG_UHDM:-$HOME/git-repos/slang-uhdm/build/slang-uhdm}
UHDM_DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
CORPUS=${CORPUS:-$HOME/git-repos/uhdm2rtlil/test}
DIR=$(dirname "$(realpath "$0")")
fail=0
for g in "$DIR"/golden/*.dump; do
    t=$(basename "$g" .dump)
    W=$(mktemp -d)
    "$SLANG_UHDM" "$CORPUS/$t/dut.sv" --nobuiltin -o "$W/slang.uhdm" >/dev/null 2>&1
    "$UHDM_DUMP" "$W/slang.uhdm" 2>/dev/null | sed '1d' > "$W/slang.dump"
    if diff -q "$g" "$W/slang.dump" >/dev/null; then
        echo "PASS $t"
    else
        echo "FAIL $t (diff $g $W/slang.dump)"
        fail=1
    fi
    [ $fail -eq 0 ] && rm -rf "$W"
done
exit $fail
