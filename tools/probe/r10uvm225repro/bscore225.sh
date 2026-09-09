#!/usr/bin/env bash
# r10uvm225 — RE-SCORE EVERY MOVED BOUNDARY ARM AGAINST A FRESH SURELOG.
#
# `bound225.sh` proves WHICH probe arms moved; it cannot say whether they moved
# toward golden.  This driver compiles each moved arm with the CANONICAL
# golden-side Surelog (the one `scripts/verify_golden.py` names) and scores the
# array_net census of both binaries against it, three ways.  An arm whose
# COMPILE fails on either side is reported as such and teaches error recovery,
# not golden (uvm215's lesson).
#
#   usage: bash bscore225.sh <BOUNDARY.txt> <boundary scratch> <out>
set -u
B=${1:?BOUNDARY.txt}; SCR=${2:?scratch}; OUT=${3:?out}
HERE=$(cd "$(dirname "$0")" && pwd)
SL=${SL:-$HOME/git-repos/Surelog/build/bin/surelog}
DUMP=${DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
: > "$OUT"
tg=0; aw=0; sw=0; sr=0; n=0
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
        continue
    fi
    "$DUMP" "$gdb" > "$g/golden.dump" 2>/dev/null
    for ev in def elab; do
        d="$SCR/run/$key.$ev"
        [ -f "$d/a.uhdm" ] && [ -f "$d/b.uhdm" ] || continue
        "$DUMP" "$d/a.uhdm" > "$g/$ev.pris.dump" 2>/dev/null
        "$DUMP" "$d/b.uhdm" > "$g/$ev.pat.dump"  2>/dev/null
        read -r a b c e < <(python3 - "$g/golden.dump" "$g/$ev.pris.dump" "$g/$ev.pat.dump" "$HERE" <<'PY'
import subprocess, sys
gd, p1, p2, here = sys.argv[1:5]
def cells(p):
    out = {}
    txt = subprocess.run([sys.executable, here + '/anetcen225.py', p],
                         capture_output=True, text=True).stdout
    seen = {}
    for ln in txt.splitlines():
        if not ln.startswith('CELL '):
            continue
        k, _, v = ln[5:].partition(' | ')
        holder, _, full = k.partition(']=')
        holder = holder.split('[')[0]
        key = (holder, full)
        i = seen.get(key, 0); seen[key] = i + 1
        out[(holder, full, i)] = v
    return out
g, o1, o2 = cells(gd), cells(p1), cells(p2)
tg = aw = sw = sr = 0
for k in set(g) | set(o1) | set(o2):
    gv = g.get(k)
    ok1 = (o1.get(k) == gv) if gv is not None else (k not in o1)
    ok2 = (o2.get(k) == gv) if gv is not None else (k not in o2)
    if ok1 and ok2: sr += 1
    elif ok2:       tg += 1
    elif ok1:       aw += 1
    else:           sw += 1
print(tg, aw, sw, sr)
PY
)
        echo "ARM $rel $ev  TO-GOLDEN=$a AWAY=$b STILL-WRONG=$c SAME-RIGHT=$e" >> "$OUT"
        tg=$((tg+a)); aw=$((aw+b)); sw=$((sw+c)); sr=$((sr+e))
    done
done
echo "-- MOVED_ARMS=$n  TO-GOLDEN=$tg  AWAY=$aw  STILL-WRONG=$sw  SAME-RIGHT=$sr" >> "$OUT"
tail -1 "$OUT"
