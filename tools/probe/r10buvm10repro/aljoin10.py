#!/usr/bin/env python3
"""r10buvm10 — THE ALIAS CENSUS JOIN.  Reads two r10buvm10cen outputs (golden
tagged G, ours tagged P) and joins their ref_typespec Actual EDGES on an
ORDER-BLIND, ID-BLIND, ADDRESS-BLIND key:

    (actual kind:name, ref fullname, parent chain of kinds+names)

with `hasalias` on the named typespec as the VALUE.  Nothing in the key can
depend on allocation order (every `#id` is stripped), which is what lets the
golden-vs-golden calibration read 0.

MEASUREMENT ONLY.  The official uhdm-cmp is the acceptance judge.

  usage: aljoin10.py <golden.cen (tag G)> <ours.cen (tag P)>

An edge key present on only one side is reported as such (`-`), never silently
dropped: our emitter mints ONE memoized per-use copy where Surelog mints one per
declaration, so one-sided keys are the COPY-COUNT difference and not an alias
fact.  Conflating the two is how a count gap gets read as a defect.
"""
import re, sys, collections

def load(path, tag):
    refs = collections.Counter()
    for line in open(path):
        if not line.startswith('REF ' + tag + ' '):
            continue
        m = re.match(r'REF \S+ ts=(\S+) hasalias=(\d) ref=(\S+) reffull=(\S+) chain=(.*)$',
                     line.rstrip('\n'))
        if not m:
            continue
        ts, ha, rid, rfull, chain = m.groups()
        refs[(re.sub(r':#\d+$', '', ts), re.sub(r'#\d+', '', rfull),
              re.sub(r'#\d+', '', chain), ha)] += 1
    return refs

def bykey(c):
    d = collections.defaultdict(lambda: [0, 0])
    for (tsn, rf, ch, ha), n in c.items():
        d[(tsn, rf, ch)][int(ha)] += n
    return d

G, P = bykey(load(sys.argv[1], 'G')), bykey(load(sys.argv[2], 'P'))
cls, rows = collections.Counter(), []
for k in sorted(set(G) | set(P)):
    g, p = G.get(k, [0, 0]), P.get(k, [0, 0])
    gA = 'A' if g[1] else ('N' if g[0] else '-')
    pA = 'A' if p[1] else ('N' if p[0] else '-')
    cls[(gA, pA)] += 1
    if gA != pA:
        rows.append((k, gA, pA))
print("== key-class counts (golden, ours): A=aliased N=not-aliased -=absent")
for (a, b), n in sorted(cls.items(), key=lambda kv: -kv[1]):
    print("   G=%s P=%s  keys=%d" % (a, b, n))
print("== DISAGREEING keys: %d" % len(rows))
grp = collections.Counter()
for (tsn, rf, ch), gA, pA in rows:
    grp[(gA, pA, tsn.split(':')[0], ch.split('(')[0] if ch != '-' else '-')] += 1
for (gA, pA, tk, ok), n in sorted(grp.items(), key=lambda kv: -kv[1])[:40]:
    print("   G=%s P=%s  actual=%-22s owner=%-24s keys=%d" % (gA, pA, tk, ok, n))
print("== the ACTIONABLE class, G=A P=N (golden aliases, we do not):")
for (tsn, rf, ch), gA, pA in rows:
    if gA == 'A' and pA == 'N':
        print("   %-44s ref=%-46s chain=%s" % (tsn, rf, ch[:140]))
