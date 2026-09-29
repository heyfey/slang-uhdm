#!/usr/bin/env python3
# (r11u213: copied from r11u208verify/drivers, paths renamed; the landings under test are passes 206 and 207.)
# (r11u208) unmask2.py <off_wd> <on_wd> [stage...]: unmask.py with the walk INDEX kept.  Every row / probe case whose
# strict verdict differs between two gate sweeps (a landing off vs on) is re-read record by record (uhdm-strictcmp
# --max 100000 on golden vs each database; a record = (index, field, golden text, ours text)):
#   CONVERSION  on reads STRICT_EQUAL
#   SUBSET      every record of on is one off had (field, golden, ours; index ignored): a strict improvement
#   UNMASK      off's walk diverged at index D; every record of on BEFORE D is one off had, and every record of on that off
#               lacks sits at or past D (the new records are the faces the removed divergence had hidden)
#   NEW         any other move (inspect).
# Prints the first record of each side.  Fail-closed on $FENCED: a fenced row is named FENCED_n and never read.
import csv, os, re, subprocess, sys, glob, collections
FENCED = os.environ.get('FENCED', '').split()
if len(FENCED) != 4: sys.exit('unmask2.py: source drivers/env.sh first')
sys.path.insert(0, os.environ['R221_ROOT'] + '/scripts')
import check_probe as cp
SC = os.environ['STRICT_CMP']
OFF, ON = sys.argv[1:3]
stages = sys.argv[3:] or ['probe', 'surelog', 'uhdm2rtlil']
def recs(g, o):
    r = subprocess.run([SC, '--max', '100000', g, o], capture_output=True, text=True, timeout=3600, errors='replace').stdout
    L = r.splitlines(); out = []
    for i, l in enumerate(L):
        m = re.match(r'#(\d+) (\w+)$', l)
        if m and i + 2 < len(L): out.append((int(m.group(1)), m.group(2), L[i+1].strip()[3:], L[i+2].strip()[3:]))
    last = L[-1] if L else ''
    div = out[-1][0] if ('walk diverged' in r and out) else None
    return out, last, div
def corpus_paths(wd, corpus, mode, name):
    d = glob.glob(f'{wd}/{corpus}/{mode}/{name}-*')
    if not d: return None, None
    cmds = open(d[0] + '/cmds.txt').read()
    m = re.search(r'golden cache hit (\S+)\)', cmds) or re.search(r'(/\S*slang-uhdm-goldens/[0-9a-f]+)', cmds)
    return ((m.group(1) + '/golden.uhdm') if m else None), d[0] + '/slang.uhdm'
def load(p, key): return {key(r): r for r in csv.DictReader(open(p))}
def fmt(r): return f'#{r[0]} {r[1]} golden[{r[2][:90]}] ours[{r[3][:90]}]'.replace('\t', ' ')
for st in stages:
    if st == 'probe':
        A = load(f'{OFF}/probe.csv', lambda r: r['case']); B = load(f'{ON}/probe.csv', lambda r: r['case'])
    else:
        A = load(f'{OFF}/{st}.csv', lambda r: (r['name'], r['mode'])); B = load(f'{ON}/{st}.csv', lambda r: (r['name'], r['mode']))
    keys = sorted(k for k in set(A) | set(B) if (A.get(k, {}).get('status'), A.get(k, {}).get('strict')) != (B.get(k, {}).get('status'), B.get(k, {}).get('strict')))
    tally = collections.Counter(); print(f'== {st}: {len(keys)} rows differ', flush=True)
    for k in keys:
        a, b = A.get(k, {}), B.get(k, {})
        if st == 'probe':
            name = k; g = os.path.join(cp.cache_dir(k), 'golden.uhdm')
            po = f'{OFF}/probe/' + k.replace('/', '__') + '.uhdm'; lo = f'{ON}/probe/' + k.replace('/', '__') + '.uhdm'
        else:
            name = f'{st}/{k[1]}/{k[0]}'
            if any(re.search(rf"\b{re.escape(f)}\b", k[0]) for f in FENCED):
                print(f'FENCED_ROW {k[1]} not read'); tally['FENCED'] += 1; continue
            g, po = corpus_paths(OFF, st, k[1], k[0]); _, lo = corpus_paths(ON, st, k[1], k[0])
        vo = f'{a.get("status")} {a.get("strict")}'; vn = f'{b.get("status")} {b.get("strict")}'
        if not (g and os.path.exists(g) and po and os.path.exists(po) and lo and os.path.exists(lo)):
            print(f'{name} MISSING | {vo} -> {vn}'); tally['MISSING'] += 1; continue
        ra, la, da = recs(g, po); rb, lb, db = recs(g, lo)
        ma = collections.Counter(r[1:] for r in ra); mb = collections.Counter(r[1:] for r in rb)
        new = mb - ma
        if lb.startswith('STRICT_EQUAL'): v = 'CONVERSION'
        elif not new: v = 'SUBSET'
        elif da is not None:
            # the unmatched instances of on, consuming off's multiset in walk order
            pool = collections.Counter(ma); newidx = []
            for r in rb:
                if pool[r[1:]] > 0: pool[r[1:]] -= 1
                else: newidx.append(r[0])
            v = 'UNMASK' if min(newidx) >= da else 'NEW'
        else: v = 'NEW'
        tally[v] += 1
        same_first = bool(ra and rb and ra[0] == rb[0])
        print(f'{name} {v} | {vo} -> {vn} | off {len(ra)} rec{" div@%d" % da if da is not None else ""} on {len(rb)} rec{" div@%d" % db if db is not None else ""} | new={sum(new.values())} gone={sum((ma - mb).values())} first-record-same={same_first}', flush=True)
        if ra: print('    off first: ' + fmt(ra[0]))
        if rb and not same_first: print('    on  first: ' + fmt(rb[0]))
    print(f'   tally {st}: ' + ' '.join(f'{t}={c}' for t, c in sorted(tally.items())), flush=True)
