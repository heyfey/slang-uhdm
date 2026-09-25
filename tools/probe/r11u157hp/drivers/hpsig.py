#!/usr/bin/env python3
"""r11u157: per-hier_path element signatures of two databases (objtab), joined by (line, col, path name).
sig = <base anchor>:<element name kinds>:<element spans>
  base anchor: N = the base element carries the NEXT element's span (Surelog compileSelectExpression's r1),
               O = its own span, Z = no span;
  name kinds per element: o = the vpi full name reads empty (stored == own name), c = a full name (stored or
               computed at save), with the tail shown for c;
Args: <golden objtab> <ours objtab> [--src dut.sv] -> one line per key: golden sigs | ours sigs | MATCH/DIFF."""
import sys, collections
def load(p):
    out = collections.defaultdict(list); cur = None
    for l in open(p):
        x = l.rstrip('\n').split('\t')
        if x[0] == 'P':
            cur = [x[2], x[4], x[5], []]; ln, col = x[4].split(':')[:2]
            out[(int(ln), int(col), x[2])].append(cur)
        else:
            cur[3].append(x)
    return out
def sig(p):
    name, span, ptype, el = p
    if not el: return 'EMPTY'
    sp = [e[6] for e in el]
    if sp[0] == '0:0:0:0': b = 'Z'
    elif len(sp) > 1 and sp[0] == sp[1]: b = 'N'
    else: b = 'O'
    nk = ''.join('o' if e[4] == '' else 'c' for e in el)
    full = ','.join(e[4] for e in el if e[4])
    zs = ''.join('z' if s == '0:0:0:0' else 's' for s in sp)
    types = ''.join({'ref_obj': 'r', 'bit_select': 'b', 'part_select': 'p', 'var_select': 'v', 'indexed_part_select': 'i', 'method_func_call': 'm'}.get(e[2], '?') for e in el)
    return f'{b}:{nk}:{zs}:{types}' + (f' [{full}]' if full else '')
G = load(sys.argv[1]); O = load(sys.argv[2])
src = None
if '--src' in sys.argv: src = open(sys.argv[sys.argv.index('--src') + 1], errors='replace').read().split('\n')
for k in sorted(set(G) | set(O)):
    gs = sorted(sig(p) for p in G.get(k, [])); os_ = sorted(sig(p) for p in O.get(k, []))
    st = 'MATCH' if gs == os_ else 'DIFF'
    t = src[k[0] - 1].strip()[:70] if src and 0 < k[0] <= len(src) else ''
    ptypes = sorted(set(p[2] for p in G.get(k, []) + O.get(k, [])))
    print(f'{st:5s} {k[0]}:{k[1]} {k[2]:24s} G{gs} O{os_} <{",".join(ptypes)}> | {t}')
