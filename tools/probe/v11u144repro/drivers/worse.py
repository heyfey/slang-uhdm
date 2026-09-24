import sys, os, re, csv, glob, subprocess
sys.path.insert(0, '/tmp/wt_v11u144/scripts')
os.environ.setdefault('STRICT_CMP', '/tmp/v11u144_bin/uhdm-strictcmp')
SC = '/tmp/v11u144_bin/uhdm-strictcmp'
P, L = '/tmp/v11u144_wdP', '/tmp/v11u144_wdL'
def load(f, keys): return {tuple(r[k] for k in keys): r for r in csv.DictReader(open(f))}
def recs(g, o):
    out = subprocess.run([SC, '--max', '1000000', g, o], capture_output=True, text=True, timeout=1800).stdout
    lines = out.split('\n'); d = {}
    for i, ln in enumerate(lines):
        m = re.match(r'#(\d+) (\w+)', ln)
        if m:
            a = lines[i+1].strip() if i+1 < len(lines) else ''; b = lines[i+2].strip() if i+2 < len(lines) else ''
            d[int(m.group(1))] = (m.group(2), a, b)
    div = '(walk diverged)' in out
    return d, div
def gold(cmds):
    m = re.search(r'golden cache hit ([^)]*)', open(cmds).read()); g = m.group(1)
    return sorted(glob.glob(g + '/*.uhdm'))[0] if os.path.isdir(g) else g
jobs = []
for corp in ('surelog', 'uhdm2rtlil'):
    a, b = load(f'{P}/{corp}.csv', ['name','mode']), load(f'{L}/{corp}.csv', ['name','mode'])
    for k in sorted(a):
        if a[k]['strict'] != b[k]['strict'] and b[k]['status'] != 'CMP_EQUAL':
            dp = glob.glob(f'{P}/{corp}/{k[1]}/{k[0]}-*')[0]; dl = glob.glob(f'{L}/{corp}/{k[1]}/{k[0]}-*')[0]
            jobs.append((f'{corp}/{k[1]}/{k[0]}', gold(dp+'/cmds.txt'), dp+'/slang.uhdm', dl+'/slang.uhdm', a[k]['strict'], b[k]['strict']))
import check_probe as cp
a, b = load(f'{P}/probe.csv', ['case']), load(f'{L}/probe.csv', ['case'])
for k in sorted(a):
    if a[k]['strict'] != b[k]['strict'] and b[k]['status'] != 'EQUAL':
        rel = k[0]; g = cp.golden(rel, '/tmp/v11u144_pg', 300)[0]; f = rel.replace('/', '__') + '.uhdm'
        jobs.append((f'probe/{rel}', g, f'{P}/probe/{f}', f'{L}/probe/{f}', a[k]['strict'], b[k]['strict']))
for name, g, po, lo, sa, sb in jobs:
    dp, divp = recs(g, po); dl, divl = recs(g, lo)
    # records that pristine matched but law differs, with same golden record (A side) -> NEW
    # compare by index up to the first structural divergence of pristine
    pdiv = min([i for i,(f,_,_) in dp.items() if f in ('type','depth','count','name')], default=10**12) if divp else 10**12
    new = [i for i in dl if i < pdiv and i not in dp]
    changed = [i for i in dl if i < pdiv and i in dp and dl[i][2] != dp[i][2]]
    v = 'NEW' if new else ('IMPROVE' if set(dl) <= set(dp) else 'UNMASK')
    print(f'{v}\t{name}\t{sa} -> {sb}\tP={len(dp)} div={divp}/{pdiv}\tL={len(dl)} div={divl}\tnew={new[:5]}\tsame-rec-diff-value={len(changed)}', flush=True)
    for i in new[:3]: print('   NEW', i, dl[i])
