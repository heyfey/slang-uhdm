#!/usr/bin/env python3
"""r10earl54 LADDER BEFORE/AFTER — which RUNGS did § connReplFoldNested54 clear?

`ctladder` (tools/probe/r10ladder1repro, MEASUREMENT-ONLY — uhdm-cmp stays the
sole judge) walks the design masking each head and continuing, so a before/after
pair says which heads a law removed and which it did not touch.  Rung NUMBERS
are not comparable across runs (removing one head renumbers everything after it),
so the join is on the SITE — (KINDL>KINDR, golden span, golden object id) — never
on the rung index.

  usage: ladcmp54.py <lad_pris.txt> <lad_pat.txt>
"""
import re
import sys
from collections import Counter


def rungs(path):
    """[(site, fam, rung, Lline, Rline)] in ladder order."""
    out = []
    cur = None
    for line in open(path, 'rt', errors='replace'):
        line = line.rstrip('\n')
        if line.startswith('RUNG'):
            f = dict()
            for tok in line.split('\t'):
                if '=' in tok:
                    k, v = tok.split('=', 1)
                    f[k] = v
            cur = {'rung': line.split('\t')[1], 'fam': f.get('FAM', '?'),
                   'L': '', 'R': ''}
            out.append(cur)
        elif cur is not None and line.startswith('   L  '):
            cur['L'] = line[6:]
        elif cur is not None and line.startswith('   R  '):
            cur['R'] = line[6:]
    for r in out:
        # golden's printed identity is stable across our-side changes
        r['site'] = r['L']
    return out


def main():
    if len(sys.argv) != 3:
        print(__doc__)
        return 2
    a, b = rungs(sys.argv[1]), rungs(sys.argv[2])
    print('rungs: pristine=%d patched=%d' % (len(a), len(b)))
    sa = {r['site']: r for r in a}
    sb = {r['site']: r for r in b}
    cleared = [sa[s] for s in sa if s not in sb]
    added = [sb[s] for s in sb if s not in sa]
    kept = [s for s in sa if s in sb]
    print('CLEARED (a pristine rung whose golden site is gone) = %d' % len(cleared))
    print('NEW     (a patched rung with no pristine twin)      = %d' % len(added))
    print('KEPT                                                = %d' % len(kept))
    for tag, lst in (('CLEARED', cleared), ('NEW', added)):
        if not lst:
            continue
        print('-- %s by family' % tag)
        for f, n in Counter(x['fam'] for x in lst).most_common(12):
            print('   %-52s %d' % (f, n))
        print('-- %s: first 6 sites' % tag)
        for x in sorted(lst, key=lambda y: int(y['rung']))[:6]:
            print('   rung %-6s %s' % (x['rung'], x['site']))
    # The family this pass names
    FAM = 'constant|VpiType|KIND:constant>operation'
    fa = [x for x in a if x['fam'] == FAM]
    fb = [x for x in b if x['fam'] == FAM]
    print('-- family %s: pristine=%d patched=%d' % (FAM, len(fa), len(fb)))
    tl = [x for x in fa if 'tlul_fifo_sync.sv:76:69-76:91' in x['site']]
    tlb = [x for x in fb if 'tlul_fifo_sync.sv:76:69-76:91' in x['site']]
    print('   of which tlul_fifo_sync.sv:76:69-76:91  pristine=%d patched=%d'
          % (len(tl), len(tlb)))
    return 0


if __name__ == '__main__':
    sys.exit(main())
