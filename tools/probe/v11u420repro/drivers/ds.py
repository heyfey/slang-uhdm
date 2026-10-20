# ds.py <binary> <tag> <casedir>...: downstream verdict per case (main tree's harness, read-only)
import sys, os
sys.path.insert(0, '/home/heyfey/git-repos/slang-uhdm/scripts')
binp, tag = sys.argv[1], sys.argv[2]
os.environ['SLANG_UHDM'] = binp
import verify_golden as vg
vg.SLANG_UHDM = binp
import downstream_uhdm2rtlil as ds
for c in sys.argv[3:]:
    c = os.path.abspath(c)
    if not os.path.isdir(c) or not os.path.exists(c + '/dut.sv'): continue
    k = os.path.basename(os.path.dirname(c)) + '/' + os.path.basename(c)
    row = ds.one('v11u420_' + k.replace('/', '_'), c, ['-parse', '-nobuiltin', '-nocache', '-sv', 'dut.sv'], '/tmp/v11u420_dsw_' + tag, 300)
    print(k, row['verdict'], row['differs'], flush=True)
