import sys, os, concurrent.futures as cf
sys.path.insert(0, '/tmp/wt_v11u147/scripts')
import downstream_uhdm2rtlil as ds
tag = sys.argv[1]; cases = [l.strip() for l in open(sys.argv[2]) if l.strip()]
wr = f'/tmp/v11u147_ds_{tag}'
def run(d):
    name = d.replace('/', '_')[-60:]
    r = ds.one(name, d, ['-parse', '-nobuiltin', '-nocache', '-sv', 'dut.sv'], wr, 300)
    return d, r
with cf.ThreadPoolExecutor(3) as ex:
    for d, r in ex.map(run, cases):
        print(tag, d.split('/probe/')[-1], r['verdict'], r['surelog_status'], r['slang_status'], r['differs'], sep=' | ', flush=True)
