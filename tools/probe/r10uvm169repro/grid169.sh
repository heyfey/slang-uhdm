#!/usr/bin/env bash
# r10uvm169repro/grid169.sh — the grid driver.  MEASUREMENT ONLY.
#   grid169.sh <file.sv> <binA:pristine> <binB:patched> <workdir> <cen bin>
# Builds the golden (Surelog) and BOTH binaries' databases in BOTH views,
# echoing every command WITH ITS BINARY PATH into <workdir>/cmds.txt and
# recording every rc — an rc=139 SEGFAULT must never read as a result
# (RESUME.md §9).  Descended from r10uvm167repro/grid167.sh.
#
# The DEF and ELAB censuses are kept in SEPARATE files and the RUN tag is part
# of every row (r10uvm166 §6: merging the two views into one multiset
# manufactures phantom cells).
set -u
SV=$(readlink -f "$1"); A=$2; B=$3; W=$4; CEN=$5
SL=$HOME/git-repos/Surelog/build/bin/surelog
mkdir -p "$W"; : > "$W/cmds.txt"
run() { echo "CMD $*" >> "$W/cmds.txt"; "$@" > /dev/null 2>&1; echo "rc=$? $*" >> "$W/cmds.txt"; }
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
echo "-- Surelog units compiled (an arm that compiles to NOTHING reads green while testing nothing):"
grep -hoE 'Compile (package|class|module) "[^"]+"' "$W"/g_def/slpp_all/*.log 2>/dev/null | sort -u | head -40
grep -c '^rc=0' "$W/cmds.txt"; grep -v '^rc=0' "$W/cmds.txt" | grep '^rc=' ; true
