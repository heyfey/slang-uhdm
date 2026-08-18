#!/usr/bin/env bash
# r10v63 — run ONE arm through Surelog (golden) + PRISTINE + PATCHED, census
# all three param_assign tables with pacen63, and print a 3-way verdict.
#   usage: ./v63run.sh <file.sv> <outdir> [extra slang/surelog flags]
set -u
SL=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
PACEN=/tmp/v63_bin/pacen63
PRIS=/tmp/v63_bin/pris
PAT=/tmp/v63_bin/pat
F=$(readlink -f "${1:?file.sv}"); D=${2:?outdir}; EXTRA=${3:-}
mkdir -p "$D"; D=$(cd "$D" && pwd)
( cd "$D" && "$SL" -parse -nobuiltin -nocache -d uhdm $EXTRA "$F" ) > "$D/sl.log" 2>&1
G="$D/slpp_all/surelog.uhdm"
[ -f "$G" ] || { echo "SURELOG_FAIL $(basename $F)"; exit 6; }
( cd "$D" && "$PRIS" $EXTRA "$F" -o "$D/pris.uhdm" ) > "$D/pris.log" 2>&1; rcp=$?
( cd "$D" && "$PAT"  $EXTRA "$F" -o "$D/pat.uhdm"  ) > "$D/pat.log"  2>&1; rcq=$?
echo "RC pris=$rcp pat=$rcq"
[ -f "$D/pris.uhdm" ] && "$PACEN" "$G" | sort > "$D/gold.pa" || { echo "NO_PRIS $(basename $F) rc=$rcp"; tail -2 "$D/pris.log"; }
[ -f "$D/pris.uhdm" ] && "$PACEN" "$D/pris.uhdm" | sort > "$D/pris.pa"
[ -f "$D/pat.uhdm" ]  && "$PACEN" "$D/pat.uhdm"  | sort > "$D/pat.pa" || { echo "NO_PAT $(basename $F) rc=$rcq"; tail -2 "$D/pat.log"; }
