#!/usr/bin/env python3
"""r10v179repro/vscore179.py — the VERIFIER's independent scorer.

MEASUREMENT ONLY.  It reads `uhdm-dump` text (never the judge's verdict) and
builds, for every reference object in a database, the MULTISET of actuals it
carries, keyed on the reference's spelled fullname and span and on the HOME
listing it sits in.  Golden / pristine / patched are then joined key by key and
each moved key is labelled TOGOLD / AWAY / MOVED-WRONG.

Deliberately NOT r10uvm179's C++ census: a second, differently-built instrument
over the same databases.

usage: vscore179.py <dump.g> <dump.a(pristine)> <dump.b(patched)> [--label L]
"""
import re
import sys
import collections

OBJ = re.compile(r'^(\s*)\\_([a-z_0-9]+): \(([^)]*)\)(?:, line:(\d+):(\d+), endln:(\d+):(\d+))?')
OBJ_NONAME = re.compile(r'^(\s*)\\_([a-z_0-9]+): (?:, )?line:(\d+):(\d+), endln:(\d+):(\d+)')
REL = re.compile(r'^(\s*)\|([A-Za-z_]+):\s*$')

LIST_KINDS = {'package', 'module_inst', 'class_defn', 'interface_inst',
              'program'}
SUB_KINDS = {'task', 'function'}


def homeof(stack):
    listing = [e for e in stack if e[1] in LIST_KINDS]
    sub = [e for e in stack if e[1] in SUB_KINDS]
    L = '/'.join('%s:%s' % (e[1], _b(e[2])) for e in listing) or 'TOP'
    S = _b(sub[-1][2]) if sub else '-'
    return L + '|' + S
REF_KINDS = {'ref_obj', 'ref_var'}


def _b(n):
    n = n.split('::')[-1]
    n = n.split('.')[-1]
    n = n.split('@')[-1]
    return n


def base(n):
    n = n.split('::')[-1]
    n = n.split('.')[-1]
    n = n.split('@')[-1]
    return n


def parse(path):
    """-> dict key -> Counter(actual descriptor)."""
    out = collections.defaultdict(collections.Counter)
    stack = []          # (indent, kind, name, span)
    pending_rel = None  # (indent, relname)
    with open(path, errors='replace') as fh:
        for raw in fh:
            line = raw.rstrip('\n')
            m = REL.match(line)
            if m:
                pending_rel = (len(m.group(1)), m.group(2))
                continue
            m = OBJ.match(line)
            if not m:
                m2 = OBJ_NONAME.match(line)
                if not m2:
                    continue
                indent, kind, name = len(m2.group(1)), m2.group(2), ''
                span = '%s:%s-%s:%s' % m2.group(3, 4, 5, 6)
            else:
                indent, kind, name = len(m.group(1)), m.group(2), m.group(3)
                span = ('%s:%s-%s:%s' % m.group(4, 5, 6, 7)
                        if m.group(4) else '')
            while stack and stack[-1][0] >= indent:
                stack.pop()
            # a reference's ACTUAL is the object printed under |vpiActual:
            if (pending_rel and pending_rel[1] == 'vpiActual'
                    and pending_rel[0] == indent and stack
                    and stack[-1][1] in REF_KINDS):
                pk = stack[-1]
                key = (pk[1], base(pk[2]), pk[3], homeof(stack[:-1]))
                out[key]['BOUND=%s:%s' % (kind, base(name))] += 1
            if pending_rel and pending_rel[0] == indent:
                pending_rel = None
            if kind in REF_KINDS:
                key = (kind, base(name), span, homeof(stack))
                if key not in out:
                    out[key] = collections.Counter()
            stack.append((indent, kind, name, span))
    # every key with no BOUND entry is BARE
    for k, v in out.items():
        if not v:
            v['BARE'] += 1
    return out


def show(c):
    return ' '.join('%dx%s' % (n, k) for k, n in sorted(c.items()))


def main():
    g, a, b = sys.argv[1], sys.argv[2], sys.argv[3]
    label = sys.argv[4] if len(sys.argv) > 4 else ''
    G, A, B = parse(g), parse(a), parse(b)
    keys = sorted(set(G) | set(A) | set(B))
    tog = away = mw = moved = same = 0
    lines = []
    for k in keys:
        gg, aa, bb = G.get(k), A.get(k), B.get(k)
        if aa == bb:
            same += 1
            continue
        moved += 1
        if gg is None:
            verdict = 'MOVED-NOGOLD'
            mw += 1
        elif bb == gg and aa != gg:
            verdict = 'TOGOLD'
            tog += 1
        elif aa == gg and bb != gg:
            verdict = 'AWAY'
            away += 1
        else:
            verdict = 'MOVED-WRONG'
            mw += 1
        lines.append('%-12s %-9s %-58s %-22s %-34s | G=%-26s P=%-26s X=%s'
                     % (verdict, k[0], k[1][-58:], k[2], k[3][-34:],
                        show(gg) if gg is not None else '<absent>',
                        show(aa) if aa is not None else '<absent>',
                        show(bb) if bb is not None else '<absent>'))
    dg_a = sum(1 for k in keys if G.get(k) != A.get(k))
    dg_b = sum(1 for k in keys if G.get(k) != B.get(k))
    print('== %s  keys G=%d P=%d X=%d | vs-golden disagreeing  pristine=%d  patched=%d'
          % (label, len(G), len(A), len(B), dg_a, dg_b))
    print('== %s  MOVED=%d TOGOLD=%d AWAY=%d MOVEDWRONG=%d UNMOVED=%d'
          % (label, moved, tog, away, mw, same))
    for l in lines:
        print(l)


if __name__ == '__main__':
    main()
