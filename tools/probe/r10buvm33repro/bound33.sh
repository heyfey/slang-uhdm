#!/usr/bin/env bash
# r10buvm33repro/bound33.sh — THE BOUNDARY GATE (bound24.sh, unchanged but for this header and the default OUT).
# Compiles EVERY .sv AND .v arm under a COPY of the whole probe tree (NO path
# filter) with both binaries, in BOTH views (default and --elabuhdm), and
# asserts the uhdm-dump TEXT is byte-identical — so any bind-window law whose
# arm lives in the tree (buvm13/15/16, uvm88/90, sd8-12, classArgBind12,
# § controlBodyNoBind28, § blkLocalSameCtrlDepthArgBinds57/64,
# § pkgVarBindsOnlyThroughInstance88, § superNewFormalBinds28,
# § classInBodyRecvCallArgNoBind52, § newArrayArgNoBind16 …) is proved
# untouched, and so are the uvm89/92/94/95 hier_path NAME-TEXT laws and the
# § builtinRecvIndexedStepIsBitSelect74 / § …Chain14 arms.
#
# MODE=file (default) compiles each arm alone; MODE=dir compiles every arm of a
# directory TOGETHER, which is how the sd8-12 SUBDIRECTORY arms are meant to be
# read (a top-level glob runs nothing and prints green).
#
# GUARDS, each one paid for by an earlier pass: the arm list rides fd 3 (a child
# that reads stdin cannot eat it), every child gets </dev/null, PROCESSED is
# asserted against the list length, scratch is keyed on the RELATIVE path (three
# different `dut.sv` exist), and uhdm-dump's `Restored design` banner is
# normalised away (without it EVERY arm reads "differing").
set -u
: "${PRISTINE:?}"; : "${PATCHED:?}"; : "${ROOT:?probe root (a COPY)}"
OUT=${OUT:-/tmp/r10buvm32_bound}
MODE=${MODE:-file}
VIEW=${VIEW:-def}          # def | elab
EF=""; [ "$VIEW" = elab ] && EF="--elabuhdm"
rm -rf "$OUT"; mkdir -p "$OUT"
LIST=$OUT/arms.txt
if [ "$MODE" = dir ]; then
  ( cd "$ROOT" && find . \( -name '*.sv' -o -name '*.v' \) -type f -printf '%h\n' | LC_ALL=C sort -u ) > "$LIST"
else
  ( cd "$ROOT" && find . \( -name '*.sv' -o -name '*.v' \) -type f | LC_ALL=C sort ) > "$LIST"
fi
N=$(wc -l < "$LIST")
echo "== boundary gate: MODE=$MODE VIEW=$VIEW  $N arms under $ROOT"
proc=0; diffn=0; rejp=0; rejq=0
exec 3< "$LIST"
while IFS= read -r rel <&3; do
  proc=$((proc+1))
  key=$(printf '%s' "$rel" | sed 's#^\./##; s#/#__#g; s#\.\(sv\|v\)$##')
  # GUARD (r10buvm32): MODE=dir lists the ROOT itself as `.`, whose key is the
  # EMPTY string — `$OUT/` then aliases the output directory and the cleanup
  # `rm -rf "$d"` tries to delete the whole run.  Name that arm explicitly.
  [ -n "$key" ] && [ "$key" != "." ] || key=ROOT
  d="$OUT/$key"; mkdir -p "$d"
  if [ "$MODE" = dir ]; then
    srcs=(); while IFS= read -r f; do srcs+=("$ROOT/$rel/$f"); done < <(cd "$ROOT/$rel" && ls *.sv *.v 2>/dev/null | LC_ALL=C sort)
  else
    cp "$ROOT/$rel" "$d/a.${rel##*.}"; srcs=("$d/a.${rel##*.}")
  fi
  ( cd "$d" && "$PRISTINE" "${srcs[@]}" $EF -o p.uhdm >p.log 2>&1; echo "rc=$?" >> p.log ) </dev/null
  ( cd "$d" && "$PATCHED"  "${srcs[@]}" $EF -o q.uhdm >q.log 2>&1; echo "rc=$?" >> q.log ) </dev/null
  if [ ! -s "$d/p.uhdm" ] && [ ! -s "$d/q.uhdm" ]; then
     rejp=$((rejp+1)); rejq=$((rejq+1)); echo "BOTH-REJECT $rel" >> "$OUT/reject.txt"; rm -rf "$d"; continue
  fi
  [ -s "$d/p.uhdm" ] || { rejp=$((rejp+1)); echo "PRIS-ONLY-REJECT $rel" >> "$OUT/asym.txt"; }
  [ -s "$d/q.uhdm" ] || { rejq=$((rejq+1)); echo "PATCHED-ONLY-REJECT $rel" >> "$OUT/asym.txt"; }
  if [ -s "$d/p.uhdm" ] && [ -s "$d/q.uhdm" ]; then
    ( cd "$d" && uhdm-dump p.uhdm 2>&1 | sed '1s#^[^:]*\.uhdm:#<DB>:#' > p.txt
                 uhdm-dump q.uhdm 2>&1 | sed '1s#^[^:]*\.uhdm:#<DB>:#' > q.txt ) </dev/null
    if ! cmp -s "$d/p.txt" "$d/q.txt"; then
      diffn=$((diffn+1)); echo "$rel" >> "$OUT/differ.txt"
      diff "$d/p.txt" "$d/q.txt" > "$d/diff.txt" 2>&1
    else
      rm -rf "$d"
    fi
  fi
done
exec 3<&-
echo "PROCESSED=$proc LISTED=$N DIFFER=$diffn PRIS_REJECT=$rejp PATCHED_REJECT=$rejq"
[ "$proc" = "$N" ] || { echo "FATAL: PROCESSED != LISTED"; exit 9; }
[ -s "$OUT/asym.txt" ] && { echo "FATAL: ASYMMETRIC REJECT"; cat "$OUT/asym.txt"; }
if [ "$diffn" -gt 0 ]; then echo "-- differing arms:"; cat "$OUT/differ.txt"; fi
exit 0
