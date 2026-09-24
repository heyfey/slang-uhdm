#!/usr/bin/env python3
"""r11u118 census — MEASUREMENT ONLY.  For every row of a sweep workdir
(corpus rows: <wd>/{surelog,uhdm2rtlil}/<mode>/<test>-<hash>/cmds.txt;
downstream rows: <wd>/downstream/<test>/{slang.uhdm,surelog/run.ys}) take the
package-qualified select cells — part_select / indexed_part_select /
var_select whose VpiName carries `::` — and print, per row with any:
    <row>  G=<golden cells>  X=<golden cells ours reproduces EXACTLY>  O=<ours ::-cells>
EXACT = kind, span, VpiFile basename, name, defname, fullname (multiset).
Rows with X<G or O>0 are the § pkgQualParam*118 candidates (a mover must be
one of them); X==G on the patched sweep is the law's success.
usage: cen118.py <workdir> [<const printer>]"""
import collections, glob, os, re, subprocess, sys
wd = sys.argv[1]
tool = sys.argv[2] if len(sys.argv) > 2 else '/tmp/r11u118_const'
RX = re.compile(r"^(part_select|indexed_part_select|var_select)#\d+ (.*?) dec=")
def cells(db):
    if not db or not os.path.isfile(db):
        return None
    out = subprocess.run([tool, db], capture_output=True, text=True).stdout
    c = collections.Counter()
    for l in out.splitlines():
        m = RX.match(l)
        if m and "::" in re.search(r"name='([^']*)'", l).group(1):
            c[m.group(1) + ' ' + m.group(2)] += 1
    return c
rows = []
for c in sorted(glob.glob(os.path.join(wd, '*', '*', '*', 'cmds.txt'))):
    txt = open(c, errors='replace').read()
    m = re.search(r'(/\S+/slang-uhdm-goldens/[0-9a-f]+)', txt)
    g = os.path.join(m.group(1), 'golden.uhdm') if m else None
    parts = c[len(wd):].strip('/').split('/')
    rows.append(('/'.join(parts[:2]) + '/' + re.sub(r'-[0-9a-f]{8}$', '', parts[2]), g,
                 os.path.join(os.path.dirname(c), 'slang.uhdm')))
for r in sorted(glob.glob(os.path.join(wd, 'downstream', '*', 'surelog', 'run.ys'))):
    g = None
    for l in open(r):
        if l.startswith('read_uhdm'):
            g = l.split()[-1]
    rows.append(('downstream/' + r.split('/')[-3], g,
                 os.path.join(os.path.dirname(os.path.dirname(r)), 'slang.uhdm')))
for name, g, o in rows:
    cg, co = cells(g), cells(o)
    if cg is None or co is None or (not cg and not co):
        continue
    x = sum((cg & co).values())
    print(f'{name}  G={sum(cg.values())}  X={x}  O={sum(co.values())}')
print(f'ROWS={len(rows)}', file=sys.stderr)
