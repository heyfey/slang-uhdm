#!/bin/bash
# r10det1repro/dtcen.sh — THE POPULATION CENSUS the whole pass turns on.
#
# For ONE slang binary (and optionally one env setting), report per test:
#     ALIAS  objects whose Typedef_alias() is non-null   (a FIELD carrier count)
#     CTS    class_typespec objects
#     TOTAL  all objects in the database
# for BOTH sides: golden (Surelog, LHS) and ours (RHS).
#
#   usage: dtcen.sh <slang-binary> <outdir> [test ...]
#   env:   R10DET1_PAD / R10DET1_ORDER are PASSED THROUGH to the binary, so the
#          same bytes can be measured under two allocation layouts.  The env
#          setting is printed on every run beside the md5 — a census that names
#          the binary but not the env is unreproducible.
#          DTCEN_REP=<tag> appends a tag to the artefact names so N reps of the
#          same binary do not clobber each other.
#
# GUARDS, each one a trap this campaign has paid for:
#   * COUNTS ARE OBJECTS, NOT DUMP OCCURRENCES.  `uhdm-dump | grep -c` counts
#     PRINTS and uhdm-dump re-prints back-references (r10oth8 F3 caught a 2.6x
#     inflation of exactly this shape), so the counts come from dtpop, which
#     walks Serializer::AllObjects().  CROSS-CHECKED: dtpop's CTS agrees with
#     `uhdm-dump --stats` class_typespec to the unit on BuildUVMPkg (6371).
#   * a missing or unrestorable database is NO_OUTPUT / UNMEASURED, never 0.
#   * --jobs 1, so no parallel-parse term enters the measurement.
#   * the binary's md5 IS printed: a population count is BINARY-local, which is
#     the whole finding this directory exists to record.
#   * LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
set -u
BIN=${1:?slang binary}
OUT=${2:?outdir}
shift 2
TESTS=${*:-"BuildUVMPkg SeqDriver Scoreboard"}
HERE=$(cd "$(dirname "$0")" && pwd)
ROOT=$(cd "$HERE/../../.." && pwd)
POP=${DTPOP:-/tmp/r10det1_dtpop}
REP=${DTCEN_REP:-}
[ -x "$BIN" ] || { echo "FATAL: not executable: $BIN"; exit 3; }
[ -x "$POP" ] || { echo "FATAL: no dtpop at $POP (build it: see README §9)"; exit 3; }
mkdir -p "$OUT" || exit 1
echo "BINARY=$BIN md5=$(md5sum "$BIN" | cut -d' ' -f1)"
echo "ENV   R10DET1_PAD=${R10DET1_PAD:-<unset>} R10DET1_ORDER=${R10DET1_ORDER:-<unset>} rep=${REP:-<none>}"
printf '%-14s %8s %8s %8s %8s %10s %10s\n' test aliasG aliasO ctsG ctsO totalG totalO
for T in $TESTS; do
  WD=$OUT/wd_$T$REP
  rm -rf "$WD"
  SLANG_UHDM="$BIN" python3 "$ROOT/scripts/verify_golden.py" --corpus surelog \
     --mode default --filter "^$T\$" --jobs 1 \
     --out "$WD.csv" --workdir "$WD" >"$OUT/vg_$T$REP.log" 2>&1
  D=$(echo "$WD"/default/"$T"-*/ | cut -d' ' -f1)
  [ -d "$D" ] || { echo "$T: NO_OUTPUT (no row dir)"; continue; }
  O=$D/slang.uhdm
  G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$D/cmds.txt" | head -1)
  [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
  [ -f "$O" ] || { echo "$T: NO_OUTPUT (ours absent)"; continue; }
  [ -f "$G" ] || { echo "$T: NO_OUTPUT (golden absent)"; continue; }
  cp "$O" "$OUT/$T$REP.ours.uhdm"
  go=$("$POP" "$G" 2>&1 >/dev/null); rcg=$?
  oo=$("$POP" "$O" 2>&1 >/dev/null); rco=$?
  [ $rcg -eq 0 ] && [ $rco -eq 0 ] || { echo "$T: UNMEASURED (dtpop rc g=$rcg o=$rco)"; continue; }
  ag=$(echo "$go" | awk '$1=="ALIAS"{print $2}'); ao=$(echo "$oo" | awk '$1=="ALIAS"{print $2}')
  cg=$(echo "$go" | awk '$1=="CTS"{print $2}');   co=$(echo "$oo" | awk '$1=="CTS"{print $2}')
  tg=$(echo "$go" | awk '$1=="TOTAL"{print $2}'); to=$(echo "$oo" | awk '$1=="TOTAL"{print $2}')
  printf '%-14s %8s %8s %8s %8s %10s %10s\n' "$T" "$ag" "$ao" "$cg" "$co" "$tg" "$to"
  rm -rf "$WD" "$WD.csv"
done
