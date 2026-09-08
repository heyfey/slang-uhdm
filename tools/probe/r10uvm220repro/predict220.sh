#!/usr/bin/env bash
# r10uvm220 — THE A-PRIORI PREDICTOR (question 5).  MEASUREMENT ONLY.
# Run from PRISTINE databases and PRISTINE sources alone, BEFORE the patched
# binary is run on either corpus.
#
# § uninstIfaceForeachHdrUnresolved220 rides `uninstIfaceSubBody218`, which is
# raised at EXACTLY ONE call site: ModuleEmit.cpp's `emitTaskFuncs` for an
# interface definition with `defAllInstCount[&def] == 0`.  So the law needs
#   (1) a file set that declares an INTERFACE NOTHING INSTANTIATES,
#   (2) that interface to declare a SUBROUTINE, and
#   (3) that subroutine to contain a `foreach`.
# A row-mode missing any of the three is untouchable BY CONSTRUCTION.
#
#   STAGE 1 (source):   the compiled file set declares `interface <name>` and
#                       `<name>` is instantiated nowhere in the set; that file
#                       also writes `foreach` somewhere.
#   STAGE 2 (database): the row-mode's PRISTINE `slang.uhdm` EXISTS (a
#                       SLANG_REJECT row has no database to move) and really
#                       carries a `foreach_stmt` under `uhdmallInterfaces`.
#
# `include`d files are not listed in cmds.txt, which is why stage 2 re-reads the
# PRISTINE DATABASE rather than trusting the grep.  Every stage records what it
# rejected and why, so a row that reaches nothing is never read as perfection.
#
#   usage: predict220.sh <verify_golden-workdir> <out>
set -u
WD=${1:?workdir}; OUT=${2:?out}
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
[ -d "$WD" ] || { echo "FATAL: no workdir $WD"; exit 3; }
[ -x "$DUMP" ] || { echo "FATAL: no uhdm-dump $DUMP"; exit 3; }
: > "$OUT"
tot=0; s1=0; s2=0
for c in $(find "$WD" -name cmds.txt | sort); do
  d=$(dirname "$c")
  tot=$((tot+1))
  files=$(sed -n 's/^slang: *//p' "$c" | tr ' ' '\n' | grep -E '\.(sv|v|svh|vh)$'); true
  hit=""
  for f in $files; do
    [ -f "$f" ] || continue
    grep -qE '(^|[^A-Za-z0-9_$])foreach([^A-Za-z0-9_$]|$)' "$f" 2>/dev/null || continue
    ifs=$(grep -oE '^[[:space:]]*interface[[:space:]]+[A-Za-z_][A-Za-z0-9_$]*' "$f" 2>/dev/null | awk '{print $2}'); true
    for i in $ifs; do
      [ -n "$i" ] || continue
      inst=0
      for g in $files; do
        [ -f "$g" ] || continue
        if grep -qE "(^|[^A-Za-z0-9_$])$i[[:space:]]+[A-Za-z_][A-Za-z0-9_$]*[[:space:]]*[(\[]|(^|[^A-Za-z0-9_$])$i[[:space:]]*#[[:space:]]*\(" "$g" 2>/dev/null; then
          inst=1; break
        fi
      done
      [ "$inst" -eq 0 ] && hit="$hit $i"
    done
  done
  if [ -n "$hit" ]; then
    s1=$((s1+1))
    echo "STAGE1 $d uninstantiated-interface-with-foreach:$hit" >> "$OUT"
  fi
done
echo "-- STAGE1: $s1 of $tot row-modes carry a candidate" >> "$OUT"

# STAGE 2 — the database filter, over the STAGE 1 survivors only.
while read -r _ d _; do
  [ -n "${d:-}" ] || continue
  if [ ! -f "$d/slang.uhdm" ]; then
    echo "STAGE2 $d NO-DATABASE (SLANG_REJECT / no slang.uhdm) — untouchable" >> "$OUT"
    continue
  fi
  n=$("$DUMP" "$d/slang.uhdm" 2>/dev/null |
      awk '/^\|uhdm/{v=$0} /foreach_stmt/{if (v=="|uhdmallInterfaces:") c++} END{print c+0}')
  echo "STAGE2 $d foreach_stmt-under-uhdmallInterfaces=$n" >> "$OUT"
  [ "$n" -gt 0 ] && s2=$((s2+1))
done < <(grep '^STAGE1 ' "$OUT")
echo "-- STAGE2: $s2 row-modes PREDICTED TO MOVE" >> "$OUT"
grep -E '^-- STAGE' "$OUT"
