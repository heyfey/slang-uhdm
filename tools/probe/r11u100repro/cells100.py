#!/usr/bin/env python3
"""r11u100 per-cell printer — the net-decl-assign road, golden beside each
binary, NO scoring.  usage: cells100.py <g.dump> <a.dump> [<b.dump>]"""
import sys, importlib.util
spec = importlib.util.spec_from_file_location('n97', sys.argv[0].rsplit('/',1)[0] + '/nda97.py')
src = open(sys.argv[0].rsplit('/',1)[0] + '/nda97.py').read().replace('main()\n', '', 1)
ns = {}
exec(compile(src, 'nda97', 'exec'), ns)
read = ns['read']
g = read(sys.argv[1]); a = read(sys.argv[2])
b = read(sys.argv[3]) if len(sys.argv) > 4 or len(sys.argv) == 4 else None
def f(d):
    if d is None: return 'ABSENT'
    if d['kind'] != 'constant': return 'NOFOLD/' + d['kind']
    return f'{d["v"]} ct{d["ct"]} sz{d["sz"]} d[{d["d"]}]'
for n in sorted(g):
    row = f'{n:10s} G  {f(g[n]):52s} A  {f(a.get(n)):52s}'
    if b is not None: row += f' B  {f(b.get(n))}'
    mark = ''
    if a.get(n) and g[n].get('kind')=='constant' and a[n].get('kind')=='constant':
        if any(g[n][k]!=a[n][k] for k in ('v','ct','sz','d')): mark = '  <<<'
    print(row + mark)
