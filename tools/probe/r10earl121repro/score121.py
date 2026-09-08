#!/usr/bin/env python3
"""r10earl121 — THE THREE-WAY CENSUS SCORE.  MEASUREMENT ONLY.

  score121.py <pristine-sweep.tsv> <patched-sweep.tsv> [--slot] [--wrap] [--detail]

Each sweep file is `censweep121.sh` output: side(G/O) mode test <cen121 row>.
The GOLDEN half of both files must be IDENTICAL -- Surelog's databases are
immutable for a pinned binary and pinned sources -- and this script REFUSES TO
SCORE otherwise (r10earl120's calibration rule, and the only thing that
separates a real mover from a re-run of the golden side).

KEY   = (mode, test, cen121 key)     -- see cen121.cpp for the key's fields.
PAYLOAD is a MULTISET per key (a key can legitimately repeat: our emitter can
leave a superseded pattern operation behind, which cen121 marks live=0 and
whose operands it does not emit at all -- so a repeat here is a real duplicate,
never a bookkeeping one).

VERDICTS per key:
  SAME_AGREE    golden == pristine == patched
  TO-GOLDEN     pristine != golden, patched == golden      (the law working)
  AWAY-GOLDEN   pristine == golden, patched != golden      (MUST BE 0)
  MOVED-WRONG   both differ from golden AND from each other(MUST BE 0)
  STILL-WRONG   both differ from golden, patched == pristine (untouched residue)
  NOGOLD_SAME   key absent from golden, patched == pristine
  NOGOLD_MOVED  key absent from golden, patched != pristine (MUST BE 0 unless named)
  GOLD_ONLY     key present in golden, absent from BOTH of ours
"""
import collections
import sys


# THE TWO PROJECTIONS.  `CELL` is the whole payload -- the wrapper AND the
# value it wraps.  `WRAP` drops the value's kind and keeps only the wrapper this
# law owns (`TP|<tag ts kind>|<tag name>|<tag span>` or `RAW`), because a member
# whose VALUE another law still gets wrong would otherwise read as this law
# moving a cell wrong when all it did was put golden's own tag on it.  Both are
# scored, separately and out loud (r10earl120's CELL/ROLECELL discipline).
def project(payload, mode):
    if mode == 'CELL':
        return payload
    if payload.startswith('RAW|'):
        return 'RAW'
    return '|'.join(payload.split('|')[:4])


# THE TWO KEYINGS.  cen121's key is `home | pattern-op span | operand index |
# OPERAND SPAN`.  That last field is part of the object this law REPLACES: a bare
# `bit_select` operand carries the INDEX's span where the `tagged_pattern` that
# wraps it carries the VALUE's span (golden's own).  Keyed on it, one moved cell
# reads as two -- a vacated key and a new one -- so `--slot` re-keys on the SLOT
# (site + operand index) and moves the operand span into the PAYLOAD, where a
# change in it is still fully visible.  Both keyings are scored, out loud.
def rekey(key, payload, slot):
    if not slot:
        return key, payload
    parts = key.split('|')
    if len(parts) < 4:
        return key, payload
    return '|'.join(parts[:3]), parts[3] + '#' + payload


def load(path, proj='CELL', slot=False):
    gold, ours = {}, {}
    rc = collections.Counter()
    for line in open(path):
        f = line.rstrip('\n').split('\t')
        if len(f) < 4:
            continue
        side, mode, test, kind = f[0], f[1], f[2], f[3]
        if kind == 'CENRC':
            rc[(side, mode, test)] = f[4] if len(f) > 4 else '?'
            continue
        if kind != 'CELL' or len(f) < 6:
            continue
        k, pay = rekey(f[4], project(f[5], proj), slot)
        key = (mode, test, k)
        tgt = gold if side == 'G' else ours
        tgt.setdefault(key, collections.Counter())[pay] += 1
    return gold, ours, rc


def fmt(c):
    return '|'.join('%s x%d' % (k, v) for k, v in sorted(c.items()))


