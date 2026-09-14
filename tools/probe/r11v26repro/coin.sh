#!/usr/bin/env bash
# v11u26 verifier — ORDER-BLIND attribution of one surelog byte mover.
# Dumps both databases, normalises the workdir path and object ids OUT, sorts,
# and prints the surviving line-level delta.  A pristine-nondeterminism coin
# shows a 0-or-small order-blind delta made only of line-number-class lines
# (`UINT:<n>` and its `vpiDecompile:<n>`); a LAW mover shows named law lines.
set -u
rel=${1:?relative path under the workdir}
A=${A:-/tmp/v11u26_wdL/sl}; B=${B:-/tmp/v11u26_wdP/sl}
UD=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
t=$(mktemp -d /tmp/v11u26_coin_XXXX)
$UD "$A/$rel" 2>/dev/null | sed -e "s#$A/##g" -e 's/id:[0-9]*/id:#/g' | sort > "$t/a"
$UD "$B/$rel" 2>/dev/null | sed -e "s#$B/##g" -e 's/id:[0-9]*/id:#/g' | sort > "$t/b"
n=$(diff "$t/a" "$t/b" | grep -c '^[<>]'; true)
echo "== $rel : order-blind delta lines = $n"
diff "$t/a" "$t/b" | grep '^[<>]' | sed 's/^/   /'
rm -rf "$t"
