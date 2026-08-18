#!/usr/bin/env python3
"""r10rgg13/score13.py — golden-vs-ours (and base-vs-patched) over a grid census.

  usage: score13.py <golden.cen> <ours-base.cen> [<ours-patched.cen>]
                    [--rows] [--only ARG|PA|PORT|CA|RANGE|ALL]

A census line is `<cell>\\t<key>\\t<value>`; keys can repeat, so the join is a
MULTISET join (a last-writer dict silently drops rows — RESUME §9).

With two ours-files the three-way OK / FIXED / BROKEN / STILL / MOVED-STILL-
WRONG classification is printed; with one, the plain golden-vs-ours split.
"""
import sys, collections, re

# --cmpvis: keep ONLY what the generated `Compare` methods actually read.
# acensus13 prints two columns no Compare touches — `/P:<parent kind>@<l:c>`
# (vpiParent, read by NO generated Compare at all: it is the census's COPY
# MARKER, nothing more) and the LOCATION inside `T:<kind>@<l:c>` (typespec
# identity; `typespec::Compare` reads the KIND and the per-kind fields, never
# the file/line/column).  Scoring with them in place reports a row as differing
# when the judge calls it EQUAL, so every claim about uhdm-cmp is made in this
# mode and every claim about object identity in the other.
def cmpvis(v):
    v = re.sub(r'/P:[^/]*', '', v)
    v = re.sub(r'(T:[A-Za-z_]+)@[0-9]+:[0-9]+', r'\1', v)
    return v

def load(p, vis=False):
    d = collections.defaultdict(list)
    for ln in open(p):
        parts = ln.rstrip('\n').split('\t')
        if len(parts) < 3: continue
        d[(parts[0], parts[1])].append(cmpvis(parts[2]) if vis else parts[2])
    return d

def main():
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    flags = [a for a in sys.argv[1:] if a.startswith('--')]
    rows = '--rows' in flags
    only = 'ALL'
    for f in flags:
        if f.startswith('--only'): only = f.split('=')[1] if '=' in f else 'ALL'
    vis = '--cmpvis' in flags
    g = load(args[0], vis); b = load(args[1], vis)
    p = load(args[2], vis) if len(args) > 2 else None
    keys = set(g) | set(b) | (set(p) if p else set())
    if only != 'ALL':
        keys = {k for k in keys if k[1].split('|')[1] == only}
    cnt = collections.Counter()
    out = []
    for k in sorted(keys):
        gv = sorted(g.get(k, [])); bv = sorted(b.get(k, []))
        if p is None:
            c = 'SAME' if gv == bv else 'DIFF'
            cnt[c] += 1
            if rows and c == 'DIFF': out.append((c, k, gv, bv, None))
            continue
        pv = sorted(p.get(k, []))
        if gv == bv and gv == pv: c = 'OK'
        elif gv != bv and gv == pv: c = 'FIXED'
        elif gv == bv and gv != pv: c = 'BROKEN'
        elif gv != bv and bv == pv: c = 'STILL'
        else: c = 'MOVED-STILL-WRONG'
        cnt[c] += 1
        if rows and c in ('FIXED', 'BROKEN', 'MOVED-STILL-WRONG'):
            out.append((c, k, gv, bv, pv))
    for c, k, gv, bv, pv in out:
        print(f"{c} {k[0]} {k[1]}\n   G={gv}\n   B={bv}" + (f"\n   P={pv}" if pv is not None else ""))
    print("-- " + " ".join(f"{k}={v}" for k, v in sorted(cnt.items())) +
          f" TOTAL={sum(cnt.values())}")

main()
