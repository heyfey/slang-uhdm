#!/usr/bin/env bash
# r10v165repro/vgrid165.sh — the VERIFIER's own arm driver.  MEASUREMENT ONLY.
#   vgrid165.sh <file.sv> <binA:pristine> <binB:patched> <workdir>
# Builds the golden (Surelog) and BOTH binaries' databases in BOTH views and
# DUMPS all three with uhdm-dump.  Every command is echoed WITH ITS BINARY PATH
# into <workdir>/cmds.txt and every rc recorded (rc=139 must never read as a
# result).  Scratch is keyed on the workdir the caller names; nothing is
# hard-coded outside it.
set -u
SV=$(readlink -f "$1"); A=$2; B=$3; W=$4
SL=$HOME/git-repos/Surelog/build/bin/surelog
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
mkdir -p "$W"; : > "$W/cmds.txt"
run() { echo "CMD $*" >> "$W/cmds.txt"; "$@" > /dev/null 2>&1; echo "rc=$? $*" >> "$W/cmds.txt"; }
dump() { # dump <db> <out>
  if [ -f "$1" ]; then "$DUMP" "$1" > "$2" 2>>"$W/dump.err"; echo "dump rc=$? $1" >> "$W/cmds.txt"
  else : > "$2"; echo "dump MISSING $1" >> "$W/cmds.txt"; fi
}
for v in def elab; do
  EF=""; SF=""
  [ "$v" = elab ] && { EF="--elabuhdm"; SF="-elabuhdm"; }
  ( cd "$W" && run "$SL" -parse -nocache -nowritecache -noprecompiledcache -d coveruhdm $SF -o "$W/g_$v" "$SV" )
  run "$A" "$SV" $EF -o "$W/a_$v.uhdm"
  run "$B" "$SV" $EF -o "$W/b_$v.uhdm"
  dump "$W/g_$v/slpp_all/surelog.uhdm" "$W/g.$v.dump"
  dump "$W/a_$v.uhdm"                  "$W/a.$v.dump"
  dump "$W/b_$v.uhdm"                  "$W/b.$v.dump"
done
echo "rc0=$(grep -c '^rc=0' "$W/cmds.txt"; true)"
grep '^rc=' "$W/cmds.txt" | grep -v '^rc=0' ; true
