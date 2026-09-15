#!/usr/bin/env bash
# r11v42 grid runner — LHS is ALWAYS golden.  Keyed join on line:col, never paste.
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
SL=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
WD=${WD:?}
GRID=${GRID:?}
PRIS=${PRIS:?}
PAT=${PAT:?}
mkdir -p "$WD"
for A in "$@"; do
  SRC=$GRID/$A/dut.sv
  [ -f "$SRC" ] || { echo "ARM=$A MISSING_SOURCE"; continue; }
  mkdir -p "$WD/$A"
  "$SL" -parse -nobuiltin -nocache -sv "$SRC" -mt 0 -mp 0 -o "$WD/$A/g" > "$WD/$A/surelog.log" 2>&1
  echo "ARM=$A SURELOG_RC=$?"
  "$PRIS" "$SRC" --single-unit -o "$WD/$A/pris.uhdm" > "$WD/$A/pris.log" 2>&1
  echo "ARM=$A PRIS_RC=$?"
  "$PAT" "$SRC" --single-unit -o "$WD/$A/pat.uhdm" > "$WD/$A/pat.log" 2>&1
  echo "ARM=$A PAT_RC=$?"
  G="$WD/$A/g/slpp_all/surelog.uhdm"
  [ -f "$G" ] || { echo "ARM=$A GOLDEN_MISSING — TEACHES NOTHING"; continue; }
  [ -f "$WD/$A/pris.uhdm" ] || { echo "ARM=$A PRIS_MISSING — compile failed"; continue; }
  [ -f "$WD/$A/pat.uhdm" ] || { echo "ARM=$A PAT_MISSING — compile failed"; continue; }
  "$DUMP" "$G" | tail -n +2 > "$WD/$A/golden.dump"; echo "ARM=$A GOLDEN_DUMP_RC=$?"
  "$DUMP" "$WD/$A/pris.uhdm" | tail -n +2 > "$WD/$A/pris.dump"; echo "ARM=$A PRIS_DUMP_RC=$?"
  "$DUMP" "$WD/$A/pat.uhdm" | tail -n +2 > "$WD/$A/pat.dump"; echo "ARM=$A PAT_DUMP_RC=$?"
  python3 "$HERE/join42v.py" "$A" "$WD/$A/golden.dump" "$WD/$A/pris.dump" "$WD/$A/pat.dump"
done
