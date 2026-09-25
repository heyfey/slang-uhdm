#!/usr/bin/env python3
"""changecheck.py <pristine_wd> <law_wd> <sweep.log>: for every CHANGE line of the law sweep (probe
cases and corpus row-modes), run uhdm-strictcmp (--max 100000) on pristine's and the law's database
against the same golden and report NEW differing records (a record key = walk index + field + the two
record texts) that pristine did not have.  A clean change prints `subset`.  Fail-closed on $FENCED."""
import os, re, subprocess, sys, glob
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..', '..', 'scripts'))
import check_probe as cp
FENCED = set(os.environ.get('FENCED', '').split())
if len(FENCED) != 4: sys.exit('changecheck.py: export FENCED first')
SC = os.environ.get('STRICT_CMP', '/tmp/r11u152_bin/uhdm-strictcmp')
P, L, LOG = sys.argv[1:4]

def recs(g, o):
    r = subprocess.run([SC, '--max', '100000', g, o], capture_output=True, text=True, timeout=900).stdout
    out, cur = set(), None
    lines = r.splitlines()
    for i, l in enumerate(lines):
        m = re.match(r'#(\d+) (\w+)', l)
        if m and i + 2 < len(lines):
            out.add((m.group(2), lines[i+1].strip(), lines[i+2].strip()))
    return out, (lines[-1] if lines else '')

def corpus_paths(wd, corpus, mode, name):
    d = glob.glob(f'{wd}/{corpus}/{mode}/{name}-*')
    if not d: return None, None
    cmds = open(d[0] + '/cmds.txt').read()
    m = re.search(r'golden cache hit (\S+)\)', cmds)
    g = m.group(1) + '/golden.uhdm' if m else None
    return g, d[0] + '/slang.uhdm'

stage = None
for l in open(LOG):
    if l.startswith('== '):
        stage = 'probe' if 'probe' in l else ('surelog' if 'surelog' in l else ('uhdm2rtlil' if 'uhdm2rtlil' in l else stage))
    if not l.startswith('CHANGE'): continue
    parts = l.split()
    if stage == 'probe':
        rel = parts[1]
        g = os.path.join(cp.cache_dir(rel), 'golden.uhdm')
        po = f'{P}/probe/' + rel.replace('/', '__') + '.uhdm'
        lo = f'{L}/probe/' + rel.replace('/', '__') + '.uhdm'
        key = rel
    else:
        name, mode = parts[1], parts[2]
        if name in FENCED: print(name, 'FENCED-SKIPPED'); continue
        g, po = corpus_paths(P, stage, mode, name)
        _, lo = corpus_paths(L, stage, mode, name)
        key = f'{stage}/{mode}/{name}'
    if not (g and os.path.exists(g) and po and lo):
        print(key, 'MISSING'); continue
    a, la = recs(g, po); b, lb = recs(g, lo)
    new = b - a
    print(key, 'subset' if not new else f'NEW {len(new)}', f'| pris: {la} | law: {lb}')
    for n in sorted(new)[:3]: print('   ', n)
