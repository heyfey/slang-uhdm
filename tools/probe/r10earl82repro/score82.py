#!/usr/bin/env python3
"""r10earl82 — MULTISET JOIN + 3-WAY SCORER for range-bound censuses.

MEASUREMENT ONLY.  The official uhdm-cmp remains the sole judge.

`rngcen82` rows look like

    RNG <chain> s=<slot> sp=<span> || K=constant ct=9 sz=64 val=UINT:8 dec=8 ts=-

The join key is (chain, slot, span): the chain separates DEF from ELAB and
names the CONSUMER, the span names the written bound.  Payload scoring uses
ONLY the judge-visible fields — the `sp=` field is stripped from the payload
side, never from the key, so a cell can be located without a span ever
entering a score (earl60's attrv60.py lesson).

Modes
  --diff  GOLD OURS         list every key whose payload multiset differs,
                            tagged SIZE-ONLY when the ONLY differing field
                            is `sz`
  --score GOLD PRIS PATCHED 3-way on the WHOLE judge-visible payload:
                            TO-GOLDEN / AWAY-GOLDEN / MOVED-WRONG /
                            UNMOVED-RIGHT / UNMOVED-WRONG
  --field F GOLD PRIS PATCHED
                            the SAME 3-way, projected onto ONE payload field
                            (`sz`, `ct`, `val`, `ts`, ...) plus the object KIND.
                            A cell whose OTHER fields are wrong in BOTH states
                            makes the whole-payload score read MOVED-WRONG for a
                            move that landed the projected field exactly on
                            golden; earl63's grids are scored field by field for
                            that reason, and both numbers are reported here.
  --cons  GOLD OURS         population table keyed by CONSUMER (the range's
                            own parent kind) x verdict
"""
import sys, collections, re

CONS = collections.defaultdict(set)


def parse(fn, cons=None):
    if cons is None:
        cons = collections.defaultdict(set)
    rows = collections.Counter()
    try:
        f = open(fn, errors='replace')
    except OSError:
        return rows
    for l in f:
        if not l.startswith('RNG '):
            continue
        try:
            head, pay = l.rstrip('\n').split(' || ', 1)
        except ValueError:
            continue
        parts = head.split(' ')
        # RNG <chain> s=<slot> sp=<span>
        chain = ' '.join(parts[1:-2])
        slot = parts[-2][2:]
        span = parts[-1][3:]
        # The FILE is stripped from the key: our ranges carry an empty
        # VpiFile, so keeping it would put every golden cell in one bucket and
        # every one of ours in another (measured: a CMP_EQUAL u2r test scored
        # 40+ phantom OTHERs before this line existed).
        col = span.find(':')
        fpart, span = span[:col], span[col + 1:]
        # KEY = (span, slot).  The CHAIN is deliberately NOT in the key:
        # vpiParent is not a field any generated Compare reads, so our parent
        # chains legitimately differ from golden's on cells the judge calls
        # equal, and keying on them manufactures phantom rows (measured: a
        # CMP_EQUAL u2r test produced 40+ of them).  The chain is kept as the
        # CONSUMER label of the golden side.
        rows[((span, slot), pay)] += 1
        cons[(span, slot)].add(consumer(chain))
    return rows

def bykey(rows):
    d = collections.defaultdict(collections.Counter)
    for (k, pay), n in rows.items():
        d[k][pay] += n
    return d

FIELD = re.compile(r'(\w+)=(\S+)')

def fields(pay):
    return dict(FIELD.findall(pay))

def sizeonly(gl, ol):
    """SIZE-ONLY == the two sides pair up element-for-element with `sz` as the
    ONLY differing field.  The pairing is over MULTISETS, not single cells: one
    written bound legitimately carries several live copies (DEF listing, the
    elaborated typespec, the declaration-side copy), and the head this pass
    starts from is 3-vs-3, which a len==1 test would have mis-filed as OTHER."""
    if len(gl) != len(ol) or not gl:
        return False
    for a, b in zip(sorted(gl), sorted(ol)):
        fa, fb = fields(a), fields(b)
        if set(fa) != set(fb):
            return False
        if [k for k in fa if fa[k] != fb[k]] != ['sz']:
            return False
    return True

def consumer(chain):
    # the range's own parent = the LAST chain component
    return chain.split('/')[-1].split('(')[0] if chain else '-'


def conslabel(cons, k):
    return ','.join(sorted(cons.get(k, {'-'})))

