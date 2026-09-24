#!/usr/bin/env python3
"""Resolve every corpus row-mode of a (corpus,test,mode,...) csv to its (golden, ours) database pair
in the 9c839593 strict sweep tree (<sweep>/<corpus>/<mode>/<test>-<hash>/ with slang.uhdm and cmds.txt
naming the golden cache dir). Output TSV: corpus mode test golden ours slang_binary ndirs.
A row that does not resolve is printed with '-' so it is counted, never dropped."""
import csv, glob, os, re, sys

src = sys.argv[1] if len(sys.argv) > 1 else '/tmp/canon_modes23.csv'
sweep = sys.argv[2] if len(sys.argv) > 2 else '/tmp/strict_sweep'
for r in csv.DictReader(open(src)):
    ds = glob.glob(os.path.join(sweep, r['corpus'], r['mode'], glob.escape(r['test']) + '-*'))
    ds = [d for d in ds if re.fullmatch(re.escape(r['test']) + r'-[0-9a-f]{8}', os.path.basename(d))]
    g = o = b = '-'
    if len(ds) == 1:
        cmds = open(os.path.join(ds[0], 'cmds.txt')).read()
        m = re.search(r'golden cache (?:hit|store) ([^)\s]+)', cmds)
        if m and os.path.exists(os.path.join(m.group(1), 'golden.uhdm')):
            g = os.path.join(m.group(1), 'golden.uhdm')
        m = re.search(r'^slang:\s+(\S+)', cmds, re.M)
        b = m.group(1) if m else '-'
        if os.path.exists(os.path.join(ds[0], 'slang.uhdm')):
            o = os.path.join(ds[0], 'slang.uhdm')
    print('\t'.join([r['corpus'], r['mode'], r['test'], g, o, b, str(len(ds))]))
