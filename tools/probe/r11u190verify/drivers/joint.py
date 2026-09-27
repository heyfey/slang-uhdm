#!/usr/bin/env python3
# (r11u190: copied from r11u185verify/drivers, paths renamed; the landings under test are passes 180 and 181.)
"""joint.py <H> <A> <off180> <off181> <key>...: the share proof of a row both landings move (JOINT conversions and
changes).  Per state S the order-blind strict records (uhdm-strictcmp --dump-a/-b, depth dropped) ours holds that
golden lacks, bad(S), and golden holds that ours lacks, miss(S).  fix180 = bad(A) - bad(off181) (what pass 180 alone
removes), fix181 = bad(A) - bad(off180); overlap = fix180 & fix181; intro180 = bad(off181) - bad(A), intro181 =
bad(off180) - bad(A); CANCELLED = records one landing alone introduces that H no longer holds; each cancelled record
is paired with the golden record H gained over A for the same (type, name): `paired` counts pairs <= 3 fields apart
and names the fields (the field-additive pattern: each landing fixes another field of one object).  A key is a probe
case path or corpus/mode/name.  Fenced corpus rows refused (fail-closed on $FENCED)."""
import os, re, sys, glob, subprocess, collections
F = os.environ.get('FENCED', '').split()
if len(F) != 4: sys.exit('joint.py: source drivers/env.sh first')
sys.path.insert(0, '/tmp/wt_r11u190/scripts'); import check_probe as cp
SC = os.environ['STRICT_CMP']; T = '/tmp/r11u190_joint'; os.makedirs(T, exist_ok=True)
H, A, O6, O8 = sys.argv[1:5]
N = ['type', 'name', 'defname', 'fullname', 'file', 'line', 'col', 'endline', 'endcol', 'decompile', 'size', 'value', 'consttype']
def paths(w, key):
    if not key.startswith(('surelog/', 'uhdm2rtlil/')):
        return os.path.join(cp.cache_dir(key), 'golden.uhdm'), f'{w}/probe/' + key.replace('/', '__') + '.uhdm'
    c, m, n = key.split('/')
    if any(re.search(rf'\b{re.escape(f)}\b', n) for f in F): sys.exit('fenced refused')
    d = glob.glob(f'{w}/{c}/{m}/{n}-*')[0]
    g = re.search(r'golden cache [a-z]* ([^)]*)\)', open(d + '/cmds.txt').read()).group(1)
    return glob.glob(g + '/*.uhdm')[0], d + '/slang.uhdm'
rd = lambda p: collections.Counter(l.rstrip('\n').split('\t', 1)[1] for l in open(p, errors='replace') if '\t' in l)
def recs(f):
    subprocess.run([SC, '--max', '0', '--dump-a', f'{T}/a', '--dump-b', f'{T}/b', f[0], f[1]], capture_output=True)
    return rd(f'{T}/a'), rd(f'{T}/b')
n = lambda c: sum(c.values())
for key in sys.argv[5:]:
    G = None; o = {}
    for s, w in (('H', H), ('A', A), ('o6', O6), ('o8', O8)):
        G, o[s] = recs(paths(w, key))
    bad = {s: o[s] - G for s in o}; miss = {s: G - o[s] for s in o}
    fix180 = bad['A'] - bad['o8']; fix181 = bad['A'] - bad['o6']; ov = fix180 & fix181
    intro = {'180': bad['o8'] - bad['A'], '181': bad['o6'] - bad['A']}
    canc = {k: v - bad['H'] for k, v in intro.items()}
    gain = (o['H'] & G) - (o['A'] & G); byn = collections.defaultdict(list)
    for r in gain: f = r.split('\t'); byn[(f[0], f[1])].append(f)
    paired = 0; unp = 0; flds = collections.Counter()
    for who, c in canc.items():
        for r, k in c.items():
            f = r.split('\t'); best = None
            for q in byn.get((f[0], f[1]), []):
                d = [i for i in range(min(len(f), len(q))) if f[i] != q[i]]
                if best is None or len(d) < len(best): best = d
            if best is not None and len(best) <= 3:
                paired += k; flds[who + ':' + ('+'.join(N[i] for i in best) or 'count')] += k
            else:
                unp += k
                if os.environ.get('UNP'): print('   UNPAIRED', who, k, r[:230])
    print(f'{key} bad(ours-not-golden): A={n(bad["A"])} off180={n(bad["o6"])} off181={n(bad["o8"])} H={n(bad["H"])} '
          f'miss(golden-not-ours): A={n(miss["A"])} off180={n(miss["o6"])} off181={n(miss["o8"])} H={n(miss["H"])} | '
          f'fix180={n(fix180)} fix181={n(fix181)} overlap={n(ov)} | intro180={n(intro["180"])} intro181={n(intro["181"])} '
          f'CANCELLED={n(canc["180"]) + n(canc["181"])} paired={paired} {dict(flds)} UNPAIRED={unp}', flush=True)
