#!/usr/bin/env python3
"""jobs.py <workdir> > jobs.tsv : one line per CMP_EQUAL, strict-NE row-mode of a
sweep workdir: corpus mode test golden ours strict."""
import csv, sys, os, glob, re
wd = sys.argv[1]
for corp in ('surelog', 'uhdm2rtlil'):
    for r in csv.reader(open(f'{wd}/{corp}.csv', newline='')):
        if len(r) < 6 or r[0] == 'name' or r[2] != 'CMP_EQUAL' or r[5].strip() == 'equal':
            continue
        name, mode = r[0], r[1]
        ds = [d for d in glob.glob(f'{wd}/{corp}/{mode}/{glob.escape(name)}-*') if os.path.basename(d).rsplit('-', 1)[0] == name]
        if len(ds) != 1:
            print('AMBIG', corp, mode, name, ds, file=sys.stderr); continue
        d = ds[0]
        t = open(f'{d}/cmds.txt').read()
        m = re.search(r'golden cache hit ([^)]*)\)', t)
        g = m.group(1) + '/golden.uhdm' if m else None
        if not g or not os.path.exists(g):
            print('NOGOLDEN', corp, mode, name, file=sys.stderr); continue
        print('\t'.join([corp, mode, name, g, f'{d}/slang.uhdm', r[5].strip()]))
