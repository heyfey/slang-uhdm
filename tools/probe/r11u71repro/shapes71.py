#!/usr/bin/env python3
"""r11v69 SHAPE LISTER — every cont_assign in a uhdm-dump, keyed by span, with
its Rhs shape.  Sections are kept apart (uhdmallModules = DEF view control,
uhdmtopModules = ELAB view).  Ids and file paths are never read."""
import re, sys, json, os

NODE = re.compile(r'^(\s*)\\_(\w+):\s*(.*)$')
FLD  = re.compile(r'^(\s*)\|([A-Za-z_]\w*):\s*(.*)$')
SPAN = re.compile(r'line:(\d+):(\d+), endln:(\d+):(\d+)')

def parse(path):
    lines = open(path, errors='replace').read().split('\n')
    return lines

def span_of(rest):
    m = SPAN.search(rest)
    return f"{m.group(1)}:{m.group(2)}-{m.group(3)}:{m.group(4)}" if m else "?"

def name_of(rest):
    m = re.match(r'^\(([^)]*)\)', rest.strip())
    return m.group(1) if m else ''

def section_of(lines, i):
    for j in range(i, -1, -1):
        m = FLD.match(lines[j])
        if m and m.group(2) in ('uhdmallModules', 'uhdmtopModules',
                                'uhdmallPackages', 'uhdmallInterfaces'):
            return m.group(2)
    return '?'

def indent(line):
    m = NODE.match(line) or FLD.match(line)
    return len(m.group(1)) if m else -1

def children(lines, i):
    """(fieldname, nodeline_index) pairs directly under the node at line i."""
    base = indent(lines[i]); out = []; cur = None
    j = i + 1
    while j < len(lines):
        ind = indent(lines[j])
        if ind < 0:
            j += 1; continue
        if ind <= base:
            break
        if ind == base + 2:
            f = FLD.match(lines[j])
            n = NODE.match(lines[j])
            if f:
                cur = f.group(2)
                if f.group(3).strip():
                    out.append((cur, None, f.group(3).strip()))
            elif n and cur:
                out.append((cur, j, None))
        j += 1
    return out

def rhs_shape(lines, j, resolve='pending'):
    n = NODE.match(lines[j])
    kind = n.group(2); rest = n.group(3)
    d = {'kind': kind, 'span': span_of(rest), 'name': name_of(rest)}
    for f, cj, val in children(lines, j):
        if cj is None and val is not None:
            if f in ('vpiSize', 'vpiConstType', 'vpiDecompile', 'vpiName'):
                d[f] = val
        if cj is None and val is None:
            pass
    # the raw value line (|UINT:.., |INT:.., |BIN:.., |DEC:.., |HEX:.., |OCT:..)
    base = indent(lines[j])
    k = j + 1
    while k < len(lines):
        ind = indent(lines[k])
        if ind < 0:
            k += 1; continue
        if ind <= base:
            break
        if ind == base + 2:
            m = FLD.match(lines[k])
            if m and re.match(r'^(UINT|INT|BIN|DEC|HEX|OCT|REAL|STRING|SCALAR)$',
                              m.group(2)):
                d['value'] = m.group(2) + ':' + m.group(3)
        k += 1
    if resolve is not None and resolve != 'pending':
        empty = not any(x in d for x in ('value', 'vpiSize', 'vpiConstType'))
        if empty:
            cand = resolve.get((kind, d['span'])) or []
            # r11u71: a stub is a REVISIT, so its object's full print is EARLIER
            # in the dump -- take the nearest preceding one, and only fall back
            # to the first when none precedes.  A span-keyed map with one entry
            # per span read AMBIG wherever golden holds BOTH a shared source
            # object and an `adjustSize` uniquify clone at the same span
            # (`n3_ifacegrid`), which is precisely this law's grid.
            sigs = {c[1] for c in cand}
            if len(sigs) > 1:
                # The span alone cannot name WHICH object this stub revisits:
                # golden holds both a SHARED source object and an `adjustSize`
                # uniquify clone at this very span (`n3_ifacegrid`).  Marked,
                # never guessed -- a guess manufactures AWAY-GOLDEN phantoms.
                d['value'] = 'SHARED-AMBIG'
                d['shared'] = 'AMBIG'
                return d
            sig = cand[0][1] if cand else None
            if sig:
                d['value'], d['vpiSize'], d['vpiConstType'], d['vpiDecompile'] = sig
                d['shared'] = 'resolved'
    return d

