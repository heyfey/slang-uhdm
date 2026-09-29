#!/usr/bin/env python3
"""r11u233: gridsum233.py <evidence dir>: the per-case-view summary of the fresh grid: from grid/raw/grid_<F>.txt
(drivers/grid.py output), grid/away_<F>.txt (drivers/caseaway.py: every state against HEAD), fix/fixrun_fix.txt and
grid/away_pris_fix.txt / away_law_fix.txt (drivers/fixrun.sh + awaypair.py).  One markdown table per family: the laws
fired (HEAD, R11U227_TRACE / R11U228_TRACE), exit codes of HEAD / pristine (both landings off) / fix, the judge status
(uhdm-cmp lines, strict verdict) of HEAD and pristine, the chain-keyed record census pristine -> HEAD and pristine -> fix
and HEAD -> fix (lost/toward), and the verdict: BREAK (HEAD lost golden records pristine had), TOWARD, UNFIRED (HEAD =
pristine bytes), BYTES (bytes move, no record moves), CRASH (rc 134/139 at HEAD where pristine exits 0), NOGOLD."""
import os, re, sys, collections
E = sys.argv[1]
def aw(path):
    d = {}
    if not os.path.exists(path): return d
    for l in open(path):
        m = re.match(r'(\S+) (\S+) chain_lost=(\d+) chain_toward=(\d+)', l)
        if m: d[(m.group(1).split('/r11u233_g/')[-1], m.group(2))] = (int(m.group(3)), int(m.group(4)))
    return d
fixrc = {}
for f in ('fix/fixrun_fix.txt',):
    for l in open(os.path.join(E, f)):
        p = l.split()
        if len(p) >= 2:
            m = re.search(r'rc=(\d+)', l); fixrc[p[0]] = (m.group(1) if m else '?', 'SURELOG_FAIL' in l)
pf = aw(os.path.join(E, 'grid/away_pris_fix.txt')); lf = aw(os.path.join(E, 'grid/away_law_fix.txt'))
tot = collections.Counter()
for fam in 'MJSBFPNX':
    raw = os.path.join(E, f'grid/raw/grid_{fam}.txt')
    if not os.path.exists(raw): continue
    st = collections.defaultdict(dict); fired = {}
    for l in open(raw):
        if l.startswith('FIRED '):
            p = l.split(None, 2); fired[p[1]] = p[2].strip() if len(p) > 2 else '-'
        m = re.match(r'  (\S+) (\S+) (.*)', l)
        if m:
            rel, tag, rest = m.groups()
            rc = re.search(r'rc=(\d+)', rest); cl = re.search(r'cmplines=(\d+)', rest); s = re.search(r'strict=(\S+)', rest); md = re.search(r'md5=(\w+)', rest)
            st[rel][tag] = (rc.group(1) if rc else '?', cl.group(1) if cl else '-', s.group(1) if s else rest.split()[0], md.group(1) if md else '-')
    away = aw(os.path.join(E, f'grid/away_{fam}.txt'))
    print(f'\n### family {fam}\n')
    print('| case-view | fired at HEAD | rc HEAD / pristine / fix | HEAD (cmp lines, strict) | pristine (cmp lines, strict) | pristine->HEAD lost/toward | pristine->fix lost/toward | HEAD->fix lost/toward | verdict |')
    print('|---|---|---|---|---|---|---|---|---|')
    for rel in sorted(st):
        on = st[rel].get('on'); off = st[rel].get('alloff')
        if not on or not off: continue
        frc = fixrc.get(rel, ('-', False))[0]
        a = away.get((rel, 'alloff'), (0, 0)); b = pf.get((rel, 'alloff->fix'), (0, 0)); c = lf.get((rel, 'on->fix'), (0, 0))
        if on[2] == 'SURELOG_FAIL': v = 'NOGOLD'
        elif on[0] in ('134', '139') and off[0] == '0': v = 'CRASH'
        elif on[3] == off[3]: v = 'UNFIRED'
        elif a[0] > 0: v = 'BREAK' if a[1] == 0 else 'BREAK(mixed)'
        elif a[1] > 0: v = 'TOWARD'
        else: v = 'BYTES'
        fv = ''
        if v.startswith('BREAK'): fv = ' -> fix: ' + ('pristine bytes' if b == (0, 0) and c[1] >= a[0] else f'{b[0]}/{b[1]} vs pristine')
        tot[(fam, v)] += 1; tot[v] += 1
        print(f'| {rel} | {fired.get(rel, "-")} | {on[0]} / {off[0]} / {frc} | {on[1]}, {on[2]} | {off[1]}, {off[2]} | {a[0]}/{a[1]} | {b[0]}/{b[1]} | {c[0]}/{c[1]} | {v}{fv} |')
print('\n#### totals\n')
for k, v in sorted(tot.items(), key=str): print(f'* {k}: {v}')
