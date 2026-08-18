#!/usr/bin/env bash
# r10buvm21repro/grid21.sh — one grid arm, three ways (golden / pristine /
# patched), through r10buvm21cen + cen3.py.  MEASUREMENT ONLY.
#
# usage: grid21.sh <arm.sv> <pristine-bin> <patched-bin> [workdir]
set -u
D=$(cd "$(dirname "$0")" && pwd)
ARM=$1; PRIS=$2; PAT=${3:-}; W=${4:-/tmp/r10buvm21_grid_run}
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
CEN=${CEN:-/tmp/r10buvm21cen}
rm -rf "$W"; mkdir -p "$W/g" "$W/p" "$W/q"
for x in g p q; do cp "$ARM" "$W/$x/a.sv"; done
( cd "$W/g" && "$SURELOG" a.sv -parse -d coveruhdm -nocache -createcache \
      -noprecompiledcache -nowritecache -mt 0 -mp 0 -o w >sl.log 2>&1 ) </dev/null
( cd "$W/p" && "$PRIS" a.sv -o p.uhdm >p.log 2>&1; echo "rc=$?" >>p.log ) </dev/null
ALLREFS=1 "$CEN" "$W/g/w/slpp_all/surelog.uhdm" G > "$W/g.tsv" 2>"$W/g.err"
ALLREFS=1 "$CEN" "$W/p/p.uhdm" O > "$W/o.tsv" 2>"$W/o.err"
if [ -n "$PAT" ]; then
  ( cd "$W/q" && "$PAT" a.sv -o q.uhdm >q.log 2>&1; echo "rc=$?" >>q.log ) </dev/null
  ALLREFS=1 "$CEN" "$W/q/q.uhdm" P > "$W/p.tsv" 2>"$W/p.err"
  python3 "$D/cen3.py" "$W/g.tsv" "$W/o.tsv" "$W/p.tsv" --noloc
else
  python3 "$D/cen3.py" "$W/g.tsv" "$W/o.tsv" --noloc
fi