def main():
    mode = sys.argv[1]
    if mode == '--diff':
        gc = collections.defaultdict(set)
        g, o = bykey(parse(sys.argv[2], gc)), bykey(parse(sys.argv[3]))
        tally = collections.Counter()
        for k in sorted(set(g) | set(o)):
            gp, op = g.get(k, collections.Counter()), o.get(k, collections.Counter())
            if gp == op:
                tally['AGREE'] += sum(gp.values())
                continue
            gl = sorted((gp - op).elements())
            ol = sorted((op - gp).elements())
            tag = 'OTHER'
            if sizeonly(gl, ol):
                tag = 'SIZE-ONLY'
            tally[tag] += 1
            print(f"{tag}\t{conslabel(gc, k)}\t{k[0]}\t{k[1]}\tG:{'|'.join(gl)}\tO:{'|'.join(ol)}")
        print('# ' + '  '.join(f'{k}={v}' for k, v in sorted(tally.items())), file=sys.stderr)
    elif mode == '--cons':
        gc = collections.defaultdict(set)
        g, o = bykey(parse(sys.argv[2], gc)), bykey(parse(sys.argv[3]))
        t = collections.Counter()
        for k in set(g) | set(o):
            gp, op = g.get(k, collections.Counter()), o.get(k, collections.Counter())
            lab = conslabel(gc, k)
            if gp == op:
                t[(lab, 'AGREE')] += 1
            else:
                gl, ol = sorted((gp - op).elements()), sorted((op - gp).elements())
                if sizeonly(gl, ol):
                    t[(lab, 'SIZE-ONLY')] += 1
                else:
                    t[(lab, 'OTHER')] += 1
        for k in sorted(t):
            print(f"{k[0]}\t{k[1]}\t{t[k]}")
    elif mode == '--field':
        f = sys.argv[2]
        g, p, q = (bykey(parse(sys.argv[i])) for i in (3, 4, 5))

        def proj(c):
            out = collections.Counter()
            for pay, n in c.items():
                fl = fields(pay)
                out[(fl.get('K', '?'), fl.get(f, '-'))] += n
            return out
        t = collections.Counter()
        for k in sorted(set(g) | set(p) | set(q)):
            gp = proj(g.get(k, collections.Counter()))
            pp = proj(p.get(k, collections.Counter()))
            qp = proj(q.get(k, collections.Counter()))
            if pp == qp:
                t['UNMOVED-RIGHT' if qp == gp else 'UNMOVED-WRONG'] += 1
                continue
            if qp == gp:
                t['TO-GOLDEN'] += 1
            elif pp == gp:
                t['AWAY-GOLDEN'] += 1
                print(f"AWAY[{f}]\t{k}\tG:{sorted(gp.items())}\tP:{sorted(pp.items())}\tQ:{sorted(qp.items())}")
            else:
                # Closer or further ON THIS FIELD, measured as the size of the
                # multiset symmetric difference against golden.
                dp = sum(((pp - gp) + (gp - pp)).values())
                dq = sum(((qp - gp) + (gp - qp)).values())
                t['MOVED-CLOSER' if dq < dp else
                  ('MOVED-FURTHER' if dq > dp else 'MOVED-SIDEWAYS')] += 1
                print(f"{'CLOSER' if dq < dp else ('FURTHER' if dq > dp else 'SIDEWAYS')}[{f}]"
                      f"\t{k}\tdist P={dp} Q={dq}\tG:{sorted(gp.items())}"
                      f"\tP:{sorted(pp.items())}\tQ:{sorted(qp.items())}")
        print('# ' + '  '.join(f'{k}={v}' for k, v in sorted(t.items())))
    elif mode == '--score':
        g, p, q = (bykey(parse(sys.argv[i])) for i in (2, 3, 4))
        t = collections.Counter()
        for k in sorted(set(g) | set(p) | set(q)):
            gp = g.get(k, collections.Counter())
            pp = p.get(k, collections.Counter())
            qp = q.get(k, collections.Counter())
            if pp == qp:
                t['UNMOVED-RIGHT' if qp == gp else 'UNMOVED-WRONG'] += 1
                continue
            if qp == gp:
                t['TO-GOLDEN'] += 1
            elif pp == gp:
                t['AWAY-GOLDEN'] += 1
                print(f"AWAY\t{k}\tG:{sorted(gp.elements())}\tP:{sorted(pp.elements())}\tQ:{sorted(qp.elements())}")
            else:
                t['MOVED-WRONG'] += 1
                print(f"MOVED-WRONG\t{k}\tG:{sorted(gp.elements())}\tP:{sorted(pp.elements())}\tQ:{sorted(qp.elements())}")
        print('# ' + '  '.join(f'{k}={v}' for k, v in sorted(t.items())))
    else:
        print(__doc__)
        sys.exit(2)

main()
