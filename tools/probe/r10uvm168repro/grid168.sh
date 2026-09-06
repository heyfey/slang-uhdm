#!/usr/bin/env bash
# r10uvm168repro/grid168.sh — the grid driver.  MEASUREMENT ONLY.
#   grid168.sh <file.sv> <binA:pristine> <binB:patched> <workdir>
# Builds ONE Surelog golden and BOTH binaries' databases in BOTH views, dumps
# all six with uhdm-dump, and runs cen168.py over each dump.  Every command is
# echoed WITH ITS BINARY PATH into <workdir>/cmds.txt and EVERY rc recorded —
# an rc=139 SEGFAULT must never read as a result (RESUME §9).
# Descended from r10uvm164repro/grid164.sh.
set -u
SV=$(readlink -f "$1"); A=$2; B=$3; W=$4
SL=$HOME/git-repos/Surelog/build/bin/surelog
DUMP=${UHDM_DUMP:-$HOME/.local/bin/uhdm-dump}
CEN=$(dirname "$(readlink -f "$0")")/cen168.py
mkdir -p "$W"; : > "$W/cmds.txt"
run() { echo "CMD $*" >> "$W/cmds.txt"; "$@" > /dev/null 2>&1; echo "rc=$? $*" >> "$W/cmds.txt"; }
for v in def elab; do
  EF=""; SF=""
  [ "$v" = elab ] && { EF="--elabuhdm"; SF="-elabuhdm"; }
  ( cd "$W" && run "$SL" -parse -nocache -nowritecache -noprecompiledcache -d coveruhdm $SF -o "$W/g_$v" "$SV" )
  run "$A" "$SV" $EF -o "$W/a_$v.uhdm"
  run "$B" "$SV" $EF -o "$W/b_$v.uhdm"
  for pair in "g_$v/slpp_all/surelog.uhdm:g.$v" "a_$v.uhdm:a.$v" "b_$v.uhdm:b.$v"; do
    f=${pair%%:*}; tg=${pair#*:}
    if [ -f "$W/$f" ]; then
      "$DUMP" "$W/$f" > "$W/dump.$tg.txt" 2>>"$W/dump.err"
      echo "dump rc=$? $f" >> "$W/cmds.txt"
      python3 "$CEN" "$W/dump.$tg.txt" pa  > "$W/pa.$tg.txt"
      python3 "$CEN" "$W/dump.$tg.txt" all > "$W/all.$tg.txt"
    else
      : > "$W/dump.$tg.txt"; : > "$W/pa.$tg.txt"; : > "$W/all.$tg.txt"
      echo "dump MISSING $f" >> "$W/cmds.txt"
    fi
  done
done
for s in g a b; do
  sed 's/^/DEF\t/'  /dev/null > /dev/null
  cat "$W/pa.$s.def.txt"  "$W/pa.$s.elab.txt"  > "$W/pa.$s.txt"
  cat "$W/all.$s.def.txt" "$W/all.$s.elab.txt" > "$W/all.$s.txt"
done
wc -l "$W"/pa.g.txt "$W"/pa.a.txt "$W"/pa.b.txt "$W"/all.g.txt
echo "rc0 $(grep -c '^rc=0' "$W/cmds.txt"; true)"
grep '^rc=' "$W/cmds.txt" | grep -v '^rc=0' ; true
