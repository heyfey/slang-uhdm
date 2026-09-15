#!/usr/bin/env python3
"""r11u40 A-PRIORI MOVER PREDICTOR for § ovHopBareActualElabFold40.

Names, from the PRISTINE side alone, every test whose bytes the law can move.
Run it BEFORE the patched sweep; `byteverify.sh`'s mover set must then be a
SUBSET of this answer, with every over-predicted row armed on both binaries and
shown byte-identical.

THE PREDICATE (both halves must hold):

  (a) SOURCE half — the test writes a module-instantiation parameter override
      whose actual is a BARE dotted path, `.FORMAL(BASE.MEM[.MEM...])` or the
      positional `(BASE.MEM...)`, with nothing around it.  Both gated arms
      strip a MemberAccess chain and demand the BASE be a HierarchicalValue
      parameter, so an actual with an operator, an index or a call around it
      can never reach either of them.

  (b) DATABASE half — the PRISTINE database carries at least one of the two
      arms' OWN OUTPUT:
        S1  a `hier_path` that is the Rhs of a `param_assign`
            (src/ParamEmit.cpp's `ovHierInit` arm), or
        S2  a `hier_path` inside a `range`'s bound that carries its OWN
            `vpiTypespec` (src/TypeEmit.cpp's `ovHierParam` arm).  The
            typespec is what separates it from the DEFINITION view's own
            `[CFG.BUS.DAT-1:0]`, which BOTH producers write as a bare
            hier_path and which this law must not touch.
      Nothing else the law touches can move a byte: the gate only ever turns
      one of those two emissions OFF.

Half (b) alone is the exact signature but costs a `uhdm-dump` per row; half (a)
is cheap and over-predicts.  The tool runs (a) over every row and (b) only over
the survivors, and prints both answers so an over-prediction is visible.

  usage:  pred40.py <verify_golden workdir>/<mode> [name ...]
          pred40.py --selftest            (the POSITIVE + NEGATIVE control)

Measurement-only.  The judge is uhdm-cmp through scripts/verify_golden.py.
"""
import os
import re
import subprocess
import sys

UHDM_DUMP = os.path.expanduser('~/git-repos/UHDM/build/bin/uhdm-dump')

DOTTED = re.compile(r'[.(]\s*[A-Za-z_$][\w$]*\s*\(\s*([A-Za-z_$][\w$]*)'
                    r'(?:\s*\.\s*[A-Za-z_$][\w$]*)+\s*\)')
BARE = re.compile(r'\(\s*([A-Za-z_$][\w$]*)(?:\s*\.\s*[A-Za-z_$][\w$]*)+\s*\)')
COMMENT = re.compile(r'//[^\n]*|/\*.*?\*/', re.S)

def _fenced():
    """The slang-FENCED names, read out of the sibling `canaudit.sh`'s own
    `FENCED=` line so this file never spells them.  A fenced row is never
    dispatched here — the tool only READS a workdir the harness already made —
    but its NAME is masked in the output all the same, the way
    `r11u3repro/predict.py` masks it."""
    here = os.path.dirname(os.path.abspath(__file__))
    try:
        for ln in open(os.path.join(here, 'canaudit.sh')):
            if ln.startswith('FENCED='):
                return set(ln.split('=', 1)[1].strip().strip('"\'').split())
    except Exception:
        pass
    return set()


FENCED = _fenced()


def mask(name):
    return '<FENCED>' if name in FENCED else name


HOME = os.path.expanduser('~')
ROOTS = [os.path.join(HOME, 'git-repos', 'uhdm2rtlil', 'test'),
         os.path.join(HOME, 'git-repos', 'Surelog', 'tests'),
         os.path.join(HOME, 'git-repos', 'Surelog', 'third_party', 'tests')]


def sources_of(cmds):
    line = ''
    for ln in open(cmds, encoding='utf-8', errors='replace'):
        if ln.startswith('slang:'):
            line = ln[len('slang:'):].strip()
    out, toks, skip = [], line.split(), False
    for t in toks:
        if skip:
            skip = False
            continue
        if t in ('-o', '-y', '-I', '-v'):
            skip = True
            continue
        if t.startswith('-') or t.endswith('slang-uhdm') or t.endswith('.bin'):
            continue
        if t.endswith(('.sv', '.v', '.svh', '.vh')):
            out.append(t)
    return out


def test_root(name):
    for r in ROOTS:
        d = os.path.join(r, name)
        if os.path.isdir(d):
            return d
    return None


def bases_in_sources(srcs, root):
    bases = set()
    for s in srcs:
        p = s if os.path.isabs(s) else os.path.join(root or '', s)
        if not os.path.isfile(p):
            continue
        txt = COMMENT.sub(' ', open(p, encoding='utf-8',
                                    errors='replace').read())
        for m in DOTTED.finditer(txt):
            bases.add(m.group(1))
        for m in BARE.finditer(txt):
            bases.add(m.group(1))
    return bases


