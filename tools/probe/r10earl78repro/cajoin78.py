#!/usr/bin/env python3
"""r10earl78 — MULTISET JOIN of two cacen78 censuses (golden vs ours, or a
3-way golden/pristine/patched score).  MEASUREMENT ONLY.

Key   = SEC | HOME | OWNER | line:col-line:col   (the FILE component of the
        span is dropped: our hier objects carry an EMPTY VpiFile).
        Repeated keys are kept as a MULTISET (a comma-list cont_assign gives
        every member the same span — a last-writer dict would drop rows).
Value = the whole payload (lhs=, rhs=, ct=, sz=, val=, dec=, ts=, tsval=,
        tssgn=), i.e. the fields a generated Compare reads plus the shape.
        NO span rides in the payload (earl60's attrv60.py lesson).

  usage: cajoin78.py <golden.txt> <ours.txt> [patched.txt]
         cajoin78.py --shape <golden.txt> <ours.txt>   # per-shape tally
"""
import sys, re, collections

SPANRE = re.compile(r'^[^ ]*?:(\d+:\d+-\d+:\d+)$')

def load(path):
    d = collections.Counter()
    rows = []
    for ln in open(path):
        ln = ln.rstrip('\n')
        if not ln.startswith('CA '):
            continue
        f = ln.split(' ')
        sec, home, owner, span = f[1], f[2], f[3], f[4]
        m = SPANRE.match(span)
        span = m.group(1) if m else span
        key = (sec, home, owner, span)
        pay = ' '.join(f[5:])
        d[(key, pay)] += 1
        rows.append((key, pay))
    return d, rows

def shape(pay):
    m = re.search(r'rhs=(\S+)', pay)
    if not m: return '?'
    r = m.group(1)
    if r.startswith('op34('):
        inner = r[5:-1]
        # first operand = count, rest = element
        return 'REPL:' + re.sub(r'c(\d+):[^:,)]*:(\d+)', r'c\1/\2', inner)
    if r.startswith('op33('): return 'CONCAT'
    if r.startswith('op'):    return 'OP' + r[2:r.find('(')] if '(' in r else r
    if r.startswith('c'):     return 'CONST'
    return r.split(':')[0]

def main():
    args = sys.argv[1:]
    shapemode = False
    if args and args[0] == '--shape':
        shapemode = True; args = args[1:]
    g, grows = load(args[0])
    o, orows = load(args[1])
    p = load(args[2])[0] if len(args) > 2 else None

    gk = collections.Counter(k for (k, _), n in g.items() for _ in range(n))
    ok = collections.Counter(k for (k, _), n in o.items() for _ in range(n))
    print(f"cells golden={sum(gk.values())} ours={sum(ok.values())}")
    print(f"keys  only-golden={sum((gk-ok).values())} only-ours={sum((ok-gk).values())}")

    same = (g & o)
    print(f"IDENTICAL cells {sum(same.values())}")
    gd = g - o
    od = o - g
    print(f"DIFFERING cells golden-side {sum(gd.values())} ours-side {sum(od.values())}")

    if shapemode:
        # tally the DIFFERING cells by (home, sec, our shape, golden kind)
        gmap = collections.defaultdict(list)
        for k, pay in grows: gmap[k].append(pay)
        omap = collections.defaultdict(list)
        for k, pay in orows: omap[k].append(pay)
        tal = collections.Counter()
        for k in set(gmap) | set(omap):
            gl, ol = gmap.get(k, []), omap.get(k, [])
            for i in range(max(len(gl), len(ol))):
                gp = gl[i] if i < len(gl) else '<absent>'
                op = ol[i] if i < len(ol) else '<absent>'
                if gp == op: continue
                gk_ = 'CONST' if re.search(r'rhs=c\d', gp) else shape(gp)
                tal[(k[0], k[1], shape(op), gk_)] += 1
        print("\nDIFFERING cells by SEC | HOME | OUR SHAPE | GOLDEN KIND")
        for (sec, home, os_, gk_), n in sorted(tal.items(), key=lambda x: -x[1]):
            print(f"{n:6d}  {sec:4s} {home:3s}  ours={os_:52s} golden={gk_}")

    if p is not None:
        # 3-way score
        gmap = collections.defaultdict(list)
        for k, pay in grows: gmap[k].append(pay)
        omap = collections.defaultdict(list)
        for k, pay in orows: omap[k].append(pay)
        pmap = collections.defaultdict(list)
        for ln in open(args[2]):
            if not ln.startswith('CA '): continue
            f = ln.rstrip('\n').split(' ')
            m = SPANRE.match(f[4]); sp = m.group(1) if m else f[4]
            pmap[(f[1], f[2], f[3], sp)].append(' '.join(f[5:]))
        cnt = collections.Counter()
        movers = []
        for k in set(gmap) | set(omap) | set(pmap):
            gl, ol, pl = gmap.get(k, []), omap.get(k, []), pmap.get(k, [])
            for i in range(max(len(gl), len(ol), len(pl))):
                gp = gl[i] if i < len(gl) else '<absent>'
                op = ol[i] if i < len(ol) else '<absent>'
                pp = pl[i] if i < len(pl) else '<absent>'
                if op == pp:
                    cnt['STILL-RIGHT' if gp == pp else 'STILL-WRONG'] += 1
                elif pp == gp:
                    cnt['TO-GOLDEN'] += 1; movers.append(('TO-GOLDEN', k, op, pp))
                elif op == gp:
                    cnt['AWAY-GOLDEN'] += 1; movers.append(('AWAY-GOLDEN', k, op, pp))
                else:
                    cnt['MOVED-WRONG'] += 1; movers.append(('MOVED-WRONG', k, op, pp))
        print("\n3-WAY SCORE  " + '  '.join(f"{k}={v}" for k, v in sorted(cnt.items())))
        for tag in ('AWAY-GOLDEN', 'MOVED-WRONG'):
            for m in movers:
                if m[0] == tag:
                    print(f"  {tag} {m[1]}\n    was={m[2]}\n    now={m[3]}")
        return movers
    return None

if __name__ == '__main__':
    main()
