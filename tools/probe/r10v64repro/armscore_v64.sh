#!/usr/bin/env bash
# r10v64 — score a differing boundary arm AGAINST A REBUILT GOLDEN, field by
# field, with the verifier's OWN census (cen64.py) — never the pass's.
set -u
PAT=/tmp/v64_bin/pat; PRIS=/tmp/v64_bin/pris
SL=$HOME/git-repos/Surelog/build/bin/surelog
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
CEN=/tmp/wt_v64/tools/probe/r10v64repro/cen64.py
SC=/tmp/wt_v64/tools/probe/r10v64repro/sc64.py
rel=$1; view=${2:-plain}; ROOT=/tmp/v64_probe
f="$ROOT/$rel"; b=$(basename "$f")
key=$(echo "${rel}_$view" | tr '/' '_'); key=${key%.sv}
d=/tmp/v64_bscore/$key; rm -rf "$d"; mkdir -p "$d"; cp "$f" "$d/"
case $view in plain) SLF=""; SGF="";; elab) SLF="--elabuhdm"; SGF="-elabuhdm";; esac
( cd "$d" && $SL -parse -nobuiltin -nocache -sv $SGF -d uhdm "$b" >sl.log 2>&1 </dev/null )
G=""; for c in "$d/slpp_all/surelog.uhdm" "$d/slpp_unit/surelog.uhdm"; do [ -f "$c" ] && G="$c"; done
[ -n "$G" ] || { echo "$rel $view SURELOG_FAIL"; exit 0; }
( cd "$d" && "$PRIS" $SLF "$b" -o pris.uhdm >p1.log 2>&1 </dev/null )
( cd "$d" && "$PAT"  $SLF "$b" -o pat.uhdm  >p2.log 2>&1 </dev/null )
[ -f "$d/pris.uhdm" ] && [ -f "$d/pat.uhdm" ] || { echo "$rel $view NO_DB"; exit 0; }
for pr in "$G g" "$d/pris.uhdm o" "$d/pat.uhdm p"; do set -- $pr
  $DUMP "$1" 2>/dev/null | sed '1d' | sed "s#$d#WD#g" > "$d/$2.raw"
  python3 "$CEN" "$d/$2.raw" > "$d/$2.cen"; done
echo "$rel $view $(python3 "$SC" "$d/g.cen" "$d/o.cen" "$d/p.cen" 0)"
