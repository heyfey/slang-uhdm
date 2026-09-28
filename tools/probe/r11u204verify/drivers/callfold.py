#!/usr/bin/env python3
"""callfold.py <GW case dir>...: the fold judge for the kept-call laws.  Per database of the case dir (golden, on, every
off state), every cont_assign of the strict walk keyed by (line:col, occurrence) with its right side read as KEEP (a
func_call child) or FOLD (a constant child, with its value).  Prints per state the calls where the state and golden
disagree on keep/fold; per state against ON: AWAY (off agrees with golden on keep/fold, on does not) / TOWARD.
Fail-closed on $FENCED."""
import os, re, sys, glob, subprocess, collections
if len(os.environ.get('FENCED', '').split()) != 4: sys.exit('callfold.py: source drivers/env.sh first')
SC = os.environ['STRICT_CMP']
def calls(u):
    t = f'/tmp/r11u204_cf_{os.getpid()}.rec'
    subprocess.run([SC, '--max', '0', '--dump-a', t, '--dump-b', '/dev/null', u, u], capture_output=True)
    R = [l.rstrip('\n').split('\t') for l in open(t, errors='replace') if l[:1].isdigit()]
    os.remove(t)
    out = {}; seen = collections.Counter()
    for i, r in enumerate(R):
        if r[1] != 'cont_assign': continue
        d = int(r[0]); k = None
        for s in R[i+1:]:
            if int(s[0]) <= d: break
            if int(s[0]) == d + 1 and s[1] in ('func_call', 'constant'):
                k = 'KEEP:' + s[2] if s[1] == 'func_call' else 'FOLD'
                break
        if k is None: continue
        key = f'{r[6]}:{r[7]}'; seen[key] += 1
        out[f'{key}#{seen[key]}'] = k
    return out
for d in sys.argv[1:]:
    if any(re.search(rf'\b{re.escape(n)}\b', d) for n in os.environ['FENCED'].split()): continue
    g = glob.glob(f'{d}/gold_*/golden.uhdm')
    if not g or not os.path.exists(f'{d}/on.uhdm'): continue
    G = calls(g[0]); O = calls(f'{d}/on.uhdm')
    rel = d.split('/r11u204_g/')[-1]
    bad = [k for k in G if k in O and G[k].split(':')[0] != O[k].split(':')[0]]
    print(f'{rel} on: calls={len(G)} disagree={len(bad)} ' + ' '.join(f'{k}(g={G[k]},o={O[k]})' for k in bad))
    for f in sorted(glob.glob(f'{d}/*.uhdm')):
        tag = os.path.basename(f)[:-5]
        if tag in ('on', 'tr'): continue
        T = calls(f)
        away = [k for k in G if k in O and k in T and T[k].split(':')[0] == G[k].split(':')[0] != O[k].split(':')[0]]
        tow = [k for k in G if k in O and k in T and O[k].split(':')[0] == G[k].split(':')[0] != T[k].split(':')[0]]
        if away or tow: print(f'   {tag}: AWAY={len(away)} {" ".join(away)} TOWARD={len(tow)} {" ".join(tow)}')
