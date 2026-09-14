#!/usr/bin/env python3
"""r11u21 — KEYED directional census of ELABORATED param_assign Rhs cells.

Reads a uhdm-dump text and extracts, for every `param_assign` under
`|uhdmtopModules:` / `|uhdmtopPackages:` / `|uhdmallModules:` (sectioned), the
JUDGE-VISIBLE cells of its Rhs:  kind, VpiDecompile, VpiSize, VpiConstType,
the Rhs typespec ref's NAME and its Actual typespec's kind+span.  Keyed by
(section, instance name, Lhs parameter name) -- never by span, never by id.

    pacen21.py <dump>                 # list the cells
    pacen21.py <golden.dump> <ours.dump>   # directional census
"""
import re, sys

SECT = re.compile(r'^\|uhdm(\w+):')

def parse(path):
    lines = open(path, errors='replace').read().split('\n')
    sect = '?'
    inst = '?'
    rows = {}
    i = 0
    n = len(lines)
    def ind(s):
        return len(s) - len(s.lstrip(' '))
    while i < n:
        l = lines[i]
        m = SECT.match(l)
        if m:
            sect = m.group(1); i += 1; continue
        ms = re.match(r'^(\s*)\\_(module_inst|interface_inst|package|program_inst): \S+ \(([^)]*)\)', l)
        if ms and ind(l) <= 1:
            inst = ms.group(3).strip()
        else:
            ms2 = re.match(r'^(\s*)\\_(module_inst|interface_inst|package|program_inst): \(([^)]*)\)', l)
            if ms2 and ind(l) <= 1:
                inst = ms2.group(3).strip()
        if re.match(r'^\s*\\_param_assign: ', l):
            base = ind(l)
            # collect the block until dedent
            j = i + 1
            blk = []
            while j < n and (lines[j].strip() == '' or ind(lines[j]) > base):
                blk.append(lines[j]); j += 1
            rows.setdefault((sect, inst), [])
            cell = cells(blk, base)
            if cell:
                rows[(sect, inst)].append(cell)
            i = j; continue
        i += 1
    out = {}
    for (s, ins), cs in rows.items():
        for c in cs:
            out[(s, ins, c['lhs'])] = c
    return out

def cells(blk, base):
    def ind(s):
        return len(s) - len(s.lstrip(' '))
    lhs = None
    rhs = {'kind': '<none>', 'dec': '', 'size': '', 'ct': '', 'val': '',
           'tsref': '<none>', 'tsname': '', 'tsact': '', 'loc': '', 'par': 'no'}
    i = 0
    while i < len(blk):
        l = blk[i]
        if l.strip() == '|vpiLhs:' and ind(l) == base + 2:
            if i + 1 < len(blk):
                m = re.match(r'\s*\\_(\w+): \(([^)]*)\)', blk[i + 1])
                if m: lhs = m.group(2)
        if l.strip() == '|vpiRhs:' and ind(l) == base + 2:
            j = i + 1
            m = re.match(r'^(\s*)\\_(\w+):\s*(.*)$', blk[j])
            if m:
                rhs['kind'] = m.group(2)
                rest = m.group(3)
                lm = re.search(r'line:(\d+:\d+), endln:(\d+:\d+)', rest)
                rhs['loc'] = (lm.group(1) + '-' + lm.group(2)) if lm else 'NOLOC'
                rb = ind(blk[j])
                k = j + 1
                depth_ts = None
                while k < len(blk) and (blk[k].strip() == '' or ind(blk[k]) > rb):
                    t = blk[k].strip()
                    d = ind(blk[k])
                    if d == rb + 2:
                        if t.startswith('|vpiDecompile:'): rhs['dec'] = t[14:]
                        elif t.startswith('|vpiSize:'): rhs['size'] = t[9:]
                        elif t.startswith('|vpiConstType:'): rhs['ct'] = t[14:]
                        elif t == '|vpiParent:': rhs['par'] = 'yes'
                        elif re.match(r'^\|(BIN|INT|UINT|HEX|OCT|DEC|STRING|REAL):', t):
                            rhs['val'] = t[1:]
                        elif t == '|vpiTypespec:':
                            depth_ts = k
                    if depth_ts is not None and k == depth_ts + 1:
                        mm = re.match(r'\s*\\_ref_typespec:\s*(.*)$', blk[k])
                        if mm:
                            nm = mm.group(1).strip()
                            rhs['tsref'] = 'ref'
                            rhs['tsname'] = nm if nm else '<bare>'
                            rb2 = ind(blk[k]); q = k + 1
                            while q < len(blk) and (blk[q].strip() == '' or ind(blk[q]) > rb2):
                                if blk[q].strip() == '|vpiActual:' and q + 1 < len(blk):
                                    am = re.match(r'\s*\\_(\w+):\s*(.*)$', blk[q + 1])
                                    if am:
                                        al = re.search(r'line:(\d+:\d+), endln:(\d+:\d+)', am.group(2))
                                        rhs['tsact'] = am.group(1) + '@' + (
                                            (al.group(1) + '-' + al.group(2)) if al else 'NOLOC')
                                    break
                                q += 1
                        depth_ts = None
                    k += 1
        i += 1
    if lhs is None:
        return None
    rhs['lhs'] = lhs
    return rhs

KEYS = ['kind', 'dec', 'size', 'ct', 'val', 'tsname', 'tsact']

def fmt(c):
    return ' '.join('%s=%s' % (k, c[k]) for k in KEYS) + \
           '   [loc=%s par=%s]' % (c['loc'], c['par'])

def main():
    if len(sys.argv) == 2:
        g = parse(sys.argv[1])
        for k in sorted(g):
            print('%-14s %-28s %-10s %s' % (k[0], k[1], k[2], fmt(g[k])))
        return
    g = parse(sys.argv[1]); o = parse(sys.argv[2])
    to = away = same = 0
    for k in sorted(set(g) | set(o)):
        gc = g.get(k); oc = o.get(k)
        gs = fmt(gc) if gc else '<absent>'
        os_ = fmt(oc) if oc else '<absent>'
        # judge-visible comparison only
        gj = ' '.join('%s=%s' % (x, gc[x]) for x in KEYS) if gc else '<absent>'
        oj = ' '.join('%s=%s' % (x, oc[x]) for x in KEYS) if oc else '<absent>'
        tag = 'SAME' if gj == oj else 'DIFF'
        if tag == 'SAME': same += 1
        print('%-4s %-12s %-26s %-10s\n     G %s\n     O %s' % (tag, k[0], k[1], k[2], gs, os_))
    print('[S] cells=%d same=%d diff=%d' % (len(set(g) | set(o)), same,
                                            len(set(g) | set(o)) - same))

main()
