import sys, os, shlex, subprocess, hashlib, glob
from concurrent.futures import ThreadPoolExecutor
sys.path.insert(0, '/home/heyfey/git-repos/slang-uhdm/scripts')
binary, wd, tag = sys.argv[1], sys.argv[2], sys.argv[3]
rows = [tuple(x.split(':')) for x in sys.argv[4].split(',')]
import verify_golden as vg
tests = {t.name if hasattr(t,'name') else t[0]: t for t in []}
for mode, name in rows:
    cf = glob.glob(f'{wd}/surelog/{mode}/{name}-*/cmds.txt')[0]
    line = [l for l in open(cf) if l.startswith('slang:')][0][len('slang:'):].strip()
    argv = shlex.split(line); argv[0] = binary
    i = argv.index('-o'); 
    src_db = argv[i+1]
    # locate the test dir: the dir of the first relative source that exists
    cand = [d for d in glob.glob('/home/heyfey/git-repos/slang-uhdm/third_party/Surelog/**/'+name, recursive=True) if os.path.isdir(d)]
    d = cand[0] + ('/sim-icarus' if name == 'Earlgrey_0_1' else '')
    def draw(k):
        out = f'/tmp/v11u404_det_{tag}_{name}_{k}.uhdm'
        if os.path.exists(out): os.unlink(out)
        a = list(argv); a[i+1] = out
        r = subprocess.run(a, cwd=d, capture_output=True)
        return r.returncode, hashlib.md5(open(out,'rb').read()).hexdigest() if os.path.exists(out) else None
    with ThreadPoolExecutor(3) as ex:
        res = list(ex.map(draw, range(3)))
    print(mode, name, d.replace('/home/heyfey/git-repos/slang-uhdm/',''), res, 'sweep', hashlib.md5(open(src_db,'rb').read()).hexdigest())
