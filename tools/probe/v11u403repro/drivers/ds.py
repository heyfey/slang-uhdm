import sys, os
sys.path.insert(0, '/tmp/wt_v11u403/scripts')
import importlib
binary, root, wr = sys.argv[1], sys.argv[2], sys.argv[3]
os.environ['SLANG_UHDM'] = binary
import downstream_uhdm2rtlil as ds
for d in sorted(os.listdir(root)):
    for c in sorted(os.listdir(os.path.join(root, d))):
        p = os.path.join(root, d, c)
        if not os.path.exists(os.path.join(p, 'dut.sv')) or 'class' in open(os.path.join(p, 'dut.sv')).read():
            continue
        r = ds.one(d + '_' + c, p, ['-parse','-nobuiltin','-nocache','-sv','dut.sv'], wr, 300)
        print(d + '/' + c, r.get('verdict'), r.get('differs', ''))