def main():
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    detail = '--detail' in sys.argv
    if len(args) != 2:
        print(__doc__)
        return 2
    proj = 'WRAP' if '--wrap' in sys.argv else 'CELL'
    slot = '--slot' in sys.argv
    print('PROJECTION %s  (%s)' % (proj,
          'whole payload: the wrapper AND the value it wraps' if proj == 'CELL'
          else 'the WRAPPER only -- the field this law owns'))
    print('KEYING     %s' % ('SLOT (site + operand index; the operand span is '
                             'in the payload)' if slot else
                             'POSITIONAL (the operand span is in the KEY)'))
    gP, oP, rcP = load(args[0], proj, slot)
    gX, oX, rcX = load(args[1], proj, slot)

    # CALIBRATION FIRST.
    print('CALIB  golden keys: pristine-sweep %d   patched-sweep %d' %
          (len(gP), len(gX)))
    if gP != gX:
        only = set(gP) ^ set(gX)
        diff = [k for k in (set(gP) & set(gX)) if gP[k] != gX[k]]
        print('CALIB  FAIL: golden halves differ  keys-only-in-one=%d  '
              'payload-differs=%d' % (len(only), len(diff)))
        for k in list(only)[:5] + diff[:5]:
            print('   ', k, fmt(gP.get(k, collections.Counter())), '||',
                  fmt(gX.get(k, collections.Counter())))
        return 3
    print('CALIB  OK: the two sweeps\' golden halves are IDENTICAL')
    print('CENRC  pristine non-zero: %d   patched non-zero: %d' %
          (sum(1 for v in rcP.values() if not v.startswith('0')),
           sum(1 for v in rcX.values() if not v.startswith('0'))))

    gold = gP
    tally = collections.Counter()
    rows = collections.defaultdict(collections.Counter)
    for key in set(gold) | set(oP) | set(oX):
        g = gold.get(key)
        p = oP.get(key)
        x = oX.get(key)
        if g is None:
            v = 'NOGOLD_SAME' if p == x else 'NOGOLD_MOVED'
        elif p is None and x is None:
            v = 'GOLD_ONLY'
        elif p == g and x == g:
            v = 'SAME_AGREE'
        elif p != g and x == g:
            v = 'TO-GOLDEN'
        elif p == g and x != g:
            v = 'AWAY-GOLDEN'
        elif p == x:
            v = 'STILL-WRONG'
        else:
            v = 'MOVED-WRONG'
        tally[v] += 1
        rows[(key[0], key[1])][v] += 1
        if detail and v in ('TO-GOLDEN', 'AWAY-GOLDEN', 'MOVED-WRONG',
                            'NOGOLD_MOVED'):
            print('DETAIL %-12s %s' % (v, key))
            print('        G=%s' % fmt(g) if g else '        G=<absent>')
            print('        P=%s' % fmt(p) if p else '        P=<absent>')
            print('        X=%s' % fmt(x) if x else '        X=<absent>')

    print()
    for v in ('SAME_AGREE', 'TO-GOLDEN', 'AWAY-GOLDEN', 'MOVED-WRONG',
              'STILL-WRONG', 'NOGOLD_SAME', 'NOGOLD_MOVED', 'GOLD_ONLY'):
        print('%-14s %d keys' % (v, tally[v]))
    print()
    print('MOVER ROWS (any key that is not SAME_AGREE/STILL-WRONG/NOGOLD_SAME/'
          'GOLD_ONLY):')
    moved = 0
    for (mode, test), c in sorted(rows.items()):
        interesting = {k: n for k, n in c.items()
                       if k in ('TO-GOLDEN', 'AWAY-GOLDEN', 'MOVED-WRONG',
                                'NOGOLD_MOVED')}
        if interesting:
            print('   %-10s %-28s %s' % (mode, test, interesting))
            moved += 1
    if not moved:
        print('   (none)')
    bad = (tally['AWAY-GOLDEN'] + tally['MOVED-WRONG'] +
           tally['NOGOLD_MOVED'])
    print()
    print('VERDICT %s  (AWAY-GOLDEN %d + MOVED-WRONG %d + NOGOLD_MOVED %d)' %
          ('CLEAN' if bad == 0 else 'DIRTY', tally['AWAY-GOLDEN'],
           tally['MOVED-WRONG'], tally['NOGOLD_MOVED']))
    return 0 if bad == 0 else 1


if __name__ == '__main__':
    sys.exit(main())
