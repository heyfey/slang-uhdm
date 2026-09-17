#!/usr/bin/env python3
"""r11u60 A-PRIORI MOVER PREDICTOR — reads PRISTINE databases and the tests'
OWN SOURCES, never a patched database, and names every test the law can touch.

A test is predicted to move when BOTH halves hold:
  DUMP half   — its pristine database has at least one DEFINITION-listing
                (`uhdmallModules` / `uhdmallInterfaces`) `param_assign` whose
                Rhs is an op75 over a STRUCT typespec, tagged or flat.  That is
                the only cell shape the law's walk can produce or re-produce.
  SOURCE half — a textual mirror of `hasMemberSelectOf`: the parameter's bare
                name appears as `NAME.` inside a `package ... endpackage`
                region and OUTSIDE every `class ... endclass` region in it
                (the § pkgClassBodySelectDeclined49v fence).

The source half is deliberately CRUDE and over-inclusive (it cannot tell a
member select from a hierarchical reference, and it keys on a bare name exactly
as the predicate itself does).  Over-prediction is stated, never hidden: the
gate is that every MEASURED mover is inside this set.
usage: pred60.py <workdir> <mode>    [env CENSUS_JOBS=2]
"""
import os, re, subprocess, sys, concurrent.futures
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import shape

DUMP = '/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump'
DEFSECT = ('uhdmallModules', 'uhdmallInterfaces')
STRUCTOP = re.compile(r'op=75 ts=struct_typespec|op=75 ts=- ops=\[.*tagged_pattern')

def pkg_select_bases(srcs):
    """bare names selected as NAME. inside a package region, outside classes"""
    out = set()
    for f in srcs:
        try:
            t = open(f, errors='replace').read()
        except OSError:
            continue
        for m in re.finditer(r'\bpackage\b.*?\bendpackage\b', t, re.S):
            body = re.sub(r'\bclass\b.*?\bendclass\b', ' ', m.group(0), flags=re.S)
            for s in re.finditer(r'\b([A-Za-z_]\w*)\s*\.\s*[A-Za-z_]', body):
                out.add(s.group(1))
    return out

def one(root, d):
    p = os.path.join(root, d)
    name = d.rsplit('-', 1)[0]
    o = os.path.join(p, 'slang.uhdm')
    cmds = os.path.join(p, 'cmds.txt')
    res = {'name': name, 'hit': [], 'cand': 0, 'note': ''}
    if not os.path.exists(o) or not os.path.exists(cmds):
        res['note'] = 'NOFILE'
        return res
    line = [l for l in open(cmds) if l.startswith('slang:')]
    srcs = []
    if line:
        cwdm = re.search(r'-o (\S+)/slang\.uhdm', line[0])
        for tok in line[0].split():
            if tok.endswith(('.sv', '.v', '.svh', '.vh')):
                if not os.path.isabs(tok):
                    # verify_golden runs with cwd = the test's source directory
                    for base in (os.path.dirname(os.path.realpath(p)),):
                        pass
                srcs.append(tok)
    # resolve relative sources against the test source dir recorded in cmds.txt
    m = re.search(r'\(golden cache hit \S+\)', open(cmds).read())
    tdir = None
    for cand in (os.environ.get('SRCROOT_SL', ''), os.environ.get('SRCROOT_U2R', '')):
        if cand and os.path.isdir(os.path.join(cand, name)):
            tdir = os.path.join(cand, name)
            break
    srcs = [s if os.path.isabs(s) else (os.path.join(tdir, s) if tdir else s) for s in srcs]
    sel = pkg_select_bases(srcs)
    try:
        r = subprocess.run([DUMP, o], capture_output=True, text=True, timeout=900)
    except subprocess.TimeoutExpired:
        res['note'] = 'TIMEOUT'
        return res
    if r.returncode:
        res['note'] = 'DUMPRC%d' % r.returncode
        return res
    tmp = '/tmp/r11u60_pred_%s_%d.txt' % (re.sub(r'\W', '_', name), os.getpid())
    open(tmp, 'w').write(r.stdout)
    for a, b, c, dd in shape.parse(tmp):
        if a in DEFSECT and STRUCTOP.match(dd):
            res['cand'] += 1
            base = b.rsplit('.', 1)[-1]
            if base in sel:
                res['hit'].append((b, c))
    os.unlink(tmp)
    return res

wd, mode = sys.argv[1], sys.argv[2]
root = os.path.join(wd, mode)
dirs = sorted(d for d in os.listdir(root) if os.path.isdir(os.path.join(root, d)))
jobs = int(os.environ.get('CENSUS_JOBS', '2'))
cand = 0
names = []
with concurrent.futures.ThreadPoolExecutor(max_workers=jobs) as ex:
    for res in ex.map(lambda d: one(root, d), dirs):
        if res['note']:
            print('NOTE %s %s' % (res['name'], res['note']))
            continue
        cand += res['cand']
        for b, c in res['hit']:
            print('PRED %-34s %-44s %s' % (res['name'], b, c))
            names.append(res['name'])
print('== %s %s: CANDIDATE DEF struct-op cells=%d   PREDICTED cells=%d on %d tests'
      % (wd, mode, cand, len(names), len(set(names))))
print('== PREDICTED MOVERS: %s' % ' '.join(sorted(set(names))))
