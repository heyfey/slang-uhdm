#!/usr/bin/env python3
# (r11u213) recorder.py <GW dir> [on_tag]: the ORDER-AWARE twin of recaway2.py.  Every record of a database's self-walk
# (uhdm-strictcmp --dump-a, walk order, depth) is keyed by its ancestor chain AND its ordinal among the records of the
# same depth under the same parent (so a reordered argument list moves the key of every argument it reorders, which
# the order-blind censuses cannot see).  Per (case, state T): away = keyed records T shared with golden that ON lost.
# An inserted or dropped sibling shifts the ordinals of the siblings after it: read every hit by hand (drivers/calls.py
# for call lists).  Works on stage-1 cases.  Fail-closed on $FENCED.
import os, sys, glob, subprocess, collections, re, pickle
if len(os.environ.get('FENCED', '').split()) != 4: sys.exit('recorder.py: source drivers/env.sh first')
SC = os.environ['STRICT_CMP']; FEN = os.environ['FENCED'].split()
def keyed(u):
    m = u + '.kord'
    if os.path.exists(m) and os.path.getmtime(m) >= os.path.getmtime(u):
        return pickle.load(open(m, 'rb'))
    t = u + '.orec'
    subprocess.run([SC, '--max', '0', '--dump-a', t, '--dump-b', '/dev/null', u, u], capture_output=True)
    c = collections.Counter(); st = []; cnt = [collections.Counter()]
    for l in open(t, errors='replace'):
        f = l.rstrip('\n').split('\t')
        if len(f) < 3 or not f[0].isdigit(): continue
        d = int(f[0]); st = st[:d]; cnt = cnt[:d + 1]
        while len(cnt) < d + 1: cnt.append(collections.Counter())
        k = f'{f[1]}:{f[2]}'
        o = sum(cnt[d].values()); cnt[d][k] += 1
        c[(' < '.join(reversed(st)), f'#{o}', '|'.join(f[1:]))] += 1
        st.append(f'{k}#{o}'); cnt.append(collections.Counter())
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
        T = keyed(t); away = (T & G) - O; toward = (O & G) - T
        det = (' | ' + ' || '.join((k[2] + ' ' + k[1] + ' @ ' + k[0])[:200] for k in list(away)[:2])) if away else ''
        print(rel, tag, f'away={sum(away.values())}', f'toward={sum(toward.values())}', det)
