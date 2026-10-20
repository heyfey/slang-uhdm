# downstream_cases.py <binary> <tag> <casedir>...: the downstream verdict per class-free case
# (explicit case directories; scripts/downstream_uhdm2rtlil.py's one()).
import sys, os
sys.path.insert(0, '/home/heyfey/git-repos/slang-uhdm/scripts')
binp, tag = sys.argv[1], sys.argv[2]
os.environ['SLANG_UHDM'] = binp
import verify_golden as vg
vg.SLANG_UHDM = binp
import downstream_uhdm2rtlil as ds
for c in sys.argv[3:]:
    c = os.path.abspath(c)
    if not os.path.isdir(c):
        print(c, 'SKIP-nondir'); continue
    files = open(c + '/FILES').read().split() if os.path.exists(c + '/FILES') else ['dut.sv']
    txt = ''.join(open(os.path.join(c, f)).read() for f in files)
    key = '/'.join(c.split('/')[-2:])
    if 'class' in txt:
        print(key, 'SKIP-class'); continue
    args = ['-parse', '-nobuiltin', '-nocache', '-sv'] + files
    if os.path.exists(c + '/TOP'):
        args = ['-parse', '-nobuiltin', '-nocache', '-sv', '-top', open(c + '/TOP').read().strip()] + files
    row = ds.one('v11u418_' + key.replace('/', '_'), c, args, '/tmp/v11u418_dsw_' + tag, 300)
    print(key, row['verdict'], row.get('differs', ''), flush=True)
