#!/usr/bin/env bash
# r10buvm22repro/grid22.sh — run ONE golden grid file through Surelog and one
# slang-uhdm binary, in BOTH views, and score the FUNCTION RETURN VARIABLE's
# object kind cell by cell.  MEASUREMENT ONLY: uhdm-cmp is the judge, not this.
#
# LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
#
#   grid22.sh <g22.sv|g22b.sv> <slang-uhdm binary> <workdir> [<census binary>]
set -u
SRC=$1; BIN=$2; W=$3; CEN=${4:-/tmp/r10buvm22_cen}
SURELOG=$HOME/git-repos/Surelog/build/bin/surelog
mkdir -p "$W" || exit 1
cp "$SRC" "$W/" || exit 1
B=$(basename "$SRC")
( cd "$W" && "$SURELOG" -parse -noprecompiledcache "$B" -mt 0 -mp 0 -o gd > gd.log 2>&1
  "$SURELOG" -parse -elabuhdm -noprecompiledcache "$B" -mt 0 -mp 0 -o ge > ge.log 2>&1
  "$BIN" "$B" --single-unit            -o od.uhdm > od.log 2>&1
  "$BIN" "$B" --single-unit --elabuhdm -o oe.uhdm > oe.log 2>&1
  for p in "gd/slpp_all/surelog.uhdm GD" "ge/slpp_all/surelog.uhdm GE" \
           "od.uhdm OD" "oe.uhdm OE"; do
      set -- $p; "$CEN" "$1" "$2"
  done > cen.tsv 2> cen.err )
python3 - "$W/cen.tsv" <<'PY'
import collections, sys
cells = collections.defaultdict(dict)
for l in open(sys.argv[1]):
    f = l.rstrip('\n').split('\t')
    if f[1] != 'RET':
        continue
    cells[(f[3].split('::')[-1], f[2])][f[0]] = (f[8], f[10])
print(f"{'CELL':22} {'VIEW':11} {'GOLDEN':12} {'OURS':12} {'GOLDEN-TS':38} V")
ns = nd = 0
for (fn, view) in sorted(cells):
    c = cells[(fn, view)]
    for gt, ot in (('GD', 'OD'), ('GE', 'OE')):
        if gt in c and ot in c:
            g, o = c[gt], c[ot]
            v = 'SAME' if g[0] == o[0] else '**DIFF**'
            ns += v == 'SAME'; nd += v != 'SAME'
            print(f"{fn:22} {view+'/'+gt[1]:11} {g[0]:12} {o[0]:12} {g[1][:36]:38} {v}")
print('SAME', ns, 'DIFF', nd)
PY
