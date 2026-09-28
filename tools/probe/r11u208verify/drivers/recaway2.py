#!/usr/bin/env python3
# (r11u208: copied from r11u204verify/drivers, paths renamed; the landings under test are passes 202 and 201.)
# (r11u204: copied from r11u199verify/drivers, paths renamed; the landings under test are passes 196 and 198.)
# (r11u199: copied from r11u194verify/drivers, paths renamed; the landings under test are passes 192 and 193.)
# (r11u194: copied from r11u190verify/drivers, paths renamed; the landings under test are passes 184 and 186.)
"""recaway2.py <GW dir> [on_tag]: recaway.py with every record keyed by its ancestor chain (type:name of the enclosing
records, from the walk depth), which keeps a moved object apart from an unrelated copy that happens to print the
same record elsewhere.  Per (case, state T): away = chain-keyed records T shared with golden that ON lost; toward =
records ON shares with golden that T lacked.  Works on stage-1 cases (each database is walked against itself).
Fail-closed on $FENCED."""
import os, sys, glob, subprocess, collections, re, pickle
if len(os.environ.get('FENCED', '').split()) != 4: sys.exit('recaway2.py: source drivers/env.sh first')
SC = os.environ['STRICT_CMP']; FEN = os.environ['FENCED'].split()
def keyed(u):
    m = u + '.kms'
    if os.path.exists(m) and os.path.getmtime(m) >= os.path.getmtime(u):
        return pickle.load(open(m, 'rb'))
    t = u + '.krec'
    subprocess.run([SC, '--max', '0', '--dump-a', t, '--dump-b', '/dev/null', u, u], capture_output=True)
    c = collections.Counter(); st = []
    for l in open(t, errors='replace'):
        f = l.rstrip('\n').split('\t')
        if len(f) < 3: continue
        if not f[0].isdigit(): continue   # (r11u190: a record whose name holds a newline, a macro text)
        d = int(f[0]); st = st[:d]
        c[(' < '.join(reversed(st)), '|'.join(f[1:]))] += 1
        st.append(f'{f[1]}:{f[2]}')
    os.remove(t); pickle.dump(c, open(m, 'wb')); return c
gw = sys.argv[1]; on = sys.argv[2] if len(sys.argv) > 2 else 'on'
for w in sorted(glob.glob(f'{gw}/**/{on}.uhdm', recursive=True)):
    d = os.path.dirname(w); rel = os.path.relpath(d, gw)
    if any(re.search(rf'\b{re.escape(n)}\b', d) for n in FEN): continue
    g = glob.glob(f'{d}/gold_*/golden.uhdm')
    if not g: continue
    G = keyed(g[0]); O = keyed(w)
    for t in sorted(glob.glob(f'{d}/*.uhdm')):
        tag = os.path.basename(t)[:-5]
        if tag == on: continue
        T = keyed(t); tg = T & G; og = O & G
        away = tg - O; toward = og - T
        det = ''
        if away: det = ' | ' + ' || '.join((k[1] + ' @ ' + k[0])[:220] for k in list(away)[:2])
        print(rel, tag, f'away={sum(away.values())}', f'toward={sum(toward.values())}', det)
