#!/usr/bin/env python3
"""r10uvm94 — join the GOLDEN and OURS range-select censuses cell by cell.

MULTISET join (keys collide; a dict would drop rows).  The key is the SPAN plus
the element's structural kind columns -- never the NAME or the BRK text, which
are exactly what is being compared.  Our hier_paths carry an EMPTY VpiFile, so
the file column is dropped from the key and the span carries the identity.

Per cell it reports
    GBRK  the bracket text GOLDEN's hier_path NAME actually carries
    OBRK  the bracket text OURS carries today
    OEXP  decompileHelper(OUR OWN element)  -- what the law would write
and classifies:
    SAME        OBRK == GBRK  (already right)
    FIX         OBRK != GBRK  and  OEXP == GBRK      (the law fixes it)
    BREAK       OBRK == GBRK  and  OEXP != GBRK      (the law would BREAK it)
    STILL       OBRK != GBRK  and  OEXP != GBRK      (wrong before and after)
    UNMATCHED   no partner in the other side
"""
import sys, re, collections

def cells(path):
    out = []
    try:
        f = open(path)
    except OSError:
        return out
    for ln in f:
        ln = ln.rstrip('\n')
        if not ln or '\tCELLS=' not in ln:
            continue
        head, rest = ln.split('\t', 1)
        span = head.split('|', 1)[1] if '|' in head else head
        fields = dict()
        for part in rest.split('\t'):
            if '=' in part:
                k, v = part.split('=', 1)
                fields[k] = v
        cs = fields.get('CELLS', '-')
        if cs == '-':
            continue
        for i, c in enumerate(cs.split(';')):
            m = re.match(r'^(MID|TRAIL):(.*)$', c)
            if not m:
                continue
            pos, body = m.group(1), m.group(2)
            def grab(tag):
                mm = re.search(r'(?:^|:)' + tag + r'=(.*?)(?=:(?:ELEM|PST|BASEK|WIDK|LK|RK|IXK|BRK|EXP|EXPM)=|$)', body)
                return mm.group(1) if mm else ''
            elem, brk, exp = grab('ELEM'), grab('BRK'), grab('EXP')
            kind = ':'.join([elem, grab('PST'), grab('BASEK'), grab('WIDK'),
                             grab('LK'), grab('RK'), grab('IXK')])
            if elem not in ('part_select', 'indexed_part_select'):
                continue
            key = (span, fields.get('NELEM', ''), fields.get('LVAL', ''), pos, i, kind)
            out.append((key, brk, exp, fields.get('NAME', '')))
    return out

def main():
    gpath, opath = sys.argv[1], sys.argv[2]
    verbose = '--verbose' in sys.argv
    g = collections.defaultdict(list)
    for k, brk, exp, nm in cells(gpath):
        g[k].append((brk, nm))
    o = collections.defaultdict(list)
    for k, brk, exp, nm in cells(opath):
        o[k].append((brk, exp, nm))
    tally = collections.Counter()
    rows = []
    for k in sorted(set(list(g.keys()) + list(o.keys()))):
        gl, ol = list(g.get(k, [])), list(o.get(k, []))
        n = max(len(gl), len(ol))
        for i in range(n):
            if i >= len(gl) or i >= len(ol):
                tally['UNMATCHED'] += 1
                rows.append(('UNMATCHED', k, gl[i][0] if i < len(gl) else '-',
                             ol[i][0] if i < len(ol) else '-',
                             ol[i][1] if i < len(ol) else '-'))
                continue
            gb = gl[i][0]; ob, oe = ol[i][0], ol[i][1]
            if ob == gb and oe == gb:   cls = 'SAME'
            elif ob == gb and oe != gb: cls = 'BREAK'
            elif ob != gb and oe == gb: cls = 'FIX'
            else:                       cls = 'STILL'
            tally[cls] += 1
            rows.append((cls, k, gb, ob, oe))
    print('  '.join(f'{c}={tally[c]}' for c in
                    ('SAME', 'FIX', 'BREAK', 'STILL', 'UNMATCHED')))
    if verbose:
        for cls, k, gb, ob, oe in rows:
            if cls == 'SAME' and '--allrows' not in sys.argv:
                continue
            print(f'{cls}\t{k[0]}\t{k[5]}\tG={gb}\tO={ob}\tOEXP={oe}')

main()
