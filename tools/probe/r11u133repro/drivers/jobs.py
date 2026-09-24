#!/usr/bin/env python3
"""jobs.py <workdir> [all] : one line per STRICT_NOTEQUAL row-mode (or every judge-equal one with 'all'):
corpus/mode/test golden ours strict. Measurement only (r11u133)."""
import csv, sys, os, glob, re
wd = sys.argv[1]; allrows = len(sys.argv) > 2
for corp in ('surelog', 'uhdm2rtlil'):
    for r in csv.DictReader(open(f'{wd}/{corp}.csv', newline='')):
        if r['status'] not in (('STRICT_NOTEQUAL','CMP_EQUAL') if allrows else ('STRICT_NOTEQUAL',)): continue
        name, mode = r['name'], r['mode']
        ds = [d for d in glob.glob(f'{wd}/{corp}/{mode}/{glob.escape(name)}-*') if os.path.basename(d).rsplit('-', 1)[0] == name]
        if len(ds) != 1: print('AMBIG', corp, mode, name, file=sys.stderr); continue
        d = ds[0]; t = open(f'{d}/cmds.txt').read()
        m = re.search(r'golden cache hit ([^)]*)\)', t)
        g = m.group(1) + '/golden.uhdm' if m else None
        if not g or not os.path.exists(g): print('NOGOLDEN', corp, mode, name, file=sys.stderr); continue
        print('\t'.join([f'{corp}/{mode}/{name}', g, f'{d}/slang.uhdm', r['strict']]))
