#!/usr/bin/env python3
"""v11u224: chain-keyed away census of case-views (map 13's key, the variant comparator's records with the RAW full
name, as r11u224repro/drivers/awayrows.py): caseaway.py <case-view dir under $S/g> [tagA=P] [tagB=L] [v]
away = golden-agreeing records A had and B lost (chain-keyed / flat); toward = the reverse.  Plus the multiset
uhdm-dump census (weaklyReferenced tail cut).  Case goldens only (never a corpus database); fail-closed on $FENCED."""
import os, re, sys, glob, subprocess, collections
F = os.environ.get('FENCED', '').split()
if len(F) != 4: sys.exit('caseaway.py: source drivers/env.sh first')
SC = os.path.join(os.environ['B'], 'strictcmp_x'); DUMP = os.environ['UHDM_DUMP']
d = sys.argv[1]; a = sys.argv[2] if len(sys.argv) > 2 else 'P'; b = sys.argv[3] if len(sys.argv) > 3 else 'L'
if any(re.search(rf'(?<![A-Za-z0-9_]){re.escape(f)}(?![A-Za-z0-9_])', d) for f in F): sys.exit('fenced refused')
g = glob.glob(f'{d}/gold_*/golden.uhdm')[0]
def keyed(u, tag):
    t = f'{d}/.{tag}.xrec'
    subprocess.run([SC, '--max', '0', '--dump-a', t, '--dump-b', '/dev/null', u, u], capture_output=True, timeout=3600)
    ck = collections.Counter(); fl = collections.Counter(); st = []
    for l in open(t, errors='replace'):
        f = l.rstrip('\n').split('\t')
        if len(f) < 15 or not f[0].isdigit(): continue
        raw = f[14].split('\x1f')[0]; f = f[:14]; f[4] = raw
        dd = int(f[0]); st = st[:dd]; rec = '|'.join(f[1:])
        ck[(' < '.join(reversed(st)), rec)] += 1; fl[rec] += 1; st.append(f'{f[1]}:{f[2]}')
    return ck, fl
def dump(u):
    out = subprocess.run([DUMP, u], capture_output=True, text=True, errors='replace').stdout.splitlines()[1:]
    r = []
    for l in out:
        if l.rstrip().endswith('weaklyReferenced:'): break
        r.append(re.sub(r'file:[^,]*/', 'file:', re.sub(r'id:[0-9]*', '', l)))
    return collections.Counter(r)
(G, Gf), (A, Af), (B, Bf) = keyed(g, 'g'), keyed(f'{d}/{a}.uhdm', a), keyed(f'{d}/{b}.uhdm', b)
away = (A & G) - B; tow = (B & G) - A; fa = (Af & Gf) - Bf; ft = (Bf & Gf) - Af
DG, DA, DB = dump(g), dump(f'{d}/{a}.uhdm'), dump(f'{d}/{b}.uhdm')
tw = aw = 0
for k in set(DA) | set(DB):
    if DA[k] == DB[k]: continue
    x = min(DA[k], DG[k]); y = min(DB[k], DG[k])
    if y > x: tw += y - x
    elif x > y: aw += x - y
print(f'{d.split("/g/")[-1]} chain_away={sum(away.values())} chain_toward={sum(tow.values())} flat_away={sum(fa.values())} flat_toward={sum(ft.values())} dump_away={aw} dump_toward={tw}')
if len(sys.argv) > 4:
    for k, v in away.items(): print('  AWAY', v, k)
    for k, v in fa.items(): print('  FLATAWAY', v, k)
