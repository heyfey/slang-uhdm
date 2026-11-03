import sys, os
sys.path.insert(0, '/tmp/wt_v11u481/scripts')

binp, tag = sys.argv[1], sys.argv[2]
os.environ["SLANG_UHDM"] = binp
import downstream_uhdm2rtlil as ds
os.environ['SLANG_UHDM'] = binp
for d in sys.argv[3:]:
    d = os.path.realpath(d)
    name = d.split('/cases/')[-1].replace('/', '_')
    wr = '/tmp/v11u481_ds/' + tag
    os.makedirs(wr, exist_ok=True)
    r = ds.one(name, d, ['-parse','-nobuiltin','-nocache','-sv','dut.sv'], wr, 300)
    print(d.split('/cases/')[-1], tag, r)
