#!/usr/bin/env python3
"""cells116.py <grid-dir> <out-root> <tag> [<tag2>] — per-CELL scorer.
A cell = (arm, read span) for every IDENTIFIER token named M/P (and p::P) in
the arm's dut.sv.  Per dump, the objects whose five-field span starts at that
token are collected with their compare-visible fields (kind, name, value, size,
decompile, const type, typespec-actual kind, actual kind + the actual's own
value/size/decompile when it is an enum_const), per section, as a SORTED
MULTISET (one entry per elaborated copy).  Prints one row per cell:
  arm line:col  G==<tag>?  [G==<tag2>?]  golden-shape | tag-shape
Parent and fullname are out of the key (no Compare reads them)."""
import sys, os, re, subprocess
DUMP = '/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump'
KEEP = re.compile(r'^\|(UINT|INT|BIN|HEX|DEC|OCT|vpiSize|vpiName|vpiDecompile|vpiConstType|vpiOpType)')
SECS = (('|uhdmallModules', 'DEF'), ('|uhdmtopModules', 'TOP'), ('|uhdmallPackages', 'PKGDEF'),
        ('|uhdmtopPackages', 'PKGTOP'), ('\\_weaklyReferenced', 'WEAK'))
def dump(u):
    t = u + '.dump'
    if not os.path.exists(t) or os.path.getmtime(t) < os.path.getmtime(u):
        with open(t, 'w') as f:
            subprocess.run([DUMP, u], stdout=f, stderr=subprocess.STDOUT, timeout=120)
    return open(t, errors='replace').read().split('\n')
def objs(L):
    sec = 'HDR'; out = {}
    for i, l in enumerate(L):
        for k, v in SECS:
            if l.startswith(k): sec = v
        if sec == 'WEAK': break
        m = re.match(r'^(\s*)\\_(\w+): (.*?)(?:, id:\d+)?(?:, file:[^,]*)?, line:(\d+):(\d+), endln:(\d+):(\d+)', l)
        if not m: continue
        ind = len(m.group(1)); kind = m.group(2)
        if kind in ('parameter', 'param_assign', 'gen_scope', 'gen_scope_array', 'module_inst', 'package',
                    'cont_assign', 'always', 'assignment', 'begin', 'event_control', 'if_stmt', 'if_else'):
            continue
        props = []; j = i + 1
        # skip back-reference lines (a \_x immediately after |vpiParent:)
        if i > 0 and L[i - 1].strip() in ('|vpiParent:',): continue
        while j < len(L):
            s = L[j]; si = len(s) - len(s.lstrip())
            if si <= ind: break
            st = s.strip()
            if si == ind + 2 and KEEP.match(st): props.append(st)
            if si == ind + 2 and st in ('|vpiActual:', '|vpiTypespec:'):
                nx = L[j + 1].strip() if j + 1 < len(L) else ''
                tag = st[1:-1] + '=' + nx.split(':')[0]
                if st == '|vpiTypespec:':
                    k = j + 2
                    while k < len(L) and len(L[k]) - len(L[k].lstrip()) >= si + 2:
                        if L[k].strip() == '|vpiActual:' and len(L[k]) - len(L[k].lstrip()) == si + 2:
                            tag += '>' + L[k + 1].strip().split(':')[0]
                            break
                        k += 1
                props.append(tag)
            j += 1
        if j == i + 1: continue
        key = (int(m.group(4)), int(m.group(5)))
        out.setdefault(key, []).append('%s:%s{%s}' % (sec, kind, ' '.join(props)))
    return out
def enumconsts(L):
    # the loc-less enum_const clones: summarise their fields (value/size/decompile)
    res = []; w = False
    for i, l in enumerate(L):
        if l.startswith('\\_weaklyReferenced'): w = True
        if w and l.startswith('\\_enum_const:'):
            p = []
            for s in L[i + 1:i + 9]:
                st = s.strip()
                if s.startswith('\\_'): break
                if KEEP.match(st): p.append(st)
            res.append(l.strip() + '{' + ' '.join(sorted(p)) + '}')
    return sorted(res)
grid, out = sys.argv[1], sys.argv[2]; tags = sys.argv[3:]
tot = {t: [0, 0] for t in tags}
for arm in sorted(os.listdir(os.path.join(grid))):
    src = os.path.join(grid, arm, 'dut.sv')
    if not os.path.exists(src): continue
    toks = []
    for ln, text in enumerate(open(src).read().split('\n'), 1):
        for m in re.finditer(os.environ.get('TOKRE', r'(p::P|\bM\b|\bP\b)'), text):
            if re.match(r'\s*(parameter|localparam|typedef|import)', text) or 'import pk::' in text: continue
            if re.match(r'\s*(parameter|localparam)', text[:m.start()] + ' ') and '=' not in text[:m.start()]:
                pass
            pre = text[:m.start()]
            if re.search(r'(parameter|localparam)\s+(int unsigned|logic \[31:0\])?\s*$', pre): continue
            if 'import p::' in pre[-10:]: continue
            toks.append((ln, m.start() + 1))
    w = os.path.join(out, arm)
    if not os.path.exists(os.path.join(w, 'gold.uhdm')): continue
    G = objs(dump(os.path.join(w, 'gold.uhdm')))
    D = {t: objs(dump(os.path.join(w, t + '.uhdm'))) for t in tags if os.path.exists(os.path.join(w, t + '.uhdm'))}
    for tk in toks:
        g = sorted(G.get(tk, []))
        row = []
        for t in tags:
            o = sorted(D.get(t, {}).get(tk, [])) if t in D else None
            eq = (o == g)
            tot[t][0 if eq else 1] += 1
            row.append('%s=%s' % (t, 'EQ' if eq else 'NE'))
        shp = lambda x: ' ; '.join(sorted(set(x)))[:160]
        print('%s %d:%d %s | G: %s | %s' % (arm, tk[0], tk[1], ' '.join(row), shp(g),
              ' | '.join('%s: %s' % (t, shp(sorted(D.get(t, {}).get(tk, [])))) for t in tags if t in D and sorted(D[t].get(tk, [])) != g)))
for t in tags: print('TOTAL %s EQ=%d NE=%d' % (t, tot[t][0], tot[t][1]))
