#!/usr/bin/env python3
"""v11u90 VERIFIER's own corpus census — INDEPENDENT of cellcen90/srcscan90.

Discovery comes from scripts/verify_golden.py itself (the same discovery the
sweep uses), so the row set is the corpus's, not a guess.  For each row every
SystemVerilog/Verilog source under the row's own directory is scanned — a
SUPERSET of what the row compiles, so a zero here is stronger than a zero
over the compiled set.

  LAW A  a net DECLARATION carrying a drive or charge strength
         (net_type '(' strength ...): the shape whose Signal the producer's
         compileNetDeclaration never pushes.
  LAW B  a continuous assign, or a net declaration, whose delay is a BARE
         identifier (`assign #NAME`, `wire #NAME`): the shape LAW B respells.

POSITIVE CONTROL: --control scans the verifier's own grid, which must fire.
Unreadable files are counted and named, never silently skipped.
No test is dispatched; this reads bytes only.
"""
import os, re, sys, collections, importlib.util

REPO = os.environ.get('REPO', os.path.expanduser('~/git-repos/slang-uhdm'))
spec = importlib.util.spec_from_file_location(
    'vg', os.path.join(REPO, 'scripts', 'verify_golden.py'))
vg = importlib.util.module_from_spec(spec)
spec.loader.exec_module(vg)

NETTYPE = r'(?:wire|tri|tri0|tri1|triand|trior|wand|wor|trireg|uwire)'
STRENGTH = r'(?:supply0|supply1|strong0|strong1|pull0|pull1|weak0|weak1|highz0|highz1|small|medium|large)'
LAWA = re.compile(r'\b' + NETTYPE + r'\s*\(\s*' + STRENGTH + r'\b')
LAWB_CA = re.compile(r'\bassign\b[^;\n]*?#\s*([A-Za-z_]\w*)')
LAWB_ND = re.compile(r'\b' + NETTYPE + r'\b[^;\n]*?#\s*([A-Za-z_]\w*)')
EXT = ('.sv', '.v', '.svh', '.vh', '.svi', '.vlt')


def files_under(d):
    out = []
    for root, dirs, fns in os.walk(d):
        dirs[:] = [x for x in dirs if x not in ('slpp_all', 'slpp_unit', '.git')]
        for fn in fns:
            if fn.lower().endswith(EXT):
                out.append(os.path.join(root, fn))
    return out


def census(rowdirs, label):
    a_sites = collections.Counter()
    b_sites = collections.Counter()
    a_rows, b_rows = set(), set()
    unread = []
    seen = set()
    for row, d in rowdirs:
        for p in files_under(d):
            key = (row, p)
            if p in seen:
                pass
            seen.add(p)
            try:
                t = open(p, errors='replace').read()
            except Exception as e:
                unread.append((p, str(e)))
                continue
            na = len(LAWA.findall(t))
            nb = len(LAWB_CA.findall(t)) + len(LAWB_ND.findall(t))
            if na:
                a_sites[p] += na
                a_rows.add(row)
            if nb:
                b_sites[p] += nb
                b_rows.add(row)
    print('== %s: rows=%d distinct-files=%d unreadable=%d' %
          (label, len(rowdirs), len(seen), len(unread)))
    print('   LAW A  sites=%d files=%d rows=%d' %
          (sum(a_sites.values()), len(a_sites), len(a_rows)))
    for p, n in sorted(a_sites.items(), key=lambda kv: -kv[1])[:15]:
        print('      A %4d  %s' % (n, p))
    print('   LAW B  sites=%d files=%d rows=%d' %
          (sum(b_sites.values()), len(b_sites), len(b_rows)))
    for p, n in sorted(b_sites.items(), key=lambda kv: -kv[1])[:15]:
        print('      B %4d  %s' % (n, p))
    for p, e in unread[:10]:
        print('   UNREADABLE %s (%s)' % (p, e))
    return sorted(a_rows), sorted(b_rows)


if __name__ == '__main__':
    if '--control' in sys.argv:
        g = os.environ.get('GRID', os.path.join(os.path.dirname(os.path.abspath(__file__)), 'grid.verifier'))
        rd = [(a, os.path.join(g, a)) for a in sorted(os.listdir(g))
              if os.path.isdir(os.path.join(g, a))]
        ar, br = census(rd, 'POSITIVE CONTROL (verifier grid)')
        print('   control LAW A rows:', ar)
        print('   control LAW B rows:', br)
        sys.exit(0)
    for corpus in ('surelog', 'uhdm2rtlil'):
        rows = (vg.discover_surelog(None) if corpus == 'surelog'
                else vg.discover_uhdm2rtlil(None))
        rd = []
        for name, v in rows.items():
            d = v[0] if isinstance(v, (tuple, list)) else v
            if isinstance(d, str) and os.path.isdir(d):
                rd.append((name, d))
        ar, br = census(rd, corpus)
        print('   LAW A rows:', ar)
        print('   LAW B rows:', br)
