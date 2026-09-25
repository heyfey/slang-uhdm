#!/usr/bin/env python3
"""r11u172 mover predictor, run on the PRISTINE sweep's databases before the law sweep.

predict.py <pristine sweep workdir> <out.csv> [jobs]

Per row-mode directory (<wd>/{surelog,uhdm2rtlil}/<mode>/<test>-<hash>/slang.uhdm) and per
probe database (<wd>/probe/*.uhdm), predicts which of the four r11u172 laws can change the
bytes, from the pristine database (uhdm-dump) and, for the FILE axis, the strict record dumps
of golden vs pristine:
  VALUE  a constant under a range whose decompile is an unsized decimal with a leading zero
         (or '_' separators) and whose UINT value is not that digit text;
  SPAN   a $signed / $unsigned sys_func_call whose span is longer than its name;
  DEPTH  a cast operation (vpiOpType 67) in the elaborated package listing (uhdmtopPackages);
  FILE   a struct / union / enum typespec whose file differs from golden's (strict dumps).
Fail-closed fence: refuses to run without $FENCED (4 names) and never opens a fenced row.
"""
import os, re, sys, glob, subprocess
from concurrent.futures import ThreadPoolExecutor

FENCED = os.environ.get('FENCED', '').split()
if len(FENCED) != 4:
    sys.exit('predict: FENCED must hold the 4 fenced names (fail closed)')
fre = re.compile(r'\b(' + '|'.join(map(re.escape, FENCED)) + r')\b')
DUMP = os.environ['UHDM_DUMP']; SCMP = os.environ['STRICT_CMP']
wd, out = sys.argv[1], sys.argv[2]; jobs = int(sys.argv[3]) if len(sys.argv) > 3 else 3

def golden_of(d):
    try:
        t = open(os.path.join(d, 'cmds.txt')).read()
    except OSError:
        return None
    m = re.search(r'(/\S*slang-uhdm-goldens/[0-9a-f]+)', t)
    return os.path.join(m.group(1), 'golden.uhdm') if m else None

def dump_preds(db):
    try:
        txt = subprocess.run([DUMP, db], capture_output=True, text=True, errors='replace', timeout=900).stdout
    except subprocess.TimeoutExpired:
        return {'TIMEOUT'}
    p = set()
    lines = txt.split('\n')
    sec = ''
    for i, l in enumerate(lines):
        if l.startswith('|uhdm'):
            sec = l
        m = re.search(r'\\_sys_func_call: \((\$signed|\$unsigned)\), .*line:(\d+):(\d+), endln:(\d+):(\d+)', l)
        if m:
            nm, a, b, c, e = m.group(1), *map(int, m.group(2, 3, 4, 5))
            if c != a or e - b != len(nm):
                p.add('SPAN')
        if 'vpiOpType:67' in l and sec.startswith('|uhdmtopPackages'):
            p.add('DEPTH')
        m = re.match(r'\s*\|vpiDecompile:([0-9_]+)$', l)
        if m and (m.group(1).startswith('0') and len(m.group(1).replace('_', '')) > 1 or '_' in m.group(1)):
            dig = m.group(1).replace('_', '')
            for k in range(i + 1, min(i + 6, len(lines))):
                v = re.match(r'\s*\|UINT:(\S+)$', lines[k])
                if v:
                    if v.group(1) != dig:
                        p.add('VALUE')
                    break
    return p

def strict_file_pred(g, db, tmp):
    a, b = tmp + '.a', tmp + '.b'
    try:
        subprocess.run([SCMP, '--max', '0', '--dump-a', a, '--dump-b', b, g, db],
                       capture_output=True, timeout=900)
    except subprocess.TimeoutExpired:
        return {'TIMEOUT'}
    p = set()
    try:
        # name-keyed multiset of (type, name, span) -> files, on each side
        def files(fn):
            m = {}
            for l in open(fn, errors='replace'):
                x = l.rstrip('\n').split('\t')
                if len(x) < 10 or x[1] not in ('struct_typespec', 'union_typespec', 'enum_typespec') or not x[2]:
                    continue
                m.setdefault((x[1], x[2], x[6], x[7], x[8], x[9]), set()).add(x[5])
            return m
        if not (os.path.exists(a) and os.path.exists(b)):
            # stage 1 (uhdm-cmp) rejects the pair and no record dump is written: fall back to
            # "any named aggregate typespec in a multi-file row" (a superset)
            return {'FILE?'}
        A, B = files(a), files(b)
        for k, fb in B.items():
            fa = A.get(k)
            if fa is not None and fa != fb:
                p.add('FILE')
                break
    finally:
        for f in (a, b):
            try: os.unlink(f)
            except OSError: pass
    return p

def job(item):
    kind, d, db, key = item
    if fre.search(key):
        return key, 'FENCED', ''
    if not os.path.exists(db) or os.path.getsize(db) == 0:
        return key, 'NODB', ''
    p = dump_preds(db)
    g = golden_of(d) if kind == 'corpus' else os.path.join(d, key + '.golden')
    if kind == 'corpus' and g and os.path.exists(g):
        p |= strict_file_pred(g, db, '/tmp/r11u172_pred_' + re.sub(r'\W', '_', key))
    return key, 'OK', ' '.join(sorted(p))

items = []
for corpus in ('surelog', 'uhdm2rtlil'):
    for d in sorted(glob.glob(os.path.join(wd, corpus, '*', '*'))):
        mode = os.path.basename(os.path.dirname(d)); test = re.sub(r'-[0-9a-f]{8}$', '', os.path.basename(d))
        items.append(('corpus', d, os.path.join(d, 'slang.uhdm'), f'{corpus}/{mode}/{test}'))
for db in sorted(glob.glob(os.path.join(wd, 'probe', '*.uhdm'))):
    items.append(('probe', os.path.dirname(db), db, 'probe/' + os.path.basename(db)[:-5]))
prev = {}
if os.path.exists(out):   # resumable: keep the rows an earlier run completed
    for l in open(out).read().splitlines()[1:]:
        x = l.split(',')
        if len(x) == 3: prev[x[0]] = l
items = [it for it in items if it[3] not in prev]
with ThreadPoolExecutor(jobs) as ex, open(out, 'w') as f:
    f.write('row,state,predicted\n')
    for l in prev.values():
        f.write(l + '\n')
    for key, st, pr in ex.map(job, items):
        f.write(f'{key},{st},{pr}\n'); f.flush()
print('predict: rows', len(items))
