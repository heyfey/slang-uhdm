#!/usr/bin/env bash
# r10vbuvm21repro/vgrid21.sh — VIEW-GENERAL three-way grid runner (golden /
# pristine / patched) for one arm, in BOTH views: the DEFAULT model and the
# ELABORATED model (`-elabuhdm` on Surelog, `--elabuhdm` on ours).  The pass's
# own grid21.sh ran the default view only.  MEASUREMENT ONLY.
#
# usage: vgrid21.sh <arm.sv> <pristine-bin> <patched-bin> <view: def|elab> [workdir]
set -u
D=$(cd "$(dirname "$0")" && pwd)
ARM=$1; PRIS=$2; PAT=$3; VIEW=${4:-def}; W=${5:-/tmp/vbuvm21_grid_run}
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
CEN=${CEN:-/tmp/vbuvm21_cen}
CEN3=${CEN3:-$D/../r10buvm21repro/cen3.py}
SLE=""; SUE=""
[ "$VIEW" = elab ] && { SLE="--elabuhdm"; SUE="-elabuhdm"; }
rm -rf "$W"; mkdir -p "$W/g" "$W/p" "$W/q"
for x in g p q; do cp "$ARM" "$W/$x/a.sv"; done
( cd "$W/g" && "$SURELOG" a.sv -parse $SUE -d coveruhdm -nocache -createcache \
      -noprecompiledcache -nowritecache -mt 0 -mp 0 -o w >sl.log 2>&1; echo "rc=$?" >>sl.log ) </dev/null
( cd "$W/p" && "$PRIS" a.sv $SLE -o p.uhdm >p.log 2>&1; echo "rc=$?" >>p.log ) </dev/null
( cd "$W/q" && "$PAT"  a.sv $SLE -o q.uhdm >q.log 2>&1; echo "rc=$?" >>q.log ) </dev/null
echo "ARM=$(basename "$ARM") VIEW=$VIEW  surelog_rc=$(grep -o 'rc=[0-9]*' "$W/g/sl.log" | tail -1)  pris_rc=$(grep -o 'rc=[0-9]*' "$W/p/p.log" | tail -1)  pat_rc=$(grep -o 'rc=[0-9]*' "$W/q/q.log" | tail -1)"
ALLREFS=1 "$CEN" "$W/g/w/slpp_all/surelog.uhdm" G > "$W/g.tsv" 2>"$W/g.err"
ALLREFS=1 "$CEN" "$W/p/p.uhdm" O > "$W/o.tsv" 2>"$W/o.err"
ALLREFS=1 "$CEN" "$W/q/q.uhdm" P > "$W/p.tsv" 2>"$W/p.err"
python3 "$CEN3" "$W/g.tsv" "$W/o.tsv" "$W/p.tsv" --noloc
