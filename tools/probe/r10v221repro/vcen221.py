#!/usr/bin/env python3
# r10v221repro/vcen221.py — THE VERIFIER'S OWN ENUM-ACTUAL CENSUS.
# MEASUREMENT ONLY; uhdm-cmp remains the sole acceptance judge.
#
# Written from the dump format up, independently of the implementer's cen221.py,
# so a flaw in that scorer cannot be inherited.
#
#   usage: vcen221.py <golden.dump> <a.dump> <b.dump> [--holder=SUBSTR]
#
# For every `ref_obj`/`ref_var` in a dump it records
#     key     = (vpiName, line, col)
#     payload = the vpiActual's KIND, and for an enum_const its NAME+DECOMPILE
# as a MULTISET per key (the same position is printed once per copy of the
# enclosing listing; a last-writer dict would silently drop rows — RESUME §9).
# The weaklyReferenced tail is cut on every side: it is unreachable to the judge
# and re-prints objects with a shorter field set, manufacturing phantom keys.
#
# It then reports, for BOTH ours-columns against the SAME golden:
#     SAME / MISSING-OURS / EXTRA-OURS / OTHER
# and — the part that convicts — the per-key TRANSITION between the two
# ours-columns, scored against golden:
#     TOWARD-GOLDEN   the patched column agrees where the pristine did not
#     AWAY-GOLDEN     the pristine agreed and the patched does not   <-- FATAL
#     NEITHER         both disagree, differently
# A missing input is FATAL: a scorer that reads nothing must never print
# perfection.
import sys, re, collections, os

def scan(path, holder=None):
    if not os.path.isfile(path):
        sys.exit("FATAL: no dump at %s" % path)
    lines = open(path, errors='replace').read().split('\n')
    for ti, tl in enumerate(lines):
        if tl.startswith('\\_weaklyReferenced:'):
            lines = lines[:ti]
            break
    cells = collections.defaultdict(list)
    n = len(lines)
    for i, l in enumerate(lines):
        m = re.match(r'^(\s*)\\_(ref_obj|ref_var): \(([^)]*)\), line:(\d+):(\d+)', l)
        if not m:
            continue
        ind, fn, ln, col = m.group(1), m.group(3), int(m.group(4)), int(m.group(5))
        if holder and holder not in fn:
            continue
        name = fn.rsplit('.', 1)[-1]
        # Walk this object's OWN field lines — the ones at exactly indent+2.
        #
        # THE ACTUAL IS THE OBJECT THAT FOLLOWS THE `|vpiActual:` MARKER, AND
        # NOTHING ELSE.  A ref_obj prints its `|vpiParent:` the same way it
        # prints its actual — as a nested `\_kind: (name)` line — so a scanner
        # that records "every nested kind" reads the PARENT as the actual.  That
        # is not hypothetical: it made this scorer report golden as binding
        # `io_decl(v)` at buvm13's `IE13_B` 14:43, where golden in fact leaves
        # the ref BARE and the `io_decl` is merely its parent, and so
        # manufactured a MISSING-OURS that does not exist.  Cross-checking
        # against the implementer's cen221.py is what caught it.  Only a
        # `\_kind:` line IMMEDIATELY AFTER `|vpiActual:` at the object's own
        # field level counts.
        payload = 'BARE'
        fieldind = len(ind) + 2
        want_actual = False
        j = i + 1
        while j < n:
            s = lines[j]
            if s.strip() == '':
                j += 1
                continue
            si = len(s) - len(s.lstrip())
            if si <= len(ind):
                break
            if si == fieldind:
                if re.match(r'^\s*\|vpiActual:\s*$', s):
                    want_actual = True
                elif want_actual:
                    mo = re.match(r'^\s*\\_(\w+):\s*\(([^)]*)\)', s)
                    if mo:
                        payload = 'ACT:%s(%s)' % (mo.group(1), mo.group(2))
                    else:
                        mo2 = re.match(r'^\s*\\_(\w+):', s)
                        if mo2:
                            payload = 'ACT:%s' % mo2.group(1)
                    want_actual = False
                else:
                    mm = re.match(r'^\s*\|vpiActual:\s*(\S+)', s)
                    if mm:
                        payload = 'ACT:' + mm.group(1)
            j += 1
        cells[(name, ln, col)].append(payload)
    return {k: sorted(v) for k, v in cells.items()}

def has_enum(vals):
    return any(v.startswith('ACT:enum_const') for v in vals)

def cls(g, o):
    if g == o:
        return 'SAME'
    gk = [x for x in g if x != 'BARE']
    ok = [x for x in o if x != 'BARE']
    if gk and not ok:
        return 'MISSING-OURS'
    if ok and not gk:
        return 'EXTRA-OURS'
    return 'OTHER'

def main():
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    holder = None
    for a in sys.argv[1:]:
        if a.startswith('--holder='):
            holder = a.split('=', 1)[1]
    if len(args) != 3:
        sys.exit("usage: vcen221.py <golden.dump> <pris.dump> <pat.dump> [--holder=S]")
    G = scan(args[0], holder)
    A = scan(args[1], holder)
    B = scan(args[2], holder)
    keys = sorted(set(G) | set(A) | set(B))
    out = {}
    for side, D in (('pris', A), ('pat', B)):
        c = collections.Counter()
        for k in keys:
            c[cls(G.get(k, []), D.get(k, []))] += 1
        out[side] = c
    print("KEYS %d  holder=%s" % (len(keys), holder or '*'))
    for side in ('pris', 'pat'):
        c = out[side]
        print("  %-4s SAME %3d  MISSING-OURS %3d  EXTRA-OURS %3d  OTHER %3d" %
              (side, c['SAME'], c['MISSING-OURS'], c['EXTRA-OURS'], c['OTHER']))
    toward = away = neither = 0
    for k in keys:
        g, a, b = G.get(k, []), A.get(k, []), B.get(k, [])
        if a == b:
            continue
        ca, cb = cls(g, a), cls(g, b)
        if cb == 'SAME' and ca != 'SAME':
            toward += 1
            print("  TOWARD-GOLDEN %s golden=%s pris=%s pat=%s" % (k, g, a, b))
        elif ca == 'SAME' and cb != 'SAME':
            away += 1
            print("  AWAY-GOLDEN   %s golden=%s pris=%s pat=%s   <== FATAL" % (k, g, a, b))
        else:
            neither += 1
            print("  NEITHER       %s golden=%s pris=%s pat=%s" % (k, g, a, b))
    print("TRANSITIONS toward=%d away=%d neither=%d" % (toward, away, neither))
    # the law's own population: enum-const cells only
    ge = sum(1 for k in keys if has_enum(G.get(k, [])))
    ae = sum(1 for k in keys if has_enum(A.get(k, [])))
    be = sum(1 for k in keys if has_enum(B.get(k, [])))
    print("ENUM-ACTUAL CELLS golden=%d pris=%d pat=%d" % (ge, ae, be))
    print("VERDICT %s" % ("AWAY-GOLDEN PRESENT" if away else "no away"))

main()
