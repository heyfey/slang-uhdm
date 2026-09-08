import sys, re
# Parse a uhdm-dump; for every cont_assign under the ELAB (topModules) section,
# report scope fullname + line, and the vpiOpType/operand kinds of its Rhs.
def parse(path, section='elab'):
    lines = open(path, errors='replace').read().split('\n')
    start = 0
    for i,l in enumerate(lines):
        if l.startswith('|uhdmtopModules:'):
            start = i; break
    if section == 'def':
        seg = lines[:start]
    else:
        seg = lines[start:]
    out = []
    # stack of (indent, kind, name, loc)
    i = 0
    n = len(seg)
    while i < n:
        l = seg[i]
        m = re.match(r'^(\s*)\\_(\w+): ?(.*)$', l)
        if m and m.group(2) == 'cont_assign':
            ind = len(m.group(1))
            loc = m.group(3)
            # collect subtree
            j = i+1
            body = []
            while j < n:
                l2 = seg[j]
                m2 = re.match(r'^(\s*)[\\|]', l2)
                if not m2: break
                if len(m2.group(1)) <= ind and re.match(r'^\s*\\_', l2): break
                if len(m2.group(1)) < ind: break
                body.append((len(m2.group(1)), l2.strip()))
                j += 1
            # find vpiRhs at depth ind+2
            rhs_idx = None
            for k,(d,t) in enumerate(body):
                if d == ind+2 and t == '|vpiRhs:':
                    rhs_idx = k; break
            ops = []
            optype = None
            lhsname = None
            for k,(d,t) in enumerate(body):
                if d == ind+2 and t == '|vpiLhs:':
                    # next line is the lhs node
                    if k+1 < len(body):
                        ops_lhs = body[k+1][1]
                        lhsname = ops_lhs
            if rhs_idx is not None:
                rd = body[rhs_idx+1][0]
                rkind = re.match(r'\\_(\w+)', body[rhs_idx+1][1])
                rkind = rkind.group(1) if rkind else '?'
                # operands at depth rd+2
                for k in range(rhs_idx+2, len(body)):
                    d,t = body[k]
                    if d <= rd and t.startswith('\\_'): break
                    if d == rd+2 and t.startswith('|vpiOpType:'):
                        optype = t.split(':',1)[1]
                    if d == rd+2 and t == '|vpiOperand:':
                        kk = re.match(r'\\_(\w+)', body[k+1][1])
                        ops.append(kk.group(1) if kk else '?')
                out.append((loc, rkind, optype, tuple(ops), lhsname))
            i = j
            continue
        i += 1
    return out

if __name__ == '__main__':
    sec = sys.argv[2] if len(sys.argv)>2 else 'elab'
    res = parse(sys.argv[1], sec)
    seen = {}
    for loc, rk, ot, ops, lhs in res:
        key = (loc, rk, ot, ops)
        seen.setdefault(key, 0)
        seen[key]+=1
    for k,v in sorted(seen.items(), key=lambda kv: str(kv[0])):
        loc, rk, ot, ops = k
        tag = sum(1 for o in ops if o=='tagged_pattern')
        print(f'{loc}  rhs={rk} op={ot} nops={len(ops)} ntag={tag} x{v}  {ops[:3]}')
