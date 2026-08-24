#!/usr/bin/env bash
# r10uvm118 — build ONE arm with Surelog (GOLDEN) and with the two FROZEN
# binaries in BOTH views, census each with ct118cen and score.
# MEASUREMENT ONLY; the official uhdm-cmp stays the judge on the corpus.
#   usage: arm118.sh <file.sv> <outdir>
#   env:   SURELOG PRIS PATCHED CEN118 JOIN118
# Every child gets </dev/null and its rc is RECORDED (a rc=139 that leaves a
# short .uhdm behind must never read as "no difference").
set -u
SL=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
CEN=${CEN118:?set CEN118}; JOIN=${JOIN118:?set JOIN118}
PRIS=${PRIS:?}; PATCHED=${PATCHED:?}
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-}:$HOME/.local/lib64:$HOME/.local/lib
F=$(readlink -f "$1"); mkdir -p "$2"; D=$(readlink -f "$2"); B=$(basename "$F")
cp "$F" "$D/"
( cd "$D" && "$SL" -parse -nobuiltin -nocache -d uhdm "$B" >sl.log 2>&1 </dev/null ); echo "SL    rc=$?"
[ -f "$D/slpp_all/surelog.uhdm" ] && cp "$D/slpp_all/surelog.uhdm" "$D/g.uhdm"
( cd "$D" && "$PRIS"    "$B"            -o o.uhdm  >o.log  2>&1 </dev/null ); echo "pris  rc=$?"
( cd "$D" && "$PRIS"    "$B" --elabuhdm -o oe.uhdm >oe.log 2>&1 </dev/null ); echo "prisE rc=$?"
( cd "$D" && "$PATCHED" "$B"            -o q.uhdm  >q.log  2>&1 </dev/null ); echo "patc  rc=$?"
( cd "$D" && "$PATCHED" "$B" --elabuhdm -o qe.uhdm >qe.log 2>&1 </dev/null ); echo "patcE rc=$?"
for t in g o oe q qe; do
  [ -f "$D/$t.uhdm" ] || { echo "MISSING $t.uhdm"; continue; }
  "$CEN" "$D/$t.uhdm" --all > "$D/$t.all" 2>"$D/$t.sum"
  "$CEN" "$D/$t.uhdm" --cast > "$D/$t.cast" 2>/dev/null
  printf "%-3s %s\n" "$t" "$(sed -n 's/^-- //p' "$D/$t.sum")"
done
# score on the reduced key (OPT/NOPS/SPAN/PAR) — see join118.py's header
red() { awk -F'\t' '{split($0,a,"\t\\|\\|\t"); k=""; n=split(a[1],f,"\t");
        for(i=1;i<=n;i++) if(f[i] ~ /^(OPT|NOPS|SPAN|PAR)=/) k=k f[i] "\t";
        print k "||\t" a[2]}' "$1" | sort; }
for pair in "o:default" "q:default" "oe:elab" "qe:elab"; do
  t=${pair%%:*}; v=${pair##*:}
  [ -f "$D/$t.all" ] || continue
  red "$D/g.all" > "$D/g.k"; red "$D/$t.all" > "$D/$t.k"
  echo "-- $v $( [ "$t" = o ] || [ "$t" = oe ] && echo PRISTINE || echo PATCHED ) vs GOLDEN (all operations)"
  python3 "$JOIN" "$D/g.k" "$D/$t.k"
done
