# usage: SLANG_UHDM=<bin> python3 downstream_cases.py <workroot> <case dir>...
# one downstream verdict per case through scripts/downstream_uhdm2rtlil.one
import os, sys
sys.path.insert(0, '/tmp/wt_r11u435/scripts')
import downstream_uhdm2rtlil as ds
wr = sys.argv[1]
for c in sys.argv[2:]:
    c = os.path.abspath(c)
    name = os.path.basename(os.path.dirname(c)) + '_' + os.path.basename(c)
    r = ds.one(name, c, ['-parse', '-nobuiltin', '-nocache', '-sv', 'dut.sv'], wr, 300)
    print(name, r.get('verdict'), r.get('differs') or '-', flush=True)
