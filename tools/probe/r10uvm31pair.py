#!/usr/bin/env python3
"""r10uvm31pair.py <golden.io> <ours.io> [--top N] [--only KEYSUB]

Join two r10uvm30io censuses by ROW KEY and classify the surviving diff by
PAIR CLASS instead of by line.  r10uvm30iom.sh reports IOTOTAL2 as a raw
`diff | grep -c '^[<>]'`, which counts a single wrong formal twice and gives
no shape at all; pass 31's ranked #1 is "census by PAIR CLASS first", and this
is that census.

Row key   = everything up to and including the `io[i] 'name'` field, i.e. the
            view tag, the owner, the method and the formal position.
Row value = the projected fields, split into named columns:
            dir / ts / expr / v / d.

Output, most populous first:
  <count>  <column>  golden=<lhs>  ours=<rhs>
followed by a per-column and a per-test total, then a few example keys per
class so the decode has somewhere to start.
"""
import re
import sys
from collections import Counter, defaultdict

KEYRE = re.compile(r"^(.*? io\[[-0-9]+\] '[^']*') (.*)$")


def parse(path):
    rows = {}
    order = []
    with open(path) as f:
        for line in f:
            line = line.rstrip('\n')
            m = KEYRE.match(line)
            if not m:
                # `io[-] <none>` rows have no quoted formal name
                k, _, rest = line.partition(' io[-] ')
                if rest:
                    rows.setdefault(k + ' io[-]', rest)
                    order.append(k + ' io[-]')
                continue
            key, rest = m.group(1), m.group(2)
            # duplicate keys (same method listed twice) get a suffix
            k = key
            n = 1
            while k in rows:
                n += 1
                k = f'{key}#{n}'
            rows[k] = rest
            order.append(k)
    return rows, order


def cols(rest):
    """Split an r10uvm30io value into named columns."""
    out = {}
    m = re.match(r"^(\S+) ts=(.*?) expr=(\S+) '([^']*)'(.*)$", rest)
    if not m:
        return {'raw': rest}
    out['dir'] = m.group(1)
    out['ts'] = m.group(2)
    out['expr'] = m.group(3) + " '" + m.group(4) + "'"
    tail = m.group(5)
    mv = re.match(r"^ v=(.*) d=(.*)$", tail)
    if mv:
        out['val'] = mv.group(1)
        out['dec'] = mv.group(2)
    return out


def tskind(ts):
    """Coarsen a ts projection to its KIND / NAME / INSTANCE parts."""
    m = re.match(r"^([a-z_]+)'([^']*)'(@(\S+))?", ts)
    if not m:
        return (ts, '', '')
    return (m.group(1), m.group(2), m.group(4) or '')


def main():
    g, ourspath = sys.argv[1], sys.argv[2]
    top = 40
    if '--top' in sys.argv:
        top = int(sys.argv[sys.argv.index('--top') + 1])
    only = None
    if '--only' in sys.argv:
        only = sys.argv[sys.argv.index('--only') + 1]

    gr, go = parse(g)
    orr, oo = parse(ourspath)
    gk, ok = set(gr), set(orr)

    print(f'rows golden={len(gr)} ours={len(orr)} '
          f'goldenonly={len(gk - ok)} oursonly={len(ok - gk)} '
          f'shared={len(gk & ok)}')

    pair = Counter()
    ex = defaultdict(list)
    colcnt = Counter()
    for k in sorted(gk & ok):
        if only and only not in k:
            continue
        a, b = cols(gr[k]), cols(orr[k])
        for c in sorted(set(a) | set(b)):
            va, vb = a.get(c, '<absent>'), b.get(c, '<absent>')
            if va == vb:
                continue
            colcnt[c] += 1
            if c == 'ts':
                ka, kb = tskind(va), tskind(vb)
                sub = ('KIND' if ka[0] != kb[0] else
                       'NAME' if ka[1] != kb[1] else
                       'INST' if ka[2] != kb[2] else 'OTHER')
                lab = (f'ts/{sub}', f'{ka[0]}|{ka[1]}|{ka[2]}',
                       f'{kb[0]}|{kb[1]}|{kb[2]}')
            else:
                lab = (c, va, vb)
            pair[lab] += 1
            if len(ex[lab]) < 3:
                ex[lab].append(k)

    print('\n-- POPULATION (rows present on one side only) --')
    for tag, s in (('GOLDEN-ONLY', gk - ok), ('OURS-ONLY', ok - gk)):
        if not s:
            continue
        c = Counter(k.split('::')[0].split(' ')[-1] for k in s)
        print(f'{tag} {len(s)}: ' + ', '.join(f'{n}x{o}' for o, n in
                                              c.most_common(8)))

    print('\n-- PER-COLUMN diffs on shared rows --')
    for c, n in colcnt.most_common():
        print(f'{n:7d}  {c}')

    print(f'\n-- PAIR CLASSES (top {top}) --')
    for (c, va, vb), n in pair.most_common(top):
        print(f'{n:7d}  {c}\n         G: {va}\n         O: {vb}')
        for e in ex[(c, va, vb)]:
            print(f'         @ {e}')
    print(f'\nPAIRTOTAL={sum(pair.values())}')


main()
