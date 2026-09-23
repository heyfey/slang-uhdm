#!/usr/bin/env python3
"""r11u109 a-priori signature census over one row's golden + OURS (pristine) dumps.
Prints '<face> <count>' for every face whose DATABASE signature is present:
 F4  def-view (uhdmallModules) port whose golden typespec is array_typespec and ours is not
 F5  elab object named X: ours struct_var, golden struct_net / packed_array_var
 HP  part_selects whose vpiName carries '[' (the dotted arm's flattened member select): ours minus golden
 F1  golden elab void_typespec count minus ours
 F2S typespec_member Actual_value (vpiExpr) count: ours minus golden
 F2F uhdmtopPackages tagged_pattern count: ours minus golden
Superset of each law's gates by construction (the sweep is the arbiter)."""
import sys, re, collections
def load(p):
    return open(p, errors='replace').read().split('\n')
def sections(L):
    sec = {}; cur = None
    for i, l in enumerate(L):
        m = re.match(r'^\|(uhdm\w+):$', l)
        if m: cur = m.group(1)
        sec[i] = cur
    return sec
def ports_def(L):
    sec = sections(L); out = {}
    for i, l in enumerate(L):
        if sec.get(i) != 'uhdmallModules': continue
        m = re.match(r'^(\s*)\\_port: \(([^)]*)\)', l)
        if not m: continue
        ind = len(m.group(1)); name = m.group(2)
        # find module name context: nearest preceding module_inst at indent 0
        j = i
        while j > 0 and not L[j].startswith('\\_module_inst'): j -= 1
        mod = L[j].split(' ')[1] if j > 0 else '?'
        act = None
        for k in range(i + 1, min(i + 40, len(L))):
            s = L[k]
            if len(s) - len(s.lstrip(' ')) <= ind and s.strip().startswith('\\_'): break
            if s.strip() == '|vpiTypedef:':
                for q in range(k + 1, min(k + 8, len(L))):
                    if L[q].strip() == '|vpiActual:':
                        act = re.match(r'\s*\\_(\w+)', L[q + 1]).group(1); break
                break
        out.setdefault((mod, name), []).append(act)
    return out
def elab_kinds(L):
    sec = sections(L); d = collections.defaultdict(set)
    for i, l in enumerate(L):
        if sec.get(i) != 'uhdmtopModules': continue
        m = re.match(r'^\s*\\_(struct_var|struct_net|packed_array_var|logic_var|logic_net): \(([^)]*)\)', l)
        if m: d[m.group(2)].add(m.group(1))
    return d
def count_in(L, secname, pat):
    sec = sections(L); r = re.compile(pat)
    return sum(1 for i, l in enumerate(L) if (secname is None or sec.get(i) == secname) and r.search(l))
def hp(L):
    n = 0
    for i, l in enumerate(L):
        if re.match(r'^\s*\\_part_select: ', l):
            for k in range(i + 1, min(i + 12, len(L))):
                m = re.match(r'^\s*\|vpiName:(.*)$', L[k])
                if m:
                    if '[' in m.group(1): n += 1
                    break
    return n
def tsm_expr(L):
    """set of (struct name, member name) whose typespec_member carries a vpiExpr"""
    out = set(); cur = None; sec = sections(L)
    for i, l in enumerate(L):
        m = re.match(r'^\s*\\_struct_typespec: \(([^)]*)\)', l)
        if m: cur = m.group(1)
        m = re.match(r'^(\s*)\\_typespec_member: \(([^)]*)\)', l)
        if m:
            ind = len(m.group(1))
            for k in range(i + 1, min(i + 60, len(L))):
                s2 = L[k]; si = len(s2) - len(s2.lstrip(' '))
                if si <= ind: break
                if si == ind + 2 and s2.strip() == '|vpiExpr:':
                    out.add((sec.get(i), cur, m.group(2))); break
    return out
G, O = load(sys.argv[1]), load(sys.argv[2])
res = {}
pg, po = ports_def(G), ports_def(O)
f4 = 0
for k, gv in pg.items():
    ov = po.get(k, [])
    for a, b in zip(gv, ov):
        if a == 'array_typespec' and b != 'array_typespec': f4 += 1
res['F4'] = f4
kg, ko = elab_kinds(G), elab_kinds(O)
res['F5'] = sum(1 for n, ks in ko.items() if 'struct_var' in (ks - kg.get(n, set())) and ((kg.get(n, set()) - ks) & {'struct_net', 'packed_array_var'}))
res['HP'] = hp(O) - hp(G)
res['F1'] = count_in(G, 'uhdmtopModules', r'\\_void_typespec') - count_in(O, 'uhdmtopModules', r'\\_void_typespec')
res['F2S'] = len(tsm_expr(O) - tsm_expr(G))
res['F2F'] = count_in(O, 'uhdmtopPackages', r'\\_tagged_pattern') - count_in(G, 'uhdmtopPackages', r'\\_tagged_pattern')
for k, v in res.items():
    if v: print(k, v)
