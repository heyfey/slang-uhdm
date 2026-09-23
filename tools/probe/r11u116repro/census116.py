#!/usr/bin/env python3
"""census116.py <db.uhdm>... — a-priori mover census over PRISTINE databases.
Dumps each database once (cached under $CENDIR, default /tmp/r11u116_cen), parses the
indent tree, and counts the shapes each r11u116 law rewrites:
  C1 (F1)  an ELABORATED constant inside a top-module top-level LOOP gen scope
           whose source text is an identifier NAME, where the instance's
           param_assign for NAME has a constant Rhs whose value prefix is not
           UINT (the encoding the law copies) and the constant is UINT
  C2 (F2)  an ELABORATED constant inside a process nested in >=2 gen scopes,
           under an assignment's vpiLhs, whose source text is an identifier
           naming a PACKAGE parameter
  C3 (R1)  a constant (not in a gen scope / function / task / case item) whose
           text is an identifier NAME whose module copy is an imported
           parameter with an OPERATION Rhs
  C4 (R3)  a case_item vpiExpr constant WITHOUT a typespec whose text is an
           identifier NAME whose module copy is an imported parameter with a
           CONSTANT Rhs
Prints '<db> C1=n C2=n C3=n C4=n'."""
import sys, os, re, subprocess
DUMP = '/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump'
HDR = re.compile(r'^(\s*)\\_(\w+): ?(.*?)(?:, id:\d+)?(?:, file:([^,]*))?(?:, line:(\d+):(\d+), endln:(\d+):(\d+))?\s*$')
IDENT = re.compile(r'^[A-Za-z_][A-Za-z0-9_$]*$')
srccache = {}
def text(f, l1, c1, l2, c2):
    if not f or l1 != l2: return None
    if f not in srccache:
        try: srccache[f] = open(f, errors='replace').read().split('\n')
        except Exception: srccache[f] = []
    L = srccache[f]
    if l1 - 1 >= len(L): return None
    return L[l1 - 1][c1 - 1:c2 - 1]
