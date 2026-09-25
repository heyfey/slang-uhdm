#!/usr/bin/env python3
"""objcheck.py <law workdir root> <pristine workdir root> <corpus: surelog|uhdm2rtlil> [out.tsv]

For every row-mode whose slang.uhdm bytes differ between the two sweeps (same relative paths), run the strict
comparator's record dump (golden vs pristine, golden vs law) and pair the records by walk index; per location/name
field count IMPROVED (law == golden != pristine), WORSENED (pristine == golden != law), NEUTRAL (both differ from
golden, differently).  A row whose walk lengths differ is flagged WALK.  Refuses to run without FENCED and skips
fenced rows (word boundary)."""
import os, re, subprocess, sys
fenced = os.environ.get('FENCED', '').split()
if not fenced:
    sys.exit('REFUSE: FENCED unset')
law, pris, corpus = sys.argv[1], sys.argv[2], sys.argv[3]
out = open(sys.argv[4], 'w') if len(sys.argv) > 4 else sys.stdout
sc = os.environ['STRICT_CMP']
FIELDS = ['depth', 'type', 'name', 'defname', 'fullname', 'file', 'line', 'col', 'endline', 'endcol',
          'decompile', 'size', 'value', 'consttype']
tot = {'improved': 0, 'worsened': 0, 'neutral': 0}
rows = 0
for mode in ('default', 'testflags'):
    dl, dp = os.path.join(law, corpus, mode), os.path.join(pris, corpus, mode)
    if not os.path.isdir(dl):
        continue
    for d in sorted(os.listdir(dl)):
        name = d.rsplit('-', 1)[0]
        if any(re.search(r'(^|[^A-Za-z0-9_])%s([^A-Za-z0-9_]|$)' % re.escape(f), name) for f in fenced):
            continue
        a, b = os.path.join(dl, d, 'slang.uhdm'), os.path.join(dp, d, 'slang.uhdm')
        if not (os.path.exists(a) and os.path.exists(b)):
            continue
        if open(a, 'rb').read() == open(b, 'rb').read():
            continue
        cmds = open(os.path.join(dl, d, 'cmds.txt')).read()
        m = re.search(r'golden cache \w+ ([^)\s]+)', cmds)
        g = os.path.join(m.group(1), 'golden.uhdm') if m else os.path.join(dl, d, 'golden.uhdm')
        if not os.path.exists(g):
            print('%s\t%s\tNO_GOLDEN' % (name, mode), file=out); continue
        tmp = '/tmp/r11u166_objcheck'
        os.makedirs(tmp, exist_ok=True)
        for tag, db in (('p', b), ('l', a)):
            subprocess.run([sc, '--max', '0', '--dump-a', tmp + '/g.rec', '--dump-b', tmp + '/%s.rec' % tag, g, db],
                           capture_output=True, timeout=900)
        # Streamed (the UVM / Earlgrey record lists are large): the three
        # dumps are read in lockstep.  Beyond a depth/type divergence of golden
        # from pristine the pairing is not meaningful: counted as WALK.
        c = {'improved': 0, 'worsened': 0, 'neutral': 0}
        flag = ''
        with open(tmp + '/g.rec') as fg, open(tmp + '/p.rec') as fp, open(tmp + '/l.rec') as fl:
            for lg, lp, ll in zip(fg, fp, fl):
                if lp == ll:
                    continue
                G = lg.rstrip('\n').split('\t')
                P = lp.rstrip('\n').split('\t')
                L = ll.rstrip('\n').split('\t')
                if G[:2] != P[:2] or P[:2] != L[:2]:
                    flag = 'WALK'
                    continue
                for j in range(min(len(G), len(P), len(L))):
                    if P[j] == L[j]:
                        continue
                    if L[j] == G[j]:
                        c['improved'] += 1
                    elif P[j] == G[j]:
                        c['worsened'] += 1
                    else:
                        c['neutral'] += 1
        rows += 1
        for k in c:
            tot[k] += c[k]
        print('%s\t%s\t%d\t%d\t%d\t%s' % (name, mode, c['improved'], c['worsened'], c['neutral'], flag), file=out)
        out.flush()
print('TOTAL rows=%d improved=%d worsened=%d neutral=%d' % (rows, tot['improved'], tot['worsened'], tot['neutral']),
      file=out)
