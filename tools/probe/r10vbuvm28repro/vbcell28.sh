#!/usr/bin/env bash
# r10vbuvm28 boundary WORKER — one cell.  argv: kind view key outdir src...
set -u
kind=$1; view=$2; key=$3; OUT=$4; shift 4
W="$OUT/w/$kind/$view/$key"; mkdir -p "$W"
FL=""; [ "$view" = elab ] && FL="--elabuhdm"
D=$(dirname "$1")
( cd "$D" >/dev/null 2>&1 || exit 9
  "$PRI" $FL "$@" --single-unit -o "$W/pri.uhdm" > "$W/pri.log" 2>&1 </dev/null
  echo "$?" > "$W/pri.rc"
  "$PAT" $FL "$@" --single-unit -o "$W/pat.uhdm" > "$W/pat.log" 2>&1 </dev/null
  echo "$?" > "$W/pat.rc" )
ra=$(cat "$W/pri.rc" 2>/dev/null || echo X); rb=$(cat "$W/pat.rc" 2>/dev/null || echo X)
if [ -f "$W/pri.uhdm" ] && [ -f "$W/pat.uhdm" ]; then
  if cmp -s "$W/pri.uhdm" "$W/pat.uhdm"; then v=SAME; else v=MOVED; fi
elif [ -f "$W/pri.uhdm" ] || [ -f "$W/pat.uhdm" ]; then v=ONE-SIDED
else v=NO-DB; fi
# keep the databases ONLY for a cell that moved (the scorer needs them);
# a SAME cell's two databases are deleted so the wide sweep fits on disk.
[ "$v" = MOVED ] || rm -f "$W/pri.uhdm" "$W/pat.uhdm"
echo "$kind $view $key rc_pri=$ra rc_pat=$rb $v"
