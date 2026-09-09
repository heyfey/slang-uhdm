#!/usr/bin/env bash
# r10uvm226 — RE-SCORE EVERY MOVED BOUNDARY ARM AGAINST A FRESH SURELOG,
# ON BOTH AXES.
#
# `bound226.sh` proves WHICH probe arms moved; it cannot say whether they moved
# toward golden.  This driver compiles each moved arm with the CANONICAL
# golden-side Surelog (the one `scripts/verify_golden.py` names) and scores it
# three ways on the CELL axis (a whole process subtree, keyed positionally the
# way `interface_inst::Compare` reads the vector) AND on the FIELD axis (every
# line of the flattened subtree) — because a whole-cell compare is blind to a
# single judge-visible field going right -> wrong inside a cell that is wrong on
# both binaries (r10v225 §2.1).
#
# An arm whose COMPILE fails on either side is reported as such and teaches
# error recovery, not golden (uvm215's lesson).
#
#   usage: bash bscore226.sh <BOUNDARY.txt> <boundary scratch> <out>
set -u
B=${1:?BOUNDARY.txt}; SCR=${2:?scratch}; OUT=${3:?out}
HERE=$(cd "$(dirname "$0")" && pwd)
SL=${SL:-$HOME/git-repos/Surelog/build/bin/surelog}
DUMP=${DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
: > "$OUT"
ctg=0; caw=0; csw=0; csr=0; ftg=0; faw=0; fsw=0; fsr=0; n=0; efail=0
for rel in $(grep '^MOVED ' "$B" | awk '{print $2}' | sort -u); do
    n=$((n+1))
    key=$(echo "$rel" | sed 's|^\./||; s|/|__|g; s|\.sv$||')
    src="$SCR/tree/${rel#./}"
    g="$SCR/gold/$key"; mkdir -p "$g"
    ( cd "$(dirname "$src")" && "$SL" -parse -nobuiltin -nocache -sv \
        "$(basename "$src")" > "$g/sl.log" 2>&1 </dev/null )
    grc=$?
    gdb=$(ls "$(dirname "$src")"/slpp_all/surelog.uhdm 2>/dev/null | head -1)
    if [ "$grc" != 0 ] || [ -z "$gdb" ]; then
        echo "ARM $rel  SURELOG rc=$grc  NO GOLDEN — error recovery, not golden" >> "$OUT"
        efail=$((efail+1))
        continue
    fi
    "$DUMP" "$gdb" > "$g/golden.dump" 2>/dev/null
    for ev in def elab; do
        d="$SCR/run/$key.$ev"
        [ -f "$d/a.uhdm" ] && [ -f "$d/b.uhdm" ] || continue
        "$DUMP" "$d/a.uhdm" > "$g/$ev.pris.dump" 2>/dev/null
        "$DUMP" "$d/b.uhdm" > "$g/$ev.pat.dump"  2>/dev/null
        read -r a b c e a2 b2 c2 e2 < <(python3 - "$g/golden.dump" "$g/$ev.pris.dump" "$g/$ev.pat.dump" "$HERE" <<'PY'
import subprocess, sys
gd, p1, p2, here = sys.argv[1:5]


def cells(p):
    out = {}
    txt = subprocess.run([sys.executable, here + '/proccen226.py', p],
                         capture_output=True, text=True).stdout
    for ln in txt.splitlines():
        if not ln.startswith('CELL '):
            continue
        k, _, v = ln[5:].partition(' | ')
        out[k.strip()] = v.strip()
    return out


def fields(d):
    out = {}
    for k, v in d.items():
        for i, t in enumerate(v.split(' ; ')):
            out['%s#%d' % (k, i)] = t
    return out


def score(g, o1, o2):
    tg = aw = sw = sr = 0
    for k in set(g) | set(o1) | set(o2):
        gv = g.get(k)
        ok1 = (o1.get(k) == gv) if gv is not None else (k not in o1)
        ok2 = (o2.get(k) == gv) if gv is not None else (k not in o2)
        if ok1 and ok2:
            sr += 1
        elif ok2:
            tg += 1
        elif ok1:
            aw += 1
        else:
            sw += 1
    return tg, aw, sw, sr


g, o1, o2 = cells(gd), cells(p1), cells(p2)
print(*score(g, o1, o2), *score(fields(g), fields(o1), fields(o2)))
PY
)
        echo "ARM $rel $ev  CELL TO-GOLDEN=$a AWAY=$b STILL-WRONG=$c SAME-RIGHT=$e  FIELD TO-GOLDEN=$a2 AWAY=$b2 STILL-WRONG=$c2 SAME-RIGHT=$e2" >> "$OUT"
        [ "${b:-0}" != 0 ] && echo "   !! CELL AWAY on $rel $ev" >> "$OUT"
        [ "${b2:-0}" != 0 ] && echo "   !! FIELD AWAY on $rel $ev" >> "$OUT"
        ctg=$((ctg+a)); caw=$((caw+b)); csw=$((csw+c)); csr=$((csr+e))
        ftg=$((ftg+a2)); faw=$((faw+b2)); fsw=$((fsw+c2)); fsr=$((fsr+e2))
    done
done
echo "-- MOVED_ARMS=$n  ERROR_RECOVERY_ARMS=$efail" >> "$OUT"
echo "-- CELL  TO-GOLDEN=$ctg  AWAY=$caw  STILL-WRONG=$csw  SAME-RIGHT=$csr" >> "$OUT"
echo "-- FIELD TO-GOLDEN=$ftg  AWAY=$faw  STILL-WRONG=$fsw  SAME-RIGHT=$fsr" >> "$OUT"
tail -3 "$OUT"
