# ds.py <tag> <casedir>...: downstream verdict per case with $SLANG_UHDM (workroot /tmp/v11u474_ds/<tag>)
import sys, os
sys.path.insert(0, '/home/heyfey/git-repos/slang-uhdm/scripts')
import downstream_uhdm2rtlil as ds
tag = sys.argv[1]
for c in sys.argv[2:]:
    c = os.path.realpath(c)
    if not os.path.isdir(c): continue
    name = c.split('/cases/')[1].replace('/', '_')
    r = ds.one(name, c, ['-parse', '-nobuiltin', '-nocache', '-sv', 'dut.sv'], '/tmp/v11u474_ds/' + tag, 300)
    print(c.split('/cases/')[1], r['verdict'], r['differs'], r['surelog_status'], r['slang_status'], flush=True)
