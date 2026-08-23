#!/usr/bin/env python3
"""v102 view-general multiset comparator for parameter declarations.

Payload = parameter VpiName + typespec presence/kind (+ const/local/signed/value tag)
          and param_assign Lhs name + Rhs constant fields.  NO span, NO file.
Order-blind (multiset), depth-blind, view-general.
"""
import re, sys, subprocess, collections

DUMP = "/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump"

OBJ = re.compile(r'^(\s*)\\_([A-Za-z_0-9]+): ?(.*)$')
ATTR = re.compile(r'^(\s*)\|([A-Za-z_0-9]+):(.*)$')

def parse(path):
    out = subprocess.run([DUMP, path], capture_output=True, text=True)
    lines = out.stdout.split('\n')
    # build a tree: stack of (indent, node)
    root = {'kind': 'ROOT', 'hdr': '', 'attrs': [], 'kids': []}
    stack = [(-1, root)]
    pending_attr = None
    for ln in lines:
        m = OBJ.match(ln)
        if m:
            ind = len(m.group(1))
            node = {'kind': m.group(2), 'hdr': m.group(3), 'attrs': [], 'kids': []}
            while stack and stack[-1][0] >= ind:
                stack.pop()
            parent = stack[-1][1] if stack else root
            parent['kids'].append((pending_attr, node))
            pending_attr = None
            stack.append((ind, node))
            continue
        m = ATTR.match(ln)
        if m:
            ind = len(m.group(1))
            while stack and stack[-1][0] >= ind:
                stack.pop()
            node = stack[-1][1] if stack else root
            val = m.group(3)
            if val == '':
                pending_attr = m.group(2)
            else:
                node['attrs'].append((m.group(2), val))
                pending_attr = None
            continue
    return root

def attr(node, name, dflt=None):
    for k, v in node['attrs']:
        if k == name:
            return v
    return dflt

def kid(node, edge):
    for e, n in node['kids']:
        if e == edge:
            return n
    return None

VALTAGS = ('BIN','OCT','HEX','INT','UINT','DEC','REAL','STRING','SCAL','TIME')

def valtag(node):
    for k, v in node['attrs']:
        if k in VALTAGS:
            return f'{k}={v}'
    return 'novalue'

def tsdesc(node):
    ts = kid(node, 'vpiTypespec')
    if ts is None:
        return 'TS=none'
    act = kid(ts, 'vpiActual')
    if act is None:
        return f'TS={ts["kind"]}->none'
    return f'TS={ts["kind"]}->{act["kind"]}'

def constdesc(node):
    if node is None:
        return 'RHS=<absent>'
    d = [f'RHS={node["kind"]}']
    for f in ('vpiDecompile','vpiSize','vpiConstType','vpiName','vpiFullName'):
        v = attr(node, f)
        if v is not None:
            d.append(f'{f}={v}')
    d.append(valtag(node))
    d.append(tsdesc(node))
    return '|'.join(d)

def payloads(root):
    bag = collections.Counter()
    def walk(node):
        for e, n in node['kids']:
            if n['kind'] == 'parameter' and (n['attrs'] or n['kids']):
                nm = attr(n, 'vpiName', '?')
                p = '|'.join(['PARAM', f'name={nm}', tsdesc(n),
                              f'local={attr(n,"vpiLocalParam","0")}',
                              f'signed={attr(n,"vpiSigned","0")}',
                              f'const={attr(n,"vpiConstType","-")}',
                              f'size={attr(n,"vpiSize","-")}',
                              valtag(n)])
                if __import__('os').environ.get('PROJ') == 'ts':
                    p = '|'.join(['PARAM', f'name={nm}', tsdesc(n)])
                bag[p] += 1
            if __import__('os').environ.get('PROJ') == 'ts':
                walk(n); continue
            if n['kind'] == 'param_assign' and n['kids']:
                lhs = kid(n, 'vpiLhs')
                nm = '?'
                if lhs is not None:
                    nm = attr(lhs, 'vpiName')
                    if nm is None:
                        nm = re.sub(r',\s*(line|endln|file):[^,]*', '', lhs['hdr']).strip()
                rhs = kid(n, 'vpiRhs')
                bag['|'.join(['PA', f'lhs={nm}', constdesc(rhs)])] += 1
            walk(n)
    walk(root)
    return bag

def main():
    g, p, s = sys.argv[1], sys.argv[2], sys.argv[3]
    label = sys.argv[4] if len(sys.argv) > 4 else ''
    G, P, S = payloads(parse(g)), payloads(parse(p)), payloads(parse(s))
    keys = set(G) | set(P) | set(S)
    ep = es = 0
    moves = []
    for k in sorted(keys):
        gp, pp, sp = G[k], P[k], S[k]
        ep += abs(pp - gp); es += abs(sp - gp)
        if pp != sp:
            if abs(sp - gp) < abs(pp - gp):
                cls = 'TO_GOLDEN'
            elif abs(sp - gp) > abs(pp - gp):
                cls = 'AWAY_GOLDEN'
            else:
                cls = 'LATERAL'
            moves.append((cls, gp, pp, sp, k))
    verdict = 'IMPROVED' if es < ep else ('SAME' if es == ep else 'REGRESSED')
    print(f'ARM {label}: err_pris={ep} err_ship={es} {verdict} '
          f'TO_GOLDEN={sum(1 for m in moves if m[0]=="TO_GOLDEN")} '
          f'AWAY_GOLDEN={sum(1 for m in moves if m[0]=="AWAY_GOLDEN")} '
          f'LATERAL={sum(1 for m in moves if m[0]=="LATERAL")}')
    for cls, gp, pp, sp, k in moves:
        print(f'   {cls} g={gp} pris={pp} ship={sp} {k}')
    import os
    if os.environ.get('SHOWRES'):
        for k in sorted(keys):
            if G[k] != S[k]:
                print(f'   RESIDUAL g={G[k]} ship={S[k]} {k}')

main()
