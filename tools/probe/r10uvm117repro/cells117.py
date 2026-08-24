#!/usr/bin/env python3
"""r10uvm117repro/cells117.py — THE IMPLICIT-NET POPULATION JOIN.

MEASUREMENT ONLY (the official uhdm-cmp is the judge).
LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.

Reads one pair of ct117cen listings (G side and O side) and prints, per TOP
MODULE, the IMPLICIT-NET population difference as a MULTISET join keyed on
(view, module fullname, net name, span) -- never on a dict, so two nets of one
name in one module cannot silently collapse (RESUME §9).

Each differing cell is JOINED WITH ITS ORIGIN: the reference that mints it.
The minting reference is the one whose OWN span equals the net's span
(UhdmWriter.cpp:3982-4004 stamps the net with the reference's span); its owner,
the owner's HOME kind (CLS / PKG / MOD) and its OOB/IB class are printed, and
so is whether the named declaration is a `ref_var` LOCAL on that side (the RV
rows).  ORIGIN is looked up on the side that HAS the net.

Two keys are printed, because they answer two different questions:
  * SPAN-KEYED (the rows) -- (view, module, name, span).  A name present on
    both sides at two different spans prints as one GOLDEN-ONLY and one
    OURS-ONLY row: that is a MINTING-ORDER residue (the net takes the FIRST
    unbindable reference's span), and no generated Compare reads a span.
  * NAME-KEYED (the SUMMARY's second half) -- (view, module, name).  THAT is
    the population the judge can see: a name golden's module holds and ours
    does not (or the mirror).

  usage: cells117.py <g.txt> <o.txt> [label]
"""
import sys, collections

def load(p):
    rv, nets, refs = [], [], []
    for ln in open(p):
        f = ln.rstrip('\n').split('\t')
        if len(f) < 3: continue
        if f[1] == 'RV' and len(f) >= 7: rv.append(f)
        elif f[1] == 'NET' and len(f) >= 9: nets.append(f)
        elif f[1] == 'REF' and len(f) >= 14: refs.append(f)
    return rv, nets, refs

def implkey(n):        # (view, module, name, span)
    return (n[2], n[4], n[6], n[5])

def main():
    g, o, label = sys.argv[1], sys.argv[2], (sys.argv[3] if len(sys.argv) > 3 else '')
    grv, gnet, gref = load(g)
    orv, onet, oref = load(o)
    gi = collections.Counter(implkey(n) for n in gnet if n[3] == 'IMPL')
    oi = collections.Counter(implkey(n) for n in onet if n[3] == 'IMPL')
    def origin(refs, rvs, view, name, span):
        # the MINTING reference: same view, same name, span == the net's span
        hit = [r for r in refs if r[2] == view and r[7] == name and r[6] == span]
        if not hit:
            hit = [r for r in refs if r[7] == name and r[6] == span]
        if not hit:
            hit = [r for r in refs if r[2] == view and r[7] == name and r[12] == 'IMPL']
        if not hit:
            return '-\t-\t-\t-\t-'
        r = hit[0]
        isrv = any(v[6] == name and v[5] == r[5] for v in rvs)
        return '%s\t%s\t%s\t%s\t%s' % (r[4], r[3], r[5], r[11], 'RV' if isrv else 'notRV')
    out = []
    for k in sorted(set(gi) | set(oi)):
        gc, oc = gi.get(k, 0), oi.get(k, 0)
        if gc == oc: continue
        view, mod, name, span = k
        who = 'GOLDEN-ONLY' if oc == 0 else ('OURS-ONLY' if gc == 0 else 'COUNT')
        refs, rvs = (gref, grv) if gc else (oref, orv)
        out.append('%s\t%s\t%s\t%s\t%s\t%s\tg=%d\to=%d\t%s' %
                   (label, who, view, mod, name, span, gc, oc,
                    origin(refs, rvs, view, name, span)))
    print('# LABEL\tWHO\tVIEW\tMODULE\tNAME\tSPAN\tgN\toN\tOWNER\tHOME\tOOB\tPARENT\tDECL')
    for l in out: print(l)
    tg = sum(1 for l in out if '\tGOLDEN-ONLY\t' in l)
    to = sum(1 for l in out if '\tOURS-ONLY\t' in l)
    tc = sum(1 for l in out if '\tCOUNT\t' in l)
    print('# SUMMARY %s  IMPLNETS golden=%d ours=%d  SPAN-KEYED differing cells=%d '
          '(GOLDEN-ONLY %d / OURS-ONLY %d / COUNT %d)' %
          (label, sum(gi.values()), sum(oi.values()), len(out), tg, to, tc))
    # NAME-KEYED: the judge-visible population.
    gn = collections.Counter((k[0], k[1], k[2]) for k in gi.elements())
    on = collections.Counter((k[0], k[1], k[2]) for k in oi.elements())
    gonly = [k for k in sorted(set(gn) | set(on)) if on.get(k, 0) == 0]
    oonly = [k for k in sorted(set(gn) | set(on)) if gn.get(k, 0) == 0]
    for k in gonly:
        span = [x[3] for x in gi if (x[0], x[1], x[2]) == k][0]
        print('%s\tNAME-GOLDEN-ONLY\t%s\t%s\t%s\t%s\t\t\t%s' %
              (label, k[0], k[1], k[2], span, origin(gref, grv, k[0], k[2], span)))
    for k in oonly:
        span = [x[3] for x in oi if (x[0], x[1], x[2]) == k][0]
        print('%s\tNAME-OURS-ONLY\t%s\t%s\t%s\t%s\t\t\t%s' %
              (label, k[0], k[1], k[2], span, origin(oref, orv, k[0], k[2], span)))
    print('# NAMESUMMARY %s  NAME-KEYED golden-only=%d ours-only=%d' %
          (label, len(gonly), len(oonly)))

main()
