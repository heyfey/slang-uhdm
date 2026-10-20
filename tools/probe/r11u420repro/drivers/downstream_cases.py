# downstream_cases.py <binary> <tag>: the uhdm2rtlil downstream verdict of every
# class-free case dir under this repro's cases/ (explicit dirs only), through the
# main tree's scripts/downstream_uhdm2rtlil.py (read-only).
import sys, os, glob
sys.path.insert(0, '/home/heyfey/git-repos/slang-uhdm/scripts')
binp, tag = sys.argv[1], sys.argv[2]
os.environ['SLANG_UHDM'] = binp
import verify_golden as vg
vg.SLANG_UHDM = binp
import downstream_uhdm2rtlil as ds
R = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'cases')
R = os.path.abspath(R)
for c in sorted(glob.glob(R + '/*/*')):
    if not os.path.isdir(c) or not os.path.exists(c + '/dut.sv'):
        continue
    txt = open(c + '/dut.sv').read()
    if 'class' in txt or 'package' in txt:
        print(os.path.relpath(c, R), 'SKIP-class-or-package'); continue
    name = 'r11u420_' + os.path.relpath(c, R).replace('/', '_')
    row = ds.one(name, c, ['-parse', '-nobuiltin', '-nocache', '-sv', 'dut.sv'], '/tmp/r11u420_dsw_' + tag, 300)
    print(os.path.relpath(c, R), row['verdict'], row['differs'], flush=True)
