#!/usr/bin/env python3
"""r10uvm72 — PREDICT THE MOVERS from the PRISTINE workdir, BEFORE the patched
sweep is read.  A mover list produced afterwards predicts nothing.

  usage: ct72predict.py <pristine_workdir_root> [--quiet]

`§ inheritedNameBindsPkgFn72` changes exactly one thing: the callee a func_call
written inside a CLASS METHOD binds when the NAME IS INHERITED.  A database can
therefore move only if, in the PRISTINE build, it contains at least one
func_call that is either

  (P1) BOUND to a CLASS METHOD `X::C::m` while a FREE subroutine named `m`
       exists in the same database at package or module scope — that call will
       either re-target to the free function or (with no free twin reachable)
       lose its link; or
  (P2) UNBOUND and named `m`, with such a free subroutine present and a
       class_defn / class-method print on its ancestor chain — that call will
       gain the link.

Both are properties of the PRISTINE dump alone.

TRAPS this instrument encodes:
  * `sed 1d` — uhdm-dump's first line is the database path.
  * a print with no field lines at indent+2 is a BACK-REFERENCE, not an object.
  * a database that fails to dump is printed as DUMP_FAIL and COUNTED; a
    predictor that silently skips inputs under-predicts and then congratulates
    itself when the sweep agrees.
  * FREE vs METHOD is read off the printed FULLNAME's component count
    (`p::fe` / `work@top.mfe` are free; `p::C::fe` is a method) — never off the
    bare name, which both spellings share.
"""
import os
import re
import subprocess
import sys

OBJ = re.compile(r'^(\s*)\\_(\w+): (?:\(([^)]*)\))?(.*)$')
FLD = re.compile(r'^(\s*)\|(\w+):(.*)$')
SUBS = ('function', 'task')


def is_free(nm):
    """`p::fe` or `work@top.mfe` -> free; `p::C::fe` -> a class method."""
    if not nm:
        return False
    return nm.count('::') <= 1


def leaf(nm):
    n = nm.split('::')[-1]
    return n.split('.')[-1]


def scan(path):
    """-> (n_p1, n_p2) for one dump file."""
    freenames = set()
    methodnames = set()
    calls = []          # (name, target, has_class_ancestor)
    stack = []
    openc = []

    def commit(oc):
        ind, nm, flds, anc, tgt = oc
        if not flds:
            return
        calls.append((nm, tgt, anc))

    for ln in open(path, errors='replace'):
        ln = ln.rstrip('\n')
        m = OBJ.match(ln)
        if m:
            ind = len(m.group(1))
            kind, nm = m.group(2), m.group(3) or ''
            while stack and stack[-1][0] >= ind:
                stack.pop()
            for oc in [o for o in openc if o[0] >= ind]:
                commit(oc)
            openc = [o for o in openc if o[0] < ind]
            stack.append((ind, kind, nm))
            if kind in SUBS:
                (freenames if is_free(nm) else methodnames).add(leaf(nm))
            for oc in openc:
                if ind == oc[0] + 2 and oc[4] == '<pending>':
                    oc[4] = nm
            if kind == 'func_call':
                anc = any(s[1] == 'class_defn' or
                          (s[1] in SUBS and s[2].count('::') >= 2)
                          for s in stack[:-1])
                openc.append([ind, nm, set(), anc, None])
            continue
        m = FLD.match(ln)
        if m:
            ind, fld = len(m.group(1)), m.group(2)
            for oc in openc:
                if ind == oc[0] + 2:
                    oc[2].add(fld)
                    if fld == 'vpiFunction':
                        oc[4] = '<pending>'
    for oc in openc:
        commit(oc)

    p1 = p2 = 0
    for nm, tgt, anc in calls:
        if tgt and tgt not in ('<pending>',) and not is_free(tgt) \
                and leaf(tgt) in freenames:
            p1 += 1
        elif not tgt and anc and nm in freenames and nm in methodnames:
            p2 += 1
    return p1, p2


def main():
    root = sys.argv[1]
    dump = os.path.expanduser('~/git-repos/UHDM/build/bin/uhdm-dump')
    paths = []
    for dp, _d, files in os.walk(root):
        if 'slang.uhdm' in files:
            paths.append(os.path.join(dp, 'slang.uhdm'))
    paths.sort()
    print('databases scanned: %d' % len(paths), file=sys.stderr)
    # VERIFIER FIX (r10uvm72 verification): this scratch path used to be the
    # FIXED string '/tmp/r10uvm72_predict.dump'.  Two invocations running at
    # once -- the surelog corpus and the uhdm2rtlil corpus, the obvious way to
    # use a two-core budget -- then overwrite each other's dump BETWEEN the
    # write and the scan, and the predictor reports WRONG NUMBERS WITHOUT ANY
    # ERROR.  Measured during verification: concurrent runs gave 5/953 and
    # 1/679; run serially the SAME script on the SAME inputs gives the correct
    # 7/953 and 0/679.  A silent wrong answer from a gate instrument is the
    # worst failure mode there is, so the path is now per-process.
    tmp = '/tmp/r10uvm72_predict.%d.dump' % os.getpid()
    movers, fails = [], 0
    for i, p in enumerate(paths, 1):
        rel = os.path.relpath(p, root)
        try:
            with open(tmp, 'wb') as fh:
                r = subprocess.run([dump, p], stdout=fh,
                                   stderr=subprocess.DEVNULL, timeout=900)
            if r.returncode != 0:
                print('DUMP_FAIL %s' % rel)
                fails += 1
                continue
        except Exception as exc:
            print('DUMP_FAIL %s (%s)' % (rel, exc))
            fails += 1
            continue
        with open(tmp, 'rt', errors='replace') as fh:
            lines = fh.readlines()[1:]          # the database-path first line
        with open(tmp + '.2', 'wt') as fh:
            fh.writelines(lines)
        p1, p2 = scan(tmp + '.2')
        if p1 or p2:
            movers.append((rel, p1, p2))
            print('PREDICT-MOVE %-58s retarget=%-5d newbind=%d' % (rel, p1, p2))
        if i % 100 == 0:
            print('  ... %d/%d' % (i, len(paths)), file=sys.stderr)
    for scratch in (tmp, tmp + '.2'):
        try:
            os.remove(scratch)
        except OSError:
            pass
    print('---- PREDICTED MOVERS: %d / %d   DUMP_FAIL=%d' %
          (len(movers), len(paths), fails))


main()
