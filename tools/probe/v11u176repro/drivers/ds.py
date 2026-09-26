# ds.py <tag> <bin> <listfile> <out> : downstream verdict per single-file case via the harness's own one()
import os, sys, concurrent.futures as cf
tag, binp, lst, outp = sys.argv[1:5]
os.environ['SLANG_UHDM'] = binp
os.environ['GOLDEN_CACHE'] = '/tmp/v11u176_dsgc'
sys.path.insert(0, '/tmp/wt_v11u176pris/scripts')
import downstream_uhdm2rtlil as ds
fenced = os.environ['FENCED'].split()
cases = [l.strip() for l in open(lst) if l.strip()]
def run(c):
    d = '/tmp/v11u176_cases/' + c
    if any(f in c.split('/') for f in fenced): return c, 'FENCED'
    if os.path.exists(d + '/files'): return c, 'MULTIFILE-SKIP'
    name = c.replace('/', '__')
    r = ds.one(name, d, ['-parse', '-nobuiltin', '-nocache', '-sv', 'dut.sv'], '/tmp/v11u176_dsw_' + tag, 300)
    return c, '%s %s %s %s %s' % (r['verdict'], r['surelog_status'], r['slang_status'], r['differs'].replace(' ', '+') or '-', (r['detail'] or '-').replace(' ', '_')[:60])
with cf.ThreadPoolExecutor(3) as ex:
    res = sorted(ex.map(run, cases))
with open(outp, 'w') as f:
    for c, v in res: f.write(f'{c} {v}\n')
