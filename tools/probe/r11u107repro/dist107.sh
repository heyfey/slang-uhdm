#!/bin/bash
# dist107.sh <arm-workdir> <tagA> <tagB>: whole-dump distance to golden
# (ordered `diff | grep -c '^[<>]'`, and order-blind on sorted dumps) for two
# binaries' databases.  Measurement only.
W=${1:?}; A=${2:?}; B=${3:?}
D=/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump
norm() { "$D" "$1" 2>/dev/null | tail -n +2 | sed -E 's#/tmp/[^ ,]*/##g'; }
norm "$W/gold.uhdm" > "$W/gold.n"
for t in "$A" "$B"; do norm "$W/$t.uhdm" > "$W/$t.n"; done
da=$(diff "$W/gold.n" "$W/$A.n" | grep -c '^[<>]'); db=$(diff "$W/gold.n" "$W/$B.n" | grep -c '^[<>]')
sa=$(diff <(sort "$W/gold.n") <(sort "$W/$A.n") | grep -c '^[<>]'); sb=$(diff <(sort "$W/gold.n") <(sort "$W/$B.n") | grep -c '^[<>]')
echo "$(basename "$W") ordered $da -> $db sorted $sa -> $sb"
