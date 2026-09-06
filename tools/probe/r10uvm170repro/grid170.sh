#!/usr/bin/env bash
# r10uvm170repro/grid170.sh — the grid driver.  MEASUREMENT ONLY.
#   grid170.sh <file.sv> <binA:pristine> <binB:patched> <workdir>
# Builds ONE Surelog golden and BOTH binaries' databases in BOTH views and runs
# `ct170cen` over all six.  Every command is echoed WITH ITS BINARY PATH into
# <workdir>/cmds.txt and EVERY rc is recorded — an rc=139 SEGFAULT must never
# read as a result (RESUME.md §9).  Descended from r10uvm168repro/grid168.sh.
set -u
SV=$(readlink -f "$1"); A=$2; B=$3; W=$4
SL=$HOME/git-repos/Surelog/build/bin/surelog
CEN=${CT170CEN:?set CT170CEN to the built ct170cen}
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
      for m in casts unsup tsrefs; do
        "$CEN" "$W/$f" --$m > "$W/$m.$tg.txt" 2>>"$W/cen.err"
        echo "cen rc=$? --$m $f" >> "$W/cmds.txt"
      done
    else
      for m in casts unsup tsrefs; do : > "$W/$m.$tg.txt"; done
      echo "cen MISSING $f" >> "$W/cmds.txt"
    fi
  done
done
for s in g a b; do
  for m in casts unsup tsrefs; do
    cat "$W/$m.$s.def.txt" "$W/$m.$s.elab.txt" > "$W/$m.$s.txt"
  done
done
wc -l "$W"/casts.g.txt "$W"/casts.a.txt "$W"/casts.b.txt "$W"/unsup.g.txt
echo "rc0 $(grep -c '^rc=0' "$W/cmds.txt"; true)"
grep '^rc=' "$W/cmds.txt" | grep -v '^rc=0' ; true
