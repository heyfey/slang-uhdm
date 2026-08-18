#!/usr/bin/env bash
# r10rgg10/cell10.sh — ONE grid cell: compile with both tools, census both.
# (A separate FILE, not an exported shell function: `export -f` does not
# survive into the xargs children in this environment, and the first run of
# run_grid10.sh silently measured ZERO cells because of it.  A driver that
# reaches nothing must never read as perfection — hence the counted status
# lines and the cells= assert in run_grid10.sh.)
set -u
d=$1; O=$2; BIN=$3; SURELOG=$4; CEN=$5
n=$(basename "$d")
( cd "$d" && "$SURELOG" -parse top.sv -mt 0 -mp 0 -o "$d/sl" >"$d/sl.log" 2>&1 </dev/null )
grc=$?
( cd "$d" && "$BIN" top.sv -o "$d/slang.uhdm" >"$d/sg.log" 2>&1 </dev/null )
src=$?
gdb=$d/sl/slpp_all/surelog.uhdm
if [ ! -f "$gdb" ]; then echo "$n NODB grc=$grc src=$src"; exit 0; fi
if [ ! -f "$d/slang.uhdm" ]; then echo "$n NOSLANG grc=$grc src=$src"; exit 0; fi
"$CEN" "$gdb" > "$O/$n.gold" 2>/dev/null
"$CEN" "$d/slang.uhdm" > "$O/$n.ours" 2>/dev/null
echo "$n OK grc=$grc src=$src"
