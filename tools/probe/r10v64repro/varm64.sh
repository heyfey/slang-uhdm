#!/usr/bin/env bash
# r10v64 — score ONE arm against Surelog golden with BOTH frozen binaries in
# BOTH views.  Prints: arm view rc_pris rc_pat cmpPRIS cmpPAT dPRIS dPAT
# where cmp* = uhdm-cmp line count vs golden (HEAD DEPTH) and d* = sorted
# path-normalised whole-dump diff line count vs golden.  MEASUREMENT ONLY.
set -u
PAT=${PATCHED_BIN:?}; PRIS=${PRISTINE_BIN:?}
SL=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
CMP=$HOME/git-repos/UHDM/build/bin/uhdm-cmp
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
F=$1; STAGE=${2:?stage}
b=$(basename "$F")
for view in plain elab; do
  case $view in plain) SLF="";      SGF="";;
                elab)  SLF="--elabuhdm"; SGF="-elabuhdm";; esac
  d="$STAGE/$(basename ${F%.sv})_$view"; rm -rf "$d"; mkdir -p "$d"; cp "$F" "$d/"
  ( cd "$d" && $SL -parse -nobuiltin -nocache -sv $SGF -d uhdm "$b" >sl.log 2>&1 </dev/null )
  G=""
  for c in "$d/slpp_all/surelog.uhdm" "$d/slpp_unit/surelog.uhdm"; do [ -f "$c" ] && G="$c"; done
  if [ -z "$G" ]; then echo "$b $view SURELOG_FAIL"; continue; fi
  ( cd "$d" && "$PRIS" $SLF "$b" -o pris.uhdm >pris.log 2>&1 </dev/null ); rcp=$?
  ( cd "$d" && "$PAT"  $SLF "$b" -o pat.uhdm  >pat.log  2>&1 </dev/null ); rca=$?
  if [ ! -f "$d/pris.uhdm" ] || [ ! -f "$d/pat.uhdm" ]; then
    echo "$b $view NO_DB rc_pris=$rcp rc_pat=$rca"; continue; fi
  "$CMP" "$G" "$d/pris.uhdm" > "$d/cmp_pris.log" 2>&1; cp1=$(wc -l < "$d/cmp_pris.log")
  "$CMP" "$G" "$d/pat.uhdm"  > "$d/cmp_pat.log"  2>&1; cp2=$(wc -l < "$d/cmp_pat.log")
  h1=$(grep -c '^LHS:' "$d/cmp_pris.log"); h2=$(grep -c '^LHS:' "$d/cmp_pat.log")
  "$DUMP" "$G"            2>/dev/null | sed '1d' | sed "s#$d#WD#g" | sort > "$d/g.s"
  "$DUMP" "$d/pris.uhdm"  2>/dev/null | sed '1d' | sed "s#$d#WD#g" | sort > "$d/o.s"
  "$DUMP" "$d/pat.uhdm"   2>/dev/null | sed '1d' | sed "s#$d#WD#g" | sort > "$d/p.s"
  d1=$(diff "$d/g.s" "$d/o.s" | grep -c '^[<>]'; true)
  d2=$(diff "$d/g.s" "$d/p.s" | grep -c '^[<>]'; true)
  d3=$(diff "$d/o.s" "$d/p.s" | grep -c '^[<>]'; true)
  echo "$b $view rc=$rcp/$rca cmpLINES=$cp1/$cp2 heads=$h1/$h2 dGOLD=$d1/$d2 dP2P=$d3"
done