def field_label(lines, i):
    """the field name this node line sits under (same indent, nearest above)."""
    ind = indent(lines[i])
    for j in range(i - 1, -1, -1):
        jind = indent(lines[j])
        if jind < 0:
            continue
        if jind == ind:
            f = FLD.match(lines[j])
            if f:
                return f.group(2)
            return None
        if jind < ind:
            return None
    return None


def resolve_map(lines, want_sec=None):
    """(kind, span) -> the FULL field set, from every node printed with fields.
    uhdm-dump prints a REVISITED shared object as a bare header, so a cell whose
    Rhs is shared reads empty unless it is resolved here.  AMBIG marks a span
    that two DIFFERENT full prints disagree on."""
    m = {}
    for i, ln in enumerate(lines):
        n = NODE.match(ln)
        if not n:
            continue
        # r11u71: RESOLVE WITHIN THE SECTION.  The same (kind, span) is printed
        # with DIFFERENT fields in the package/def listing and in the elaborated
        # one (w9's `300` is 64 bits in `uhdmallPackages` and 32 in
        # `uhdmtopModules`), so a section-blind map reads AMBIG and the census
        # goes blind on exactly the cells this law moves.
        if want_sec is not None and section_of(lines, i) != want_sec:
            continue
        sh = rhs_shape(lines, i, resolve=None)
        if not any(k in sh for k in ('value', 'vpiSize', 'vpiConstType')):
            continue
        key = (n.group(2), sh['span'])
        sig = (sh.get('value'), sh.get('vpiSize'), sh.get('vpiConstType'),
               sh.get('vpiDecompile'))
        m.setdefault(key, []).append((i, sig))
    return m


def cells(path):
    lines = parse(path)
    rmaps = {}
    out = {}
    for i, ln in enumerate(lines):
        n = NODE.match(ln)
        if not n or n.group(2) != 'cont_assign':
            continue
        # a `vpiParent: \_cont_assign` back-reference is not a cell
        if field_label(lines, i) == 'vpiParent':
            continue
        sec = section_of(lines, i)
        if sec not in rmaps:
            rmaps[sec] = resolve_map(lines, sec)
        rmap = rmaps[sec]
        ca_span = span_of(n.group(3))
        lhs = None; rhs = None
        for f, cj, val in children(lines, i):
            if f == 'vpiLhs' and cj is not None:
                lhs = rhs_shape(lines, cj, resolve=rmap)
            elif f == 'vpiRhs' and cj is not None:
                rhs = rhs_shape(lines, cj, resolve=rmap)
        key = (sec, ca_span, lhs['span'] if lhs else '?')
        out.setdefault(key, []).append({'lhs': lhs, 'rhs': rhs})
    return out

def flat(path):
    c = cells(path)
    rows = []
    for k in sorted(c):
        for idx, v in enumerate(sorted(c[k], key=lambda x: json.dumps(x, sort_keys=True))):
            rows.append((k + (idx,), v))
    return rows

if __name__ == '__main__':
    if sys.argv[1] == 'list':
        for k, v in flat(sys.argv[2]):
            r = v['rhs'] or {}
            print('|'.join(map(str, k)), '::', r.get('kind'), r.get('span'),
                  r.get('value'), 'sz=' + str(r.get('vpiSize')),
                  'ct=' + str(r.get('vpiConstType')),
                  'dec=' + str(r.get('vpiDecompile')),
                  'nm=' + str(r.get('name')))
    elif sys.argv[1] == 'cmp':
        g = dict(flat(sys.argv[2])); o = dict(flat(sys.argv[3]))
        keys = sorted(set(g) | set(o), key=lambda t: tuple(map(str, t)))
        nd = 0
        for k in keys:
            gv = g.get(k); ov = o.get(k)
            def sig(v):
                if not v or not v['rhs']:
                    return 'NONE'
                r = v['rhs']
                sp = '' if os.environ.get('NOSPAN') else f" span={r.get('span')}"
                return f"{r.get('kind')} {r.get('value')} sz={r.get('vpiSize')} ct={r.get('vpiConstType')} dec={r.get('vpiDecompile')} nm={r.get('name')}{sp}"
            if sig(gv) != sig(ov):
                nd += 1
                print('DIFF', '|'.join(map(str, k)))
                print('   G:', sig(gv))
                print('   O:', sig(ov))
        print(f'CELLS golden={len(g)} ours={len(o)} DIFFERING={nd}')
