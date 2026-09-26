#!/usr/bin/env python3
"""fieldrows.py <off_wd> <on_wd> [stage...]: the field-level reading of every row / probe case whose DATABASE BYTES
differ between two gate sweeps (fenced corpus rows skipped unread by word boundary; fail-closed on $FENCED).
uhdm-strictcmp --max 100000 on golden vs each database; per walk index the set of fields ours differs from golden on.
Only the ALIGNED prefix is compared: indices below both walks' divergence (the last record of a diverged walk).
  FTOWARD  on's differing fields are a subset of off's at every index, some field lost
  FNEUTRAL same field sets (values moved, wrong on both)
  FAWAY    an index where on differs on a field off matched golden on (printed: index, field, golden, off, on)
  FSAME    identical records in the prefix
plus the count of on's records past off's divergence (UNMASKED) and off's past on's (MASKED)."""
import csv, os, re, subprocess, sys, glob, hashlib
FENCED = os.environ.get('FENCED', '').split()
if len(FENCED) != 4: sys.exit('fieldrows.py: source drivers/env.sh first')
sys.path.insert(0, '/tmp/wt_r11u177/scripts'); import check_probe as cp
SC = os.environ['STRICT_CMP']; OFF, ON = sys.argv[1:3]; stages = sys.argv[3:] or ['probe', 'surelog', 'uhdm2rtlil']
F = ['depth', 'type', 'name', 'defname', 'fullname', 'file', 'line', 'col', 'endline', 'endcol', 'decompile', 'size', 'value', 'consttype']
def fenced(n): return any(re.search(rf'\b{re.escape(f)}\b', n) for f in FENCED)
def md5(p): return hashlib.md5(open(p, 'rb').read()).hexdigest() if os.path.exists(p) else None
def recs(g, o):
    r = subprocess.run([SC, '--max', '100000', g, o], capture_output=True, text=True, errors='replace', timeout=3600).stdout
    L = r.splitlines(); out = {}; last = L[-1] if L else ''
    if 'stage1' in last: return None, None, 'STAGE1'
    for i, l in enumerate(L):
        m = re.match(r'#(\d+) (\w+)$', l)
        if m and i + 2 < len(L):
            a = L[i+1].split('A: ', 1)[-1].split('\t'); b = L[i+2].split('B: ', 1)[-1].split('\t')
            d = {}
            for k, f in enumerate(F):
                x = a[k] if k < len(a) else ''; y = b[k] if k < len(b) else ''
                if x != y: d[f] = (x, y)
            out[int(m.group(1))] = d
    div = max(out) if (out and 'diverged' in r) else None
    return out, div, last
def gold_of(wd, st, mode, name):
    d = glob.glob(f'{wd}/{st}/{mode}/{name}-*')
    if not d: return None, None
    cm = open(d[0] + '/cmds.txt').read()
    m = re.search(r'golden cache hit (\S+)\)', cm) or re.search(r'(/\S*slang-uhdm-goldens/[0-9a-f]+)', cm)
    return ((m.group(1) + '/golden.uhdm') if m else None), d[0] + '/slang.uhdm'
for st in stages:
    items = []
    if st == 'probe':
        for p in sorted(glob.glob(f'{ON}/probe/*.uhdm')):
            k = os.path.basename(p); q = f'{OFF}/probe/{k}'
            if md5(p) != md5(q):
                rel = k[:-5].replace('__', '/'); items.append((rel, os.path.join(cp.cache_dir(rel), 'golden.uhdm'), q, p))
    else:
        for p in sorted(glob.glob(f'{ON}/{st}/*/*/slang.uhdm')):
            rel = os.path.relpath(p, ON); mode, dn = rel.split('/')[1:3]; name = dn.rsplit('-', 1)[0]
            if fenced(name): continue
            g, _ = gold_of(ON, st, mode, name); q = f'{OFF}/{rel}'
            if md5(p) != md5(q): items.append((f'{st}/{mode}/{name}', g, q, p))
    tally = {}
    for name, g, q, p in items:
        if not (g and os.path.exists(g) and os.path.exists(q)): print(name, 'MISSING'); continue
        ro, do, lo = recs(g, q); rn, dn, ln = recs(g, p)
        if ro is None or rn is None: v = 'STAGE1' if (ro is None and rn is None) else 'STAGE1-CHANGE'; print(name, v, lo, '->', ln, flush=True); tally[v] = tally.get(v, 0) + 1; continue
        lim = min(x for x in (do, dn, 10**12) if x is not None)
        away = []; lost = neutral = 0
        for i in set(ro) | set(rn):
            if i >= lim: continue
            a = rn.get(i, {}); b = ro.get(i, {})
            for f in a:
                if f not in b: away.append((i, f, a[f][0], a[f][1]))
                elif a[f] != b[f]: neutral += 1
            lost += sum(1 for f in b if f not in a)
        unm = sum(1 for i in rn if do is not None and i >= do and (dn is None or i <= dn))
        v = 'FAWAY' if away else 'FTOWARD' if lost else 'FNEUTRAL' if neutral else 'FSAME'
        tally[v] = tally.get(v, 0) + 1
        det = f'lost={lost} neutral={neutral} offdiv={do} ondiv={dn} unmasked={unm} | {lo} -> {ln}'
        if away: det += ' | ' + ' ; '.join(f'#{i} {f} gold={x!r} on={y!r} off={ro.get(i, {}).get(f, ("", "(=gold)"))[1]!r}' for i, f, x, y in away[:5])
        print(name, v, det, flush=True)
    print(f'-- {st} tally: ' + ' '.join(f'{k}={v}' for k, v in sorted(tally.items())), flush=True)
