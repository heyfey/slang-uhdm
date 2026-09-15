#!/bin/bash
# v11u34 verifier arm runner: one .sv through Surelog (golden) and BOTH of my
# frozen binaries.  usage: arm.sh <file.sv> <outdir>
set -u
F=$(readlink -f "${1:?file}"); OUT=${2:?outdir}
SL=$HOME/git-repos/Surelog/build/bin/surelog
DUMP=/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump
# Both binaries are parameters; nothing here hard-codes another pass's tree.
PRIS=${PRIS:?set PRIS to the frozen PRISTINE binary}
PAT=${PAT:?set PAT to the frozen PATCHED binary}
rm -rf "$OUT"; mkdir -p "$OUT/g" "$OUT/p" "$OUT/q"
( cd "$OUT/g" && "$SL" -parse -nobuiltin -nocache -sv "$F" -mt 0 -mp 0 -o . > sl.log 2>&1 ); grc=$?
( cd "$OUT/p" && "$PRIS" "$F" --single-unit -o slang.uhdm > our.log 2>&1 ); prc=$?
( cd "$OUT/q" && "$PAT"  "$F" --single-unit -o slang.uhdm > our.log 2>&1 ); qrc=$?
G=$(ls "$OUT"/g/slpp_all/*.uhdm 2>/dev/null | head -1)
slerr=$(grep -c '\[ERROR\]' "$OUT/g/sl.log" 2>/dev/null; true)
echo "ARM $(basename "$F") slrc=$grc slerr=$slerr prisrc=$prc patrc=$qrc"
[ -n "$G" ] && "$DUMP" "$G" | sed "s#$OUT##g" > "$OUT/g.dump" 2>&1
[ -f "$OUT/p/slang.uhdm" ] && "$DUMP" "$OUT/p/slang.uhdm" | sed "s#$OUT##g" > "$OUT/p.dump" 2>&1
[ -f "$OUT/q/slang.uhdm" ] && "$DUMP" "$OUT/q/slang.uhdm" | sed "s#$OUT##g" > "$OUT/q.dump" 2>&1
for s in g p q; do
  printf '  %s.dump=%s\n' "$s" "$( [ -s "$OUT/$s.dump" ] && wc -l < "$OUT/$s.dump" || echo NONE)"
done
