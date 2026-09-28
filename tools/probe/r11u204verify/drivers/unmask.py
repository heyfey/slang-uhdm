#!/usr/bin/env python3
# (r11u204: copied from r11u199verify/drivers, paths renamed; the landings under test are passes 196 and 198.)
# (r11u199: copied from r11u194verify/drivers, paths renamed; the landings under test are passes 192 and 193.)
# (r11u194: copied from r11u190verify/drivers, paths renamed; the landings under test are passes 184 and 186.)
# r11u177: copied from tools/probe/r11u173verify/drivers/unmask.py (paths changed).
"""unmask.py <off_wd> <on_wd> [stage...]: every row / probe case whose strict verdict differs between two
gate sweeps (the landings switched off vs on) is re-read record by record: uhdm-strictcmp --max 100000 on
golden vs the off database and golden vs the on database; a record = (field, golden text, ours text).
  CONVERSION  on reads STRICT_EQUAL
  SUBSET      every differing record of on is one off had (a strict improvement)
  UNMASK      off's walk diverged (or stage 1) and on's is aligned: on's records are the unmasked faces
  NEW         on is aligned, off aligned, and on has records off had not  (inspect)
  WORSE       any other move (inspect)
Fail-closed on $FENCED: a fenced row is named FENCED_n and never read."""
import csv, os, re, subprocess, sys, glob, collections
FENCED = os.environ.get('FENCED', '').split()
if len(FENCED) != 4: sys.exit('unmask.py: source drivers/env.sh first')
sys.path.insert(0, os.environ['R204_ROOT'] + '/scripts')
import check_probe as cp
SC = os.environ['STRICT_CMP']
OFF, ON = sys.argv[1:3]
stages = sys.argv[3:] or ['probe', 'surelog', 'uhdm2rtlil']

def recs(g, o):
    try:
        r = subprocess.run([SC, '--max', '100000', g, o], capture_output=True, text=True, timeout=1800, errors='replace').stdout
    except subprocess.TimeoutExpired:
        return None, 'timeout', False
    L = r.splitlines(); out = collections.Counter()
    for i, l in enumerate(L):
        m = re.match(r'#(\d+) (\w+)$', l)
        if m and i + 2 < len(L): out[(m.group(2), L[i+1].strip(), L[i+2].strip())] += 1
    last = L[-1] if L else ''
    div = 'walk diverged' in r or 'stage1' in last
    return out, last, div

def corpus_paths(wd, corpus, mode, name):
    d = glob.glob(f'{wd}/{corpus}/{mode}/{name}-*')
    if not d: return None, None
    cmds = open(d[0] + '/cmds.txt').read()
    m = re.search(r'golden cache hit (\S+)\)', cmds) or re.search(r'(/\S*slang-uhdm-goldens/[0-9a-f]+)', cmds)
    g = (m.group(1) + '/golden.uhdm') if m else None
    return g, d[0] + '/slang.uhdm'

def load(p, key):
    return {key(r): r for r in csv.DictReader(open(p))}

for st in stages:
    if st == 'probe':
        A = load(f'{OFF}/probe.csv', lambda r: r['case']); B = load(f'{ON}/probe.csv', lambda r: r['case'])
    else:
        A = load(f'{OFF}/{st}.csv', lambda r: (r['name'], r['mode'])); B = load(f'{ON}/{st}.csv', lambda r: (r['name'], r['mode']))
    keys = sorted(k for k in set(A) | set(B) if (A.get(k, {}).get('status'), A.get(k, {}).get('strict')) != (B.get(k, {}).get('status'), B.get(k, {}).get('strict')))
    tally = collections.Counter()
    print(f'== {st}: {len(keys)} rows differ')
    for k in keys:
        a, b = A.get(k, {}), B.get(k, {})
        if st == 'probe':
            rel = k; g = os.path.join(cp.cache_dir(rel), 'golden.uhdm')
            po = f'{OFF}/probe/' + rel.replace('/', '__') + '.uhdm'; lo = f'{ON}/probe/' + rel.replace('/', '__') + '.uhdm'
            name = rel
        else:
            name = f'{st}/{k[1]}/{k[0]}'
            if any(re.search(rf"\b{re.escape(f)}\b", k[0]) for f in FENCED):
                print(f'FENCED_ROW {k[1]} | off {a.get("status")} {a.get("strict")} -> on {b.get("status")} {b.get("strict")} | not read')
                tally['FENCED'] += 1; continue
            g, po = corpus_paths(OFF, st, k[1], k[0]); _, lo = corpus_paths(ON, st, k[1], k[0])
        vo = f'{a.get("status")} {a.get("strict")}'; vn = f'{b.get("status")} {b.get("strict")}'
        if not (g and os.path.exists(g) and po and os.path.exists(po) and lo and os.path.exists(lo)):
            print(f'{name} MISSING | {vo} -> {vn}'); tally['MISSING'] += 1; continue
        ra, la, da = recs(g, po); rb, lb, db = recs(g, lo)
        if rb is None or ra is None: v = 'TIMEOUT'
        elif lb.startswith('STRICT_EQUAL'): v = 'CONVERSION'
        elif not (rb - ra): v = 'SUBSET'
        elif da and not db: v = 'UNMASK'
        elif not da and not db: v = 'NEW'
        else: v = 'WORSE' if not (da and db) else 'BOTH-DIVERGED'
        tally[v] += 1
        extra = ''
        if v in ('NEW', 'WORSE', 'BOTH-DIVERGED'):
            new = rb - ra
            extra = f' new={sum(new.values())} first: ' + ' / '.join(sorted(new)[0])[:300]
        print(f'{name} {v} | {vo} -> {vn} | off {sum(ra.values())} rec{" (diverged)" if da else ""} on {sum(rb.values())} rec{" (diverged)" if db else ""}{extra}', flush=True)
    print(f'-- {st} tally: ' + ' '.join(f'{k}={v}' for k, v in sorted(tally.items())))
