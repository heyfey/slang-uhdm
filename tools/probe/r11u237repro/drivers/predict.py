#!/usr/bin/env python3
# (r11u237: copied from r11u231repro/drivers; the trace switch writes <pid>.237.)
# predict.py <corpus trace dir> <corpus workdir> <probe census file (fire.py output over tests/probe)> <out>:
# the byte-mover prediction, frozen before the law sweep: every corpus row-mode whose run wrote an R11U237_TRACE
# firing (the trace's OUT line names the database under the census workdir) and every probe case fire.py saw fire.
# Each law traces on every branch that writes (the switch sites), so a database no law fired on keeps its bytes.
# Fenced rows are refused (fail closed on $FENCED). The output carries its own md5 and a UTC time stamp.
import os, re, sys, glob, hashlib, datetime
F = os.environ.get('FENCED', '').split()
if len(F) != 4: sys.exit('predict.py: FENCED unset')
fre = re.compile(r'\b(' + '|'.join(map(re.escape, F)) + r')\b')
tdir, wd, probe, out = sys.argv[1:5]
rows = {}
for f in glob.glob(tdir + '/*'):
    lines = open(f, errors='replace').read().splitlines()
    if not lines or not lines[0].startswith('OUT '): continue
    o = os.path.relpath(lines[0][4:], wd)
    m = re.match(r'(surelog|uhdm2rtlil)/(default|testflags)/(.+)-[0-9a-f]+/slang\.uhdm$', o)
    if not m: continue
    key = f'{m.group(1)}/{m.group(2)}/{m.group(3)}'
    if fre.search(key): continue
    laws = rows.setdefault(key, set())
    for l in lines[1:]:
        if l.strip(): laws.add(l.split()[0])
for l in open(probe):
    p = l.split()
    if len(p) < 3 or p[2] == 'fired=-': continue
    rel = p[0].replace('tests/probe/', 'probe/')
    if fre.search(rel): continue
    rows.setdefault(rel, set()).update(p[2][6:].split(','))
body = ''.join(f'{k} {",".join(sorted(v))}\n' for k, v in sorted(rows.items()))
md5 = hashlib.md5(body.encode()).hexdigest()
with open(out, 'w') as fo:
    fo.write(f'# r11u237 byte-mover prediction, frozen {datetime.datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ")}, '
             f'{len(rows)} databases, body md5 {md5}\n' + body)
print(f'{len(rows)} predicted, body md5 {md5}')
