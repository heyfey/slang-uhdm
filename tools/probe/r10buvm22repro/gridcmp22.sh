#!/usr/bin/env bash
# r10buvm22repro/gridcmp22.sh — the THREE-WAY grid score: golden vs PRISTINE vs
# PATCHED, per cell, reporting CONVERTED / OVER-FIRE / MSW (a cell the pristine
# binary got RIGHT and the patched binary gets WRONG — the only verdict that can
# sink a law).  MEASUREMENT ONLY; uhdm-cmp is the judge.
#
# LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
#
#   gridcmp22.sh <grid.sv> <pristine bin> <patched bin> <workdir> [<census bin>]
set -u
SRC=$1; PRIS=$2; PAT=$3; W=$4; CEN=${5:-/tmp/r10buvm22_cen}
SURELOG=$HOME/git-repos/Surelog/build/bin/surelog
rm -rf "$W"; mkdir -p "$W" || exit 1
cp "$SRC" "$W/" || exit 1
B=$(basename "$SRC")
( cd "$W" && "$SURELOG" -parse -noprecompiledcache "$B" -mt 0 -mp 0 -o gd > gd.log 2>&1
  "$SURELOG" -parse -elabuhdm -noprecompiledcache "$B" -mt 0 -mp 0 -o ge > ge.log 2>&1
  "$PRIS" "$B" --single-unit            -o pd.uhdm > pd.log 2>&1
  "$PRIS" "$B" --single-unit --elabuhdm -o pe.uhdm > pe.log 2>&1
  "$PAT"  "$B" --single-unit            -o qd.uhdm > qd.log 2>&1
  "$PAT"  "$B" --single-unit --elabuhdm -o qe.uhdm > qe.log 2>&1
  for p in "gd/slpp_all/surelog.uhdm GD" "ge/slpp_all/surelog.uhdm GE" \
           "pd.uhdm PD" "pe.uhdm PE" "qd.uhdm QD" "qe.uhdm QE"; do
      set -- $p; "$CEN" "$1" "$2"
  done > cen.tsv 2> cen.err )
python3 - "$W/cen.tsv" <<'PY'
import collections, sys
cells = collections.defaultdict(dict)
for l in open(sys.argv[1]):
    f = l.rstrip('\n').split('\t')
    if f[1] != 'RET':
        continue
    cells[(f[3].split('::')[-1], f[2])][f[0]] = f[8]
conv = wrong = mswl = same = 0
rows = []
for (fn, view) in sorted(cells):
    c = cells[(fn, view)]
    for g, p, q in (('GD', 'PD', 'QD'), ('GE', 'PE', 'QE')):
        if not (g in c and p in c and q in c):
            continue
        gk, pk, qk = c[g], c[p], c[q]
        if pk != gk and qk == gk:
            v = 'CONVERTED'; conv += 1
        elif pk == gk and qk != gk:
            v = 'MSW-REGRESSION'; mswl += 1
        elif pk == gk and qk == gk:
            v = 'same'; same += 1
        elif pk == qk:
            v = 'still-wrong'; wrong += 1
        else:
            v = 'moved-still-wrong'; wrong += 1
        if v != 'same':
            rows.append((fn, view + '/' + g[1], gk, pk, qk, v))
print(f"{'CELL':22} {'VIEW':11} {'GOLDEN':12} {'PRISTINE':12} {'PATCHED':12} VERDICT")
for r in rows:
    print(f"{r[0]:22} {r[1]:11} {r[2]:12} {r[3]:12} {r[4]:12} {r[5]}")
print('CONVERTED %d  MSW-REGRESSION %d  still-wrong %d  same %d'
      % (conv, mswl, wrong, same))
PY
