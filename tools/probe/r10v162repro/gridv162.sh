#!/usr/bin/env bash
# r10uvm162repro/grid162.sh — build the three databases one grid arm needs, in
# BOTH views, and put the OFFICIAL uhdm-cmp on each of ours.  MEASUREMENT ONLY;
# nothing here is an acceptance judge.  Descended from r10uvm160repro/grid160.sh
# with the same guards, plus the cmp verdict this pass scores its arms by.
#
#   usage: PRIS=<bin> PATCHED=<bin> grid162.sh <file.sv> <workdir>
#
# Views: `def` (no -elabuhdm / --elabuhdm) and `elab` (with it).  Surelog is the
# GOLDEN side in both.  Every command is echoed into <workdir>/cmds.txt so the
# binary each database came from is auditable BY PATH (RESUME §9), and every
# cell records its own rc — a rc=139 segfault must never read as a result.
# uhdm-cmp writes the head to STDERR, so both streams are captured; heads are
# counted with `grep -c '^LHS:'` anchored at column 0.
set -u
SV=$(readlink -f "$1"); W=$2
A=${PRIS:?PRIS=<pristine binary>}; B=${PATCHED:?PATCHED=<patched binary>}
SL=$HOME/git-repos/Surelog/build/bin/surelog
CMP=${UHDM_CMP:-$HOME/.local/bin/uhdm-cmp}
mkdir -p "$W"; : > "$W/cmds.txt"
run() { echo "$*" >> "$W/cmds.txt"; "$@" > /dev/null 2>&1; echo "rc=$? $*" >> "$W/cmds.txt"; }
NAME=$(basename "$SV" .sv)
for v in def elab; do
  EF=""; SF=""
  [ "$v" = elab ] && { EF="--elabuhdm"; SF="-elabuhdm"; }
  ( cd "$W" && run "$SL" -parse -nocache -nowritecache -noprecompiledcache \
        -d coveruhdm $SF -o "$W/g_$v" "$SV" )
  run "$A" "$SV" $EF -o "$W/a_$v.uhdm"
  run "$B" "$SV" $EF -o "$W/b_$v.uhdm"
  G="$W/g_$v/slpp_all/surelog.uhdm"
  for side in a b; do
    O="$W/${side}_$v.uhdm"
    if [ -f "$G" ] && [ -f "$O" ]; then
      "$CMP" "$G" "$O" > "$W/cmp.$side.$v.txt" 2>&1; crc=$?
      printf "%-22s %-4s %-9s cmplines=%-6s heads=%-3s cmp_rc=%s\n" "$NAME" "$v" \
        "$([ $side = a ] && echo PRISTINE || echo PATCHED)" \
        "$(wc -l < "$W/cmp.$side.$v.txt")" \
        "$(grep -c '^LHS:' "$W/cmp.$side.$v.txt")" "$crc"
    else
      printf "%-22s %-4s %-9s SKIP-NOFILE g=%s o=%s\n" "$NAME" "$v" "$side" \
        "$([ -f "$G" ] && echo ok || echo MISSING)" \
        "$([ -f "$O" ] && echo ok || echo MISSING)"
    fi
  done
  for pair in "$G:g" "$W/a_$v.uhdm:a" "$W/b_$v.uhdm:b"; do
    f=${pair%:*}; tg=${pair##*:}
    if [ -f "$f" ]; then uhdm-dump "$f" > "$W/$tg.$v.dump" 2>&1
      echo "dump rc=$? $f" >> "$W/cmds.txt"
    else : > "$W/$tg.$v.dump"; echo "dump MISSING $f" >> "$W/cmds.txt"; fi
  done
done
