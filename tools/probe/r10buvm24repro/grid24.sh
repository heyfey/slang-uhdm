#!/usr/bin/env bash
# r10buvm24repro/grid24.sh — build the THREE databases a grid cell needs, in
# BOTH views, and census them.  MEASUREMENT ONLY.
#
#   grid24.sh <file.sv> <pristine bin> <patched bin> <workdir> <cen bin>
#
# Views: `def` (no -elabuhdm / --elabuhdm) and `elab` (with it).  Surelog is the
# GOLDEN side in both.  Every command is echoed into <workdir>/cmds.txt so the
# binary each database came from is auditable by PATH, which is the trap
# RESUME §9 records.
set -u
SV=$(readlink -f "$1"); PRIS=$2; PAT=$3; W=$4; CEN=$5
SL=$HOME/git-repos/Surelog/build/bin/surelog
mkdir -p "$W"; : > "$W/cmds.txt"
run() { echo "$*" >> "$W/cmds.txt"; "$@" > /dev/null 2>&1; echo "rc=$? $*" >> "$W/cmds.txt"; }
for v in def elab; do
  EF=""; SF=""
  [ "$v" = elab ] && { EF="--elabuhdm"; SF="-elabuhdm"; }
  ( cd "$W" && run "$SL" -parse -nocache -nowritecache -noprecompiledcache -d coveruhdm $SF -o "$W/g_$v" "$SV" )
  run "$PRIS" "$SV" $EF -o "$W/pris_$v.uhdm"
  run "$PAT"  "$SV" $EF -o "$W/pat_$v.uhdm"
  "$CEN" "$W/g_$v/slpp_all/surelog.uhdm" "G.$v" > "$W/cen.g.$v.txt"  2>>"$W/cen.err"
  "$CEN" "$W/pris_$v.uhdm"               "O.$v" > "$W/cen.pris.$v.txt" 2>>"$W/cen.err"
  "$CEN" "$W/pat_$v.uhdm"                "O.$v" > "$W/cen.pat.$v.txt"  2>>"$W/cen.err"
done
cat "$W"/cen.g.def.txt    "$W"/cen.g.elab.txt    > "$W/cen.g.txt"
cat "$W"/cen.pris.def.txt "$W"/cen.pris.elab.txt > "$W/cen.pris.txt"
cat "$W"/cen.pat.def.txt  "$W"/cen.pat.elab.txt  > "$W/cen.pat.txt"
wc -l "$W"/cen.g.txt "$W"/cen.pris.txt "$W"/cen.pat.txt
