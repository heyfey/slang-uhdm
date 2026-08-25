#!/usr/bin/env bash
# r10uvm130repro/attrib130.sh — ATTRIBUTE ONE DIFFERING BOUNDARY ARM (a FILE or
# a whole DIRECTORY) against GOLDEN.  MEASUREMENT ONLY.
#
#   attrib130.sh <file-or-dir> <bin A (pristine)> <bin B (patched)> <workdir> <cen bin>
#
# Builds golden (Surelog) and both binaries' databases in BOTH views, censuses
# all six, and prints the direction score.  Every command is echoed with its own
# rc into <workdir>/cmds.txt so the binary each database came from is auditable
# BY PATH (RESUME §9).  A DIRECTORY arm compiles all of its .sv/.v together,
# which is how the subdirectory arms are meant to be read.
set -u
SRC=$(readlink -f "$1"); A=$2; B=$3; W=$4; CEN=$5
SL=$HOME/git-repos/Surelog/build/bin/surelog
mkdir -p "$W"; : > "$W/cmds.txt"
if [ -d "$SRC" ]; then
  mapfile -t FILES < <(cd "$SRC" && ls *.sv *.v 2>/dev/null | LC_ALL=C sort | sed "s#^#$SRC/#")
else
  FILES=("$SRC")
fi
[ "${#FILES[@]}" -gt 0 ] || { echo "FATAL: no sources under $SRC"; exit 3; }
echo "ARM=$SRC FILES=${#FILES[@]}" >> "$W/cmds.txt"
run() { echo "$*" >> "$W/cmds.txt"; "$@" > /dev/null 2>&1; echo "rc=$? $*" >> "$W/cmds.txt"; }
for v in def elab; do
  EF=""; SF=""
  [ "$v" = elab ] && { EF="--elabuhdm"; SF="-elabuhdm"; }
  ( cd "$W" && run "$SL" -parse -nocache -nowritecache -noprecompiledcache -d coveruhdm $SF -o "$W/g_$v" "${FILES[@]}" )
  run "$A" "${FILES[@]}" $EF -o "$W/a_$v.uhdm"
  run "$B" "${FILES[@]}" $EF -o "$W/b_$v.uhdm"
  for pair in "g_$v/slpp_all/surelog.uhdm:G.$v:cen.g.$v.txt" "a_$v.uhdm:O.$v:cen.a.$v.txt" "b_$v.uhdm:O.$v:cen.b.$v.txt"; do
    f=${pair%%:*}; rest=${pair#*:}; tg=${rest%%:*}; out=${rest#*:}
    if [ -f "$W/$f" ]; then "$CEN" "$W/$f" "$tg" > "$W/$out" 2>>"$W/cen.err"; echo "cen rc=$? $f" >> "$W/cmds.txt"
    else : > "$W/$out"; echo "cen MISSING $f" >> "$W/cmds.txt"; fi
  done
done
cat "$W"/cen.g.def.txt "$W"/cen.g.elab.txt > "$W/cen.g.txt"
cat "$W"/cen.a.def.txt "$W"/cen.a.elab.txt > "$W/cen.a.txt"
cat "$W"/cen.b.def.txt "$W"/cen.b.elab.txt > "$W/cen.b.txt"
python3 "$(dirname "$0")/score130.py" "$W/cen.g.txt" "$W/cen.a.txt" "$W/cen.b.txt"
