#!/usr/bin/env python3
"""r10buvm23repro/hpcen23.py — MULTISET join of two r10buvm23cen HP censuses.

MEASUREMENT ONLY.  LHS is ALWAYS golden, RHS is ALWAYS ours.

Key    = (view, owner, loc)            -- what identifies the SAME source site
Payload= (name, nel, elems, rootkind)  -- what the judge reads (VpiName, and the
                                          Path_elems shape behind it)

A MULTISET join, not a dict: two hier_paths can share a key (the same site
listed twice, e.g. a package's DEF and ELAB copies reached through the same
owner) and a last-writer dict silently drops rows (RESUME §9, census traps).

  usage: hpcen23.py <golden.cen> <ours.cen> [--full] [--key3]
"""
import sys, collections

def cmpvis(elems):
    """Strip the fields `Compare` never reads.  BaseClass::Compare reads
    VpiType + VpiName + VpiDefName; bit_select adds VpiConstantSelect +
    VpiIndex; hier_path adds Path_elems + Root_value + VpiName.  VpiFullName
    is NOT read by any generated Compare (RESUME 9), so a fullname-only
    disagreement is INVISIBLE to the judge and must not be counted as one."""
    out = []
    for e in elems.split(' | '):
        f = e.split(':')
        keep = f[:2] + [x for x in f[3:] if x.startswith('idx=')]
        out.append(':'.join(keep))
    return ' | '.join(out)


def load(p, want='HP'):
    rows = collections.defaultdict(list)
    n = 0
    for ln in open(p):
        f = ln.rstrip('\n').split('\t')
        if len(f) < 9 or f[1] != want:
            continue
        key = (f[2], f[3], f[4])            # view, owner, loc
        el = cmpvis(f[8]) if CMPONLY else f[8]
        pay = (f[5], f[6], el, f[9] if len(f) > 9 else '')
        rows[key].append(pay)
        n += 1
    return rows, n

CMPONLY = '--cmponly' in sys.argv
g, gn = load(sys.argv[1])
o, on = load(sys.argv[2])
full = '--full' in sys.argv

same = diff = gonly = oonly = 0
difflines = []
for k in sorted(set(g) | set(o)):
    gl = collections.Counter(g.get(k, []))
    ol = collections.Counter(o.get(k, []))
    inter = gl & ol
    same += sum(inter.values())
    gr = gl - inter
    orr = ol - inter
    if not gr and not orr:
        continue
    # pair them up positionally for reporting
    gs = sorted(gr.elements()); os_ = sorted(orr.elements())
    for i in range(max(len(gs), len(os_))):
        gg = gs[i] if i < len(gs) else None
        oo = os_[i] if i < len(os_) else None
        if gg is not None and oo is not None:
            diff += 1
            difflines.append(('DIFF', k, gg, oo))
        elif gg is not None:
            gonly += 1
            difflines.append(('GOLDEN_ONLY', k, gg, None))
        else:
            oonly += 1
            difflines.append(('OURS_ONLY', k, None, oo))

print('GOLDEN rows %d  OURS rows %d' % (gn, on))
print('SAME %d  DIFF %d  GOLDEN_ONLY %d  OURS_ONLY %d' % (same, diff, gonly, oonly))
lim = len(difflines) if full else 40
for t, k, gg, oo in difflines[:lim]:
    print('--- %s %s' % (t, ' | '.join(k)))
    if gg: print('    G name=%s %s\n      G elems=%s root=%s' % (gg[0], gg[1], gg[2], gg[3]))
    if oo: print('    O name=%s %s\n      O elems=%s root=%s' % (oo[0], oo[1], oo[2], oo[3]))
if not full and len(difflines) > lim:
    print('... %d more (use --full)' % (len(difflines) - lim))
