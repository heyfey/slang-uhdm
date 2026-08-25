#!/usr/bin/env bash
# v85 verifier arm driver: golden(Surelog) vs pristine vs patched, both views.
set -u
SL=$HOME/git-repos/Surelog/build/bin/surelog
CMP=$HOME/git-repos/UHDM/build/bin/uhdm-cmp
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
CEN=/tmp/v85_pacen85
PRIS=/tmp/v85_pris.bin; PAT=/tmp/v85_pat.bin
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-}:$HOME/.local/lib64:$HOME/.local/lib
F=$(readlink -f "$1"); B=$(basename "$F"); E=${2:-plain}
D=/tmp/v85_arms/$(basename "$F" .sv)_$E; rm -rf "$D"; mkdir -p "$D"
SLX=""; OUX=""
[ "$E" = elab ] && { SLX="-elabuhdm"; OUX="--elabuhdm"; }
cp "$F" "$D/"
( cd "$D" && "$SL" -parse -nobuiltin -nocache -sv $SLX -d uhdm "$B" >sl.log 2>&1 </dev/null ); echo "SL   rc=$?"
[ -f "$D/slpp_all/surelog.uhdm" ] && cp "$D/slpp_all/surelog.uhdm" "$D/g.uhdm"
( cd "$D" && "$PRIS" --nobuiltin $OUX "$B" -o o.uhdm >o.log 2>&1 </dev/null ); echo "pris rc=$?"
( cd "$D" && "$PAT"  --nobuiltin $OUX "$B" -o q.uhdm >q.log 2>&1 </dev/null ); echo "patc rc=$?"
for t in g o q; do [ -f "$D/$t.uhdm" ] || { echo "MISSING $t.uhdm in $D"; exit 1; }; done
for t in g o q; do "$CEN" "$D/$t.uhdm" --inst 2>/dev/null > "$D/$t.rows"; done
echo -n "cmp pris: "; ( cd "$D" && "$CMP" g.uhdm o.uhdm > cmp_o.out 2> cmp_o.err; echo "rc=$? headlines=$(wc -l < cmp_o.err)" )
echo -n "cmp patc: "; ( cd "$D" && "$CMP" g.uhdm q.uhdm > cmp_q.out 2> cmp_q.err; echo "rc=$? headlines=$(wc -l < cmp_q.err)" )
echo "-- rows g=$(wc -l < "$D/g.rows") o=$(wc -l < "$D/o.rows") q=$(wc -l < "$D/q.rows")"
python3 /tmp/wt_v85/tools/probe/r10earl85repro/score85.py "$D/g.rows" "$D/o.rows" "$D/q.rows" > "$D/score.txt"
head -8 "$D/score.txt"
echo "DIR=$D"
