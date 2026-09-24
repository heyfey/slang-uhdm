import sys, os
sys.path.insert(0, '/tmp/wt_v11u133pris/scripts')
import downstream_uhdm2rtlil as ds
root, work = sys.argv[1], sys.argv[2]
import glob
for f in sorted(glob.glob(root + '/**/dut.sv', recursive=True)):
    d = os.path.dirname(f); rel = os.path.relpath(d, root)
    r = ds.one(rel.replace('/', '__'), d, ['-parse','-nobuiltin','-nocache','-sv','dut.sv'], work, 300)
    print(rel, r, flush=True)
