#!/usr/bin/env python3
"""r11u49 CANDIDATE LISTER — every ELAB-listing (uhdmtop*/uhdmall{Modules,
Interfaces}) param_assign in OUR databases whose Rhs is an untyped op75 with
tagged_pattern operands: the complete set of cells this pass's law COULD flip,
whether or not golden currently agrees.  Printed with golden's own value beside
it, so an AGREEING candidate (both tagged) is visible as an AWAY risk.
usage: cand.py <workdir> <mode>"""
import os, re, subprocess, sys, concurrent.futures
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import shape
DUMP = '/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump'
CAND = re.compile(r'op=75 ts=- ops=\[tagged_pattern')

def one(root, d):
    p = os.path.join(root, d); name = d.rsplit('-', 1)[0]
    g = None
    cm = os.path.join(p, 'cmds.txt')
    if os.path.exists(cm):
        m = re.search(r'golden cache hit (/\S+?)\)', open(cm).read())
        if m: g = os.path.join(m.group(1), 'golden.uhdm')
    o = os.path.join(p, 'slang.uhdm')
    out = []
    if not os.path.exists(o): return (name, 'NOFILE', out)
    def sides(path):
        try: r = subprocess.run([DUMP, path], capture_output=True, text=True, timeout=900)
        except subprocess.TimeoutExpired: return None
        if r.returncode: return None
        t = '/tmp/r11u49_cand_%s_%d.txt' % (name, os.getpid())
        open(t, 'w').write(r.stdout); d2 = {(a,b,c): dd for a,b,c,dd in shape.parse(t)}
        os.unlink(t); return d2
    O = sides(o)
    if O is None: return (name, 'DUMPFAIL', out)
    G = sides(g) if g and os.path.exists(g) else {}
    if G is None: G = {}
    for k, v in sorted(O.items()):
        if not CAND.match(v): continue
        if not k[0].startswith('uhdmtop') and k[0] not in ('uhdmallModules', 'uhdmallInterfaces'):
            continue
        out.append((k, G.get(k, 'ABSENT'), v))
    return (name, '', out)

wd, mode = sys.argv[1], sys.argv[2]
root = os.path.join(wd, mode)
dirs = sorted(d for d in os.listdir(root) if os.path.isdir(os.path.join(root, d)))
n = 0
with concurrent.futures.ThreadPoolExecutor(max_workers=int(os.environ.get('CENSUS_JOBS','2'))) as ex:
    for name, note, out in ex.map(lambda d: one(root, d), dirs):
        if note: continue
        for k, gv, ov in out:
            n += 1
            agree = 'AGREE' if gv == ov else 'DIFFER'
            print('CAND %s %s %s %s %s %s  G[%s]' % (agree, name, mode, k[0], k[1], k[2], gv))
print('CANDIDATES %s %s: %d' % (wd, mode, n))
