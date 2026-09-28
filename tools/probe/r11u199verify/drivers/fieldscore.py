#!/usr/bin/env python3
# (r11u199: copied from r11u194verify/drivers, paths renamed; the landings under test are passes 192 and 193.)
# (r11u194: copied from r11u190verify/drivers, paths renamed; the landings under test are passes 184 and 186.)
"""fieldscore.py <GW dir> [on_tag] : field-level scoring of every case under the grid scratch (written by grid.py /
case.sh).  For every state tag T != on_tag present beside on.uhdm (off_<law>, offL<n>, alloff, preoff, pre, ...):
per walk index, the set of fields where ours differs from golden (uhdm-strictcmp records: depth type name defname
fullname file line col endline endcol decompile size value consttype).  With both walks aligned (no 'walk diverged'):
  FTOWARD   every index: ON's differing fields are a subset of T's, and some index loses a field
  FNEUTRAL  the same field sets (values may differ: wrong on both)
  FAWAY     some index where ON differs on a field T matched golden on (a BREAK candidate; the field and both values
            are printed)
  FSAME     identical records
Diverged or stage-1 walks are left to grid.py's reading (printed DIVERGED / STAGE1).  Fail-closed on $FENCED."""
import os, re, sys, glob
if len(os.environ.get('FENCED', '').split()) != 4: sys.exit('fieldscore.py: source drivers/env.sh first')
F = ['depth', 'type', 'name', 'defname', 'fullname', 'file', 'line', 'col', 'endline', 'endcol', 'decompile', 'size', 'value', 'consttype']
def parse(p):
    if not os.path.exists(p): return None, 'NODB'
    L = open(p, errors='replace').read().splitlines()
    last = L[-1] if L else ''
    if not L or 'stage1' in last: return None, 'STAGE1'
    if any('diverged' in l for l in L): div = True
    else: div = False
    recs = {}
    for i, l in enumerate(L):
        m = re.match(r'#(\d+) (\w+)$', l)
        if m and i + 2 < len(L):
            a = L[i+1].split('A: ', 1)[-1].split('\t'); b = L[i+2].split('B: ', 1)[-1].split('\t')
            d = {}
            for k, f in enumerate(F):
                x = a[k] if k < len(a) else ''; y = b[k] if k < len(b) else ''
                if x != y: d[f] = (x, y)
            recs[int(m.group(1))] = d
    return recs, ('DIVERGED' if div else ('EQUAL' if last.startswith('STRICT_EQUAL') else 'ALIGNED'))
gw = sys.argv[1]; on = sys.argv[2] if len(sys.argv) > 2 else 'on'
for w in sorted(glob.glob(f'{gw}/**/{on}.strict', recursive=True)):
    d = os.path.dirname(w); rel = os.path.relpath(d, gw)
    ro, so = parse(w)
    for t in sorted(glob.glob(f'{d}/*.strict')):
        tag = os.path.basename(t)[:-7]
        if tag == on: continue
        rt, st = parse(t)
        if ro is None or rt is None or so == 'DIVERGED' or st == 'DIVERGED':
            v = f'{st}->{so}' if (so != st) else so
            print(rel, tag, 'SKIP', v); continue
        away = []; lost = 0; neutral = 0
        for i in set(ro) | set(rt):
            a = ro.get(i, {}); b = rt.get(i, {})
            for f in a:
                if f not in b: away.append((i, f, a[f]))
                elif a[f] != b[f]: neutral += 1
            lost += sum(1 for f in b if f not in a)
        v = 'FAWAY' if away else 'FTOWARD' if lost else 'FNEUTRAL' if neutral else 'FSAME'
        det = f'lost={lost} neutral={neutral}'
        if away: det += ' | ' + ' ; '.join(f'#{i} {f} gold={x!r} ours={y!r}' for i, f, (x, y) in away[:4])
        print(rel, tag, v, det)
