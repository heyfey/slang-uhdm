#!/usr/bin/env python3
# fieldcheck.py <census.tsv> <pristine wd> <law wd>  -> per changed row: field tallies P vs L, flag increases
import sys, os, re, glob, subprocess
sys.path.insert(0, '/tmp/wt_r11u134/scripts')
os.environ.setdefault('SURELOG', '/home/heyfey/git-repos/Surelog/build/bin/surelog')
import verify_golden as vg, check_probe as cp
SC = '/tmp/r11u134_bin/uhdm-strictcmp'
cen, P, L = sys.argv[1:4]
def golden_of_rowdir(d):
    t = open(os.path.join(d, 'cmds.txt')).read()
    m = re.search(r'golden cache hit (\S+?)\)', t) or re.search(r'golden cache hit (\S+)', t)
    g = m.group(1) if m else None
    if g and os.path.isdir(g):
        gg = glob.glob(os.path.join(g, '*.uhdm')); g = gg[0] if gg else None
    if not g:
        gg = glob.glob(os.path.join(d, '**', 'surelog.uhdm'), recursive=True); g = gg[0] if gg else None
    return g
def fields(g, o):
    r = subprocess.run([SC, '--max', '0', g, o], capture_output=True, text=True, timeout=600)
    m = re.search(r'fields: (.*)', r.stdout + r.stderr)
    if not m: return {}
    d = {}
    for kv in m.group(1).split():
        if '=' in kv:
            k, v = kv.split('='); 
            try: d[k] = int(v)
            except: pass
    return d
for line in open(cen):
    if line.startswith('#'): continue
    corpus, key, a, b, tag = line.rstrip('\n').split('\t')
    if tag == 'TURNED_EQUAL': continue
    if corpus == 'probe':
        rel = key; g = cp.vg.cache_load(cp.cache_dir(rel)); g = g[1] if g else None
        po = f'{P}/probe/' + rel.replace('/', '__') + '.uhdm'; lo = f'{L}/probe/' + rel.replace('/', '__') + '.uhdm'
    else:
        name, mode = key.split('/')
        pd = glob.glob(f'{P}/{corpus}/{mode}/{name}-*'); ld = glob.glob(f'{L}/{corpus}/{mode}/{name}-*')
        if not pd or not ld: print(corpus, key, 'NODIR'); continue
        g = golden_of_rowdir(pd[0]); po = pd[0] + '/slang.uhdm'; lo = ld[0] + '/slang.uhdm'
    fp = fields(g, po); fl = fields(g, lo)
    inc = [f'{k}:{fp.get(k,0)}->{fl[k]}' for k in fl if k != 'objects_differing' and fl[k] > fp.get(k, 0)]
    print(f'{corpus}\t{key}\t{tag}\tP={fp.get("objects_differing")}\tL={fl.get("objects_differing")}\t{"INCREASED " + ",".join(inc) if inc else "ok"}')
