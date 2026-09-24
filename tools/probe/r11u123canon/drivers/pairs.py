#!/usr/bin/env python3
"""Resolve every re-measured row-mode to its (golden, ours) database pair.

Input: the master's re-measure csv (corpus,test,mode,old,new) and the
1fc087af strict sweep tree (<sweep>/<corpus>/<mode>/<test>-<hash>/ with
slang.uhdm and cmds.txt naming the golden cache dir).  Output (stdout, TSV):
corpus mode test old new golden ours slang_binary.  A row whose directory is
ambiguous (two corpora dirs with the same test name inside one corpus) or
whose cmds.txt names no golden is printed with golden='-' so it is counted,
never silently dropped."""
import csv, glob, os, re, sys

remeasure = sys.argv[1] if len(sys.argv) > 1 else '/tmp/canon_remeasure.csv'
sweep = sys.argv[2] if len(sys.argv) > 2 else '/tmp/strict_sweep'
for r in csv.DictReader(open(remeasure)):
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
    print('\t'.join([r['corpus'], r['mode'], r['test'], r['old'], r['new'], g, o, b,
                     str(len(ds))]))
