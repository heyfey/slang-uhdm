#!/usr/bin/env bash
# v116 verifier grid: golden(Surelog) + A + B for ONE arm in BOTH views.
#   vgrid116.sh <file.sv> <binA> <binB> <workdir>
set -u
SV=$(readlink -f "$1"); A=$2; B=$3; W=$4
SL=$HOME/git-repos/Surelog/build/bin/surelog
DUMP=${UHDM_DUMP:-$HOME/.local/bin/uhdm-dump}
mkdir -p "$W"; : > "$W/cmds.txt"
run() { echo "CMD: $*" >> "$W/cmds.txt"; "$@" > /dev/null 2>&1; echo "rc=$? $*" >> "$W/cmds.txt"; }
for v in def elab; do
  EF=""; SF=""
  [ "$v" = elab ] && { EF="--elabuhdm"; SF="-elabuhdm"; }
  ( cd "$W" && run "$SL" -parse -nocache -nowritecache -noprecompiledcache -d coveruhdm $SF -o "$W/g_$v" "$SV" )
  run "$A" "$SV" $EF -o "$W/a_$v.uhdm"
  [ -n "$B" ] && run "$B" "$SV" $EF -o "$W/b_$v.uhdm"
  for pair in "g_$v/slpp_all/surelog.uhdm:g.$v" "a_$v.uhdm:a.$v" "b_$v.uhdm:b.$v"; do
    f=${pair%%:*}; tg=${pair#*:}
    if [ -f "$W/$f" ]; then
      "$DUMP" "$W/$f" 2>/dev/null | sed "s#$W/##g; s#$(dirname "$SV")/##g; s#^.*surelog\.uhdm:#DB:#; s#^a_$v\.uhdm:#DB:#; s#^b_$v\.uhdm:#DB:#" > "$W/dump.$tg.txt"
      echo "rc=$? dump $f" >> "$W/cmds.txt"
    else : > "$W/dump.$tg.txt"; echo "rc=MISSING dump $f" >> "$W/cmds.txt"; fi
  done
done
for v in def elab; do
  na=$(diff "$W/dump.g.$v.txt" "$W/dump.a.$v.txt" | grep -c '^[<>]'; true)
  nb=$(diff "$W/dump.g.$v.txt" "$W/dump.b.$v.txt" | grep -c '^[<>]'; true)
  printf "%-14s %-5s A=%-6s B=%-6s (gold %s lines)\n" "$(basename "$SV")" "$v" "$na" "$nb" "$(wc -l < "$W/dump.g.$v.txt")"
done
