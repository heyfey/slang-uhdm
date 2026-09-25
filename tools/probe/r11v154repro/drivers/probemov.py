import sys, os, subprocess, filecmp, glob
sys.path.insert(0, '/tmp/wt_v11u154pris/scripts')
import check_probe as cp
P, L = sys.argv[1], sys.argv[2]
S = os.environ['STRICT_CMP']
import csv
M={r['case'].replace('/','__'):r['case'] for r in csv.DictReader(open(P+'/probe.csv'))}
tot_leave = tot_enter = 0; movers = 0
for f in sorted(glob.glob(P + '/probe/*.uhdm')):
    b = os.path.basename(f); l = os.path.join(L, 'probe', b)
    if not os.path.exists(l) or filecmp.cmp(f, l, shallow=False):
        continue
    movers += 1
    rel = M[b[:-5]]
    g, _ = cp.golden(rel, '/tmp/v11u154_pg', 300)
    def recs(o):
        out = subprocess.run([S, '--max', '100000', g, o], capture_output=True, text=True).stdout.splitlines()
        rs = set(); i = 0
        while i < len(out):
            if out[i].startswith('#'):
                fld = out[i].split(' ', 1)[1] if ' ' in out[i] else ''
                a = out[i+1].strip() if i+1 < len(out) else ''
                bb = out[i+2].strip() if i+2 < len(out) else ''
                rs.add((fld, a, bb)); i += 3
            else:
                i += 1
        return rs, (out[-1] if out else '')
    rp, vp = recs(f); rl, vl = recs(l)
    leave = len(rp - rl); enter = len(rl - rp)
    tot_leave += leave; tot_enter += enter
    if leave or enter or vp != vl: print(f'{rel} | pris {vp} ({len(rp)}) | law {vl} ({len(rl)}) | leave {leave} enter {enter}')
print(f'movers={movers} leave={tot_leave} enter={tot_enter}')
