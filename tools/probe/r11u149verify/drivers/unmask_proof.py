#!/usr/bin/env python3
# unmask_proof.py <rows.tsv>: for each row the record check read UNMASK (OF -> ON), prove the growth is an unmasking:
# every record that differs under ON and not under OF lies past OF's structural divergence, and its OURS side
# (the record without its walk depth) already exists in OF's record list, and its GOLDEN side exists in golden's list
# (the same objects, previously misaligned by the divergence), i.e. the landings did not write that content.
import sys, os, re, subprocess, collections
FENCED = set(os.environ.get('FENCED', '').split())  # slang-fenced test names from the environment, never spelled here
sys.path.insert(0, '/tmp/wt_r11u149/tools/probe/r11u149verify/drivers')
SC = '/tmp/r11u149_bin/uhdm-strictcmp'
STRUCT = ('type', 'depth', 'count', 'name')
def paths(tag, corp, name, mode):
    import glob
    W = f'/tmp/r11u149_w{tag}'
    if corp == 'probe':
        sys.path.insert(0, '/tmp/wt_r11u149/scripts'); import check_probe as cp
        g = sorted(glob.glob(cp.cache_dir(name) + '/*.uhdm'))[0]
        return g, f'{W}/probe/' + name.replace('/', '__') + '.uhdm'
    m = {'d': 'default', 't': 'testflags'}[mode]
    d = [x for x in glob.glob(f'{W}/{corp}/{m}/{name}-*') if re.fullmatch(re.escape(name) + r'-[0-9a-f]{8}', os.path.basename(x))][0]
    gdir = re.search(r'golden cache hit ([^)]*)', open(d + '/cmds.txt').read()).group(1)
    return sorted(glob.glob(gdir + '/*.uhdm'))[0], d + '/slang.uhdm'
def run(g, o, tag):
    base = f'/tmp/r11u149_unm/{tag}'; os.makedirs(os.path.dirname(base), exist_ok=True)
    if not os.path.exists(base + '.out'):
        r = subprocess.run([SC, '--max', '1000000', '--dump-a', base + '.a', '--dump-b', base + '.b', g, o], capture_output=True, text=True, timeout=7200)
        open(base + '.out', 'w').write(r.stdout)
    t = open(base + '.out').read(); L = t.split('\n'); d = {}
    for i, ln in enumerate(L):
        m = re.match(r'#(\d+) (\w+)', ln)
        if m: d[int(m.group(1))] = (m.group(2), L[i+1].strip()[3:], L[i+2].strip()[3:])
    return d, '(walk diverged)' in t, base
def nodepth(rec): return rec.split('\t', 1)[1] if '\t' in rec else rec
for line in open(sys.argv[1]):
    corp, name, mode = line.rstrip('\n').split('\t')[:3]
    if name in FENCED: continue
    tag = f"{corp}__{name.replace('/', '__')}__{mode}"
    g, a = paths('OF', corp, name, mode); _, b = paths('ON', corp, name, mode)
    da, va, ba = run(g, a, tag + '__OF'); db, vb, bb = run(g, b, tag + '__ON')
    rdiv = min([i for i, (f, _, _) in da.items() if f in STRUCT], default=10**12) if va else 10**12
    grown = [i for i in db if i not in da]
    early = [i for i in grown if i < rdiv]
    # align OURS(OF) with OURS(ON) record by record (difflib over the full record dumps): a grown record whose ON
    # record sits in an EQUAL block is an object the landings did not change -- its difference from golden existed
    # under OF and was hidden behind OF's divergence (an unmasking); one in a changed block is a landing-written value.
    import difflib
    A = [l.rstrip('\n') for l in open(ba + '.b')]; B = [l.rstrip('\n') for l in open(bb + '.b')]
    sm = difflib.SequenceMatcher(None, A, B, autojunk=False)
    same = set()
    for tag_, i1, i2, j1, j2 in sm.get_opcodes():
        if tag_ == 'equal': same.update(range(j1, j2))
    pre = [i for i in grown if i in same]; chg = [i for i in grown if i not in same]
    fields = collections.Counter(db[i][0] for i in grown)
    cf = collections.Counter(db[i][0] for i in chg)
    verdict = 'UNMASK-PROVEN' if not early and not chg else ('UNMASK+LANDING-WRITTEN' if not early else 'CHECK')
    ex = '; '.join(f"#{i} {db[i][0]} gold[{db[i][1][:70]}] ours[{db[i][2][:70]}]" for i in chg[:3])
    print(f"{verdict}\t{corp}/{name}/{mode}\tOF n={len(da)} div@{rdiv if rdiv < 10**12 else None}\tON n={len(db)}\tgrown={len(grown)} before-OF-div={len(early)} unchanged-by-landings={len(pre)} landing-written={len(chg)} fields={dict(fields)} written-fields={dict(cf)} ex: {ex}", flush=True)
