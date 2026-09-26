#!/usr/bin/env python3
"""predict.py <census dir>: the predicted mover set of the law binary, from the census logs
(census.sh + tracewrap.sh): one line per surelog/uhdm2rtlil row-mode or probe case with the laws
that fired on it.  FAIL-CLOSED on $FENCED: refuses to run without the four names and drops any
fenced name (the census never dispatches one)."""
import os, re, sys
fenced = os.environ.get('FENCED', '').split()
if len(fenced) != 4:
    sys.exit('predict.py: export FENCED (four names) first')
d = sys.argv[1]
out = {}
for corpus, log in (('surelog', 'census_surelog.log'), ('uhdm2rtlil', 'census_u2r.log'),
                    ('probe', 'census_probe.log')):
    p = os.path.join(d, log)
    if not os.path.exists(p):
        continue
    for line in open(p):
        f = line.split()
        if len(f) < 4:
            continue
        path, law = f[0], ' '.join(f[3:])
        if corpus == 'probe':
            key = os.path.basename(path)[:-len('.uhdm')].replace('__', '/')
            mode = '-'
        else:
            m = re.search(r'/(default|testflags)/(.+)-[0-9a-f]{8}/slang\.uhdm$', path)
            if not m:
                continue
            mode, key = m.group(1), m.group(2)
            if key in fenced:
                continue
        out.setdefault((corpus, key, mode), set()).add(law.replace('R11U174_TRACE ', ''))
# Byte-changing branches: every firing except the no-op traces (a location written equal, an abstain,
# a logic-typed cast whose alias is never written).
NOOP = {'ASMSPAN same', 'MOPUNLOC abstain', 'DEPTH172 top logic alias'}
mode_all = len(sys.argv) > 2 and sys.argv[2] == '--all'
for (c, k, m), laws in sorted(out.items()):
    mv = sorted(l for l in laws if l not in NOOP)
    if mode_all or mv:
        print(f'{c}\t{k}\t{m}\t{",".join(sorted(laws))}\t{"MOVER" if mv else "noop"}')
