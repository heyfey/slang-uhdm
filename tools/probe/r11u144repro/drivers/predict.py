#!/usr/bin/env python3
# predict.py <pristine wd> <out.tsv> -> per corpus row: the r11u144 laws whose FACE the row's SOURCE
# carries (regexes over every .sv/.v/.svh/.vh under the test directory, the UVM library when the
# command line names it) and the command line (--elabuhdm).  Written and run BEFORE the mover set is
# read; a row with no predicted law must not move.
import sys, os, re, glob
# The slang-fenced tests are skipped (their names come from $FENCED, space separated, never spelled here).
FENCED = set(os.environ.get('FENCED', '').split())
if len(FENCED) != 4:
    sys.exit('predict.py: export FENCED (the four slang-fenced test names, space separated) first; it refuses to scan without them (v11u144)')
P, OUT = sys.argv[1], sys.argv[2]
SR = '/home/heyfey/git-repos/slang-uhdm/third_party/Surelog'
U2 = '/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil/test'
SLDIR = {}
for base in (SR + '/tests', SR + '/third_party/tests'):
    for f in glob.glob(base + '/*/*.sl') + glob.glob(base + '/*/*/*.sl'):
        SLDIR.setdefault(os.path.basename(f)[:-3], os.path.dirname(f))
UVMSRC = None
def uvm():
    global UVMSRC
    if UVMSRC is None:
        UVMSRC = ''
        for f in glob.glob(SR + '/third_party/UVM/**/*.sv*', recursive=True):
            try: UVMSRC += open(f, errors='replace').read() + '\n'
            except: pass
    return UVMSRC
def srcs(corpus, name, cmd):
    cwd = SLDIR.get(name) if corpus == 'surelog' else U2 + '/' + name
    out = ''
    if cwd and os.path.isdir(cwd):
        for f in glob.glob(cwd + '/**/*', recursive=True)[:3000]:
            if f.endswith(('.sv', '.v', '.svh', '.vh', '.inc')) and os.path.isfile(f):
                try: out += open(f, errors='replace').read() + '\n'
                except: pass
        # sibling files named on the command line (../ibex/rtl/... and the like)
        for tok in cmd.split():
            for t in ([tok[2:]] if tok.startswith('-I') else [tok]):
                p = os.path.normpath(os.path.join(cwd, t))
                if os.path.isfile(p) and p.endswith(('.sv', '.v', '.svh', '.vh')):
                    try: out += open(p, errors='replace').read() + '\n'
                    except: pass
                elif os.path.isdir(p) and tok.startswith('-I'):
                    for f in glob.glob(p + '/*'):
                        if f.endswith(('.sv', '.v', '.svh', '.vh')):
                            try: out += open(f, errors='replace').read() + '\n'
                            except: pass
    if 'uvm' in cmd.lower() or 'UVM' in out[:200000] and 'uvm_pkg' in out:
        out += uvm()
    return out
RX = {
 'SELBAREDEC': re.compile(r'assign\s+[A-Za-z_]\w*\s*\[[^\]]+\]\s*=\s*\d+\s*[;,]'),
 'CALLBITSEL': re.compile(r'return\s+[A-Za-z_]\w*\s*\[[^\]:]+\]\s*;'),
 'FOLDTSNAME': re.compile(r'\[\s*[A-Za-z_]\w*\s*(-\s*\d+)?\s*:'),
 'TPPACKEDNET': re.compile(r'parameter\s+type\s+(\w+)'),
 'PARAMALIASREF': re.compile(r'typedef\s+(logic|bit|reg)\s*(signed\s*)?\[[^\]]*[A-Za-z_]'),
 'PKGQUALREF': re.compile(r'\[\s*[A-Za-z_]\w*::\w+'),
 'METHQUALSPAN': re.compile(r'\b(virtual|static|local|protected)\s+(\w+\s+)*?(function|task)\b'),
 'METHATTR': re.compile(r'\*\)\s*(pure\s+)?(virtual|static|local|protected)\s'),
 'DEFGENHP': re.compile(r'assign\s+[A-Za-z_]\w*\s*\[\s*[A-Za-z_]\w*\s*\]\s*\.\s*\w+\s*='),
}
rows = []
for corpus in ('surelog', 'uhdm2rtlil'):
    for d in sorted(glob.glob(f'{P}/{corpus}/*/*')):
        if not os.path.isfile(d + '/cmds.txt'): continue
        mode = d.split('/')[-2]
        name = re.sub(r'-[0-9a-f]{8}$', '', os.path.basename(d))
        if name in FENCED: continue
        cmd = open(d + '/cmds.txt').read()
        src = srcs(corpus, name, cmd)
        laws = [k for k, rx in RX.items() if rx.search(src)]
        if '--elabuhdm' in cmd and (re.search(r'\w+\s*\[[^\]]+\]\s*\.\s*\w+', src) or
                                    re.search(r'\b(property|sequence)\b', src)):
            laws.append('ELAB')
        rows.append((corpus, mode, name, ','.join(laws)))
with open(OUT, 'w') as fo:
    fo.write('corpus\tmode\tname\tlaws\n')
    for r in rows: fo.write('\t'.join(r) + '\n')
print(len(rows), 'rows;', sum(1 for r in rows if r[3]), 'carry a face')
