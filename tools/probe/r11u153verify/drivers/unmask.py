#!/usr/bin/env python3
# unmask.py <wdOff> <wdOn> <rows.tsv> <out.tsv> : for each changed row (corpus, key) a landing moves, prove the
# move is an unmasking or an improvement, never a new difference. Golden vs OFF and golden vs ON strict records
# (uhdm-strictcmp --dump-a/--dump-b):
#   first  first differing record index, OFF -> ON (must not move EARLIER)
#   newpre records ON gets wrong that OFF got right, before BOTH walks diverge (must be 0)
#   div    walk divergence index OFF -> ON
#   lost   golden dump lines OFF matched that ON no longer matches (a right -> wrong move; must be 0)
# and the depth-blind order-blind uhdm-dump multisets (golden, OFF, ON): obaway = golden-mismatching lines ON
# has that OFF did not (must be 0 for an unmasking: every difference ON shows was already a difference behind
# OFF's divergence), obtoward = the reverse. Fail-closed on $FENCED (refuses without it, skips those names).
import sys, os, subprocess, collections, glob, re
FENCED = set(os.environ.get('FENCED', '').split())
if len(FENCED) != 4: sys.exit('unmask.py: export FENCED (the four slang-fenced names) first')
sys.path.insert(0, '/tmp/wt_r11u153/scripts'); os.chdir('/tmp/wt_r11u153')
import check_probe as cp
SC = '/tmp/r11u153_bin/uhdm-strictcmp'; DUMP = os.environ['UHDM_DUMP']
OFF, ON, ROWS, OUT = sys.argv[1:5]
T = '/tmp/r11u153_um'; os.makedirs(T, exist_ok=True)
def locate(wd, corpus, key):
    if corpus == 'probe':
        rel = key; g = os.path.join(cp.cache_dir(rel), 'golden.uhdm')
        return g, os.path.join(wd, 'probe', rel.replace('/', '__') + '.uhdm')
    name, mode = key.split('/')
    d = glob.glob(f'{wd}/{corpus}/{mode}/{name}-*')
    if not d: return None, None
    m = re.search(r'golden cache hit (\S+)\)', open(d[0] + '/cmds.txt').read()) or re.search(r'(/\S*slang-uhdm-goldens/[0-9a-f]+)', open(d[0] + '/cmds.txt').read())
    return (m.group(1) + '/golden.uhdm' if m else None), d[0] + '/slang.uhdm'
def recs(g, o, tag):
    a, b = f'{T}/{tag}.a', f'{T}/{tag}.b'
    for f in (a, b):
        if os.path.exists(f): os.remove(f)
    subprocess.run([SC, '--max', '1', '--dump-a', a, '--dump-b', b, g, o], capture_output=True, timeout=1800)
    if not os.path.exists(a): return None, None
    return open(a, errors='replace').read().split('\n'), open(b, errors='replace').read().split('\n')
def div(ga, b):
    for i in range(min(len(ga), len(b))):
        if ga[i].split('\t')[:2] != b[i].split('\t')[:2]: return i
    return min(len(ga), len(b))
def first(ga, b):
    for i in range(min(len(ga), len(b))):
        if ga[i] != b[i]: return i
    return min(len(ga), len(b)) if len(ga) != len(b) else None
def ob(f):
    r = subprocess.run([DUMP, f], capture_output=True, text=True, errors='replace').stdout
    return collections.Counter(l.strip() for l in r.split('\n') if 'Restored design' not in l and 'file:' not in l)
out = open(OUT, 'w'); out.write('corpus\tkey\tfirst_off\tfirst_on\tnewpre\tdiv_off\tdiv_on\tobaway\tobtoward\tlost\tverdict\n')
for line in open(ROWS):
    corpus, key = line.split()[:2]
    if key.split('/')[0] in FENCED: out.write(f'{corpus}\t{key}\tFENCED-SKIP\n'); continue
    g, fo = locate(OFF, corpus, key); _, fn = locate(ON, corpus, key)
    if not g or not os.path.exists(g) or not fo or not os.path.exists(fo) or not os.path.exists(fn):
        out.write(f'{corpus}\t{key}\tNOFILE\n'); out.flush(); continue
    tag = re.sub(r'\W', '_', key)
    ga, bo = recs(g, fo, tag + '.off'); ga2, bn = recs(g, fn, tag + '.on')
    if ga is None or ga2 is None:
        fo_, fn_ = '-', '-'; newpre = '-'; dvo = dvn = '-'
    else:
        dvo, dvn = div(ga, bo), div(ga2, bn); lim = min(dvo, dvn)
        newpre = sum(1 for i in range(lim) if bn[i] != ga2[i] and bo[i] == ga[i])
        fo_, fn_ = first(ga, bo), first(ga2, bn)
    G, X, Y = ob(g), ob(fo), ob(fn)
    away = sum((((Y - G) - (X - G)) + ((G - Y) - (G - X))).values()); tow = sum((((X - G) - (Y - G)) + ((G - X) - (G - Y))).values())
    lost = sum(((G - Y) - (G - X)).values())  # golden lines OFF matched and ON lost: a right -> wrong move
    earlier = isinstance(fo_, int) and isinstance(fn_, int) and fn_ < fo_
    v = 'OK' if (newpre in (0, '-') and not earlier and away == 0) else ('OK-NOLOSS' if (newpre in (0, '-') and not earlier and lost == 0) else 'CHECK')
    out.write(f'{corpus}\t{key}\t{fo_}\t{fn_}\t{newpre}\t{dvo}\t{dvn}\t{away}\t{tow}\t{lost}\t{v}\n'); out.flush()
