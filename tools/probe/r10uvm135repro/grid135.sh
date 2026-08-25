#!/usr/bin/env bash
# r10uvm135repro/grid135.sh — build the databases one grid arm needs, in BOTH
# views, and census them.  MEASUREMENT ONLY.
#
#   grid135.sh <file> <bin A> <bin B> <workdir> <cen bin>
#
# Views: `def` (no -elabuhdm / --elabuhdm) and `elab` (with it).  Surelog is the
# GOLDEN side in both.  Every command is echoed into <workdir>/cmds.txt so the
# binary each database came from is auditable BY PATH (RESUME §9), and every
# cell records its own rc (a rc=139 segfault must never read as a result).
set -u
SV=$(readlink -f "$1"); A=$2; B=$3; W=$4; CEN=$5
SL=$HOME/git-repos/Surelog/build/bin/surelog
mkdir -p "$W"; : > "$W/cmds.txt"
run() { echo "$*" >> "$W/cmds.txt"; "$@" > /dev/null 2>&1; echo "rc=$? $*" >> "$W/cmds.txt"; }
for v in def elab; do
  EF=""; SF=""
  [ "$v" = elab ] && { EF="--elabuhdm"; SF="-elabuhdm"; }
  ( cd "$W" && run "$SL" -parse -nocache -nowritecache -noprecompiledcache -d coveruhdm $SF -o "$W/g_$v" "$SV" )
  run "$A" "$SV" $EF -o "$W/a_$v.uhdm"
  run "$B" "$SV" $EF -o "$W/b_$v.uhdm"
  for pair in "g_$v/slpp_all/surelog.uhdm:G.$v:cen.g.$v.txt" "a_$v.uhdm:O.$v:cen.a.$v.txt" "b_$v.uhdm:O.$v:cen.b.$v.txt"; do
    f=${pair%%:*}; rest=${pair#*:}; tg=${rest%%:*}; out=${rest#*:}
    if [ -f "$W/$f" ]; then "$CEN" "$W/$f" "$tg" > "$W/$out" 2>>"$W/cen.err"; echo "cen rc=$? $f" >> "$W/cmds.txt"
    else : > "$W/$out"; echo "cen MISSING $f" >> "$W/cmds.txt"; fi
  done
done
cat "$W"/cen.g.def.txt "$W"/cen.g.elab.txt > "$W/cen.g.txt"
cat "$W"/cen.a.def.txt "$W"/cen.a.elab.txt > "$W/cen.a.txt"
cat "$W"/cen.b.def.txt "$W"/cen.b.elab.txt > "$W/cen.b.txt"
wc -l "$W"/cen.g.txt "$W"/cen.a.txt "$W"/cen.b.txt
