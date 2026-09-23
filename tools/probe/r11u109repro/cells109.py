#!/usr/bin/env python3
"""Path-keyed cell scorer over uhdm-dump text (measurement only; the judge is uhdm-cmp).
A CELL is (ancestor object path, field label); its value is the multiset of the
field's values there.  Object headers in the path carry their KIND only (derived
names/spans/ids stripped; scope objects keep their name), so a wrong derived name
never re-keys a subtree.  vpiParent pairs, vpiFullName, file/line fields dropped.
Per cell, A->B against golden: TO (wrong->right), AWAY (right->wrong),
MOVED-WRONG (wrong->other wrong).  CELLS_NAMEKEY=1 keeps names in the path."""
import sys, re, collections, os
KEYSTRIP = os.environ.get('CELLS_NAMEKEY', '0') != '1'
SCOPE = re.compile(r'^\\_(module_inst|package|interface_inst|gen_scope|gen_scope_array|design|class_defn|program|function|task)\b')
# kinds whose header name is the dump's SYNTHESIZED path (never a compared field): stripped from the key
DERIVED = re.compile(r'^\\_(hier_path|bit_select|var_select|part_select|indexed_part_select|ref_obj|ref_typespec|ref_var|constant|operation|range|tagged_pattern)\b')
def cells(path):
    L = open(path, errors='replace').read().split('\n')[1:]
    out = collections.defaultdict(list)
    stack = []
    skip = False
    tail = False
    tail = False
    for idx, l in enumerate(L):
        if not l.strip(): continue
        if l.strip() == '\\_weaklyReferenced:':
            # objects printed in the weaklyReferenced section have no
            # containment path (their reference sites print a header only):
            # a text-path key cannot place them — TAIL, scored by tw106 instead
            tail = True; stack = []; continue
        if skip: skip = False; continue
        s = l.lstrip(' ')
        ind = len(l) - len(s)
        if s.startswith('|vpiParent:'): skip = True; continue
        if 'vpiFullName' in s or s.startswith(('|vpiFile', '|vpiDefFile', '|vpiDefLineNo')): continue
        s = re.sub(r', id:\d+', '', s)
        s = re.sub(r',? ?(file:[^,]*, )?line:\d+:\d+, endln:\d+:\d+', '', s)
        s = re.sub(r'/tmp/[^ ,)]*', '<P>', s)
        while stack and stack[-1][0] >= ind: stack.pop()
        key = ('TAIL' if tail else '') + '/' + '/'.join(h for _, h in stack)
        if s.startswith('\\_'):
            kind = re.match(r'\\_(\w+)', s).group(1)
            hdr = s if (not KEYSTRIP or not DERIVED.match(s)) else '\\_' + kind
            if kind == 'param_assign':
                # key a param_assign by its Lhs parameter's name (lookahead)
                for q in range(idx + 1, min(idx + 4000, len(L))):
                    t = L[q]; ti = len(t) - len(t.lstrip(' '))
                    if ti <= ind: break
                    if ti == ind + 2 and t.strip() == '|vpiLhs:' and q + 1 < len(L):
                        m2 = re.search(r'\(([^)]*)\)', L[q + 1])
                        if m2: hdr = '\\_param_assign:' + m2.group(1)
                        break
            out[key + ' ||obj:' + kind].append(kind)
            stack.append((ind, hdr))
        else:
            m = re.match(r'\|(\w+):?(.*)', s)
            lab, val = (m.group(1), m.group(2)) if m else (s, '')
            out[key + ' ||' + lab].append(val)
    return {k: sorted(v) for k, v in out.items()}
g, a, b = (cells(p) for p in sys.argv[1:4])
cnt = collections.Counter(); det = []
for k in set(g) | set(a) | set(b):
    gv, av, bv = g.get(k, []), a.get(k, []), b.get(k, [])
    ea, eb = av == gv, bv == gv
    if ea and eb: continue
    if not ea and eb: t = 'TO'
    elif ea and not eb: t = 'AWAY'
    elif av != bv:
        # a MERGED list (several same-kind siblings under one path): judge by
        # multiset distance to golden, never by list equality alone
        cg, ca, cb = (collections.Counter(x) for x in (gv, av, bv))
        da = sum(((cg - ca) + (ca - cg)).values())
        db = sum(((cg - cb) + (cb - cg)).values())
        t = 'TO' if db < da else ('AWAY' if db > da else 'MOVED-WRONG')
    else: t = 'SAME-WRONG'
    if k.startswith('TAIL') or k.startswith('/ ||'):
        t = 'TAIL-' + t      # a weakly-referenced top-level object: unjudged
    cnt[t] += 1
    if not t.endswith('SAME-WRONG'): det.append((t, k, gv[:3], av[:3], bv[:3]))
tail = sum(v for k, v in cnt.items() if k.startswith('TAIL-') and k != 'TAIL-SAME-WRONG')
print(f"TO={cnt['TO']} AWAY={cnt['AWAY']} MOVED-WRONG={cnt['MOVED-WRONG']} SAME-WRONG={cnt['SAME-WRONG']} TAILMOVED={tail}")
if '-v' in sys.argv:
    for t, k, gv, av, bv in sorted(det): print(t, k[-260:], 'G=', gv, 'A=', av, 'B=', bv)
