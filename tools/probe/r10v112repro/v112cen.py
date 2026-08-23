#!/usr/bin/env python3
# v112cen.py <golden.dump> <pris.dump> <ship.dump>
# OWNER-KEYED census with a COMPARE-VISIBLE payload.
#   key     = the type_parameter's own fullname (owner chain), SPAN-FREE
#   payload = the SET of (typespec KIND, typespec NAME) its ref_typespec reaches
#             -- VpiType and VpiName are the first two fields every generated
#             Compare reads.  No span, no file, no id: an emission-order flip
#             or a span residue cannot score.
# Verdict per key present on all three sides:
#   TO-GOLDEN  pris != golden and ship == golden
#   AWAY       pris == golden and ship != golden
#   STILL-WRONG pris != golden and ship != golden
#   STILL-RIGHT both equal golden
import sys, re, collections
NAME = re.compile(r'\\_(\w+): \(([^)]*)\)')
# An UNNAMED actual (a builtin typespec: `\_byte_typespec: , line:...`) has no
# parenthesised name at all.  VpiType is the FIRST field every generated
# Compare reads, so the KIND alone is a Compare-visible payload -- keying only
# on parenthesised names made the r10uvm54repro/a1 builtin cells INVISIBLE.
ANY  = re.compile(r'\\_(\w+): (?:\(([^)]*)\))?')
def ind(l): return len(l) - len(l.lstrip())
def cen(path):
    L = open(path, errors='replace').read().split('\n')
    out = collections.defaultdict(set)
    for i, l in enumerate(L):
        m = NAME.search(l)
        if not m or m.group(1) != 'type_parameter': continue
        d = ind(l); full = m.group(2); j = i + 1
        while j < len(L) and L[j].strip() and ind(L[j]) > d:
            if L[j].strip() == '|vpiTypespec:' and ind(L[j]) == d + 2:
                rt = j + 1
                if rt >= len(L): break
                rd = ind(L[rt]); k = rt + 1
                while k < len(L) and L[k].strip() and ind(L[k]) > rd:
                    if L[k].strip() == '|vpiActual:' and ind(L[k]) == rd + 2:
                        mm = ANY.search(L[k+1])
                        if mm: out[full].add((mm.group(1), mm.group(2) or ''))
                        break
                    k += 1
                break
            j += 1
    return out
g, p, s = (cen(x) for x in sys.argv[1:4])
tg = aw = sw = sr = 0
only = 0
for k in sorted(set(g) | set(p) | set(s)):
    if k not in g or k not in p or k not in s:
        only += 1
        print('ONLY  %-60s g=%s p=%s s=%s' % (k, sorted(g.get(k, [])), sorted(p.get(k, [])), sorted(s.get(k, []))))
        continue
    # SUBSET metric.  Golden emits ONE EXTRA type_parameter per group carrying
    # the generic class's own default (uvm_object / uvm_component / svaunit_*)
    # that we do not emit at all -- a MISSING-OBJECT residue that is systematic
    # and independent of the binding under test.  Set EQUALITY therefore scores
    # every group cell wrong on both binaries and is blind to the binding.  The
    # binding is scored by CONTAINMENT: every actual we emit must be one golden
    # emits for that same owner.
    pe, se = p[k] <= g[k], s[k] <= g[k]
    if not pe and se: tg += 1; print('TO-GOLDEN   %-55s %s -> %s' % (k, sorted(p[k]), sorted(s[k])))
    elif pe and not se: aw += 1; print('AWAY-GOLDEN %-55s %s -> %s (golden %s)' % (k, sorted(p[k]), sorted(s[k]), sorted(g[k])))
    elif not pe and not se: sw += 1; print('STILL-WRONG %-55s ours=%s golden=%s' % (k, sorted(s[k]), sorted(g[k])))
    if p[k] != s[k]: print('   MOVED    %-55s %s -> %s (golden %s)' % (k, sorted(p[k]), sorted(s[k]), sorted(g[k])))
    else: sr += 1
print('--- keys g=%d p=%d s=%d | TO-GOLDEN=%d AWAY-GOLDEN=%d STILL-WRONG=%d STILL-RIGHT=%d KEY-ONLY=%d'
      % (len(g), len(p), len(s), tg, aw, sw, sr, only))
