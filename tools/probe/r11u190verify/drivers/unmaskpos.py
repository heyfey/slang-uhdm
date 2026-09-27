#!/usr/bin/env python3
# (r11u190: copied from r11u185verify/drivers, paths renamed; the landings under test are passes 180 and 181.)
"""(r11u185: copied from r11u177verify) unmaskpos.py <off_wd> <on_wd> <probe case>...: for an UNMASK probe case (unmask.py), the walk index where the off
database's strict walk diverged and the walk index of every record the on database has that off had not: an
unmasking puts every new record at or past off's divergence (the objects were behind it); a record before it would be
a new difference on an aligned stretch.  Probe cases only (no corpus row is read)."""
import os, re, sys, subprocess, collections
if len(os.environ.get('FENCED', '').split()) != 4: sys.exit('unmaskpos.py: source drivers/env.sh first')
sys.path.insert(0, '/tmp/wt_r11u190/scripts'); import check_probe as cp
SC = os.environ['STRICT_CMP']; OFF, ON = sys.argv[1:3]
def recs(g, o):
    r = subprocess.run([SC, '--max', '100000', g, o], capture_output=True, text=True, errors='replace').stdout
    L = r.splitlines(); out = []
    for i, l in enumerate(L):
        m = re.match(r'#(\d+) (\w+)$', l)
        if m and i + 2 < len(L): out.append((int(m.group(1)), m.group(2), L[i+1].strip(), L[i+2].strip()))
    div = [l for l in L if 'diverged' in l]
    return out, (div[0] if div else '')
for rel in sys.argv[3:]:
    g = os.path.join(cp.cache_dir(rel), 'golden.uhdm'); k = rel.replace('/', '__') + '.uhdm'
    a, da = recs(g, f'{OFF}/probe/{k}'); b, db = recs(g, f'{ON}/probe/{k}')
    sa = collections.Counter((f, x, y) for _, f, x, y in a)
    new = [(i, f) for i, f, x, y in b if sa[(f, x, y)] == 0]
    offdiv = a[-1][0] if a else -1
    ok = all(i >= offdiv for i, _ in new)
    print(f'{rel}: off {len(a)} rec, diverged "{da[:60]}" (last off record #{offdiv}); on {len(b)} rec {"(diverged)" if db else ""}; new records at {[i for i, _ in new]} -> {"UNMASK (all at/after off divergence)" if ok else "NEW BEFORE DIVERGENCE"}')
