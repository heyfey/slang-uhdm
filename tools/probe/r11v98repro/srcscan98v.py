#!/usr/bin/env python3
# v11u93 INDEPENDENT source census (verifier's own).  Over-approximates on
# purpose: strips // and /* */ comments and string literals, then walks
# module/program/interface/package/class scopes by keyword and counts, per
# module/program home, the DECLARATION order of its direct class names against
# BYTE name order (LAWA), and any class/final inside a generate region of a
# module or interface home (LAWB).
import os, re, sys

TOK = re.compile(r'\b(module|macromodule|program|interface|package|class|'
                 r'function|task|generate|endgenerate|endmodule|endprogram|'
                 r'endinterface|endpackage|endclass|endfunction|endtask|'
                 r'begin|end|final|case|endcase|for|if)\b|(\bclass\s+(\w+))')
NAMED = re.compile(r'\b(module|macromodule|program|interface|package|class)\s+(\w+)')

def strip(t):
    t = re.sub(r'/\*.*?\*/', ' ', t, flags=re.S)
    t = re.sub(r'//[^\n]*', ' ', t)
    t = re.sub(r'"(\\.|[^"\\])*"', '""', t)
    return t

def scan(path):
    try:
        t = strip(open(path, errors='replace').read())
    except Exception:
        return []
    out = []
    # scope stack of (kind, name, classes[], gen_depth)
    stack = []
    toks = re.finditer(r'\b\w+\b', t)
    words = [(m.group(0), m.start()) for m in toks]
    i = 0
    while i < len(words):
        w, _ = words[i]
        nxt = words[i + 1][0] if i + 1 < len(words) else ''
        if w in ('module', 'macromodule', 'program', 'interface', 'package'):
            kind = 'module' if w == 'macromodule' else w
            stack.append([kind, nxt, [], 0])
        elif w == 'class' and stack and stack[-1][0] in (
                'module', 'program', 'interface', 'package'):
            # a class DECLARATION (next token is a name, not '(' etc.)
            if re.match(r'^\w+$', nxt):
                sc = stack[-1]
                if sc[3] == 0:
                    sc[2].append(nxt)
                else:
                    out.append(('lawb_class', sc[0], sc[1], nxt, path))
                stack.append(['class', nxt, [], 0])
        elif w == 'generate' and stack:
            stack[-1][3] += 1
        elif w == 'endgenerate' and stack and stack[-1][3] > 0:
            stack[-1][3] -= 1
        elif w == 'final' and stack and stack[-1][0] in (
                'module', 'interface', 'program') and stack[-1][3] > 0:
            out.append(('lawb_final', stack[-1][0], stack[-1][1], '', path))
        elif w in ('endmodule', 'endprogram', 'endinterface', 'endpackage',
                   'endclass'):
            if stack:
                sc = stack.pop()
                if sc[0] in ('module', 'program') and len(sc[2]) > 1:
                    if sc[2] != sorted(sc[2]):
                        out.append(('lawa_' + sc[0], sc[0], sc[1],
                                    ','.join(sc[2]), path))
                if sc[0] == 'interface' and sc[2]:
                    out.append(('lawb_iface', sc[0], sc[1],
                                ','.join(sc[2]), path))
        i += 1
    return out

if __name__ == '__main__':
    tot = {}
    rows = []
    for root in sys.argv[1:]:
        for dp, dn, fn in os.walk(root):
            for f in fn:
                if f.rsplit('.', 1)[-1] in ('v', 'sv', 'svh', 'vh'):
                    for r in scan(os.path.join(dp, f)):
                        tot[r[0]] = tot.get(r[0], 0) + 1
                        rows.append(r)
    print(' '.join(f'{k}={v}' for k, v in sorted(tot.items())) or 'ALL ZERO')
    for r in rows:
        print('  ', r[0], r[2], '[' + r[3] + ']', r[4])
