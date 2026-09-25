#!/usr/bin/env python3
"""predict.py <pristine workdir root> <corpus> [out.tsv] — which row-modes the r11u166 laws can move, from the
sources the PRISTINE sweep compiled (the `slang:` line of each cmds.txt, `include resolved through its -I/+incdir
dirs and the including file's dir).  A row is PREDICTED when its sources hold one of the law's triggers:
  ML  a macro whose `define body continues over lines (a backslash-newline) and whose name is used (`NAME);
  AS  a macro call whose parenthesised actuals span lines;
  FP  a formal-less macro used with a parenthesised list (`NAME (...)`);
  RI  a file `included twice whose include guard leaves text (a comment, TAB) outside the guard;
  PD  a use of a command-line (-D) macro or a builtin SV_COV_* macro;
  NB  a one-line macro whose body uses another macro (its text is re-preprocessed: a nested body's trailing
      blanks and comments reach the column);
  LW  (law_litall.patch only) a based literal with blanks between its base and its digits (`10'b 0`).
Fail-closed: refuses without FENCED; a fenced test (word boundary) is skipped and its sources are never opened."""
import os, re, sys
fenced = os.environ.get('FENCED', '').split()
if not fenced:
    sys.exit('REFUSE: FENCED unset')
root, corpus = sys.argv[1], sys.argv[2]
out = open(sys.argv[3], 'w') if len(sys.argv) > 3 else sys.stdout
SRC = re.compile(r'\.(sv|v|svh|vh|sva|svi|inc)$')
def isfenced(n):
    return any(re.search(r'(^|[^A-Za-z0-9_])%s([^A-Za-z0-9_]|$)' % re.escape(f), n) for f in fenced)
cache = {}
def read(p):
    if p not in cache:
        try:
            cache[p] = open(p, errors='replace').read()
        except OSError:
            cache[p] = None
    return cache[p]
def strip_comments(t):
    return re.sub(r'//[^\n]*|/\*.*?\*/', lambda m: re.sub(r'[^\n]', ' ', m.group(0)), t, flags=re.S)
def triggers(files, defines):
    trig = set()
    texts = {f: read(f) or '' for f in files}
    ml, noformal, nested = set(), set(), set()
    for f, t in texts.items():
        for m in re.finditer(r'^[ \t]*`define[ \t]+(\w+)(\()?([^\n]*)', t, re.M):
            name, paren, rest = m.group(1), m.group(2), m.group(3)
            if rest.rstrip().endswith('\\'):
                ml.add(name)
            if not paren:
                noformal.add(name)
            body = re.sub(r'//.*', '', rest)
            if not rest.rstrip().endswith('\\') and '`' in body:
                nested.add(name)
    for f, t in texts.items():
        c = strip_comments(t)
        if re.search(r"'[sS]?[bBoOdDhH][ \t]+[0-9a-fA-FxXzZ?]", c):
            trig.add('LW')
        for m in re.finditer(r'`(\w+)', c):
            n = m.group(1)
            ls = c.rfind('\n', 0, m.start()) + 1
            if c[ls:m.start()].lstrip().startswith('`define'):
                continue
            if n in ml:
                trig.add('ML')
            if n in nested:
                trig.add('NB')
            if n in noformal and re.match(r'[ \t]*\(', c[m.end():]):
                trig.add('FP')
            if n in defines or n.startswith('SV_COV_'):
                trig.add('PD')
            if re.match(r'[ \t]*\(', c[m.end():]):
                depth, i = 0, m.end()
                while i < len(c):
                    ch = c[i]
                    if ch in '([{': depth += 1
                    elif ch in ')]}':
                        depth -= 1
                        if depth == 0: break
                    elif ch == '\n' and depth > 0:
                        trig.add('AS'); break
                    i += 1
    return trig
