#!/usr/bin/env bash
# r10v166 VERIFIER — one arm, both views, THREE databases, judged by the
# OFFICIAL uhdm-cmp (golden LHS, ours RHS) and censused by ct166cen.
#   armjudge.sh <file.sv> <outroot> [<extra .sv> ...]
# Every command is echoed WITH ITS BINARY PATH into <w>/cmds.txt with its rc;
# an rc=139 must never read as a result.
set -u
SV=$(readlink -f "$1"); OUT=$2; shift 2
EXTRA=""
for e in "$@"; do EXTRA="$EXTRA $(readlink -f "$e")"; done
A=${PRIS:-/tmp/v166_bin/pris.bin}
B=${PATB:-/tmp/v166_bin/pat.bin}
CEN=${CEN:-/tmp/v166_bin/ct166cen}
CMP=${UHDM_CMP:-$HOME/.local/bin/uhdm-cmp}
SL=$HOME/git-repos/Surelog/build/bin/surelog
N=$(basename "$SV" .sv)
W=$OUT/$N
rm -rf "$W"; mkdir -p "$W"; : > "$W/cmds.txt"
run() { echo "CMD $*" >> "$W/cmds.txt"; "$@" > /dev/null 2>&1; local r=$?; echo "rc=$r $*" >> "$W/cmds.txt"; return $r; }
for v in def elab; do
  EF=""; SF=""
  [ "$v" = elab ] && { EF="--elabuhdm"; SF="-elabuhdm"; }
  ( cd "$W" && run "$SL" -parse -nocache -nowritecache -noprecompiledcache -d coveruhdm $SF -o "$W/g_$v" $EXTRA "$SV" )
  run "$A" $EXTRA "$SV" $EF -o "$W/a_$v.uhdm"
  run "$B" $EXTRA "$SV" $EF -o "$W/b_$v.uhdm"
  G="$W/g_$v/slpp_all/surelog.uhdm"
  for side in a b; do
    O="$W/${side}_$v.uhdm"
    if [ -f "$G" ] && [ -f "$O" ]; then
      "$CMP" "$G" "$O" > "$W/cmp.$side.$v.txt" 2>&1; c=$?
      printf "%-16s %-4s %-4s cmplines=%-6s heads=%-4s cmprc=%s\n" "$N" "$v" "$side" \
        "$(wc -l < "$W/cmp.$side.$v.txt")" "$(grep -c '^LHS:' "$W/cmp.$side.$v.txt")" "$c"
    else
      printf "%-16s %-4s %-4s MISSING g=%s o=%s\n" "$N" "$v" "$side" \
        "$([ -f "$G" ] && echo y || echo n)" "$([ -f "$O" ] && echo y || echo n)"
    fi
    if [ -x "$CEN" ] && [ -f "$O" ]; then "$CEN" "$O" "O.$v" > "$W/cen.$side.$v.txt" 2>>"$W/cen.err"; fi
  done
  [ -x "$CEN" ] && [ -f "$G" ] && "$CEN" "$G" "G.$v" > "$W/cen.g.$v.txt" 2>>"$W/cen.err"
done
cat "$W"/cen.g.def.txt "$W"/cen.g.elab.txt > "$W/cen.g.txt" 2>/dev/null
cat "$W"/cen.a.def.txt "$W"/cen.a.elab.txt > "$W/cen.a.txt" 2>/dev/null
cat "$W"/cen.b.def.txt "$W"/cen.b.elab.txt > "$W/cen.b.txt" 2>/dev/null
# COMPILED-SOMETHING assertion: a negative control that parses nothing reads
# byte-identical while testing nothing (r10uvm166 README sec.4.4).
echo "-- surelog units:"; grep -hE '^\[INF:(CP014[0-9]|CP0140|CP0141)\]|Compile (package|class|module)|Top level module' "$W"/g_def/slpp_all/*.log 2>/dev/null | head -0
( cd "$W/g_def" 2>/dev/null && grep -rhoE '(Compile (package|class|module|program) [A-Za-z_@:0-9]+|Top level module[s]? [A-Za-z_@:0-9]+)' . 2>/dev/null | sort -u | head -40 )
echo "-- rc!=0:"; grep '^rc=' "$W/cmds.txt" | grep -v '^rc=0' ; true
echo "-- binaries named in cmds.txt:"; grep -oE '(/tmp/v166_bin/[a-z]+\.bin|/home/[^ ]*surelog)' "$W/cmds.txt" | sort | uniq -c
