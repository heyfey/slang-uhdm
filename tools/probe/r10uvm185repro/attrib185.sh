#!/usr/bin/env bash
# r10uvm185 — ATTRIBUTE EVERY ARM THE WIDE BOUNDARY REPORTED AS MOVED.
#
# MEASUREMENT ONLY.  LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
#
#   usage: PRIS=<pristine> PATCHED=<patched> CEN=<ct185cen> \
#          ./attrib185.sh <probe-root> <arm-rel-path>...
#
# For each arm it builds the GOLDEN (Surelog, no cache, `-d coveruhdm`) in BOTH
# views and scores the same cell/field table `ct185grid.sh` scores — so a moved
# arm is not merely "moved", it is TOWARD / AWAY / MOVED-WRONG against golden.
# A boundary that reports movement without a golden column proves nothing about
# direction, which is the whole reason this script exists.
#
# Each arm runs in its OWN scratch directory keyed on the RELATIVE path
# (`r10uvm33repro` has three files called `dut.sv`), children get `</dev/null`,
# and any sibling `.svh` / `.vh` next to the arm is copied in with it.
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
PRIS=${PRIS:?}; PATCHED=${PATCHED:?}; CEN=${CEN:?}
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
STAGE=${STAGE:-/tmp/r10uvm185_attrib}
ROOT=$(cd "${1:?probe root}" && pwd); shift
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-}:$HOME/.local/lib64:$HOME/.local/lib
mkdir -p "$STAGE"
for rel in "$@"; do
  f="$ROOT/$rel"
  [ -f "$f" ] || { echo "== $rel  NO_SUCH_ARM"; continue; }
  key=$(echo "$rel" | tr '/' '_'); key=${key%.sv}; key=${key%.v}
  for view in plain elab; do
    d="$STAGE/${key}_$view"; rm -rf "$d"; mkdir -p "$d"
    cp "$f" "$d/"
    for h in "$(dirname "$f")"/*.svh "$(dirname "$f")"/*.vh; do
      [ -f "$h" ] && cp "$h" "$d/"
    done
    b=$(basename "$f")
    case $view in
      plain) SF="";          OF="";;
      elab)  SF="-elabuhdm"; OF="--elabuhdm";;
    esac
    ( cd "$d" && "$SURELOG" -parse -nocache -nowritecache -noprecompiledcache \
        -d coveruhdm $SF "$b" >surelog.log 2>&1 </dev/null )
    ( cd "$d" && "$PRIS"    $OF "$b" -o pris.uhdm >pris.log 2>&1 </dev/null )
    ( cd "$d" && "$PATCHED" $OF "$b" -o pat.uhdm  >pat.log  2>&1 </dev/null )
    g="$d/slpp_all/surelog.uhdm"
    if [ ! -f "$g" ] || [ ! -f "$d/pris.uhdm" ] || [ ! -f "$d/pat.uhdm" ]; then
      echo "== $rel/$view  SKIP (g=$( [ -f "$g" ] && echo y || echo n)" \
           "pris=$( [ -f "$d/pris.uhdm" ] && echo y || echo n)" \
           "pat=$( [ -f "$d/pat.uhdm" ] && echo y || echo n))"
      continue
    fi
    "$CEN" "$g"           > "$d/g.tsv"
    "$CEN" "$d/pris.uhdm" > "$d/pris.tsv"
    "$CEN" "$d/pat.uhdm"  > "$d/pat.tsv"
    echo "== $rel/$view"
    python3 "$HERE/score185.py" "$d/g.tsv" "$d/pris.tsv" "$d/pat.tsv"
  done
done
