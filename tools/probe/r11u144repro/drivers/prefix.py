#!/usr/bin/env python3
# prefix.py <pristine wd> <law wd> <out> : for every row / probe case whose strict column CHANGED
# (not converted) between the two sweeps, list both walks' differing records (strictcmp --max 100000)
# and check that no record the pristine walk read equal (before its own divergence point) differs in
# the law walk.  Verdicts: IMPROVE (law's differing set within pristine's), UNMASK (pristine diverged
# and the law walk reaches further; nothing before the pristine divergence is new), NEW (a record the
# pristine matched now differs: a worsening).
import sys, os, re, csv, glob, subprocess
sys.path.insert(0, '/tmp/wt_r11u144/scripts')
P, L, OUT = sys.argv[1], sys.argv[2], sys.argv[3]
SC = os.environ.get('STRICT_CMP', '/tmp/r11u144_bin/uhdm-strictcmp')
def col(csvf, keycols):
    d = {}
    for r in csv.DictReader(open(csvf)):
        d[tuple(r[k] for k in keycols)] = r
    return d
def recs(g, o):
    out = subprocess.run([SC, '--max', '100000', g, o], capture_output=True, text=True, timeout=900).stdout
    diffs, div = {}, None
    for ln in out.split('\n'):
        m = re.match(r'#(\d+) (\w+)', ln)
        if m: diffs[int(m.group(1))] = m.group(2)
    if '(walk diverged)' in out:
        ks = [k for k, v in diffs.items() if v in ('type', 'depth', 'count', 'name')]
        div = min(ks) if ks else None
    return diffs, div
def golden_of(d):
    t = open(d + '/cmds.txt').read()
    m = re.search(r'golden cache hit ([^)]*)', t)
    g = m.group(1) if m else None
    if g and os.path.isdir(g): g = sorted(glob.glob(g + '/*.uhdm'))[0]
    return g
res = []
for corpus in ('surelog', 'uhdm2rtlil'):
    a, b = col(f'{P}/{corpus}.csv', ['name', 'mode']), col(f'{L}/{corpus}.csv', ['name', 'mode'])
    for k in sorted(a):
        if k in b and a[k]['strict'] != b[k]['strict'] and b[k]['status'] != 'CMP_EQUAL':
            dp = glob.glob(f'{P}/{corpus}/{k[1]}/{k[0]}-*'); dl = glob.glob(f'{L}/{corpus}/{k[1]}/{k[0]}-*')
            res.append((f'{corpus}/{k[1]}/{k[0]}', golden_of(dp[0]), dp[0] + '/slang.uhdm', dl[0] + '/slang.uhdm', a[k]['strict'], b[k]['strict']))
import check_probe as cp
a, b = col(f'{P}/probe.csv', ['case']), col(f'{L}/probe.csv', ['case'])
for k in sorted(a):
    if k in b and a[k]['strict'] != b[k]['strict'] and b[k]['status'] != 'EQUAL':
        rel = k[0]; g = cp.golden(rel, '/tmp/r11u144_scr/pg', 300)[0]
        f = rel.replace('/', '__') + '.uhdm'
        res.append((f'probe/{rel}', g, f'{P}/probe/{f}', f'{L}/probe/{f}', a[k]['strict'], b[k]['strict']))
with open(OUT, 'w') as fo:
    for name, g, po, lo, sa, sb in res:
        dp, divp = recs(g, po); dl, divl = recs(g, lo)
        lim = divp if divp is not None else 10**12
        new = sorted(n for n in dl if n < lim and n not in dp)
        verdict = 'NEW' if new else ('IMPROVE' if set(dl) <= set(dp) else 'UNMASK')
        fo.write(f'{verdict}\t{name}\t{sa} -> {sb}\tpristine={len(dp)} div={divp}\tlaw={len(dl)} div={divl}\tnew={new[:10]}\n')
print(open(OUT).read())
