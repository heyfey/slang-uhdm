#!/usr/bin/env python3
"""r10earl30 THE vpiConstType TABLE — a whole-database census of every
`constant` object cross-tabbed by (VALUE ENCODING PREFIX, vpiConstType), both
sides, span-keyed so any cell can be looked up.

  usage: ctcensus.py <golden.dump> <ours.dump> [--pairs] [--span-of PFX,CT]
         ctcensus.py --selfcheck            (the reader's own control)

golden is ALWAYS argv[1], ours ALWAYS argv[2].  Both dumps must already have
uhdm-dump's FIRST LINE (the database path) stripped (`sed 1d`).

WHY THE CROSS-TAB IS THE RIGHT INSTRUMENT: the brief warned that "the corpus
already contains thousands of vpiConstType:9 constants that MATCH golden", so a
count of `vpiConstType:9` alone can never price a 9->7 rule.  What prices it is
the JOINT distribution with the value encoding: a constant whose value reads
`INT:` and whose vpiConstType reads 9 is SELF-INCONSISTENT (vpi_user.h:491,493 —
7 = vpiIntConst, 9 = vpiUIntConst), and THAT cell is the predicted mover set.
Cells like (UINT:,9), (BIN:,3), (DEC:,1) are consistent and must not move.

Field reading is delegated to dumpread.own_fields, whose header records the
own-child-depth defect this instrument was CAUGHT with and how it was fixed.
`--selfcheck` exercises that fix on the exact shape that broke it.
"""
import sys
from collections import Counter, defaultdict

sys.path.insert(0, __file__.rsplit('/', 1)[0])
from dumpread import objects, own_fields  # noqa: E402

SELF = '''\
  \\_constant: , line:59:23, endln:59:27
    |vpiParent:
    \\_param_assign: , line:59:18, endln:59:29
    |vpiDecompile:1
    |vpiSize:3
    |INT:1
    |vpiTypespec:
    \\_ref_typespec: (work@m)
      |vpiParent:
      \\_constant: , line:59:23, endln:59:27
      |vpiFullName:work@m
      |vpiActual:
      \\_int_typespec: , line:59:14, endln:59:17
    |vpiConstType:7
  |vpiLhs:
'''


def selfcheck():
    lines = SELF.split('\n')
    f, vpfx, vtxt = own_fields(lines, 0)
    ok = (f.get('vpiConstType') == '7' and f.get('vpiSize') == '3' and
          f.get('vpiDecompile') == '1' and vpfx == 'INT' and
          'vpiFullName' not in f)
    print('SELFCHECK reader: vpiConstType=%r vpiSize=%r vpiDecompile=%r '
          'value=%r:%r  leaked-child-fields=%r' %
          (f.get('vpiConstType'), f.get('vpiSize'), f.get('vpiDecompile'),
           vpfx, vtxt, sorted(k for k in f if k in ('vpiFullName',))))
    print('SELFCHECK: %s (a vpiConstType AFTER a nested ref_typespec must be '
          'READ, and the ref_typespec\'s own fields must NOT leak in)'
          % ('PASS' if ok else 'FAIL'))
    return 0 if ok else 5


def census(path):
    tab = Counter()
    spans = defaultdict(list)
    for span, _name, f, vpfx, _vtxt in objects(path, 'constant'):
        key = ((vpfx or 'NOVAL') + ':', f.get('vpiConstType', 'NONE'))
        tab[key] += 1
        spans[key].append((span, f.get('vpiDecompile', '-')))
    return tab, spans


def main():
    if '--selfcheck' in sys.argv:
        sys.exit(selfcheck())
    gt, gs = census(sys.argv[1])
    ot, os_ = census(sys.argv[2])
    keys = sorted(set(gt) | set(ot))
    print('%-9s %-8s %10s %10s %10s' % ('VALUE', 'ct', 'GOLDEN', 'OURS', 'delta'))
    for k in keys:
        g, o = gt.get(k, 0), ot.get(k, 0)
        flag = ''
        if k[0] == 'INT:' and k[1] == '9':
            flag = '  <== SELF-INCONSISTENT (predicted mover cell)'
        elif k[0] == 'INT:' and k[1] == '7':
            flag = '  <== consistent vpiIntConst'
        print('%-9s %-8s %10d %10d %+10d%s' % (k[0], k[1], g, o, o - g, flag))
    print('---- totals: golden %d constants, ours %d' % (sum(gt.values()),
                                                         sum(ot.values())))
    if '--pairs' in sys.argv:
        gm, om = defaultdict(list), defaultdict(list)
        for k, lst in gs.items():
            for sp, dc in lst:
                gm[sp].append((k, dc))
        for k, lst in os_.items():
            for sp, dc in lst:
                om[sp].append((k, dc))
        ctonly = dconly = both = 0
        examples = []
        for sp in sorted(set(gm) & set(om)):
            a, b = sorted(gm[sp]), sorted(om[sp])
            if a == b:
                continue
            gk, ok_ = set(x[0] for x in a), set(x[0] for x in b)
            gd, od = set(x[1] for x in a), set(x[1] for x in b)
            if gk != ok_ and gd == od:
                ctonly += 1
                if len(examples) < 6:
                    examples.append(('ENCODING', sp, a, b))
            elif gk == ok_ and gd != od:
                dconly += 1
                if len(examples) < 6:
                    examples.append(('DECOMPILE', sp, a, b))
            else:
                both += 1
                if len(examples) < 6:
                    examples.append(('BOTH', sp, a, b))
        print('---- span-keyed disagreeing constant cells: %d ENCODING-only, '
              '%d DECOMPILE-only, %d BOTH' % (ctonly, dconly, both))
        for tag, sp, a, b in examples:
            print('   %-9s %-18s G=%s' % (tag, sp, a))
            print('   %-9s %-18s O=%s' % ('', '', b))
        gonly = sorted(set(gm) - set(om))
        oonly = sorted(set(om) - set(gm))
        print('---- spans GOLDEN-ONLY: %d   OURS-ONLY: %d' % (len(gonly),
                                                             len(oonly)))
    for i, a in enumerate(sys.argv):
        if a == '--span-of' and i + 1 < len(sys.argv):
            pfx, ct = sys.argv[i + 1].split(',')
            for sp, dc in sorted(gs.get((pfx, ct), []))[:30]:
                print('  GOLDEN (%s,%s) %s dc=%s' % (pfx, ct, sp, dc))
            for sp, dc in sorted(os_.get((pfx, ct), []))[:30]:
                print('  OURS   (%s,%s) %s dc=%s' % (pfx, ct, sp, dc))


if __name__ == '__main__':
    main()
