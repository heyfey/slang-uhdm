#!/usr/bin/env python3
"""r11u32 — the ELAB-view object-KIND census the K2 triage demanded.

For each design, section the uhdm-dump by the top-level keys:
   DEF  = |uhdmallModules:  .. |uhdmtopModules:
   ELAB = |uhdmtopModules:  .. \\_weaklyReferenced:   (the judge's reach)
   TAIL = \\_weaklyReferenced: ..                      (NEVER counted)
and build the multiset of (section, object-kind, vpiFullName) for every
object line of the form `\\_<kind>: (<fullname>)` or `<kind>: (<fullname>)`.

Prints, per design:
   * SHAPE LISTER: per-kind row counts per section, both sides;
   * the multiset JOIN on (section, fullname): kind-G vs kind-O, only the
     rows where they DISAGREE or one side is missing.
Calibrate golden-vs-golden FIRST: pass the same file twice -> 0 disagreements.
"""
import re, sys, collections

OBJ = re.compile(r'^(\s*)(?:\\_)?([a-z_0-9]+): \(([^)]*)\)')

def sections(path):
    lines = open(path, errors='replace').read().split('\n')
    def_s = elab_s = tail_s = None
    for i, l in enumerate(lines):
        if l.strip() == '|uhdmallModules:' and def_s is None:
            def_s = i
        elif l.strip() == '|uhdmtopModules:' and elab_s is None:
            elab_s = i
        elif l.strip().startswith('\\_weaklyReferenced:') and tail_s is None:
            tail_s = i
    n = len(lines)
    if def_s is None: def_s = 0
    if elab_s is None: elab_s = n
    if tail_s is None: tail_s = n
    return {'DEF': lines[def_s:elab_s], 'ELAB': lines[elab_s:tail_s]}

def census(path):
    out = collections.Counter()
    kinds = collections.Counter()
    for sec, ls in sections(path).items():
        for l in ls:
            m = OBJ.match(l)
            if not m:
                continue
            kind, fn = m.group(2), m.group(3)
            if not fn:
                continue
            out[(sec, fn, kind)] += 1
            kinds[(sec, kind)] += 1
    return out, kinds

def main():
    g, o = sys.argv[1], sys.argv[2]
    tag = sys.argv[3] if len(sys.argv) > 3 else ''
    cg, kg = census(g)
    co, ko = census(o)
    print(f'== {tag}')
    print('-- SHAPE LISTER (section kind: golden / ours), kinds present on either side')
    for key in sorted(set(kg) | set(ko)):
        a, b = kg.get(key, 0), ko.get(key, 0)
        flag = '' if a == b else '   <-- differs'
        print(f'   {key[0]:5s} {key[1]:28s} {a:5d} / {b:5d}{flag}')
    # join on (section, fullname): the multiset of kinds on each side
    byname_g = collections.defaultdict(collections.Counter)
    byname_o = collections.defaultdict(collections.Counter)
    for (sec, fn, kind), c in cg.items():
        byname_g[(sec, fn)][kind] += c
    for (sec, fn, kind), c in co.items():
        byname_o[(sec, fn)][kind] += c
    dis = 0
    print('-- KIND DISAGREEMENTS on (section, vpiFullName)')
    for key in sorted(set(byname_g) | set(byname_o)):
        a = byname_g.get(key, collections.Counter())
        b = byname_o.get(key, collections.Counter())
        if a == b:
            continue
        dis += 1
        print(f'   {key[0]:5s} {key[1]}')
        print(f'        G: {dict(sorted(a.items()))}')
        print(f'        O: {dict(sorted(b.items()))}')
    print(f'-- DISAGREEMENTS: {dis}')

main()