# The surelog corpus: a test is `<Name>.sl` in its directory (verify_golden's discovery).  Only the file NAMES
# are listed here; a fenced test's .sl is never opened.
sl_index = {}
if corpus == 'surelog':
    for base in (os.path.join(os.environ.get('SURELOG_ROOT', ''), 'tests'),
                 os.path.join(os.environ.get('SURELOG_ROOT', ''), 'third_party', 'tests')):
        for dp, dn, fn in os.walk(base):
            for f in fn:
                if f.endswith('.sl') and not isfenced(f[:-3]):
                    sl_index.setdefault(f[:-3], dp)
rows = 0
for mode in ('default', 'testflags'):
    d0 = os.path.join(root, corpus, mode)
    if not os.path.isdir(d0):
        continue
    for d in sorted(os.listdir(d0)):
        name = d.rsplit('-', 1)[0]
        if isfenced(name):
            continue
        cm = os.path.join(d0, d, 'cmds.txt')
        if not os.path.exists(cm) or not os.path.exists(os.path.join(d0, d, 'slang.uhdm')):
            continue
        line = [l for l in open(cm) if l.startswith('slang:')]
        if not line:
            continue
        m = re.search(r'\(cwd ([^)]+)\)', open(cm).read())
        args = line[0].split()[2:]
        cwd = None
        # The harness runs slang in the test directory: the directory under the corpus roots that holds the
        # first relative source (or argfile).
        tdir = sl_index.get(name) if corpus == 'surelog' else \
            os.path.join(os.environ.get('UHDM2RTLIL_TESTS', ''), name)
        if tdir and not os.path.isdir(tdir):
            tdir = None
        if not tdir:
            print('%s\t%s\tNODIR' % (name, mode), file=out); continue
        # argfiles (-f) expand in place
        exp = []
        for i, a in enumerate(args):
            if i > 0 and args[i - 1] == '-f':
                t = read(os.path.join(tdir, a)) or ''
                exp += re.sub(r'//[^\n]*', ' ', t).split()
            elif a != '-f':
                exp.append(a)
        args = exp
        incs, files, defines = [tdir], [], set()
        i = 0
        while i < len(args):
            a = args[i]
            if a in ('-o',):
                i += 2; continue
            if a.startswith('-I') and len(a) > 2:
                incs.append(os.path.join(tdir, a[2:]))
            elif a.startswith('+incdir+'):
                incs += [os.path.join(tdir, x) for x in a[8:].split('+') if x]
            elif a.startswith('-D') and len(a) > 2:
                defines.add(a[2:].split('=')[0])
            elif a.startswith('+define+'):
                defines |= {x.split('=')[0] for x in a[8:].split('+') if x}
            elif SRC.search(a):
                files.append(os.path.normpath(os.path.join(tdir, a)))
            i += 1
        seen, todo = set(), list(files)
        while todo:
            f = todo.pop()
            if f in seen:
                continue
            seen.add(f)
            t = read(f)
            if t is None:
                continue
            for inc in re.findall(r'`include\s+"([^"]+)"', t):
                for base in [os.path.dirname(f)] + incs:
                    p = os.path.normpath(os.path.join(base, inc))
                    if os.path.exists(p):
                        todo.append(p); break
        trig = triggers(sorted(seen), defines)
        # RI: the same file included twice (by resolved path) with text outside its guard
        cnt = {}
        for f in seen:
            for inc in re.findall(r'`include\s+"([^"]+)"', read(f) or ''):
                cnt[os.path.basename(inc)] = cnt.get(os.path.basename(inc), 0) + 1
        for f in seen:
            if cnt.get(os.path.basename(f), 0) >= 2:
                t = read(f) or ''
                g = re.search(r'^[ \t]*`ifndef', t, re.M)
                if g and t[:g.start()].strip(' \n'):
                    trig.add('RI')
        rows += 1
        print('%s\t%s\t%s' % (name, mode, ','.join(sorted(trig)) or '-'), file=out)
print('ROWS %d' % rows, file=out)
