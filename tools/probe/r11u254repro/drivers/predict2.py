#!/usr/bin/env python3
# r11u254 predict2.py <census workdir>: the frozen mover prediction from the firing census traces, counting only the
# firings that WRITE (a trace detail starting with `abstain` or `keep` is an abstention or a same-value visit).
# One line per database: <corpus> <row>/<mode> | probe <db>, then law:count. Fail-closed on $FENCED.
import os, re, sys, collections
W = sys.argv[1]
F = os.environ.get('FENCED', '').split()
if len(F) != 4: sys.exit('predict2.py: FENCED unset')
fz = re.compile(r'(?<![A-Za-z0-9_])(?:%s)(?![A-Za-z0-9_])' % '|'.join(map(re.escape, F)))
hits = collections.defaultdict(collections.Counter)
for f in os.listdir(f'{W}/trace'):
    key = None
    for l in open(f'{W}/trace/{f}').read().splitlines():
        if l.startswith('OUT '):
            out = l[4:]
            if fz.search(out): sys.exit('FENCED path in a trace: refused')
            m = re.search(r'/(surelog|uhdm2rtlil)/(default|testflags)/(.+?)-[0-9a-f]{8}/', out)
            key = f'{m.group(1)} {m.group(3)}/{m.group(2)}' if m else 'probe ' + out.replace(W + '/probe/', '')
            continue
        if not key: continue
        law, _, det = l.partition(' ')
        if det.startswith('abstain') or det.startswith('keep'): continue
        hits[key][law] += 1
for k in sorted(hits):
    print(k, ' '.join(f'{law}:{n}' for law, n in sorted(hits[k].items())))
