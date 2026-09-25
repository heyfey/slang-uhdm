#!/usr/bin/env python3
"""pairs.py <workdir> : every judge-equal row-mode and probe case of a sweep: label golden ours status strict (r11u140)."""
import csv, sys, os, glob, re
sys.path.insert(0, '/tmp/wt_r11u145/scripts')
import check_probe as cp
wd = sys.argv[1]
for corp in ('surelog', 'uhdm2rtlil'):
    for r in csv.DictReader(open(f'{wd}/{corp}.csv', newline='')):
        if r['status'] not in ('STRICT_NOTEQUAL', 'CMP_EQUAL'): continue
        name, mode = r['name'], r['mode']
        ds = [d for d in glob.glob(f'{wd}/{corp}/{mode}/{glob.escape(name)}-*') if os.path.basename(d).rsplit('-', 1)[0] == name]
        if len(ds) != 1: print('AMBIG', corp, mode, name, file=sys.stderr); continue
        d = ds[0]; t = open(f'{d}/cmds.txt').read()
        m = re.search(r'golden cache hit ([^)]*)\)', t)
        g = m.group(1) + '/golden.uhdm' if m else None
        if not g or not os.path.exists(g):
            g2 = f'{d}/surelog.uhdm'
            print('NOGOLDEN', corp, mode, name, file=sys.stderr); continue
        print('\t'.join([f'{corp}/{mode}/{name}', g, f'{d}/slang.uhdm', r['status'], r['strict']]))
for r in csv.DictReader(open(f'{wd}/probe.csv', newline='')):
    if r['status'] not in ('STRICT_NOTEQUAL', 'EQUAL'): continue
    rel = r['case']
    g = os.path.join(cp.cache_dir(rel), 'golden.uhdm')
    o = os.path.join(wd, 'probe', rel.replace('/', '__') + '.uhdm')
    print('\t'.join([f'probe/{rel}', g, o, r['status'], r['strict']]))
