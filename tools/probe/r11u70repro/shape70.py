#!/usr/bin/env python3
"""r11u70 SHAPE LISTER — a cast-pattern-aware census over a uhdm-dump text.

For every `param_assign` (and, with --all, every `cont_assign` Rhs and every
variable `vpiExpr`) in every top-level listing, print one line:

    <listing>|<holder-name>|<sig>

where <sig> is a recursive, ENCODING+SIZE aware rendering of the expression:

    op<T>{ts=<kind>(<name>)}[ <child> <child> ... ]
    K<size>:<enc>            a constant (enc = DEC/HEX/BIN/UINT/INT/STRING/...)
    R(<name>-><actualkind>)  a ref_obj and what it binds to
    tp(<tskind>(<name>))[<child>]   a tagged_pattern and its key typespec
    <kind>                   anything else

It also prints, with --nets, the NET LIST of every module in every listing, so
a phantom mint is visible as a name in that list.
usage: shape70.py [--all] [--nets] <dump.txt> ...
"""
import re, sys

def ind(l):
    return len(l) - len(l.lstrip())

def children(lines, i, base):
    """lines strictly deeper than base, starting at i; returns (block, next_i)"""
    out = []
    while i < len(lines):
        l = lines[i]
        if l.strip() and ind(l) <= base:
            break
        out.append(l)
        i += 1
    return out, i

def fields(blk, base):
    """(label, kind, name, subblock) tuples for direct children at base+2,
    plus a dict of scalar |Field:value entries at base+2."""
    objs = []
    scal = {}
    label = None
    a = 0
    while a < len(blk):
        l = blk[a]
        if ind(l) != base + 2:
            a += 1
            continue
        s = l.lstrip()
        if s.startswith('|'):
            k, _, v = s[1:].partition(':')
            if v == '':
                label = '|' + k
            else:
                scal[k] = v
                label = None
            a += 1
            continue
        if s.startswith('\\_'):
            m = re.match(r'\\_(\w+): (\(([^)]*)\))?', s)
            kind = m.group(1)
            name = m.group(3) or ''
            sub, a2 = children(blk, a + 1, ind(l))
            objs.append((label, kind, name, sub, ind(l)))
            a = a2
            continue
        a += 1
    return objs, scal

ENC = ('DEC', 'HEX', 'BIN', 'OCT', 'UINT', 'INT', 'STRING', 'REAL', 'SCAL')

def sig(kind, name, blk, base, depth=0):
    if depth > 14:
        return '...'
    objs, scal = fields(blk, base)
    if kind == 'constant':
        enc = '?'
        val = ''
        for e in ENC:
            if e in scal:
                enc = e
                val = scal[e]
                break
        return 'K%s:%s=%s' % (scal.get('vpiSize', '-'), enc, val)
    if kind == 'ref_obj':
        act = '-'
        for lab, k, n, sub, b in objs:
            if lab == '|vpiActual':
                act = k
        return 'R(%s->%s)' % (name.split('.')[-1] or '?', act)
    if kind == 'operation':
        ts = '-'
        kids = []
        for lab, k, n, sub, b in objs:
            if lab == '|vpiTypespec':
                # ref_typespec -> vpiActual
                so, ss = fields(sub, b)
                inner = '-'
                for lab2, k2, n2, sub2, b2 in so:
                    if lab2 == '|vpiActual':
                        inner = '%s(%s)' % (k2, n2)
                ts = '%s[%s]->%s' % (k, n, inner)
            elif lab == '|vpiOperand':
                kids.append(sig(k, n, sub, b, depth + 1))
        return 'op%s{ts=%s}[%s]' % (scal.get('vpiOpType', '?'), ts,
                                    ' '.join(kids))
    if kind == 'tagged_pattern':
        key = '-'
        pat = '-'
        for lab, k, n, sub, b in objs:
            if lab == '|vpiTypespec':
                so, ss = fields(sub, b)
                for lab2, k2, n2, sub2, b2 in so:
                    if lab2 == '|vpiActual':
                        key = '%s(%s)' % (k2, n2)
            elif lab == '|vpiPattern':
                pat = sig(k, n, sub, b, depth + 1)
        return 'tp(%s)[%s]' % (key, pat)
    return '%s(%s)' % (kind, name)

def run(path, do_all, do_nets):
    lines = open(path, errors='replace').read().splitlines()
    sect = '?'
    mod = '?'
    i = 0
    while i < len(lines):
        ln = lines[i]
        m = re.match(r'^\|(uhdm\w+):', ln)
        if m:
            sect = m.group(1)
            i += 1
            continue
        s = ln.lstrip()
        m = re.match(r'\\_(module_inst|package|interface_inst): (\S+)', s)
        if m and ind(ln) <= 2:
            mod = m.group(2)
        m = re.match(r'\\_param_assign: ', s)
        if m:
            base = ind(ln)
            blk, i = children(lines, i + 1, base)
            objs, scal = fields(blk, base)
            nm = '?'
            sg = 'NONE'
            for lab, k, n, sub, b in objs:
                if lab == '|vpiLhs':
                    nm = n
                elif lab == '|vpiRhs':
                    sg = sig(k, n, sub, b)
            print('%s|%s|PARAM %s|%s' % (sect, mod, nm, sg))
            continue
        if do_all:
            m = re.match(r'\\_cont_assign: ', s)
            if m:
                base = ind(ln)
                blk, i = children(lines, i + 1, base)
                objs, scal = fields(blk, base)
                nm = '?'
                sg = 'NONE'
                for lab, k, n, sub, b in objs:
                    if lab == '|vpiLhs':
                        nm = n
                    elif lab == '|vpiRhs':
                        sg = sig(k, n, sub, b)
                print('%s|%s|CA %s|%s' % (sect, mod, nm, sg))
                continue
        i += 1
    if do_nets:
        # net list per listing per module, in ORDER
        sect = '?'
        mod = '?'
        cur = []
        out = []
        for ln in lines:
            m = re.match(r'^\|(uhdm\w+):', ln)
            if m:
                if cur:
                    out.append((sect, mod, list(cur)))
                    cur = []
                sect = m.group(1)
                continue
            s = ln.lstrip()
            m = re.match(r'\\_(module_inst|interface_inst): (\S+)', s)
            if m and ind(ln) <= 2:
                if cur:
                    out.append((sect, mod, list(cur)))
                    cur = []
                mod = m.group(2)
                continue
            m = re.match(r'\\_(logic_net|array_net|\w*_net): \(([^)]*)\), ', s)
            if m and ind(ln) == 2:
                cur.append(m.group(2).split('.')[-1])
        if cur:
            out.append((sect, mod, cur))
        for sc, md, ns in out:
            print('%s|%s|NETS|%s' % (sc, md, ','.join(ns)))

if __name__ == '__main__':
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    do_all = '--all' in sys.argv
    do_nets = '--nets' in sys.argv
    for p in args:
        if len(args) > 1:
            print('== %s' % p)
        run(p, do_all, do_nets)
