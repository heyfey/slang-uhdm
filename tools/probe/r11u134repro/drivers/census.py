#!/usr/bin/env python3
# census.py <pristine wd> <law wd>  -> row-by-row strict census, flags worse rows
import csv, sys, re
P, L = sys.argv[1], sys.argv[2]
def load(f, probe=False):
    d = {}
    for r in csv.reader(open(f)):
        if r[0] in ('name', 'case'): continue
        if probe: d[(r[0],)] = (r[1], r[3] if len(r) > 3 else '')
        else: d[(r[0], r[1])] = (r[2], r[5] if len(r) > 5 else '')
    return d
def parse(st):
    m = re.match(r'differ:(\w+)\((\d+)\)', st or '')
    return (m.group(1), int(m.group(2))) if m else None
order = ['stage1','depth','type','name','defname','fullname','file','line','col','endline','endcol','decompile','size','value','consttype','count']
tot = {}
for corpus, probe in (('surelog', False), ('uhdm2rtlil', False), ('probe', True)):
    p = load(f'{P}/{corpus}.csv', probe); l = load(f'{L}/{corpus}.csv', probe)
    eqP = sum(1 for v in p.values() if v[1] == 'equal'); eqL = sum(1 for v in l.values() if v[1] == 'equal')
    better = worse = moved = 0; lines = []
    for k in sorted(set(p) | set(l)):
        a = p.get(k, ('?', '')); b = l.get(k, ('?', ''))
        if a == b: continue
        sa, sb = a[1], b[1]
        tag = 'CHANGE'
        if a[0] != b[0] and not (a[0] in ('CMP_EQUAL','EQUAL','STRICT_NOTEQUAL') and b[0] in ('CMP_EQUAL','EQUAL','STRICT_NOTEQUAL')):
            tag = 'STATUS'
        elif sb == 'equal': tag = 'TURNED_EQUAL'
        elif sa == 'equal': tag = 'WORSE_EQUAL_LOST'
        else:
            pa, pb = parse(sa), parse(sb)
            if pa and pb and pa[0] == pb[0]:
                tag = 'FEWER' if pb[1] < pa[1] else 'WORSE_MORE'
            else: tag = 'MOVED'
        lines.append(f'{corpus}\t{"/".join(k)}\t{a[0]}:{sa}\t{b[0]}:{sb}\t{tag}')
    tags = {}
    for x in lines: tags[x.split('\t')[-1]] = tags.get(x.split('\t')[-1], 0) + 1
    print(f'# {corpus}: strict-equal {eqP} -> {eqL}; {tags}')
    for x in lines: print(x)
