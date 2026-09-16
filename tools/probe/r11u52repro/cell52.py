#!/usr/bin/env python3
"""r11u52 ROAD C cell lister.

Reads a uhdm-dump text and reports, per SOURCE POSITION, how a range bound was
written: SYM (an operation whose operand is a ref_obj -> the bound stayed
symbolic) or FOLD (a constant whose vpiDecompile is not a plain number -> the
bound was reduced but kept the written text).  Plain numeric constants are
listed as NUM.  Copies at the same position are counted, and for SYM cells the
ref_obj's vpiName / vpiFullName are recorded so the NAME-PREFIX cell is
measured, never guessed.

usage: cell52.py <dump> [<dump> ...]
"""
import re
import sys
from collections import OrderedDict

OBJ = re.compile(r'^(\s*)\\_(\w+):\s*(\([^)]*\))?,?\s*(.*)$')
FLD = re.compile(r'^(\s*)\|(\w+):(.*)$')
LOC = re.compile(r'line:(\d+):(\d+), endln:(\d+):(\d+)')


def parse(path):
    """Yield (indent, kind, paren, loc, fields) for every object in the dump."""
    objs = []
    with open(path, errors='replace') as fh:
        for line in fh:
            line = line.rstrip('\n')
            m = OBJ.match(line)
            if m:
                ind = len(m.group(1))
                loc = LOC.search(m.group(4) or '')
                objs.append({'ind': ind, 'kind': m.group(2),
                             'paren': (m.group(3) or '')[1:-1],
                             'loc': (loc.group(1), loc.group(2), loc.group(3),
                                     loc.group(4)) if loc else None,
                             'fields': OrderedDict(), 'children': []})
                continue
            m = FLD.match(line)
            if m and objs:
                # attach to the most recent object at a shallower indent
                ind = len(m.group(1))
                for o in reversed(objs):
                    if o['ind'] < ind or o['ind'] == ind - 2:
                        o['fields'].setdefault(m.group(2), []).append(
                            m.group(3))
                        break
    return objs


def cells(path):
    objs = parse(path)
    out = OrderedDict()
    for i, o in enumerate(objs):
        if not o['loc']:
            continue
        key = '%s:%s-%s:%s' % o['loc']
        if o['kind'] == 'operation':
            # operands follow at deeper indent until indent <= o.ind
            names = []
            for p in objs[i + 1:]:
                if p['ind'] <= o['ind']:
                    break
                if p['kind'] == 'ref_obj':
                    names.append(p['paren'])
            if names:
                out.setdefault(key, []).append('SYM(' + ','.join(names) + ')')
        elif o['kind'] == 'constant':
            dec = (o['fields'].get('vpiDecompile') or [''])[0]
            if dec and not re.fullmatch(r"-?\d+|\d*'[a-zA-Z]?[0-9a-fA-FxXzZ_]+",
                                        dec):
                out.setdefault(key, []).append('FOLD(%s)' % dec)
            else:
                out.setdefault(key, []).append('NUM(%s)' % dec)
    return out


def main():
    tables = [(p, cells(p)) for p in sys.argv[1:] if p != '--all']
    keys = []
    for _, t in tables:
        for k in t:
            if k not in keys:
                keys.append(k)
    keys.sort(key=lambda k: [int(x) for x in re.split(r'[:-]', k)])
    for k in keys:
        cols = []
        for p, t in tables:
            v = t.get(k, [])
            agg = OrderedDict()
            for x in v:
                agg[x] = agg.get(x, 0) + 1
            cols.append(' '.join('%dx%s' % (n, x) for x, n in agg.items())
                        or '-')
        if len(set(cols)) == 1 and '--all' not in sys.argv:
            continue
        print('%-22s | %s' % (k, ' || '.join(cols)))


if __name__ == '__main__':
    main()
