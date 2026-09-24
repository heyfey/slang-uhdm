#!/usr/bin/env python3
# objcheck.py <corpus> : per-object improved/worsened fields golden vs P vs L on byte-moved CMP_EQUAL rows
import csv, sys, os, subprocess, difflib, glob, filecmp, collections
corpus = sys.argv[1]
SC = '/tmp/v11u125_bin/uhdm-strictcmp'
F = 'depth type name defname fullname file line col endline endcol decompile size value consttype'.split()
out = f'/tmp/v11u125_objcheck/{corpus}'; os.makedirs(out, exist_ok=True)
def golden_of(d):
    for l in open(os.path.join(d, 'cmds.txt')):
        if 'golden cache hit' in l: return l.split('hit ')[1].strip(' )\n') + '/golden.uhdm'
    return None
rows = {(r['name'], r['mode']): r for r in csv.DictReader(open(f'/tmp/v11u125_wdL/{corpus}.csv', newline=''))}
tot = collections.Counter(); worse_rows = []
for dL in sorted(glob.glob(f'/tmp/v11u125_wdL/{corpus}/*/*')):
    mode, base = dL.split('/')[-2], dL.split('/')[-1]
    dP = dL.replace('_wdL', '_wdP')
    a, b = os.path.join(dP, 'slang.uhdm'), os.path.join(dL, 'slang.uhdm')
    if not (os.path.exists(a) and os.path.exists(b)) or filecmp.cmp(a, b, shallow=False): continue
    g = golden_of(dL)
    if not g or not os.path.exists(g): tot['nogolden'] += 1; continue
    if not os.path.exists(g): continue
    tag = f'{out}/{mode}_{base}'
    recs = {}
    ok = True
    for t, u in (('P', a), ('L', b)):
        subprocess.run([SC, '--max', '0', '--dump-a', tag + '.g', '--dump-b', tag + '.' + t, g, u], capture_output=True)
        if not os.path.exists(tag + '.' + t): ok = False
    if not ok: tot['nodump'] += 1; print('NODUMP', mode, base); continue
    R = lambda p: [l.rstrip('\n').split('\t') for l in open(p)]
    G, P, L = R(tag + '.g'), R(tag + '.P'), R(tag + '.L')
    key = lambda r: '\t'.join(r[:4])
    def pair(O):
        m = {}
        kg, ko = [key(r) for r in G], [key(r) for r in O]
        if kg == ko:
            return {i: O[i] for i in range(len(G))}
        # GNU diff over the key lines, unchanged lines are pairs
        open(tag + '.kg', 'w').write('\n'.join(kg) + '\n'); open(tag + '.ko', 'w').write('\n'.join(ko) + '\n')
        r = subprocess.run(['diff', '--unchanged-line-format=U\n', '--old-line-format=O\n', '--new-line-format=N\n', tag + '.kg', tag + '.ko'], capture_output=True, text=True)
        i = j = 0
        for l in r.stdout.splitlines():
            if l == 'U': m[i] = O[j]; i += 1; j += 1
            elif l == 'O': i += 1
            elif l == 'N': j += 1
        return m
    mp, ml = pair(P), pair(L)
    c = collections.Counter()
    for i, gr in enumerate(G):
        p, l = mp.get(i), ml.get(i)
        if p is None or l is None:
            if (p is None) != (l is None): c['pairing_changed'] += 1
            continue
        for j, f in enumerate(F):
            gv = gr[j] if j < len(gr) else ''; pv = p[j] if j < len(p) else ''; lv = l[j] if j < len(l) else ''
            if pv == lv: continue
            if lv == gv: c['improved'] += 1
            elif pv == gv: c['WORSENED'] += 1; c['W:' + f] += 1
            else: c['neutral'] += 1
    c['unpairedP'] = len(G) + len(P) - 2 * len(mp); c['unpairedL'] = len(G) + len(L) - 2 * len(ml)
    tot['rows'] += 1
    for k, v in c.items():
        if not k.startswith('unpaired'): tot[k] += v
    if c['WORSENED'] or c['unpairedL'] > c['unpairedP'] or c['pairing_changed']:
        worse_rows.append((mode, base, dict(c)))
print(corpus, dict(tot))
for w in worse_rows: print('FLAG', w)
