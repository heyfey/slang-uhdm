#!/usr/bin/env python3
# predict171.py <sweep workdir> <out.tsv> : predicts, from the PRISTINE databases of a sweep (corpus rows under
# <wd>/{surelog,uhdm2rtlil}/<mode>/<row>-<hash>/slang.uhdm and probe cases <wd>/probe/*.uhdm), which rows the r11u172
# TypeEmit laws and the r11u171 laws can move.  Fail-closed on $FENCED (every fenced name skipped by word boundary,
# and the script refuses to run without the four names).  One line per (row, law) with the trigger count.
import os, re, subprocess, sys, glob
FENCED = os.environ.get('FENCED', '').split()
if len(FENCED) != 4:
    sys.exit('predict171: FENCED must hold the four fenced names')
fre = re.compile(r'\b(' + '|'.join(map(re.escape, FENCED)) + r')\b')
CEN = os.environ.get('CEN171', '/tmp/r11u171_scr/tools/cen171')
env = dict(os.environ, LD_LIBRARY_PATH=os.path.expanduser('~/.local/lib64') + ':' + os.path.expanduser('~/.local/lib'))
wd, out = sys.argv[1], sys.argv[2]
srccache = {}
def lines(path):
    if fre.search(path):
        raise SystemExit('predict171: fenced source refused: ' + path)
    if path not in srccache:
        try:
            srccache[path] = open(path, errors='replace').read().split('\n')
        except OSError:
            srccache[path] = None
    return srccache[path]
SRCEXT = ('.sv', '.v', '.svh', '.vh', '.svi', '.h', '.inc', '.vlib', '.pkg', '.sva')
def roots_of(cmds):
    toks = []
    for l in open(cmds):
        if l.startswith('slang:'):
            toks = l.split()[1:]
    return {os.path.basename(t) for t in toks if t.lower().endswith(SRCEXT)}, any(t == '-f' or t.endswith('.f') for t in toks)
def census(db):
    r = subprocess.run([CEN, db], capture_output=True, text=True, env=env, timeout=600)
    return r.stdout.split('\n')
def judge(db, roots, rootsUnknown):
    hits = {}
    def hit(k): hits[k] = hits.get(k, 0) + 1
    cen = census(db)
    # a moved typedef can only change FILE when the design spans two files
    files = {l.split(' ')[1] for l in cen if l.startswith(('MEM ', 'NET ')) and l.split(' ')[1] != '-'}
    files |= {l.split(' ')[2] for l in cen if l.startswith('AGG ') and l.split(' ')[2] != '-'}
    multi = len(files) > 1
    for ln in cen:
        f = ln.split(' ')
        if not f or not f[0]:
            continue
        k = f[0]
        if k == 'VAL': hit('VALUE172')
        elif k == 'SGN': hit('SPAN172')
        elif k == 'UNF': hit('CASTUNIONFILE171')
        elif k == 'CAD': hit('SELDECSHARE171')
        elif k == 'SWL': hit('UDPSWALLOW171')
        elif k == 'MEM':
            if f[1] != '-' and (rootsUnknown or os.path.basename(f[1]) not in roots): hit('MEMBERROOTFILE171')
        elif k == 'AGG':
            path, L, C, EL, EC = f[2], int(f[3]), int(f[4]), int(f[5]), int(f[6])
            if path == '-' or L == 0 or not multi:
                continue
            src = lines(path)
            if src is None or L > len(src) or EL > len(src):
                hit('FILE172'); continue
            # the declaration's own span starts at its keyword (`typedef`
            # for an enum, the aggregate keyword otherwise) and its end line
            # holds the closing brace; anything else was moved
            st = src[L - 1][C - 1:].lstrip()
            en = src[EL - 1][:max(EC - 1, 0)]
            if not st.startswith(('struct', 'union', 'enum', 'typedef')) or '}' not in en:
                hit('FILE172')
        elif k == 'NET':
            path, L, EL = f[1], int(f[2]), int(f[4])
            if path == '-' or L == 0:
                continue
            src = lines(path)
            if src is None:
                hit('NETENDCOL171'); continue
            if any('`' in src[i - 1] for i in range(L, min(EL, len(src)) + 1)):
                hit('NETENDCOL171')
        elif k == 'SPT':
            hit('SPLITPORTKEY171')
        elif k == 'GTE':
            hit('GENELSEIF171')
    return hits
rows = []
for corpus in ('surelog', 'uhdm2rtlil'):
    for mode in ('default', 'testflags'):
        for d in sorted(glob.glob(os.path.join(wd, corpus, mode, '*'))):
            name = os.path.basename(d).rsplit('-', 1)[0]
            if fre.search(name):
                continue
            db = os.path.join(d, 'slang.uhdm')
            if not os.path.isfile(db) or not os.path.isfile(os.path.join(d, 'cmds.txt')):
                continue
            rows.append((corpus + '/' + mode + '/' + name, db, os.path.join(d, 'cmds.txt')))
for db in sorted(glob.glob(os.path.join(wd, 'probe', '*.uhdm'))):
    name = os.path.basename(db)[:-5]
    if fre.search(name):
        continue
    rows.append(('probe/' + name, db, None))
with open(out, 'w') as o:
    for key, db, cmds in rows:
        roots, unk = (roots_of(cmds) if cmds else ({'dut.sv'}, False))
        try:
            h = judge(db, roots, unk)
        except subprocess.TimeoutExpired:
            h = {'TIMEOUT': 1}
        for law, n in sorted(h.items()):
            o.write('%s\t%s\t%d\n' % (key, law, n))
        o.flush()
print('rows', len(rows))
