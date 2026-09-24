#!/usr/bin/env python3
"""r11u119 census: per downstream row, the location/value FACES on which
slang-uhdm's database differs from the Surelog lane's golden (uhdm2rtlil's
own Surelog, downstream flags), order-blind over locdump rows.

  cen119.py <downstream workdir> <out.tsv> [name-regex]

Faces (each row of the diff is keyed by type(name) + parent chain):
  IMPL     ours carries a VpiFile where golden's object has none (L2)
  DECLEND  a *_var / *_net whose start agrees and whose END differs (L1)
  COLS     same object, same start line, different columns (L3 shape)
  REAL     an attribute whose REAL: value text differs (L4)
  POPNET   a definition-view logic_net only ours lists (population extra)
  OTHER    anything else (population / other faces)
Prints per row the face counts; the prediction for the law is every row
with IMPL/DECLEND/COLS/REAL > 0.
"""
import collections, os, re, subprocess, sys
import os
REPO = os.environ.get('REPO') or os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", ".."))
sys.path.insert(0, os.path.join(REPO, 'scripts'))
import downstream_uhdm2rtlil as ds, verify_golden as vg  # noqa: E402
LD = os.environ.get('LOCDUMP', '/tmp/r11u119_scr/locdump')
wd, out = sys.argv[1], sys.argv[2]
flt = sys.argv[3] if len(sys.argv) > 3 else None
# CORPUS mode: <wd> is a verify_golden workdir (…/<mode>/<test>-<hash>/ with
# cmds.txt naming the golden cache entry); DOWNSTREAM mode otherwise.
corpus = any(os.path.isdir(os.path.join(wd, m)) for m in ('default', 'testflags'))
if corpus:
    tests = {}
    for m in ('default', 'testflags'):
        md = os.path.join(wd, m)
        if not os.path.isdir(md):
            continue
        for t in sorted(os.listdir(md)):
            if flt and not re.search(flt, t):
                continue
            tests[m + '/' + t] = (os.path.join(md, t), None)
else:
    tests = vg.discover_uhdm2rtlil(flt)
row_re = re.compile(r'^(\S+) (\S+) (\d+)\.(\d+)-(\d+)\.(\d+)( val=\S*)?(.*)$')

def rows(path):
    r = subprocess.run([LD, path, '--val'], capture_output=True, text=True)
    c = collections.Counter()
    for l in r.stdout.splitlines():
        m = row_re.match(l)
        if m:
            c[m.groups()] += 1
    return c

res = []
for n, (d, p) in sorted(tests.items()):
    if corpus:
        g = None
        try:
            for l in open(os.path.join(d, 'cmds.txt')):
                mm = re.search(r'golden cache hit (\S+)\)', l)
                if mm:
                    g = os.path.join(mm.group(1), 'golden.uhdm')
        except OSError:
            pass
        if g and not os.path.isfile(g):
            g = None
        o = os.path.join(d, 'slang.uhdm')
    else:
        rest = [x for x in p if x not in ('-parse', '-nobuiltin', '-nocache')]
        sl = ['-parse', '-nobuiltin', '-nocache'] + ds.DOWNSTREAM_FLAGS + rest
        g = ds.surelog_db(d, sl, os.path.join(os.environ.get('SCRATCH', '/tmp/r11u119_cenw'), n), 300)
        o = os.path.join(wd, n, 'slang.uhdm')
    if not g or not os.path.isfile(o):
        res.append((n, 'NODB', {}))
        continue
    G, O = rows(g), rows(o)
    onlyG, onlyO = G - O, O - G
    faces = collections.Counter()
    # key without file/span/value: (type(name), chain)
    def k(t):
        return (t[0], t[7])
    gi = collections.defaultdict(list)
    for t, c in onlyG.items():
        gi[k(t)] += [t] * c
    used = set()
    for t, c in onlyO.items():
        for _ in range(c):
            cand = gi.get(k(t), [])
            hit = None
            for i, u in enumerate(cand):
                if id(u) in used:
                    continue
                if u[1] == '-' and t[1] != '-' and u[2:6] == t[2:6]:
                    hit = ('IMPL', i); break
                if u[2:4] == t[2:4] and u[1] == t[1] and u[4:6] != t[4:6] and \
                        re.match(r'^[a-z_]*_(var|net)\(', t[0]):
                    hit = ('DECLEND', i); break
                if u[6] != t[6] and u[2:6] == t[2:6] and (t[6] or '').startswith(' val=REAL:'):
                    hit = ('REAL', i); break
                if u[2] == t[2] and u[1] == t[1] and (u[3], u[5]) != (t[3], t[5]):
                    hit = ('COLS', i); break
            if hit:
                faces[hit[0]] += 1
                cand.pop(hit[1])
            elif t[0].startswith('logic_net(') and t[1] != '-' and \
                    re.match(r'^ <- (module_inst|interface_inst|program)\(\)@', t[7]):
                # a definition-view net ONLY ours lists (population extra):
                # § implicitNetNoFile119 clears its file if it is implicit
                faces['POPNET'] += 1
            else:
                faces['OTHER'] += 1
    res.append((n, 'OK', faces))
with open(out, 'w') as f:
    for n, st, fc in res:
        f.write('%s\t%s\t%s\n' % (n, st, ' '.join('%s=%d' % kv for kv in sorted(fc.items()))))
pred = [n for n, st, fc in res if any(fc.get(x) for x in ('IMPL', 'DECLEND', 'COLS', 'REAL'))]
print('ROWS=%d PREDICTED=%d' % (len(res), len(pred)))
