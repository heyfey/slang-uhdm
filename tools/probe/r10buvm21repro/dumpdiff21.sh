#!/usr/bin/env bash
# r10buvm21repro/dumpdiff21.sh — the ORDER-BLIND and the whole-dump diff of one
# test's two databases (pristine vs patched), with the workdir path and the
# uhdm-dump BANNER normalised away (RESUME §9: dump paths embed the workdir; the
# first line is `<file>: Restored design ...`).  MEASUREMENT ONLY.
#
# usage: dumpdiff21.sh <prisdir> <patdir>   (each holding a slang.uhdm)
set -u
A=${1:?pristine test dir}; B=${2:?patched test dir}
T=$(mktemp -d)
norm() { sed -e '1s#^[^:]*\.uhdm:#<DB>:#' -e "s#$1#<WD>#g"; }
uhdm-dump "$A/slang.uhdm" 2>&1 | norm "$A" > "$T/a.txt"
uhdm-dump "$B/slang.uhdm" 2>&1 | norm "$B" > "$T/b.txt"
echo "== whole-dump diff (removed/added)"
diff "$T/a.txt" "$T/b.txt" > "$T/d.txt"; true
echo "removed=$(grep -c '^<' "$T/d.txt"; true) added=$(grep -c '^>' "$T/d.txt"; true) hunks=$(grep -c '^[0-9]' "$T/d.txt"; true)"
echo "== ORDER-BLIND diff (both sorted) -- 0 lines means a NONDETERMINISM COIN, not a mover"
sort "$T/a.txt" > "$T/as.txt"; sort "$T/b.txt" > "$T/bs.txt"
diff "$T/as.txt" "$T/bs.txt" > "$T/ds.txt"; true
echo "order-blind lines=$(grep -c '^[<>]' "$T/ds.txt"; true)  vpiActual lines=$(grep -c 'vpiActual' "$T/ds.txt"; true)"
echo "$T"
