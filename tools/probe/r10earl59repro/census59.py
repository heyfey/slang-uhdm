#!/usr/bin/env python3
"""r10earl59 census — every cont_assign Lhs/Rhs ref_obj in a uhdm-dump, keyed on
(enclosing-scope KIND, enclosing-scope NAME NORMALISED, cont_assign source
extent, slot, ref name, occurrence), payload = the vpiActual target's KIND +
NORMALISED name (or None).

The key is PATH-NORMALISED (array indices -> [], the workdir stripped) so a
golden/ours pair lines up, and it carries the OCCURRENCE index so two
elaborated copies of the same generate body are never merged.

usage: census59.py <golden.dump> <ours.dump> [--rows]
       census59.py <dump>  --list
"""
import sys, re, collections

RE_OBJ = re.compile(r'\\_(\w+): (?:(\S+) )?\(([^)]*)\)(?:, (.*))?$')
RE_OBJ_NN = re.compile(r'\\_(\w+): ?,? ?(.*)$')
RE_EXT = re.compile(r'line:(\d+):(\d+), endln:(\d+):(\d+)')
RE_IDX = re.compile(r'\[\d+\]')

def norm(n):
    return RE_IDX.sub('[]', n) if n else n

def scan(path):
    """stream the dump; return {key: payload}"""
    out = {}
    occ = collections.Counter()
    # stack of (indent, kind, name, ext)
    st = []
    lines = open(path, 'rb').read().decode('utf-8', 'replace').split('\n')
    n = len(lines)
    for i in range(n):
        l = lines[i]
        if not l:
            continue
        s = l.lstrip()
        if s[:2] != '\\_':
            continue
        ind = len(l) - len(s)
        while st and st[-1][0] >= ind:
            st.pop()
        m = RE_OBJ.match(s)
        if m:
            kind, defn, name = m.group(1), m.group(2), m.group(3)
        else:
            m2 = RE_OBJ_NN.match(s)
            kind, name = (m2.group(1) if m2 else '?'), ''
        e = RE_EXT.search(s)
        ext = e.group(0) if e else '-'
        st.append((ind, kind, name, ext))
        if kind != 'cont_assign':
            continue
        # enclosing scope = nearest ancestor whose kind is a scope
        scope = ('?', '?')
        for (ai, ak, an, ae) in reversed(st[:-1]):
            if ak in ('gen_scope', 'module_inst', 'interface_inst', 'gen_scope_array'):
                scope = (ak, norm(an))
                break
        # walk this cont_assign's direct children for vpiLhs / vpiRhs ref_obj
        rhskind = None
        for slot in ('|vpiRhs:', '|vpiLhs:'):
            j = i + 1
            found = None
            while j < n:
                t = lines[j]
                if not t:
                    break
                ts = t.lstrip()
                tind = len(t) - len(ts)
                if tind <= ind and ts[:2] == '\\_':
                    break
                if tind < ind:
                    break
                if tind == ind + 2 and ts == slot:
                    found = j
                    break
                j += 1
            if found is None:
                continue
            ol = lines[found + 1]
            om = RE_OBJ.match(ol.lstrip())
            if not om:
                om2 = RE_OBJ_NN.match(ol.lstrip())
                if slot == '|vpiRhs:' and om2:
                    rhskind = om2.group(1)
                continue
            if slot == '|vpiRhs:':
                rhskind = om.group(1)
            if om.group(1) != 'ref_obj':
                continue
            rname = norm(om.group(3)).split('.')[-1]
            oind = len(ol) - len(ol.lstrip())
            act = None
            q = found + 2
            while q < n:
                u = lines[q]
                if not u:
                    break
                us = u.lstrip()
                uind = len(u) - len(us)
                if uind <= oind and us[:2] == '\\_':
                    break
                if uind < oind:
                    break
                if uind == oind + 2 and us == '|vpiActual:':
                    am = RE_OBJ.match(lines[q + 1].lstrip())
                    if am:
                        act = (am.group(1), norm(am.group(3)).split('.')[-1])
                    else:
                        am2 = RE_OBJ_NN.match(lines[q + 1].lstrip())
                        act = ((am2.group(1) if am2 else '?'), '')
                    break
                q += 1
            if slot == '|vpiRhs:':
                rhskind = 'ref_obj'
            k0 = (scope[0], scope[1], ext, slot, rname)
            occ[k0] += 1
            out[k0 + (occ[k0],)] = (act, rhskind) if slot == '|vpiLhs:' else act
    return out

if __name__ == '__main__':
    if '--list' in sys.argv:
        a = scan(sys.argv[1])
        for k in sorted(a):
            print(k, a[k])
        sys.exit(0)
    a = scan(sys.argv[1]); b = scan(sys.argv[2])
    rows = '--rows' in sys.argv
    keys = set(a) | set(b)
    tally = collections.Counter()
    fam = collections.Counter()
    for k in sorted(keys):
        av = a.get(k, 'NO-ROW'); bv = b.get(k, 'NO-ROW')
        if av == bv:
            tally['SAME'] += 1
            continue
        if av == 'NO-ROW' or bv == 'NO-ROW':
            tag = 'KEY-ONLY-GOLD' if bv == 'NO-ROW' else 'KEY-ONLY-OURS'
        elif bv is None:
            tag = 'GOLD-BINDS-WE-DONT'
        elif av is None:
            tag = 'WE-BIND-GOLD-DOESNT'
        else:
            tag = 'BOTH-BIND-DIFFERENT'
        tally[tag] += 1
        fam[(tag, k[0], k[3], av[0] if isinstance(av, tuple) else str(av),
             bv[0] if isinstance(bv, tuple) else str(bv))] += 1
        if rows:
            print('%-20s %-14s %-58s %-26s %-46s G=%-40s O=%s' %
                  (tag, k[0], k[1][:58], k[2], k[4][:46], av, bv))
    print('== TALLY', dict(tally))
    print('== FAMILIES')
    for f, c in fam.most_common(40):
        print('  %6d %s' % (c, f))
