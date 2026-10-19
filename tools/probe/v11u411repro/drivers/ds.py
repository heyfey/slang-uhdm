import sys, os, glob
sys.path.insert(0, '/tmp/wt_v11u411/scripts')
import downstream_uhdm2rtlil as ds
binary, tag, out = sys.argv[1], sys.argv[2], sys.argv[3]
os.environ['SLANG_UHDM'] = binary
with open(out, 'w') as f:
    for c in sorted(glob.glob(sys.argv[4] + '/*/*')):
        g = c.split('/')[-2]
        if g == 'VT' or c.endswith(('vm03', 'vm04', 'vm06', 've05')):
            continue
        r = ds.one(os.path.basename(c), c, ['-parse', '-nobuiltin', '-nocache', '-sv', 'dut.sv'], '/tmp/v11u411_dsw_' + tag, 300)
        f.write('%s %s\n' % (c.split('cases/')[1], r)); f.flush()
