import sys
import os; sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from cen30 import parse, loc
objs = parse(sys.argv[1])
top = int(sys.argv[2])   # dump line where topPackages begins
def view(o): return 'TOP' if o['line'] > top else 'ALL'
rows=[]
for o in objs:
    if o['kind']=='constant':
        d=o['fields'].get('vpiDecompile',[''])[0]
        if d.startswith('-'):
            rows.append((int(loc(o).split(':')[0]), view(o), 'FOLDED', loc(o), d,
                         'sz='+o['fields'].get('vpiSize',['?'])[0],
                         'ct='+o['fields'].get('vpiConstType',['?'])[0],
                         'val='+(o['fields'].get('INT',o['fields'].get('UINT',o['fields'].get('REAL',['?']))) [0])))
    if o['kind']=='operation' and o['fields'].get('vpiOpType',[''])[0]=='1':
        kids=[objs[k] for k in o['kids'] if objs[k]['slot']=='vpiOperand']
        kk=';'.join('%s@%s%s'%(k['kind'],loc(k),'['+k['fields'].get('vpiDecompile',[''])[0]+']' if k['kind']=='constant' else '') for k in kids)
        rows.append((int(loc(o).split(':')[0]), view(o), 'OP', loc(o), kk,'','',''))
for r in sorted(set(rows)):
    print('\t'.join(str(x) for x in r))
