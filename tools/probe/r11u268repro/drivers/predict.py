#!/usr/bin/env python3
# r11u268 predict.py <census workroot>: the BYTE-MOVER prediction from the firing census' traces. A
# macroStrBodyLen268 'event' whose literal end is already golden's and whose correction is 0, or which finds no
# object at or past its threshold, moves nothing: only a 'move' line (an object re-laid by the drain) or a
# pkgQualOvrPatInitSpan268 firing (struct-qual, struct-gen, bit-qual, bit-gen) predicts a byte mover. Abstentions
# are counted apart. Fail-closed on $FENCED: a trace naming a fenced path is refused.
import os, re, sys, collections
W = sys.argv[1]
FZ = os.environ.get('FENCED', '').split()
if len(FZ) != 4: sys.exit('predict.py: FENCED unset')
fz = re.compile(r'(?<![A-Za-z0-9_])(?:%s)(?![A-Za-z0-9_])' % '|'.join(map(re.escape, FZ)))
hits = collections.defaultdict(collections.Counter)
for f in os.listdir(W + '/trace'):
    key = None
    for l in open(W + '/trace/' + f).read().splitlines():
        if l.startswith('OUT '):
            out = l[4:]
            if fz.search(out): sys.exit('FENCED path in a trace: refused')
            m = re.search(r'/(surelog|uhdm2rtlil)/(default|testflags)/(.+?)-[0-9a-f]{8}/', out)
            md = re.search(r'/downstream/([^/]+)/', out)
            key = (f'{m.group(1)} {m.group(3)}/{m.group(2)}' if m else
                   f'downstream {md.group(1)}' if md else 'probe ' + out.replace(W + '/probe/', ''))
            continue
        law, _, det = l.partition(' ')
        w = det.split()[0] if det else ''
        if w == "event":
            w = 'event-noop' if det.endswith('corr 0') and re.search(r'end (\d+)->\1 ', det) else 'event'
        hits[key][law + ':' + w] += 1
mv = ('macroStrBodyLen268:move', 'pkgQualOvrPatInitSpan268:struct-qual', 'pkgQualOvrPatInitSpan268:struct-gen',
      'pkgQualOvrPatInitSpan268:bit-qual', 'pkgQualOvrPatInitSpan268:bit-gen')
n = 0
for k in sorted(hits):
    tag = 'PREDICTED-MOVER' if any(x in hits[k] for x in mv) else 'no-move'
    n += tag == 'PREDICTED-MOVER'
    print(tag, k, ' '.join(f'{a}={b}' for a, b in sorted(hits[k].items())))
print('predicted byte movers:', n)
