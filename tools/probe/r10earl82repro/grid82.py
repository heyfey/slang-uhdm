#!/usr/bin/env python3
"""r10earl82 — score `g5_enc82.sv` cell by cell against golden.

MEASUREMENT ONLY.  Reads `rngcen82` censuses; builds nothing, dispatches
nothing.  One row per (referent, consumer) cell: what golden writes at the
bound, what the pristine binary writes, and (when given) the patched one.

usage: grid82.py <g5_enc82.sv> <gold.cen> <pris.cen> [<patched.cen>]
"""
import sys, re, collections

CONSUMER = {'n_': 'packed-net', 'v_': 'packed-structarr-var',
            'u_': 'unpacked-range-dim', 'p_': 'PORT-packed-range'}


def declmap(src):
    """line -> (referent, consumer) for every generated declaration."""
    m = {}
    for i, l in enumerate(open(src), 1):
        mm = re.match(r'\s*(?:input\s+)?(?:logic|mr_t|mr2_82)?\s*\[(\w+):0\]\s*([nvup])_(\w+)[;,)]', l)
        if mm:
            m[i] = (mm.group(3), CONSUMER[mm.group(2) + '_'])
            continue
        mm = re.match(r'\s*logic \[3:0\]\s+u_(\w+) \[(\w+):0\];', l)
        if mm:
            m[i] = (mm.group(1), 'unpacked-range-dim')
    return m


def cen(fn):
    d = collections.defaultdict(collections.Counter)
    for l in open(fn, errors='replace'):
        if not l.startswith('RNG '):
            continue
        head, pay = l.rstrip('\n').split(' || ', 1)
        parts = head.split(' ')
        slot, span = parts[-2][2:], parts[-1][3:]
        span = span[span.find(':') + 1:]          # drop the file (ours is empty)
        if slot != 'left':
            continue
        d[int(span.split(':')[0])][pay] += 1
    return d


def brief(counter):
    out = []
    for pay, n in sorted(counter.items()):
        f = dict(re.findall(r'(\w+)=(\S+)', pay))
        if pay.startswith('K=constant'):
            t = f"{f['val']}/sz{f['sz']}/ct{f['ct']}" + ('' if f['ts'] == '-' else '+TS')
        elif pay.startswith('K=ref_obj'):
            t = f"ref({f['nm']})"
        else:
            t = pay.split(' ')[0][2:]
        out.append(f"{n}x{t}")
    return ' '.join(out) if out else '-'


def main():
    src, gf, pf = sys.argv[1], sys.argv[2], sys.argv[3]
    qf = sys.argv[4] if len(sys.argv) > 4 else None
    dm = declmap(src)
    g, p = cen(gf), cen(pf)
    q = cen(qf) if qf else None
    hdr = f"{'referent':6} {'consumer':22} {'GOLDEN':34} {'PRISTINE':34}"
    if q is not None:
        hdr += f" {'PATCHED':34} verdict"
    print(hdr)
    tal = collections.Counter()
    for ln in sorted(dm):
        ref, cons = dm[ln]
        gb, pb = brief(g[ln]), brief(p[ln])
        row = f"{ref:6} {cons:22} {gb:34} {pb:34}"
        if q is not None:
            qb = brief(q[ln])
            if p[ln] == q[ln]:
                v = 'UNMOVED-RIGHT' if q[ln] == g[ln] else 'UNMOVED-WRONG'
            elif q[ln] == g[ln]:
                v = 'TO-GOLDEN'
            elif p[ln] == g[ln]:
                v = 'AWAY-GOLDEN'
            else:
                v = 'MOVED-WRONG'
            tal[v] += 1
            row += f" {qb:34} {v}"
        else:
            tal['AGREE' if g[ln] == p[ln] else 'DIFF'] += 1
        print(row)
    print('# ' + '  '.join(f'{k}={v}' for k, v in sorted(tal.items())))


main()