def db_signatures(db, timeout=1800):
    """(S1, S2) — COUNTS of the two arms' OWN OUTPUT in a pristine database.

    S1  a `hier_path` that is the IMMEDIATE `vpiRhs` child of a `param_assign`
        (src/ParamEmit.cpp's `ovHierInit` arm).  "Immediate" is load-bearing:
        a hier_path anywhere DEEPER inside an Rhs subtree is some other
        emission — measured, the loose form names `jeras_union`,
        `rp32_r5p_alu`, `iface_modport_conn` and `simple_package`, none of
        which moves a single byte under this law.

    S2  a `hier_path` inside a `range`'s bound (`vpiLeftRange` /
        `vpiRightRange`) that carries its OWN `vpiTypespec`
        (src/TypeEmit.cpp's `ovHierParam` arm stamps a ref_typespec on the
        hier_path it mints).  The typespec is what separates it from the
        DEFINITION view's own `[CFG.BUS.DAT-1:0]` bound, which BOTH producers
        write as a bare hier_path and which this law must not touch.

    A back-edge field (`vpiParent`, `vpiActual`, `vpiExpr`, `vpiTypespec`,
    `vpiInstance`, `vpiLhs`) is never followed: a hier_path printed as
    somebody's vpiActual is a reference, not an emission.
    """
    try:
        txt = subprocess.run([UHDM_DUMP, db], capture_output=True, text=True,
                             timeout=timeout).stdout
    except Exception:
        return (-1, -1)
    lines = txt.split('\n')
    OPEN = re.compile(r'^(\s*)\\_([a-z_]+):')
    FLD = re.compile(r'^(\s*)\|([A-Za-z_]+):')
    stack, field, s1, s2 = [], None, 0, 0
    for i, ln in enumerate(lines):
        m = OPEN.match(ln)
        if m:
            ind, kind = len(m.group(1)), m.group(2)
            while stack and stack[-1][0] >= ind:
                stack.pop()
            par = stack[-1][1] if stack else None
            pctx = stack[-1][2] if stack else None
            ctx = None
            if field in ('vpiParent', 'vpiActual', 'vpiExpr', 'vpiTypespec',
                         'vpiInstance', 'vpiLhs') or pctx == 'back':
                ctx = 'back'
            elif field in ('vpiLeftRange', 'vpiRightRange') or pctx == 'bound':
                ctx = 'bound'
            if kind == 'hier_path' and ctx != 'back':
                if field == 'vpiRhs' and par == 'param_assign':
                    s1 += 1
                elif ctx == 'bound':
                    has_ts = False
                    for j in range(i + 1, len(lines)):
                        f2 = FLD.match(lines[j])
                        o2 = OPEN.match(lines[j])
                        if (f2 and len(f2.group(1)) <= ind) or \
                           (o2 and len(o2.group(1)) <= ind):
                            break
                        if f2 and len(f2.group(1)) == ind + 2 and \
                           f2.group(2) == 'vpiTypespec':
                            has_ts = True
                    if has_ts:
                        s2 += 1
            stack.append((ind, kind, ctx))
            field = None
            continue
        f = FLD.match(ln)
        if f:
            field = f.group(2)
    return (s1, s2)


def selftest():
    """THE POSITIVE AND NEGATIVE CONTROLS, on the pass's own grid.

    POSITIVE — every grid arm's PRISTINE database must carry the arms' output
    (the law has something to remove there), and the counts are printed, not
    just a boolean, so a signature that reaches nothing can never read as a
    prediction.

    NEGATIVE — the GOLDEN database of every arm must read (0, 0): golden never
    stamps a typespec'd hier_path into a range bound, and its ONE legitimate
    keep (`g4_view40`'s `#(.W(s.CFG.BUS.DAT + 4))`, an actual the reducer
    fails on) is an `op24` whose OPERAND is the hier_path — not an immediate
    Rhs hier_path, which is exactly why S1 demands immediacy.  The signature
    is therefore not vacuously zero: it is zero on a golden side that DOES
    carry the keep, in the shape the law must never produce.
    """
    here = os.path.dirname(os.path.abspath(__file__))
    want = {'g1_hop40': ((4, 5), (0, 0)), 'g2_site40': ((2, 4), (0, 0)),
            'g3_shape40': ((1, 9), (0, 0)), 'g4_view40': ((4, 0), (0, 0))}
    ok = True
    for arm, (eo, eg) in sorted(want.items()):
        for who, path, exp in (
                ('ours', os.path.join(here, 'grid', arm, 'ours.pris.uhdm'), eo),
                ('gold', os.path.join(here, 'grid', arm, 'slpp_all',
                                      'surelog.uhdm'), eg)):
            if not os.path.isfile(path):
                print('%-12s %s SKIP-NOFILE %s' % (arm, who, path))
                ok = False
                continue
            got = db_signatures(path)
            print('%-12s %s S1=%-3d S2=%-3d expect %-9s %s'
                  % (arm, who, got[0], got[1], str(exp),
                     'ok' if got == exp else 'MISMATCH'))
            ok = ok and got == exp
    print('SELFTEST %s' % ('PASS' if ok else 'FAIL'))
    return 0 if ok else 1


def main():
    if len(sys.argv) > 1 and sys.argv[1] == '--selftest':
        sys.exit(selftest())
    mode_dir = sys.argv[1]
    want = set(sys.argv[2:])
    named = []
    for d in sorted(os.listdir(mode_dir)):
        full = os.path.join(mode_dir, d)
        name = d.rsplit('-', 1)[0]
        if want and name not in want:
            continue
        cmds = os.path.join(full, 'cmds.txt')
        db = os.path.join(full, 'slang.uhdm')
        if not os.path.isfile(cmds) or not os.path.isfile(db):
            continue
        srcs = sources_of(cmds)
        root = test_root(name)
        if root is None and srcs and os.path.isabs(srcs[0]):
            root = os.path.dirname(srcs[0])
        if not bases_in_sources(srcs, root):
            continue
        s1, s2 = db_signatures(db)
        print('%-60s src=True  S1=%-3d S2=%-3d  %s'
              % (mask(name), s1, s2,
                 'PREDICT-MOVER' if (s1 > 0 or s2 > 0) else 'no-db-sig'))
        if s1 > 0 or s2 > 0:
            named.append(mask(name))
    print('-- PREDICTED MOVERS (%d): %s' % (len(named), ' '.join(named)))


if __name__ == '__main__':
    main()
