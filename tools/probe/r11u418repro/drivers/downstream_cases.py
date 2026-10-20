import sys, os, glob
sys.path.insert(0, '/home/heyfey/git-repos/slang-uhdm/scripts')
binp, tag = sys.argv[1], sys.argv[2]
os.environ['SLANG_UHDM'] = binp
import verify_golden as vg
vg.SLANG_UHDM = binp
import downstream_uhdm2rtlil as ds
R = '/home/heyfey/git-repos/slang-uhdm/tools/probe/r11u418repro/cases'
for c in sorted(glob.glob(R + '/*/*')):
    if not os.path.isdir(c): continue
    files = open(c + '/FILES').read().split() if os.path.exists(c + '/FILES') else ['dut.sv']
    txt = ''.join(open(os.path.join(c, f)).read() for f in files)
    if 'class' in txt: 
        print(os.path.relpath(c, R), 'SKIP-class'); continue
    name = 'r11u418_' + os.path.relpath(c, R).replace('/', '_')
    row = ds.one(name, c, ['-parse', '-nobuiltin', '-nocache', '-sv'] + files, '/tmp/r11u418_dsw_' + tag, 300)
    print(os.path.relpath(c, R), row['verdict'], row['differs'], flush=True)
