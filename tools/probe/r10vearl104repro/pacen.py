#!/usr/bin/env python3
"""r10v104 INDEPENDENT param_assign typespec census, read straight off uhdm-dump.
MEASUREMENT ONLY.  Key = (view, Lhs fullname, param_assign span).
Payload = the Rhs node kind + the Rhs's typespec chain rendered as a STRING
(kind, name, signedness, VpiValue, every range bound) -- uvm159's lesson.
"""
import sys, re

NODE = re.compile(r'^(\s*)\\_([A-Za-z_0-9]+):\s*(.*)$')
LABEL = re.compile(r'^(\s*)\|([A-Za-z_0-9]+):(.*)$')
VAL = re.compile(r'^(\s*)\|([A-Z]+:.*)$')

def load(path):
    out = []
    with open(path, errors='replace') as f:
        for ln in f:
            ln = ln.rstrip('\n')
            m = NODE.match(ln)
            if m:
                out.append(('N', len(m.group(1)), m.group(2), m.group(3)))
                continue
            m = LABEL.match(ln)
            if m:
                out.append(('L', len(m.group(1)), m.group(2), m.group(3)))
                continue
            out.append(('?', len(ln) - len(ln.lstrip()), '', ln.strip()))
    return out

def children(lines, i, indent):
    """yield (idx, tag, ind, key, rest) for direct children rows at indent+2,
    stopping when indentation drops to <= indent."""
    j = i + 1
    want = indent + 2
    while j < len(lines):
        tag, ind, key, rest = lines[j]
        if ind <= indent:
            break
        if ind == want:
            yield j, tag, ind, key, rest
        j += 1

def node_after(lines, j, indent):
    """the node row that immediately follows a label row at the same indent"""
    k = j + 1
    if k < len(lines) and lines[k][0] == 'N' and lines[k][1] == indent:
        return k
    return None

def props(lines, i, indent):
    d = {}
    for j, tag, ind, key, rest in children(lines, i, indent):
        if tag in ('L', '?'):
            raw = key + ':' + rest if tag == 'L' else rest
            d.setdefault(raw.split(':')[0], []).append(raw)
    return d

def ts_string(lines, k, indent, depth=0):
    """render a typespec node as a compare-visible string"""
    if k is None or depth > 6:
        return 'NONE'
    tag, ind, kind, rest = lines[k]
    span = ''
    m = re.search(r'line:(\d+):(\d+), endln:(\d+):(\d+)', rest)
    if m:
        span = 'SPAN' + ':'.join(m.groups())
    else:
        span = 'LOCLESS'
    nm = ''
    m = re.match(r'^\s*\(([^)]*)\)', rest)
    if m:
        nm = m.group(1)
    bits = [kind, span, 'name=' + nm]
    for j, t, ind2, key, r in children(lines, k, ind):
        if t == '?':
            bits.append('V<' + r + '>')
        elif t == 'L' and key in ('UINT','INT','BIN','HEX','OCT','REAL','STRING','SCALAR'):
            bits.append('V<' + key + ':' + r + '>')
        elif t == 'L' and key == 'vpiSigned':
            bits.append('signed' + r)
        elif t == 'L' and key == 'vpiRange':
            n = node_after(lines, j, ind2)
            if n is not None:
                sub = []
                for j2, t2, ind3, key2, r2 in children(lines, n, lines[n][1]):
                    if t2 == 'L' and key2 in ('vpiLeftRange', 'vpiRightRange'):
                        n2 = node_after(lines, j2, ind3)
                        v = 'NONE'
                        if n2 is not None:
                            vs = [r3 for j3, t3, i3, k3, r3 in
                                  children(lines, n2, lines[n2][1]) if t3 == '?']
                            v = lines[n2][2] + '(' + ','.join(vs) + ')'
                        sub.append(key2 + '=' + v)
                bits.append('RANGE[' + ' '.join(sub) + ']')
        elif t == 'L' and key == 'vpiActual':
            n = node_after(lines, j, ind2)
            bits.append('ACT{' + ts_string(lines, n, ind2, depth + 1) + '}')
        elif t == 'L' and key == 'vpiElemTypespec':
            n = node_after(lines, j, ind2)
            bits.append('ELEM{' + ts_string(lines, n, ind2, depth + 1) + '}')
    return ' '.join(bits)

def census(path):
    lines = load(path)
    # view sectioning: everything after |uhdmtopModules: is ELAB
    view_switch = len(lines)
    weak = len(lines)
    for i, (t, ind, key, rest) in enumerate(lines):
        if t == 'L' and key == 'uhdmtopModules' and i < view_switch:
            view_switch = i
        if t == 'L' and key == '_weaklyReferenced' and i < weak:
            weak = i
    cells = {}
    for i, (t, ind, kind, rest) in enumerate(lines):
        if t != 'N' or kind != 'param_assign':
            continue
        if i >= weak:
            continue
        view = 'DEF' if i < view_switch else 'ELAB'
        m = re.search(r'line:(\d+):(\d+), endln:(\d+):(\d+)', rest)
        span = ':'.join(m.groups()) if m else '?'
        lhs = '?'
        rhskind = 'NONE'
        rhsts = 'NONE'
        rhsenc = ''
        for j, tg, ind2, key, r in children(lines, i, ind):
            if tg != 'L':
                continue
            if key == 'vpiLhs':
                n = node_after(lines, j, ind2)
                if n is not None:
                    mm = re.match(r'^\s*\(([^)]*)\)', lines[n][3])
                    lhs = mm.group(1) if mm else lines[n][2]
            elif key == 'vpiRhs':
                n = node_after(lines, j, ind2)
                if n is None:
                    continue
                rhskind = lines[n][2]
                enc = []
                for j2, t2, ind3, k2, r2 in children(lines, n, lines[n][1]):
                    if t2 == '?':
                        enc.append(r2)
                    elif t2 == 'L' and k2 in ('UINT','INT','BIN','HEX','OCT','REAL','STRING','SCALAR'):
                        enc.append(k2 + ':' + r2)
                    elif t2 == 'L' and k2 in ('vpiSize', 'vpiConstType',
                                              'vpiDecompile', 'vpiOpType'):
                        enc.append(k2 + r2)
                    elif t2 == 'L' and k2 == 'vpiTypespec':
                        n2 = node_after(lines, j2, ind3)
                        rhsts = ts_string(lines, n2, ind3)
                rhsenc = '|'.join(sorted(enc))
        cells[(view, lhs, span)] = (rhskind, rhsts, rhsenc)
    return cells

if __name__ == '__main__':
    c = census(sys.argv[1])
    for k in sorted(c):
        if k[1] == '?':
            continue
        print('\t'.join(k) + '\t' + '\t'.join(c[k]))
