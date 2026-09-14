#!/usr/bin/env python3
"""L2 a-priori prediction for § pkgBodyCallNeverListsOnHolder20.

DATABASE-keyed, run on the PRISTINE workdir BEFORE the patched databases are
inspected: a row moves iff some module_inst / interface_inst / program in its
pristine database lists a PACKAGE-QUALIFIED function in its `vpiTaskFunc`
while the row's own sources carry no `import <that package>::` at all — the
listing our push created for a call written inside the package's own body.

Reuses cen20.py's dump parser so the two agree by construction.

usage: predL2_20.py <workdir>/<mode>
"""
import os, re, subprocess, sys, tempfile
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import importlib.util
_spec = importlib.util.spec_from_file_location(
    'cen20', os.path.join(os.path.dirname(os.path.abspath(__file__)), 'cen20.py'))
# cen20 runs main() on import; load only its functions by exec'ing the source
# with the trailing main() call stripped.
_src = open(_spec.origin).read().replace('\nmain()\n', '\n')
_mod = type(sys)('cen20lib')
exec(compile(_src, _spec.origin, 'exec'), _mod.__dict__)

UD = os.environ.get('UHDM_DUMP',
                    os.path.expanduser('~/git-repos/UHDM/build/bin/uhdm-dump'))


def imported_pkgs(cmds, srcdir):
    """Every package named by an `import <pkg>::` anywhere in the row's
    sources.  The harness writes RELATIVE source names into cmds.txt, so the
    row's own corpus directory is scanned whole (a superset, which is the safe
    direction for a mover prediction)."""
    files = set(re.findall(r'(/\S+\.s?vh?)', cmds))
    if srcdir and os.path.isdir(srcdir):
        for dp, _, fs in os.walk(srcdir):
            for fn in fs:
                if fn.endswith(('.sv', '.v', '.svh', '.vh')):
                    files.add(os.path.join(dp, fn))
    pk = set()
    for s in files:
        try:
            t = open(s, errors='replace').read()
        except Exception:
            continue
        for m in re.finditer(r'\bimport\s+(\w+)\s*::', t):
            pk.add(m.group(1))
    return pk


def main():
    root = sys.argv[1]
    corpus = sys.argv[2] if len(sys.argv) > 2 else None
    for d in sorted(os.listdir(root)):
        db = os.path.join(root, d, 'slang.uhdm')
        if not os.path.exists(db):
            continue
        try:
            out = subprocess.run([UD, db], capture_output=True, text=True,
                                 timeout=600).stdout
        except Exception:
            continue
        with tempfile.NamedTemporaryFile('w', suffix='.dump', delete=False) as fh:
            fh.write(out)
            tmp = fh.name
        try:
            cells = _mod.cells(tmp)
        finally:
            os.unlink(tmp)
        hits = [(k, v) for k, v in cells.items()
                if k[0] == 'TF' and '::' in v]
        if not hits:
            continue
        row = d.rsplit('-', 1)[0]
        pk = imported_pkgs(open(os.path.join(root, d, 'cmds.txt'),
                                errors='replace').read(),
                           os.path.join(corpus, row) if corpus else None)
        for k, v in hits:
            for fn in v.strip('[]').split(','):
                if '::' in fn and fn.split('::')[0] not in pk:
                    print('%-46s %-16s %-34s %s' % (row, k[1], k[2], fn))


main()
