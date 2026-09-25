#!/usr/bin/env python3
# predict.py <pristine wd> <out.tsv> -> per corpus row: the verifier refinements of v11u146 (the three R11V146_*
# switches) whose FACE the row's SOURCE carries: regexes over every .sv/.v/.svh/.vh/.inc file under the
# test directory, the files and -I directories its command line names, and the UVM library when the row
# uses it.  Each file is scanned once (memoized); a row's set is the union over its files.  Written and
# run BEFORE the mover set is read; a row with no predicted law must not move.  Over-prediction is
# allowed, under-prediction is a failed prediction.
import sys, os, re, glob
# The slang-fenced tests are skipped (their names come from $FENCED, space separated, never spelled here).
FENCED = set(os.environ.get('FENCED', '').split())
if len(FENCED) != 4:
    sys.exit('predict.py: export FENCED (the four slang-fenced test names, space separated) first; it refuses to scan without them (v11u146)')
P, OUT = sys.argv[1], sys.argv[2]
SR = '/home/heyfey/git-repos/slang-uhdm/third_party/Surelog'
U2 = '/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil/test'
SLDIR = {}
for base in (SR + '/tests', SR + '/third_party/tests'):
    for f in glob.glob(base + '/*/*.sl') + glob.glob(base + '/*/*/*.sl'):
        SLDIR.setdefault(os.path.basename(f)[:-3], os.path.dirname(f))
EXT = ('.sv', '.v', '.svh', '.vh', '.inc')
M = re.M
RX = {
 # § tfArgDpiNoWrite146v: an enum typedef and a DPI import prototype in one file
 'TFARGDPI': [re.compile(r'\btypedef\s+enum\b'), re.compile(r'\bimport\s+"DPI(?:-C)?"[^;]*\(')],
 # § tpDefaultCaIfaceKeeps146v: an interface with a type parameter defaulted over a sized vector
 'TPCALHSIF': [re.compile(r'\binterface\b'), re.compile(r'\btype\s+[A-Za-z_]\w*\s*=\s*(?:logic|bit|reg)\s*(?:signed\s*)?\[[^\]]*[A-Za-z_]')],
 # § tfArgAliasEndFollows146v: a typedef of a named type next to an enum typedef and a subroutine
 'TFARGALIAS': [re.compile(r'\btypedef\s+enum\b'), re.compile(r'\btypedef\s+[A-Za-z_]\w*(?:::[A-Za-z_]\w*)?\s+[A-Za-z_]\w*\s*;'), re.compile(r'\b(?:function|task)\b[^;]*\(')],
}
MEMO = {}
def scan(f):
    if f not in MEMO:
        try: t = open(f, errors='replace').read()
        except Exception: t = ''
        MEMO[f] = {k for k, rs in RX.items() if all(r.search(t) for r in rs)}
    return MEMO[f]
UVMFILES = None
def uvmfiles():
    global UVMFILES
    if UVMFILES is None:
        UVMFILES = [f for f in glob.glob(SR + '/third_party/UVM/**/*', recursive=True) if f.endswith(EXT) and os.path.isfile(f)]
    return UVMFILES
def files(corpus, name, cmd):
    cwd = SLDIR.get(name) if corpus == 'surelog' else U2 + '/' + name
    out = []
    if cwd and os.path.isdir(cwd):
        out += [f for f in glob.glob(cwd + '/**/*', recursive=True)[:3000] if f.endswith(EXT) and os.path.isfile(f)]
        for tok in cmd.split():
            for t in ([tok[2:]] if tok.startswith('-I') else [tok]):
                p = os.path.normpath(os.path.join(cwd, t))
                if os.path.isfile(p) and p.endswith(EXT):
                    out.append(p)
                elif os.path.isdir(p) and tok.startswith('-I'):
                    out += [f for f in glob.glob(p + '/*') if f.endswith(EXT)]
    if 'uvm' in cmd.lower() or any('uvm' in os.path.basename(f).lower() for f in out):
        out += uvmfiles()
    return out
rows = []
for corpus in ('surelog', 'uhdm2rtlil'):
    for d in sorted(glob.glob(f'{P}/{corpus}/*/*')):
        if not os.path.isfile(d + '/cmds.txt'): continue
        mode = d.split('/')[-2]
        name = re.sub(r'-[0-9a-f]{8}$', '', os.path.basename(d))
        if name in FENCED: continue
        cmd = open(d + '/cmds.txt').read()
        laws = set()
        for f in files(corpus, name, cmd):
            laws |= scan(f)
        if '--elabuhdm' in cmd: laws.add('ELABUHDM')
        rows.append((corpus, mode, name, ','.join(sorted(laws))))
with open(OUT, 'w') as fo:
    fo.write('corpus\tmode\tname\tlaws\n')
    for r in rows: fo.write('\t'.join(r) + '\n')
print(len(rows), 'rows;', sum(1 for r in rows if r[3].replace('ELABUHDM', '').strip(',')), 'carry a face')
