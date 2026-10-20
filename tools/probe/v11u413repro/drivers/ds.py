# v11u413 ds.py <binary> <tag> <case rel>...: downstream verdict per case (ds.one machinery)
import os, sys
os.environ['SLANG_UHDM'] = sys.argv[1]
sys.path.insert(0, '/tmp/wt_v11u413/scripts')
import downstream_uhdm2rtlil as ds
C = '/tmp/wt_v11u413/tools/probe/v11u413repro/cases'
wr = '/tmp/v11u413_ds_' + sys.argv[2]
os.makedirs(wr, exist_ok=True)
for c in sys.argv[3:]:
    r = ds.one(c.split('/')[1], os.path.join(C, c), ['-parse','-nobuiltin','-nocache','-sv','dut.sv'], wr, 300)
    print(sys.argv[2], c, r['verdict'], r.get('surelog_status'), r.get('slang_status'), r.get('differs'), flush=True)