def run(db):
    import hashlib
    cd = os.environ.get('CENDIR', '/tmp/r11u116_cen'); os.makedirs(cd, exist_ok=True)
    dp = os.path.join(cd, hashlib.sha1(os.path.abspath(db).encode()).hexdigest()[:20] + '.dump')
    if not os.path.exists(dp):
        with open(dp + '.tmp', 'w') as f:
            r = subprocess.run([DUMP, db], stdout=f, stderr=subprocess.DEVNULL, timeout=1800)
        os.rename(dp + '.tmp', dp)
    L = open(dp, errors='replace').read().split('\n')
    # pass 1: nodes with role, ancestors
    nodes = []  # (ind, kind, name, file, span, role, lineidx)
    stack = []  # (ind, nodeidx)
    sec = ''
    role = None; prevrole_ind = -1
    pkgparams = set()
    for i, l in enumerate(L):
        if l.startswith('|uhdm'): sec = l.strip(); stack = []; continue
        if l.startswith('\\_weaklyReferenced'): break
        s = l.lstrip(); ind = len(l) - len(s)
        if s.startswith('|'):
            role = (ind, s.rstrip(':')[1:]); continue
        m = HDR.match(l)
        if not m: continue
        kind = m.group(2)
        r = role[1] if role and role[0] == ind else None
        role = None
        if r in ('vpiParent', 'vpiActual', 'vpiInstance', 'vpiModule'):
            # back-reference: attach to the owner
            if r == 'vpiParent' and stack:
                nodes[stack[-1][1]]['par'] = (kind, m.group(5, 6, 7, 8))
            continue
        while stack and stack[-1][0] >= ind: stack.pop()
        f = m.group(4)
        if not f and stack: f = nodes[stack[-1][1]]['file']
        sp = tuple(int(x) for x in m.group(5, 6, 7, 8)) if m.group(5) else None
        n = {'ind': ind, 'kind': kind, 'name': m.group(3), 'file': f, 'span': sp, 'role': r,
             'up': stack[-1][1] if stack else None, 'sec': sec, 'props': {}, 'kids': []}
        nodes.append(n); k = len(nodes) - 1
        if n['up'] is not None: nodes[n['up']]['kids'].append(k)
        stack.append((ind, k))
    # props (second light pass: direct props under each node)
    for n in nodes: pass
    idx_of_line = {}
    # recollect props by re-walking lines with indent tracking
    stack = []; k = -1; cur = {}
    for i, l in enumerate(L):
        if l.startswith('\\_weaklyReferenced'): break
    # simpler: second parse computing props for constants and param_assigns
    stack2 = []; ni = 0; role = None
    for i, l in enumerate(L):
        if l.startswith('|uhdm'): stack2 = []; continue
        if l.startswith('\\_weaklyReferenced'): break
        s = l.lstrip(); ind = len(l) - len(s)
        if s.startswith('|'):
            role = (ind, s.rstrip(':')[1:])
            while stack2 and stack2[-1][0] > ind - 2: stack2.pop()
            if stack2 and stack2[-1][0] == ind - 2:
                o = nodes[stack2[-1][1]]
                if ':' in s[1:] and not s.endswith(':'):
                    kk, vv = s[1:].split(':', 1); o['props'][kk] = vv
            continue
        m = HDR.match(l)
        if not m: continue
        r = role[1] if role and role[0] == ind else None
        role = None
        if r in ('vpiParent', 'vpiActual', 'vpiInstance', 'vpiModule'): continue
        while stack2 and stack2[-1][0] >= ind: stack2.pop()
        stack2.append((ind, ni)); ni += 1
    def anc(k):
        u = nodes[k]['up']
        while u is not None:
            yield u; u = nodes[u]['up']
    # package parameter names
    for n in nodes:
        if n['sec'] == '|uhdmallPackages:' and n['kind'] == 'parameter' and n['role'] == 'vpiParameter':
            nm = n['name'].split('(')[-1].rstrip(')').split('::')[-1].split('.')[-1]
            pkgparams.add(nm)
    # per module_inst param_assign map: NAME -> (rhs kind, rhs value prefix, imported)
    pamap = {}
    for k, n in enumerate(nodes):
        if n['kind'] != 'param_assign' or n['role'] != 'vpiParamAssign': continue
        mi = n['up']
        lhs = [nodes[c] for c in n['kids'] if nodes[c]['role'] == 'vpiLhs']
        rhs = [nodes[c] for c in n['kids'] if nodes[c]['role'] == 'vpiRhs']
        if not lhs or not rhs: continue
        nm = lhs[0]['name'].split('(')[-1].rstrip(')').split('.')[-1].split('::')[-1]
        v = ''
        for key in rhs[0]['props']:
            if key in ('UINT', 'INT', 'HEX', 'BIN', 'OCT', 'DEC'): v = key
        pamap[(mi, nm)] = (rhs[0]['kind'], v, 'vpiImported' in lhs[0]['props'])
    c = [0, 0, 0, 0]
    for k, n in enumerate(nodes):
        if n['kind'] != 'constant' or not n['span']: continue
        t = text(n['file'], *n['span'])
        if not t or not IDENT.match(t): continue
        A = list(anc(k))
        kinds = [nodes[a]['kind'] for a in A]
        mi = next((a for a in A if nodes[a]['kind'] == 'module_inst'), None)
        ngs = kinds.index('module_inst') if 'module_inst' in kinds else len(kinds)
        gs_depth = sum(1 for x in kinds[:ngs] if x == 'gen_scope')
        uval = 'UINT' in n['props']
        # C1
        if n['sec'] == '|uhdmtopModules:' and gs_depth == 1 and mi is not None and nodes[mi]['up'] is None:
            gsa = next((a for a in A if nodes[a]['kind'] == 'gen_scope_array'), None)
            if gsa is not None and '[' in nodes[gsa]['name'] and uval:
                pv = pamap.get((mi, t))
                if pv and pv[0] == 'constant' and pv[1] not in ('UINT', ''):
                    c[0] += 1
        # C2
        if n['sec'] == '|uhdmtopModules:' and gs_depth >= 2 and t in pkgparams and \
           any(x in ('always', 'initial', 'final') for x in kinds[:ngs]):
            # under an assignment's vpiLhs
            ch = [k] + A
            for j in range(len(ch) - 1):
                if nodes[ch[j]]['role'] == 'vpiLhs' and nodes[ch[j + 1]]['kind'] == 'assignment':
                    c[1] += 1; break
        # C3 / C4
        if mi is not None and gs_depth == 0 and not any(x in ('function', 'task') for x in kinds[:ngs]):
            pv = pamap.get((mi, t))
            if pv and pv[2]:
                if n['role'] != 'vpiExpr' and pv[0] == 'operation':
                    c[2] += 1
                if n['role'] == 'vpiExpr' and n['up'] is not None and nodes[n['up']]['kind'] == 'case_item' \
                   and 'vpiTypespec' not in [nodes[x]['role'] for x in n['kids']] and pv[0] == 'constant':
                    c[3] += 1
    return c
for db in sys.argv[1:]:
    try:
        c = run(db)
        print('%s C1=%d C2=%d C3=%d C4=%d' % (db, *c), flush=True)
    except Exception as e:
        print('%s ERROR %s' % (db, e), flush=True)
