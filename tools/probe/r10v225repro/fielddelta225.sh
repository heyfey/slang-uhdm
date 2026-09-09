#!/bin/bash
# r10v225 — THE PER-FIELD THREE-WAY (r10v224's R-C lesson, taken one level
# further).
#
#   usage: bash fielddelta225.sh <pristine griddir> <patched griddir>
#
# `armdelta225.sh` compares a cell's WHOLE field string, so a cell that is
# wrong on BOTH binaries is scored STILL-WRONG even when one JUDGE-VISIBLE
# FIELD inside it went from right to wrong.  `nets::Compare` reads
# `VpiNetType` and the typespec independently, so that is a real regression
# hiding inside a "still wrong" cell.  This scorer splits every array_net cell
# and every base-net cell into its individual fields and reports
#
#   FIELD-AWAY   this field is EXACT on pristine and WRONG on patched
#
# which must be zero even where the containing cell never becomes exact.
set -u
P=${1:?pristine griddir}
Q=${2:?patched griddir}
HERE=$(cd "$(dirname "$0")" && pwd)
python3 - "$P" "$Q" "$HERE" <<'PY'
import os, re, sys
sys.path.insert(0, sys.argv[3])
import anetcen225 as A
pris, pat = sys.argv[1], sys.argv[2]

# split a census description into named fields; the bracketed R#/I# groups are
# kept whole and also split on their inner `key=value`/`d=`/`v=` tokens.
def fields(desc):
    out = {}
    for m in re.finditer(r'(\w+)=(\S+)', desc.split('R0[')[0]):
        out[m.group(1)] = m.group(2)
    for m in re.finditer(r'(R\d+|I\d+)\[(.*?)\]', desc):
        tag, body = m.group(1), m.group(2)
        out[tag] = body
        for part in body.split('|'):
            part = part.strip()
            lbl, _, rest = part.partition(':')
            if rest:
                for mm in re.finditer(r'(\w+)=(\S+)', rest):
                    out['%s.%s.%s' % (tag, lbl.strip(), mm.group(1))] = mm.group(2)
            else:
                for mm in re.finditer(r'(\w+)=(\S+)', part):
                    out['%s.%s' % (tag, mm.group(1))] = mm.group(2)
    return out

def anet_cells(dump):
    out = {}
    if not os.path.exists(dump):
        return out
    holders = {}
    for r in A.parse(dump):
        A.walk(r, holders)
    seen = {}
    for h in sorted(holders):
        for an in holders[h]:
            full, d = A.describe(an)
            k = (h, full)
            i = seen.get(k, 0); seen[k] = i + 1
            out[('ANET', h, full, i)] = d
    return out

def net_cells(dump):
    out = {}
    if not os.path.exists(dump):
        return out
    holders = {}
    def walk(n):
        if n.kind in A.HOLDERS:
            full = A.get(n, 'vpiFullName') or A.get(n, 'vpiName') or n.head
            lst = A.kids(n, 'vpiNet')
            if lst and (full not in holders or len(lst) > len(holders[full])):
                holders[full] = lst
        for f, c in n.children:
            if f == 'vpiParent':
                continue
            walk(c)
    for r in A.parse(dump):
        walk(r)
    seen = {}
    for h in sorted(holders):
        for n in holders[h]:
            full = A.get(n, 'vpiFullName') or A.get(n, 'vpiName')
            k = (h, full)
            i = seen.get(k, 0); seen[k] = i + 1
            out[('NET', h, full, i)] = 'nt=%s ts=%s' % (
                A.get(n, 'vpiNetType', '-'), A.ts_of(n))
    return out

away = tog = 0
rows = []
for arm in sorted(os.listdir(pris)):
    gd = os.path.join(pris, arm, 'golden.dump')
    if not os.path.exists(gd):
        continue
    for get in (anet_cells, net_cells):
        g = get(gd)
        o1 = get(os.path.join(pris, arm, 'ours.dump'))
        o2 = get(os.path.join(pat, arm, 'ours.dump'))
        for k in sorted(set(g) & set(o1) & set(o2)):
            fg, f1, f2 = fields(g[k]), fields(o1[k]), fields(o2[k])
            for name in sorted(set(fg) | set(f1) | set(f2)):
                gv, v1, v2 = fg.get(name), f1.get(name), f2.get(name)
                if v1 == gv and v2 != gv:
                    away += 1
                    rows.append('  FIELD-AWAY %s %s %s  %s: G=%s PRIS=%s PAT=%s'
                                % (arm, k[0], k[2], name, gv, v1, v2))
                elif v1 != gv and v2 == gv:
                    tog += 1
print('FIELD-TO-GOLDEN=%d  FIELD-AWAY=%d' % (tog, away))
for r in rows:
    print(r)
PY
