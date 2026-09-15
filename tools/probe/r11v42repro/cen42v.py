#!/usr/bin/env python3
"""r11v42 VERIFIER CENSUS + SHAPE LISTER.

Over a set of OUR databases it names, a priori, every cell the § hpTrailSelPkgFold42
law AS FIXED can still reach.  Three candidate classes, because the verifier fix
widened the law in two directions the implementer's census could not see:

  FOLD  — a hier_path / bit_select bracket group that still spells a PACKAGE
          parameter by identifier (the cells a fold can newly fire on).
  DBASE — a bracket group carrying a DECIMAL-BASED literal (`N'd..`): the cells
          § pkgFoldTaintAndHomeScope42V (C) can RESPELL, which are invisible to a
          census that looks for identifiers only (they are ALREADY folded).
  PKGFN — the database declares a package-scope function/task/class body whose
          own text could carry an unqualified in-package read: the cells (B) can
          make ABSTAIN.  Reported per database as a flag, from the dump's
          package section.

A SHAPE LISTER sits beside the count, as ops requires.
"""
import os, re, subprocess, sys
from concurrent.futures import ThreadPoolExecutor

PARAM_RE = re.compile(r'\\_parameter: \(([A-Za-z_$][\w$]*)::([A-Za-z_$][\w$]*)\)')
NAME_RE = re.compile(r'\\_(hier_path|bit_select|var_select): \(([^)]*)\)')
IDENT_RE = re.compile(r'[A-Za-z_$][\w$]*(?:::[A-Za-z_$][\w$]*)*')
DBASE_RE = re.compile(r"\d*'[sS]?[dD]\d")
PKGFN_RE = re.compile(r'\\_(function|task|class_defn): \(([A-Za-z_$][\w$]*)::')

def bracket_groups(name):
    out, depth, start = [], 0, None
    for i, c in enumerate(name):
        if c == '[':
            if depth == 0: start = i + 1
            depth += 1
        elif c == ']':
            depth -= 1
            if depth == 0 and start is not None:
                out.append(name[start:i]); start = None
    return out

def shape_of(name):
    comps = name.split('.')
    braq = [('[' in c) for c in comps]
    if len(comps) == 1: return 'bare' + ('[]' if braq[0] else '')
    if any(braq[:-1]): return 'dotted%d/base-or-mid-sel' % len(comps)
    return 'dotted%d/%s' % (len(comps), 'trail-sel' if braq[-1] else 'no-sel')

def one(path, dump):
    try:
        r = subprocess.run([dump, path], capture_output=True, text=True, timeout=1200)
    except subprocess.TimeoutExpired:
        return (path, 'DUMP_TIMEOUT', [], [], False, {})
    if r.returncode != 0:
        return (path, 'DUMP_RC%d' % r.returncode, [], [], False, {})
    txt = r.stdout
    pkg = set()
    for m in PARAM_RE.finditer(txt):
        pkg.add(m.group(2)); pkg.add(m.group(1) + '::' + m.group(2))
    fold, dbase, shapes, seen = [], [], {}, set()
    pkgfn = bool(PKGFN_RE.search(txt))
    for m in NAME_RE.finditer(txt):
        kind, nm = m.group(1), m.group(2)
        key = (kind, nm)
        if key in seen: continue
        seen.add(key)
        if kind == 'hier_path':
            sh = shape_of(nm); shapes[sh] = shapes.get(sh, 0) + 1
        for g in bracket_groups(nm):
            for t in IDENT_RE.findall(g):
                if t in pkg or t.split('::')[-1] in pkg:
                    fold.append(kind + ':' + nm); break
            if DBASE_RE.search(g):
                dbase.append(kind + ':' + nm)
    return (path, 'OK', sorted(set(fold)), sorted(set(dbase)), pkgfn, shapes)

def main():
    roots = []
    label = 'census'
    dump = os.path.expanduser('~/git-repos/UHDM/build/bin/uhdm-dump')
    args = sys.argv[1:]
    i = 0
    jobs = 2
    while i < len(args):
        if args[i] == '--label': label = args[i+1]; i += 2
        elif args[i] == '--jobs': jobs = int(args[i+1]); i += 2
        elif args[i] == '--name': roots.append(('name', args[i+1])); i += 2
        else: roots.append(('root', args[i])); i += 1
    paths = []
    for kind, r in roots:
        if kind == 'name':
            paths.append(r); continue
        for dp, _dn, fn in os.walk(r, followlinks=True):
            for f in fn:
                if f in ('slang.uhdm', 'golden.uhdm', 'surelog.uhdm'):
                    paths.append(os.path.join(dp, f))
    paths.sort()
    print('LABEL %s databases=%d' % (label, len(paths)))
    if not paths:
        print('NO_DATABASES — a zero here means nothing'); return 2
    shapes_all = {}
    nf = nd = np_ = bad = 0
    with ThreadPoolExecutor(max_workers=jobs) as ex:
        for p, st, fold, dbase, pkgfn, shapes in ex.map(lambda q: one(q, dump), paths):
            for k, v in shapes.items(): shapes_all[k] = shapes_all.get(k, 0) + v
            if st != 'OK':
                bad += 1; print('BAD %s %s' % (st, p)); continue
            if fold: nf += 1; print('FOLD-CAND %s :: %s' % (p, ' | '.join(fold)))
            if dbase: nd += 1; print('DBASE-CAND %s :: %s' % (p, ' | '.join(dbase)))
            if pkgfn: np_ += 1
            if not fold and not dbase: print('NOCAND %s' % p)
    print('SHAPES (distinct hier_path names):')
    for k in sorted(shapes_all): print('  %-28s %d' % (k, shapes_all[k]))
    print('TOTAL databases=%d FOLD-CAND=%d DBASE-CAND=%d PKGSUBROUTINE-DBS=%d BAD=%d'
          % (len(paths), nf, nd, np_, bad))
    return 0

sys.exit(main())
