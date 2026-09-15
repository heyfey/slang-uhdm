#!/usr/bin/env bash
# r11u36 A-PRIORI MOVER PREDICTION.
#
#   usage: predict.sh <pristine_workdir_root> <out_dir>
#
# The law adds a `Param_assigns` vector to every interface-ARRAY ELEMENT PORT
# VIEW.  A database therefore MOVES only if the pristine one already holds an
# interface_inst whose own `vpiName` ends in `[<digits>]` and whose parameter
# shape is EMPTY (par=0 pa=0) -- the shape the removed
# `ei->Param_assigns(nullptr)` / `ei->Parameters(nullptr)` pair leaves behind.
# Every element view with pa>0 is a HOME-view array element, which the law does
# not touch.
#
# The printed set is a SUPERSET of the movers (an element view of an
# UNPARAMETERISED interface also reads par=0 pa=0 and stays byte-identical),
# so a mover outside it is a REFUTATION; a non-mover inside it is not.
#
# POSITIVE CONTROL: `POSCTL=<name>[,<name>...]` asserts those tests are in the
# predicted set -- a lister that cannot see a KNOWN mover reports an empty set
# exactly like a clean run.
set -u
WD=${1:?pristine workdir root}
OUT=${2:?out dir}
DUMP=${UHDM_DUMP:-/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump}
HERE=$(dirname "$(readlink -f "$0")")
mkdir -p "$OUT"
: > "$OUT/predicted.txt"
: > "$OUT/elemshapes.txt"
for db in $(cd "$WD" && find . -name slang.uhdm | sort); do
    rel=${db#./}
    mode=${rel%%/*}
    dir=${rel#*/}
    name=${dir%%-*}
    name=${name%/*}
    "$DUMP" "$WD/$rel" > "$OUT/.tmp.dump" 2>/dev/null || continue
    els=$(python3 "$HERE/elemcen.py" --elems "$OUT/.tmp.dump")
    [ -n "$els" ] || continue
    printf '%s\n' "$els" | sed "s#^#$name/$mode #" >> "$OUT/elemshapes.txt"
    if printf '%s\n' "$els" | grep -q 'par=0 pa=0 elem=1'; then
        echo "$name/$mode" >> "$OUT/predicted.txt"
    fi
done
rm -f "$OUT/.tmp.dump"
sort -u "$OUT/predicted.txt" -o "$OUT/predicted.txt"
echo "PREDICTED $(wc -l < "$OUT/predicted.txt") rows; element views seen: $(wc -l < "$OUT/elemshapes.txt")"
rc=0
if [ -n "${POSCTL:-}" ]; then
    IFS=, read -ra ctl <<< "$POSCTL"
    for c in "${ctl[@]}"; do
        if grep -q "^$c/" "$OUT/predicted.txt"; then
            echo "POSCTL ok: $c is predicted"
        else
            echo "POSCTL FAILED: $c is NOT predicted -- the lister is blind"
            rc=5
        fi
    done
fi
exit $rc
