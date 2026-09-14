#!/usr/bin/env python3
"""memcells.py <dump> — every struct_typespec typespec_member's vpiExpr LEFTOVER
in a uhdm-dump, printed as <section> <struct> <member> = <encoding> ts=<actual>.
Only FULL prints count as objects; an abbreviated repeat is marked (ref)."""
import sys, re
def ind(l): return len(l) - len(l.lstrip(' '))
for path in sys.argv[1:]:
    lines = open(path).read().split('\n')
    print('####', path)
    sec = 'HEAD'; struct = '?'
    stack = []
    for i, l in enumerate(lines):
        s = l.strip()
        if s.startswith('|uhdm'): sec = s.strip('|:')
        if s.startswith('\\_weaklyReferenced'): sec = 'weaklyReferenced'
        m = re.match(r'^(\s*)\\_struct_typespec: \(([^)]*)\)', l)
        if m: struct = m.group(2)
        m = re.match(r'^(\s*)\\_typespec_member: \(([^)]*)\)', l)
        if not m: continue
        mi, mem = len(m.group(1)), m.group(2)
        # walk this member's children for the FIRST vpiExpr
        j = i+1; expr = None
        while j < len(lines):
            nl = lines[j]
            if not nl.strip() or ind(nl) <= mi: break
            if nl.strip() == '|vpiExpr:' and ind(nl) == mi+2:
                # the next line is the object header
                hdr = lines[j+1]
                k = j+2; props = []
                while k < len(lines):
                    if not lines[k].strip() or ind(lines[k]) <= ind(hdr): break
                    props.append(lines[k]); k += 1
                enc = hdr.strip().split(',')[0]
                if not props:
                    expr = f'{enc} (ref)'
                else:
                    flat = [p.strip() for p in props if ind(p) == ind(hdr)+2]
                    val = [p for p in flat if re.match(r'\|(BIN|UINT|INT|HEX|DEC|OCT|STRING|SCALAR):', p)]
                    dec = [p for p in flat if p.startswith('|vpiDecompile')]
                    sz  = [p for p in flat if p.startswith('|vpiSize')]
                    ct  = [p for p in flat if p.startswith('|vpiConstType')]
                    ts  = 'ts=NONE'
                    if any(p == '|vpiTypespec:' for p in flat):
                        # find the ref_typespec's actual
                        for kk in range(j+2, k):
                            if lines[kk].strip() == '|vpiActual:':
                                ts = 'ts=' + lines[kk+1].strip().lstrip('\\_')
                                break
                        else:
                            ts = 'ts=?'
                    expr = ' '.join([enc] + val + dec + sz + ct + [ts])
                break
            j += 1
        print(f'  {sec:16s} {struct:28s} {mem:20s} {expr}')
