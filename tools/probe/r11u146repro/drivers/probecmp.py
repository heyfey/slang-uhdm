# probecmp.py <wdP> <wdL> <case>...: first strict diff index/record for pristine and law databases of probe cases
import sys, os, subprocess
sys.path.insert(0, '/tmp/wt_r11u146/scripts')
import check_probe as cp, verify_golden as vg
wdP, wdL = sys.argv[1], sys.argv[2]
SC='/tmp/r11u146_bin/uhdm-strictcmp'
for rel in sys.argv[3:]:
    cdir = cp.cache_dir(rel); hit = vg.cache_load(cdir)
    g = hit[0] if isinstance(hit, tuple) else hit
    if not g or not os.path.exists(str(g)):
        g = os.path.join(cdir, 'golden.uhdm')
    fn = rel.replace('/', '__') + '.uhdm'
    out = []
    for wd in (wdP, wdL):
        r = subprocess.run([SC, '--max', '1', g, os.path.join(wd, 'probe', fn)], capture_output=True, text=True).stdout.splitlines()
        out.append(' / '.join(x.strip() for x in r[:3]) + ' || ' + (r[-1] if r else ''))
    print(rel); print('  P:', out[0]); print('  L:', out[1])
