#!/usr/bin/env bash
# r10uvm116repro/grid116.sh — build golden(Surelog) + ours for ONE arm in BOTH
# views and dump both.  MEASUREMENT ONLY.
#
#   grid116.sh <file.sv> <bin A> <bin B> <workdir>
#
# Traps honoured (RESUME §9): every command echoed with its OWN rc into
# cmds.txt so the binary each database came from is auditable BY PATH and a
# rc=139 segfault can never read as a result; scratch is keyed on the arm's
# RELATIVE path so two arms with the same basename cannot collide.
set -u
SV=$(readlink -f "$1"); A=$2; B=$3; W=$4
SL=$HOME/git-repos/Surelog/build/bin/surelog
DUMP=${UHDM_DUMP:-$HOME/.local/bin/uhdm-dump}
mkdir -p "$W"; : > "$W/cmds.txt"
run() { echo "$*" >> "$W/cmds.txt"; "$@" > /dev/null 2>&1; echo "rc=$? $*" >> "$W/cmds.txt"; }
for v in def elab; do
  EF=""; SF=""
  [ "$v" = elab ] && { EF="--elabuhdm"; SF="-elabuhdm"; }
  ( cd "$W" && run "$SL" -parse -nocache -nowritecache -noprecompiledcache -d coveruhdm $SF -o "$W/g_$v" "$SV" )
  run "$A" "$SV" $EF -o "$W/a_$v.uhdm"
  [ -n "$B" ] && run "$B" "$SV" $EF -o "$W/b_$v.uhdm"
  for pair in "g_$v/slpp_all/surelog.uhdm:g.$v" "a_$v.uhdm:a.$v" "b_$v.uhdm:b.$v"; do
    f=${pair%%:*}; tg=${pair#*:}
    if [ -f "$W/$f" ]; then
      "$DUMP" "$W/$f" 2>/dev/null | sed "s#$W/##g; s#$(dirname "$SV")/##g" > "$W/dump.$tg.txt"
      echo "dump rc=$? $f" >> "$W/cmds.txt"
    else : > "$W/dump.$tg.txt"; echo "dump MISSING $f" >> "$W/cmds.txt"; fi
  done
done
wc -l "$W"/dump.*.txt
