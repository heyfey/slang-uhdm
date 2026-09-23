#!/usr/bin/env python3
"""pv115.py <dump>: every param_assign reachable (not through vpiParent) under an
interface_inst, printed as `<iface fullname> <param> <rhs value> ts=<Y|N>`,
plus each iface member var's range (`<iface fullname> var <name> [l:r]`).
Measurement only (the judge is uhdm-cmp)."""
import sys, re
L = open(sys.argv[1], errors='replace').read().split('\n')[1:]
out = []
stack = []  # (indent, header)
skipind = None
i = 0
def ctx():
    for ind, h in reversed(stack):
        m = re.match(r'\\_interface_inst: \S+ \(([^)]*)\)', h)
        if m: return m.group(1)
    return None
while i < len(L):
    l = L[i]; s = l.lstrip(' '); ind = len(l) - len(s)
    if skipind is not None:
        if ind > skipind or (ind == skipind and s.startswith('\\_')):
            i += 1; continue
        skipind = None
    if s.startswith('|vpiParent:') or s.startswith('|vpiInstance:') or s.startswith('|vpiActual') or s.startswith('|vpiTypedef'):
        skipind = ind; i += 1; continue
    if s.startswith('\\_weaklyReferenced'): break
    while stack and stack[-1][0] >= ind: stack.pop()
    if s.startswith('\\_'):
        stack.append((ind, s))
        if s.startswith('\\_param_assign'):
            c = ctx()
            # scan the block
            val = None; lhs = None; ts = 'N'; j = i + 1; rhsmode = None
            while j < len(L):
                t = L[j]; ts_ = t.lstrip(' '); ti = len(t) - len(ts_)
                if ti <= ind: break
                if ts_.startswith('|vpiRhs:'): rhsmode = 'R'
                elif ts_.startswith('|vpiLhs:'): rhsmode = 'L'
                elif rhsmode == 'R' and val is None and re.match(r'\|(UINT|INT|BIN|HEX|DEC|OCT|STRING|REAL):', ts_): val = ts_[1:]
                elif rhsmode == 'R' and ts_.startswith('\\_operation') and val is None: val = 'OP'
                elif rhsmode == 'R' and ts_.startswith('|vpiTypespec:') and ti == ind + 4: ts = 'Y'
                elif rhsmode == 'L' and lhs is None and ts_.startswith('\\_parameter'):
                    m = re.search(r'\(([^)]*)\)', ts_); lhs = m.group(1).split('.')[-1] if m else '?'
                j += 1
            if c: out.append(f'{c} {lhs} {val} ts={ts}')
    i += 1
for o in sorted(set(out)): print(o)
