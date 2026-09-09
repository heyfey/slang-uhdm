#!/usr/bin/env bash
# r10v225 — RE-SCORE EVERY MOVED BOUNDARY ARM AGAINST A FRESH SURELOG, ON
# THREE AXES INSTEAD OF ONE.
#
#   usage: bash bscore2v225.sh <BOUNDARY.txt> <boundary scratch> <out>
#
# r10uvm225's `bscore225.sh` scores the ARRAY_NET census only.  R-A
# (`assocIdxIsBuiltin225`) also rewrites `defNetOmitsTypespec224`, which decides
# the holder's OWN `Nets()` entries, and a cell that is wrong on BOTH binaries
# can still contain a judge-visible FIELD that went from right to wrong.  Both
# blind spots hid a real regression in this pass (a class SPECIALIZATION index;
# an instantiated interface's `wire <vector typedef> x [dim]`), so the boundary
# re-score reads:
#
#   ANET   the array_net census, cell-keyed          (bscore225.sh's axis)
#   NET    the holder's own Nets() census, cell-keyed
#   FIELD  every field of both, scored INDEPENDENTLY
#
# AWAY must be zero on all three.
set -u
B=${1:?BOUNDARY.txt}; SCR=${2:?scratch}; OUT=${3:?out}
HERE=$(cd "$(dirname "$0")" && pwd)
SL=${SL:-$HOME/git-repos/Surelog/build/bin/surelog}
DUMP=${DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
: > "$OUT"
n=0; nog=0
for rel in $(grep '^MOVED ' "$B" | awk '{print $2}' | sort -u); do
    n=$((n+1))
    key=$(echo "$rel" | sed 's|^\./||; s|/|__|g; s|\.sv$||')
    src="$SCR/tree/${rel#./}"
    g="$SCR/gold2/$key"; mkdir -p "$g"
    ( cd "$(dirname "$src")" && "$SL" -parse -nobuiltin -nocache -sv \
        "$(basename "$src")" > "$g/sl.log" 2>&1 </dev/null )
    grc=$?
    gdb=$(ls "$(dirname "$src")"/slpp_all/surelog.uhdm 2>/dev/null | head -1)
    if [ "$grc" != 0 ] || [ -z "$gdb" ]; then
        echo "ARM $rel  SURELOG rc=$grc  NO GOLDEN — error recovery, not golden" >> "$OUT"
        nog=$((nog+1)); continue
    fi
    "$DUMP" "$gdb" > "$g/golden.dump" 2>/dev/null
    for ev in def elab; do
        d="$SCR/run/$key.$ev"
        [ -f "$d/a.uhdm" ] && [ -f "$d/b.uhdm" ] || continue
        "$DUMP" "$d/a.uhdm" > "$g/$ev.pris.dump" 2>/dev/null
        "$DUMP" "$d/b.uhdm" > "$g/$ev.pat.dump"  2>/dev/null
        python3 "$HERE/tri3v225.py" "$g/golden.dump" "$g/$ev.pris.dump" \
            "$g/$ev.pat.dump" "$rel $ev" >> "$OUT"
    done
done
python3 - "$OUT" "$n" "$nog" <<'PY'
import re, sys
tot = {}
for ln in open(sys.argv[1]):
    for ax in ('ANET', 'NET', 'FIELD'):
        m = re.search(r'%s TO-GOLDEN=(\d+) AWAY=(\d+) STILL-WRONG=(\d+) SAME-RIGHT=(\d+)' % ax, ln)
        if m:
            t = tot.setdefault(ax, [0, 0, 0, 0])
            for i in range(4):
                t[i] += int(m.group(i + 1))
print('-- MOVED_ARMS=%s  NO-GOLDEN=%s' % (sys.argv[2], sys.argv[3]))
for ax in ('ANET', 'NET', 'FIELD'):
    t = tot.get(ax, [0, 0, 0, 0])
    print('-- %-5s TO-GOLDEN=%d  AWAY=%d  STILL-WRONG=%d  SAME-RIGHT=%d'
          % (ax, *t))
PY
