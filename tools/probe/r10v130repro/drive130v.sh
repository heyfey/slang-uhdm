#!/usr/bin/env bash
# r10v130repro/drive130v.sh — build golden + pristine + patched databases for one
# arm in BOTH views and census all six.  MEASUREMENT ONLY.
#   drive130v.sh <arm.sv> <pristine bin> <patched bin> <workdir> <cen bin>
# Every command is echoed with its own rc into <workdir>/cmds.txt so the binary
# each database came from is auditable BY PATH (RESUME §9).
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
  for pair in "g_$v/slpp_all/surelog.uhdm:G:cen.g.$v.txt" "a_$v.uhdm:O:cen.a.$v.txt" "b_$v.uhdm:O:cen.b.$v.txt"; do
    f=${pair%%:*}; rest=${pair#*:}; tg=${rest%%:*}; out=${rest#*:}
    if [ -f "$W/$f" ]; then "$CEN" "$W/$f" "$tg" | sed "s/^\([^\t]*\)\t/\1\t/" > "$W/$out" 2>>"$W/cen.err"
      # prefix the VIEW column with the run's view so def and elab never collide
      awk -v V="$v" 'BEGIN{FS=OFS="\t"} {$3=V"/"$3; print}' "$W/$out" > "$W/$out.v" && mv "$W/$out.v" "$W/$out"
      echo "cen rc=0 $f" >> "$W/cmds.txt"
    else : > "$W/$out"; echo "cen MISSING $f" >> "$W/cmds.txt"; fi
  done
done
cat "$W"/cen.g.def.txt "$W"/cen.g.elab.txt > "$W/cen.g.txt"
cat "$W"/cen.a.def.txt "$W"/cen.a.elab.txt > "$W/cen.a.txt"
cat "$W"/cen.b.def.txt "$W"/cen.b.elab.txt > "$W/cen.b.txt"
wc -l < "$W/cen.g.txt" | tr -d ' ' | sed 's/^/GOLDEN_ROWS=/'
