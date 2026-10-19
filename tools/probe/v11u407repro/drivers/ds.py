import sys, os, glob
sys.path.insert(0, '/tmp/wt_v11u407/scripts')
import downstream_uhdm2rtlil as ds
tag, root = sys.argv[1], sys.argv[2]
for d in sorted(glob.glob('/tmp/wt_v11u407/tools/probe/*407repro/cases/*/*/dut.sv')):
    c = os.path.dirname(d); name = c.split('/')[-2] + '_' + c.split('/')[-1]
    r = ds.one(name, c, ['-parse','-nobuiltin','-nocache','-sv','dut.sv'], root, 300)
    print(tag, name, r['verdict'], r['differs'], flush=True)
