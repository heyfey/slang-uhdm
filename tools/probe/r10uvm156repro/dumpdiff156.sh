#!/usr/bin/env bash
# r10uvm156 — ORDER-BLIND whole-dump attribution of one byte mover.
# MEASUREMENT ONLY.  Both dumps are path-normalised (the workdir is embedded in
# the dump) and SORTED, so a pure ORDER flip reads 0 lines.
set -u
A=${1:?pristine db}; B=${2:?patched db}; T=${3:?tag}
D=$(mktemp -d)
~/.local/bin/uhdm-dump "$A" 2>/dev/null | sed 's#/tmp/[A-Za-z0-9_]*#WD#g' | sort > "$D/a"
~/.local/bin/uhdm-dump "$B" 2>/dev/null | sed 's#/tmp/[A-Za-z0-9_]*#WD#g' | sort > "$D/b"
n=$(diff "$D/a" "$D/b" | grep -c '^[<>]'; true)
echo "== $T  order-blind dump diff lines: $n"
diff "$D/a" "$D/b" | grep '^[<>]' | sed 's/, id:[0-9]*//' | sort | uniq -c | sort -rn
echo "-- distinct KINDS on the diff:"
diff "$D/a" "$D/b" | grep '^[<>]' | sed 's/^[<>] *//; s/^\\_//; s/:.*//' | sort -u
rm -rf "$D"
