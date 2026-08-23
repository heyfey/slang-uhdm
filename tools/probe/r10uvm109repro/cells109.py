#!/usr/bin/env python3
"""r10uvm109 - per-cell golden / pristine / patched verdict printer.

MEASUREMENT ONLY; the official uhdm-cmp is the judge.
LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.

    cells109.py <golden.cen> <pristine.cen> <patched.cen> <label>

Prints every cell on which golden, pristine or patched disagree, in two
sections:

    NET  keyed (view, owner module, net name) over IMPLICIT wires only
         (logic_net, vpiNetType 1, parented at a module_inst) - a net's span is
         never read by any generated Compare, so the NAME is its whole
         judge-visible identity.
    REF  keyed (view, oob, owner, name) over reference Actual_group kinds,
         span-free because a macro-expanded UVM reference does not carry the
         same line on both sides.

Values are MULTISETS (a key legitimately repeats: DEF and ELAB copies of one
body, several importing modules).  Verdicts: TO-GOLDEN / AWAY / STILL / OTHER.
"""
import sys, collections

def load(p, kind):
    d = collections.defaultdict(collections.Counter)
    for ln in open(p):
        f = ln.rstrip('\n').split('\t')
        if kind == 'NET':
            if len(f) > 8 and f[1] == 'NET' and f[3] == 'IMPL':
                d[(f[2], f[4], f[6])][f[7]] += 1
        else:
            if len(f) > 12 and f[1] == 'REF':
                d[(f[2], f[3], f[4], f[6])][f[7] + ('/' + f[12] if f[12] != '-' else '')] += 1
    return d

label = sys.argv[4] if len(sys.argv) > 4 else '-'
for kind in ('NET', 'REF'):
    G, A, B = (load(sys.argv[i], kind) for i in (1, 2, 3))
    keys = sorted(set(G) | set(A) | set(B))
    tg = aw = still = same = 0
    rows = []
    for k in keys:
        g, a, b = G[k], A[k], B[k]
        if g == a == b:
            same += 1
            continue
        if a != g and b == g:
            v = 'TO-GOLDEN'; tg += 1
        elif a == g and b != g:
            v = 'AWAY'; aw += 1
        elif a == b:
            v = 'STILL'; still += 1
        else:
            v = 'OTHER'
        rows.append('  %-9s %-40s golden=%s pristine=%s patched=%s'
                    % (v, '|'.join(k), dict(g) or '-', dict(a) or '-', dict(b) or '-'))
    print('%s %s: cells=%d agree-everywhere=%d TO-GOLDEN=%d AWAY=%d STILL=%d'
          % (label, kind, len(keys), same, tg, aw, still))
    for r in rows:
        print(r)
