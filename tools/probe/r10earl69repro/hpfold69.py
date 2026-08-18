#!/usr/bin/env python3
# r10earl69 — a PYTHON MIRROR of the emitter helper `hpNameBareIdxFold69`, run
# over `hpname69` census output.  MEASUREMENT ONLY: it answers "what would the
# rewrite do to this database's hier_path names?" without building anything.
#
# The rewrite walks the NAME in lockstep with the Path_elems and replaces a
# bracket group's inner text with a folded constant's VpiDecompile when, and
# only when, (a) the element carries a `constant` in that slot and (b) the text
# currently there is a single unqualified identifier.  Any parse mismatch
# aborts the whole rewrite for that object (fail-closed).
import re, sys, collections

BARE = re.compile(r'^[A-Za-z_][A-Za-z0-9_$]*$')

def parse_elems(rest):
    """rest = the 'e0=kind:name{...}|e1=...' field; returns [(kind,name,slots)]"""
    out = []
    if rest in ('-', ''):
        return out
    # split on '|' at brace depth 0
    parts, d, cur = [], 0, ''
    for c in rest:
        if c == '{': d += 1
        elif c == '}': d -= 1
        if c == '|' and d == 0:
            parts.append(cur); cur = ''
        else:
            cur += c
    parts.append(cur)
    for p in parts:
        m = re.match(r'e\d+=([a-z_]+):([^{]*)(\{.*\})?$', p)
        if not m:
            return None
        kind, nm, sl = m.group(1), m.group(2), m.group(3) or ''
        slots = {}
        for sm in re.finditer(r'\{([^}]*)\}', sl):
            for piece in sm.group(1).split(';'):
                mm = re.match(r'(idx|l|r|b|w|v\d+)=(.*)$', piece)
                if mm:
                    slots[mm.group(1)] = mm.group(2)
        out.append((kind, '' if nm == '-' else nm, slots))
    return out

def slot_const_dec(s):
    if s is None or not s.startswith('constant:'):
        return None
    m = re.search(r',dec=([^,]*)', s)
    if not m:
        return None
    d = m.group(1)
    return None if d in ('-', '') else d

def grp_end(n, i):
    d = 0
    for k in range(i, len(n)):
        if n[k] == '[': d += 1
        elif n[k] == ']':
            d -= 1
            if d == 0:
                return k + 1
    return -1

def split_range(txt, ips):
    """split a range group's inner text at the top-level separator"""
    d = 0
    i = 0
    while i < len(txt):
        c = txt[i]
        if c == '[': d += 1
        elif c == ']': d -= 1
        elif d == 0:
            if ips and c in '+-' and i + 1 < len(txt) and txt[i+1] == ':':
                return txt[:i], txt[i:i+2], txt[i+2:]
            if not ips and c == ':':
                return txt[:i], ':', txt[i+1:]
        i += 1
    return None

def rewrite(name, elems):
    if elems is None:
        return name
    out = []
    i = 0
    n = name
    for k, (kind, nm, slots) in enumerate(elems):
        if nm:
            if k > 0:
                if i >= len(n) or n[i] != '.':
                    return name
                out.append('.'); i += 1
            if not n.startswith(nm, i):
                return name
            out.append(nm); i += len(nm)
        ngrp = {'ref_obj': 0, 'bit_select': 1, 'part_select': 1,
                'indexed_part_select': 1}.get(kind, None)
        if ngrp is None:
            if kind == 'var_select':
                ngrp = len([x for x in slots if x and x.startswith('v')])
            else:
                return name
        for g in range(ngrp):
            if i >= len(n) or n[i] != '[':
                return name
            e = grp_end(n, i)
            if e < 0:
                return name
            inner = n[i+1:e-1]
            new = inner
            if kind == 'bit_select':
                d = slot_const_dec(slots.get('idx'))
                if d and BARE.match(inner):
                    new = d
            elif kind == 'var_select':
                d = slot_const_dec(slots.get('v%d' % g))
                if d and BARE.match(inner):
                    new = d
            elif kind in ('part_select', 'indexed_part_select'):
                ips = kind == 'indexed_part_select'
                sp = split_range(inner, ips)
                if sp:
                    L, sep, R = sp
                    dl = slot_const_dec(slots.get('b' if ips else 'l'))
                    dr = slot_const_dec(slots.get('w' if ips else 'r'))
                    if dl and BARE.match(L): L = dl
                    if dr and BARE.match(R): R = dr
                    new = L + sep + R
            out.append('[' + new + ']')
            i = e
    if i != len(n):
        return name
    return ''.join(out)

def main():
    tot = chg = 0
    ex = collections.Counter()
    for l in sys.stdin:
        f = l.rstrip('\n').split(' ')
        if not f or f[0] != 'HP':
            continue
        kv = {}
        for x in f[5:]:
            if '=' in x:
                k, v = x.split('=', 1)
                kv.setdefault(k, v)
        name = kv.get('name', '')
        rest = f[-1]
        elems = parse_elems(rest)
        tot += 1
        nn = rewrite(name, elems)
        if nn != name:
            chg += 1
            ex[(name, nn)] += 1
    print('TOTAL %d CHANGED %d' % (tot, chg))
    for (a, b), c in ex.most_common(40):
        print('  x%-5d %s -> %s' % (c, a, b))

main()
