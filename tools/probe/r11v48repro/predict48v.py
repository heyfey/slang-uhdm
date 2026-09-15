#!/usr/bin/env python3
"""r11v48 — a-priori mover prediction / neutrality control.

Re-runs EVERY arm of a PRISTINE sweep workdir with the patched binary, in the
SAME cwd the sweep used (recovered by matching the workdir's sha1 suffix
against the corpus's own discovery), TWICE:
  * R11U48_OFF=1 -> the database must be BYTE-IDENTICAL to the pristine one
    (the positive control that the instrument is actually wired to the cells);
  * R11U48_DBG=1 -> names every cell whose answer the pass changes.
Nothing outside this pass's own scratch is written.
"""
import hashlib, os, subprocess, sys, shlex, filecmp

sys.path.insert(0, '/home/heyfey/git-repos/slang-uhdm/scripts')
import verify_golden as vg

corpus = sys.argv[1]
wd = sys.argv[2]
binpath = sys.argv[3]
out = sys.argv[4]
scratch = sys.argv[5]
os.makedirs(scratch, exist_ok=True)

tests = vg.discover_surelog(None) if corpus == 'surelog' else vg.discover_uhdm2rtlil(None)
h2dir = {}
for name, v in tests.items():
    dirpath = v[0]
    h2dir[hashlib.sha1(dirpath.encode()).hexdigest()[:8]] = dirpath

same = notsame = missing = 0
cells = []
rows = []
n = 0
for root, dirs, files in os.walk(wd):
    if 'cmds.txt' not in files:
        continue
    base = os.path.basename(root)
    h = base.rsplit('-', 1)[-1]
    dirpath = h2dir.get(h)
    line = None
    for L in open(os.path.join(root, 'cmds.txt')):
        if L.startswith('slang:'):
            line = L[len('slang:'):].strip()
    if line is None or dirpath is None:
        missing += 1
        rows.append(('NOCMD', base, 0))
        continue
    argv = shlex.split(line)
    argv[0] = binpath
    key = hashlib.sha1(root.encode()).hexdigest()[:12]
    o = os.path.join(scratch, key + '.uhdm')
    for i, a in enumerate(argv):
        if a == '-o':
            argv[i + 1] = o
    env = dict(os.environ); env['R11U48_OFF'] = '1'
    subprocess.run(argv, cwd=dirpath, capture_output=True, env=env, timeout=600)
    ref = os.path.join(root, 'slang.uhdm')
    if not os.path.exists(ref):
        st = 'NOREF'
        missing += 1
    elif os.path.exists(o) and filecmp.cmp(o, ref, shallow=False):
        st = 'SAME'; same += 1
    else:
        st = 'NOTSAME'; notsame += 1
    env2 = dict(os.environ); env2['R11U48_DBG'] = '1'
    r = subprocess.run(argv, cwd=dirpath, capture_output=True, env=env2, text=True, timeout=600)
    c = [l for l in r.stderr.splitlines() if l.startswith('R11U48')]
    for l in c:
        cells.append('%s\t%s' % (base, l))
    rows.append((st, base, len(c)))
    if os.path.exists(o):
        os.remove(o)
    n += 1

with open(out, 'w') as f:
    for st, base, nc in rows:
        f.write('%s\t%d\t%s\n' % (st, nc, base))
with open(out + '.cells', 'w') as f:
    f.write('\n'.join(cells) + '\n')
print('ARMS %d SAME %d NOTSAME %d MISSING %d CELLLINES %d' % (n, same, notsame, missing, len(cells)))
