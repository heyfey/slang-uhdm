#!/usr/bin/env bash
# r10uvm221 — THE A-PRIORI PREDICTOR (question 5).  MEASUREMENT ONLY.  Written
# and RUN from PRISTINE databases and PRISTINE sources alone, BEFORE the patched
# binary is let near either corpus.
#
# § uninstIfaceEnumConstNoActual221 rides `uninstIfaceSubBody218`, which
# ModuleEmit.cpp raises at EXACTLY ONE call site: the `emitTaskFuncs` call an
# interface DEFINITION with `defAllInstCount[&def] == 0` makes.  A database that
# never compiled an interface no instance elaborates is untouchable BY
# CONSTRUCTION; and among those that did, only one whose body actually binds an
# `enum_const` can move a byte.
#
#   STAGE 1 (source):   the row-mode's own file set declares `interface <name>`
#                       and no compiled file instantiates `<name>`.  (`include`d
#                       files are not listed in cmds.txt, which is why stage 2
#                       re-reads the DATABASE rather than trusting the grep.)
#   STAGE 2 (database): the PRISTINE database carries, inside its
#                       `uhdmallInterfaces` listing, a `ref_obj` whose
#                       `vpiActual` is an `enum_const` — the exact cell this law
#                       declines.  The count of such cells is the predicted
#                       number of moved cells for that row-mode.
#
#   usage: predict221.sh <verify_golden-workdir> <out>
#
# GUARDS: a workdir that resolves to nothing is FATAL (a predictor that reads
# nothing must never print "no movers"); `grep -c` never gates a `set -e` chain.
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
  [ -n "$hit" ] || continue
  s1=$((s1+1))
  echo "STAGE1 $d uninstantiated-interface-candidates:$hit" >> "$OUT"
  if [ ! -f "$d/slang.uhdm" ]; then
    echo "STAGE2 $d NO-DATABASE (cannot move a byte)" >> "$OUT"
    continue
  fi
  # STAGE 2: count enum_const actuals inside the uhdmallInterfaces listing of
  # the PRISTINE database.
  n=$("$DUMP" "$d/slang.uhdm" 2>/dev/null | awk '
    /^\|uhdmallInterfaces:/ {inif=1}
    /^\\_weaklyReferenced:/ {inif=0}
    inif && /\|vpiActual:/  {pend=1; next}
    inif && pend            {if ($0 ~ /\\_enum_const:/) n++; pend=0}
    END {print n+0}')
  if [ "${n:-0}" -gt 0 ]; then
    s2=$((s2+1))
    echo "STAGE2 $d FIRES cells=$n" >> "$OUT"
  else
    echo "STAGE2 $d no-enum-const-actual-in-allInterfaces" >> "$OUT"
  fi
done
echo "-- STAGE1: $s1 of $tot row-modes carry a candidate; STAGE2 FIRES: $s2" >> "$OUT"
tail -1 "$OUT"
