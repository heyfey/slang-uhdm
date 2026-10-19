# ds.py <workroot> <case dir>...: downstream verdict per case with $SLANG_UHDM (run from the repo root)
import sys, os
sys.path.insert(0, 'scripts')
import downstream_uhdm2rtlil as ds
wr = sys.argv[1]
for c in sys.argv[2:]:
    name = c.rstrip('/').split('/')[-2] + '_' + c.rstrip('/').split('/')[-1]
    r = ds.one(name, os.path.abspath(c), ['-parse', '-nobuiltin', '-nocache', '-sv', 'dut.sv'], wr, 300)
    print(name, r['verdict'], r['differs'], r['detail'][:80], sep=' | ')
