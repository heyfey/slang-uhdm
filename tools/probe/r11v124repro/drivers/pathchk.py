#!/usr/bin/env python3
"""pathchk.py G P L : key every walk record by its ancestor chain (type,name per level) plus an occurrence
index among same-keyed siblings; compare P and L to G per key. AWAY = P==G and L!=G (key in all three).
Also field-level: BOTHWRONG with fewer golden-matching fields in L = FWORSE. And keys present in P&G but missing in L."""
import subprocess, sys, tempfile, os, collections
G, P, L = sys.argv[1:4]
sc = '/tmp/v11u124_bin/strictcmp'
def dump(a, b):
    d = tempfile.mkdtemp(prefix='v11u124_pk'); fa, fb = d+'/a', d+'/b'
    subprocess.run([sc, '--max', '0', '--dump-a', fa, '--dump-b', fb, a, b], capture_output=True, text=True)
    if not os.path.exists(fa):
        subprocess.run(['rm','-rf',d]); return None, None
    A = join(open(fa, errors='replace').read().splitlines()); B = join(open(fb, errors='replace').read().splitlines()); subprocess.run(['rm','-rf',d]); return A, B
import re
def join(lines):
    out = []
    for x in lines:
        if re.match(r'^\d+\t', x) or not out: out.append(x)
        else: out[-1] += '\n' + x
    return out
def keyed(recs):
    out = {}; stack = []; occ = collections.Counter()
    for r in recs:
        f = r.split('\t'); d = int(f[0]); tn = (f[1], f[2])
        stack = stack[:d]; parent = tuple(stack)
        k0 = parent + (tn,); occ[k0] += 1
        k = k0 + (occ[k0],)
        out[k] = r; stack.append((tn, occ[k0]))
    return out
g, p = dump(G, P)
if g is None: print('STAGE1'); sys.exit(0)
_, l = dump(G, L)
kg, kp, kl = keyed(g), keyed(p), keyed(l)
c = collections.Counter(); ex = collections.defaultdict(list)
for k, gr in kg.items():
    pr, lr = kp.get(k), kl.get(k)
    if pr == lr: continue
    if pr is None or lr is None:
        c['PRESENCE-' + ('LOST' if lr is None else 'GAINED')] += 1; ex['PRESENCE'].append((gr, pr, lr)); continue
    pe, le = pr == gr, lr == gr
    if le: c['TOWARD'] += 1
    elif pe: c['AWAY'] += 1; ex['AWAY'].append((gr, pr, lr))
    else:
        gf, pf, lf = gr.split('\t'), pr.split('\t'), lr.split('\t')
        sp = sum(a == b for a, b in zip(gf, pf)); sl = sum(a == b for a, b in zip(gf, lf))
        cl = 'FWORSE' if sl < sp else 'FBETTER' if sl > sp else 'FSAME'
        c[cl] += 1; ex[cl].append((gr, pr, lr))
print(dict(c))
for cl in ('AWAY', 'FWORSE', 'FSAME', 'PRESENCE'):
    for gr, pr, lr in ex[cl][:4]:
        print(f'  {cl} G:', gr.replace('\t','|')); print('        P:', (pr or '-').replace('\t','|')); print('        L:', (lr or '-').replace('\t','|'))
