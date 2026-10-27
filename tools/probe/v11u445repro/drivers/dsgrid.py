# usage: SLANG_UHDM=<bin> GOLDEN_CACHE=<dir> python3 dsgrid.py <workroot> <casedir>...
import sys, os
sys.path.insert(0, '/tmp/wt_v11u445/scripts')
import downstream_uhdm2rtlil as ds
wr = sys.argv[1]
for c in sys.argv[2:]:
    c = os.path.abspath(c)
    key = os.path.basename(os.path.dirname(c)) + '_' + os.path.basename(c)
    r = ds.one(key, c, ['-parse', '-nobuiltin', '-nocache', '-sv', 'dut.sv'], wr, 300)
    print(key, r['verdict'], r['differs'], sep='\t', flush=True)
