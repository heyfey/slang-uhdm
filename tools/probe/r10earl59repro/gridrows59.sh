#!/usr/bin/env bash
# print the ELAB-view cont_assign Lhs/Rhs binding grid of one arm workdir
set -u
D=${1:?arm workdir}
PY=$(cd "$(dirname "$0")" && pwd)/census59.py
cd "$D" && python3 - "$PY" <<'PYEOF'
import sys, importlib.util
spec=importlib.util.spec_from_file_location('c',sys.argv[1])
m=importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
a=m.scan('g.dump'); b=m.scan('o.dump')
rows={}
for src,d in (('G',a),('O',b)):
    for k,v in d.items():
        if '.u_sub' not in k[1]: continue
        rows.setdefault((k[1],k[2],k[3],k[4]),{})[src]=v
nd=0
print('%-26s %-5s %-18s %-30s %-30s' % ('scope','slot','ref','GOLDEN','OURS'))
for k in sorted(rows, key=lambda x:x[1]):
    g=rows[k].get('G','NO-ROW'); o=rows[k].get('O','NO-ROW')
    d = g!=o
    nd += d
    print('%-26s %-5s %-18s %-30s %-30s%s' % (k[0].split('.u_sub')[1] or '<mod>', k[2][4:8], k[3][:18], str(g), str(o), '  <<< DIFFER' if d else ''))
print('DIFFERING', nd)
PYEOF
