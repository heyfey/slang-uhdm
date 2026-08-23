import sys
import os; sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from cen30 import parse, loc
objs = parse(sys.argv[1])
pat = sys.argv[2]   # e.g. "32186:23"
for o in objs:
    if pat in o['header'] and o['kind'] in ('constant', 'operation'):
        chain = []
        c = o
        while c is not None:
            chain.append('%s%s[%s]' % (c['kind'], '(' + c['header'].split('(')[1].split(')')[0] + ')' if '(' in c['header'] else '', loc(c)))
            c = objs[c['parent']] if c['parent'] is not None else None
        print('OBJ %s %s dump-line %d' % (o['kind'], loc(o), o['line']))
        print('   ' + ' <- '.join(chain[:14]))
