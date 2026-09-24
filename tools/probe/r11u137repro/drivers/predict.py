#!/usr/bin/env python3
# predict.py <pristine wd> <out.tsv>  -> per corpus row (both corpora): the laws whose FACE the PRISTINE
# database (uhdm-dump text) or the row's source carries.  Written before the mover set is read; a row
# with no predicted law must not move.
import sys, os, re, glob, subprocess, csv
from concurrent.futures import ThreadPoolExecutor
P, OUT = sys.argv[1], sys.argv[2]
DUMP = os.environ.get('UHDM_DUMP', '/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump')
C = '/tmp/r11u137_scr/pdump'; os.makedirs(C, exist_ok=True)
def rows():
    for corpus in ('surelog', 'uhdm2rtlil'):
        for d in glob.glob(f'{P}/{corpus}/*/*'):
            if os.path.isfile(d + '/slang.uhdm'):
                yield corpus, d.split('/')[-2], d
SR = '/home/heyfey/git-repos/slang-uhdm/third_party/Surelog'
U2 = '/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil/test'
SLDIR = {}
for base in (SR + '/tests', SR + '/third_party/tests'):
    for f in glob.glob(base + '/*/*.sl') + glob.glob(base + '/*/*/*.sl'):
        SLDIR.setdefault(os.path.basename(f)[:-3], os.path.dirname(f))
def srcs(corpus, name):
    cwd = SLDIR.get(name) if corpus == 'surelog' else U2 + '/' + name
    out = ''
    if cwd and os.path.isdir(cwd):
        for f in glob.glob(cwd + '/**/*', recursive=True)[:2000]:
            if f.endswith(('.sv', '.v', '.svh', '.vh')) and os.path.isfile(f):
                try: out += open(f, errors='replace').read() + '\n'
                except: pass
    return out
def feat(item):
    corpus, mode, d = item
    key = d.replace('/', '__')
    df = f'{C}/{key}.txt'
    if not os.path.isfile(df):
        with open(df, 'w') as fo:
            subprocess.run(['timeout', '600', DUMP, d + '/slang.uhdm'], stdout=fo, stderr=subprocess.DEVNULL)
    txt = open(df, errors='replace').read()
    name0 = re.sub(r'-[0-9a-f]{8}$', '', os.path.basename(d))
    src = srcs(corpus, name0)
    L = txt.split('\n')
    laws = set()
    # indentation-aware ancestor scan
    stack = []
    for i, ln in enumerate(L):
        ind = len(ln) - len(ln.lstrip(' '))
        s = ln.strip()
        while stack and stack[-1][0] >= ind: stack.pop()
        anc = [a[1] for a in stack]
        if s.startswith('\\_packed_array_typespec: (') and i and L[i-1].strip() == '|vpiTypedef:': laws.add('PATD')
        if s.startswith('\\_func_call:') and any(a.startswith('\\_range:') or a == '|vpiCondition:' for a in anc): laws.add('CALLSPAN')
        if s.startswith('\\_hier_path:') and any(a.startswith('\\_range:') or a == '|vpiCondition:' for a in anc): laws.add('PATHBASE')
        if s.startswith('\\_constant:') and i and L[i-1].strip() == '|vpiHighConn:': laws.add('REPLTSNAME?')
        if s.startswith('\\_operation:') and i and L[i-1].strip() == '|vpiHighConn:': laws.add('PORT')
        if s.startswith('\\_clocking_block:'): laws.add('CLK')
        if s.startswith('\\_array_typespec: (') and '::' in s: laws.add('SCOPEDARRTD')
        if s.startswith('\\_') or s.startswith('|vpi') and s.endswith(':'):
            stack.append((ind, s))
    if '|vpiOpType:36' in txt: laws.add('EMPTYCONN')
    if '|vpiDPIPure:1' in txt: laws.add('PUREVIRTSPAN')
    if '|vpiNetDeclAssign:1' in txt: laws.add('NDA')
    if '\\_cont_assign:' in txt: laws.add('CA')
    if re.search(r'\b(bit|logic|reg)\s+unsigned\b(?!\s*\[)', src): laws.add('UNSIGNEDSPAN')
    if re.search(r'\bunion\s+tagged\b', src): laws.add('TAGGEDSPAN')
    if re.search(r'\b(parameter|localparam)\s+type\b', src): laws.add('DEFNETTP')
    if re.search(r'\btypedef\s+[A-Za-z_]\w*\s+[A-Za-z_]\w*\s*\[', src): laws.add('ALIASFILE')
    if 'REPLTSNAME?' in laws:
        laws.discard('REPLTSNAME?')
        if re.search(r'\{\s*[\w\']+\s*\{', src): laws.add('REPLTSNAME')
    if mode == 'testflags' and ('\\_function:' in txt or '\\_task:' in txt or '\\_always:' in txt or
                                '\\_initial:' in txt or '\\_cont_assign:' in txt or '\\_final_stmt:' in txt):
        laws.add('ELABCLONE')
    name = re.sub(r'-[0-9a-f]{8}$', '', os.path.basename(d))
    return corpus, name, mode, ','.join(sorted(laws))
items = list(rows())
with ThreadPoolExecutor(3) as ex:
    res = list(ex.map(feat, items))
with open(OUT, 'w') as f:
    for r in sorted(res): f.write('\t'.join(r) + '\n')
print(len(res), 'rows;', sum(1 for r in res if r[3]), 'with a predicted face')
