import sys, os, importlib
sys.path.insert(0, '/tmp/wt_v11u461/scripts')
bin_, tag = sys.argv[1], sys.argv[2]
os.environ['SLANG_UHDM'] = bin_
import verify_golden as vg
vg.SLANG_UHDM = bin_
import downstream_uhdm2rtlil as ds
base = '/tmp/wt_v11u461/tools/probe/v11u461repro/cases/'
for c in sys.argv[3:]:
    wr = '/tmp/v11u461_ds_%s/%s' % (tag, c.replace('/', '_'))
    os.makedirs(wr, exist_ok=True)
    r = ds.one(c.replace('/', '_'), base + c, ['-parse','-nobuiltin','-nocache','-sv','dut.sv'], wr, 300)
    print(tag, c, r)
