#!/usr/bin/env python3
"""r11u93 SOURCE-LEVEL census: which corpus tests can either law reach?

LAW B (caIfacePortDeclNetMint93) fires on an INTERFACE with a NON-ANSI header
(a bare identifier list) that also carries an input/output/inout PORT
DECLARATION in its body.  LAW A (caProgramGenFlattens93) fires on a PROGRAM
whose body contains a generate construct.

Both are SYNTACTIC properties, so a scanner can answer them without building a
database -- and a scanner that returns zero needs a POSITIVE CONTROL, which is
what `--control <dir>` runs (the pass's own grid, where both must be found).
Comments and strings are stripped first; `usage: srcscan93.py <dir> ...`.
"""
import os, re, sys

def strip(t):
    t = re.sub(r'/\*.*?\*/', ' ', t, flags=re.S)
    t = re.sub(r'//[^\n]*', ' ', t)
    t = re.sub(r'"(\\.|[^"\\])*"', ' ', t)
    return t

IFACE = re.compile(r'\binterface\s+(\\?\S+|\w+)\s*(#\s*\([^;]*?\)\s*)?\(([^;]*?)\)\s*;', re.S)
PROG  = re.compile(r'\bprogram\b(.*?)\bendprogram\b', re.S)
PDECL = re.compile(r'\b(input|output|inout)\b')
GEN   = re.compile(r'\b(generate|endgenerate)\b')

def ansi(portlist):
    # A NON-ANSI header is a bare comma-separated identifier list: no
    # direction keyword, no type, no `.name(expr)` form.
    p = portlist.strip()
    if not p:
        return True
    if re.search(r'\b(input|output|inout|ref|wire|logic|reg|bit|interface)\b', p):
        return True
    if '.' in p or '[' in p:
        return True
    return not all(re.fullmatch(r'\s*(\\?\S+|\w+)\s*', x) for x in p.split(','))

def scan(path):
    try:
        t = strip(open(path, encoding='utf-8', errors='replace').read())
    except OSError:
        return set(), set()
    lawb, lawa = set(), set()
    for m in IFACE.finditer(t):
        name, plist = m.group(1), m.group(3)
        if ansi(plist):
            continue
        body = t[m.end(): m.end() + 200000]
        e = body.find('endinterface')
        if e >= 0:
            body = body[:e]
        # a port declaration naming one of the header names
        names = [x.strip() for x in plist.split(',') if x.strip()]
        for line in body.split(';'):
            if not PDECL.search(line):
                continue
            if any(re.search(r'\b%s\b' % re.escape(n), line) for n in names):
                lawb.add(name)
                break
    for m in PROG.finditer(t):
        if GEN.search(m.group(1)):
            lawa.add('program@%d' % t[:m.start()].count('\n'))
    return lawb, lawa

def walk(root):
    rows = []
    for dp, _, fns in os.walk(root):
        for fn in fns:
            if not fn.endswith(('.v', '.sv', '.svh', '.vh')):
                continue
            p = os.path.join(dp, fn)
            b, a = scan(p)
            if b or a:
                rows.append((os.path.relpath(p, root), sorted(b), sorted(a)))
    return rows

if __name__ == '__main__':
    tb = ta = 0
    for root in sys.argv[1:]:
        rows = walk(root)
        for rel, b, a in rows:
            print('%s\tLAWB=%s\tLAWA=%s' % (rel, ','.join(b) or '-', ','.join(a) or '-'))
            tb += len(b); ta += len(a)
        print('# %s: files=%d lawB_ifaces=%d lawA_programs=%d' %
              (root, len(rows), tb, ta))
