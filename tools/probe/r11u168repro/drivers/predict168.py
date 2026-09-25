#!/usr/bin/env python3
"""predict168.py (r11u168; extends r11u166mac/drivers/predict.py) <pristine workdir root> <corpus|probe> [out.tsv] — which row-modes the r11u166 laws can move, from the
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
r11u168's own laws:
  PF  § ppFileCallArgBody168: a multi-line macro body that calls another macro and holds a method call
      (`X.name(`) in it (a formal's text passed on to a nested call);
  UX  § undefKeepsOtherRootMacro168: a bare `define of a macro that an EARLIER root file's include tree
      defined and the current root's tree `undef'd before it (every `ifdef branch read as active: a superset);
  HC  § hcSelIdxInstName168: an instance port connection whose actual is a bit-select with a non-numeric
      index (`.p(v[sel])`, `(v[i+1])`);
  PS  § paramBaseSelTsInstName168: a net-declaration assignment holding a part-select with an identifier
      bound (`wire w = v[I+3:I];`);
  SP  § structParamBoundAtPatternLeaf168 / § rangeHierPathNoFullName168: a declared dimension whose bound is a
      dotted name (`logic dly [0:CFG.HSK.DLY];`).
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
        # PF: a multi-line define body with a nested macro call and a method call
        for m in re.finditer(r'^[ \t]*`define[ \t]+\w+[^\n]*\\\n(?:[^\n]*\\\n)*[^\n]*', t, re.M):
            body = m.group(0).split('\n', 1)[-1] if '\n' in m.group(0) else ''
            full = m.group(0)
            if re.search(r'`\w+', full[full.find('`define') + 7:]) and re.search(r'\w\s*\.\s*\w+\s*\(', full):
                trig.add('PF')
        # HC: .port(name[<non-numeric>]) or an ordered actual name[<non-numeric>] in an instance list
        # (a nested select in the index, `pad_pok[DioPadBank[0]]`, counts: the first prediction refused a nested bracket
        # and missed PackedArrayHighConn; widened after the sweep, README section 6)
        if re.search(r'\.\s*\w+\s*\(\s*[\w.]+\s*\[(?:[^\]\[]|\[[^\]\[]*\])*[A-Za-z_](?:[^\]\[]|\[[^\]\[]*\])*\]\s*\)', c) or \
           re.search(r'\w+\s+\w+\s*(?:\[[^\]]*\]\s*)?\(\s*(?:[^;()]*,\s*)?\w+\s*\[[^\]\[]*[A-Za-z_][^\]\[]*\]\s*[,)]', c):
            trig.add('HC')
        # SP: a dimension bound written as a dotted name
        if re.search(r'\[[^\]\[;]*\b[A-Za-z_]\w*\s*\.\s*[A-Za-z_]\w*[^\]\[;]*\]\s*;', c) or \
           re.search(r'\[\s*[^\]\[;:]*:\s*[A-Za-z_]\w*\s*\.\s*[A-Za-z_][\w.]*\s*\]', c) or \
           re.search(r'\[\s*[A-Za-z_]\w*\s*\.\s*[A-Za-z_][\w.]*\s*:', c):
            trig.add('SP')
        # PS: a net-declaration assignment with a part-select whose bound is an identifier
        for m in re.finditer(r'\b(?:wire|tri|wand|wor|supply0|supply1|uwire)\b[^;=]*=([^;]*);', c):
            if re.search(r'\[[^\]:]*[A-Za-z_]\w*[^\]:]*:[^\]]*\]|\[[^\]:]*:[^\]]*[A-Za-z_]\w*[^\]]*\]', m.group(1)):
                trig.add('PS')
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

def ux_trigger(roots, incs):
    """UX: walk the root files in command-line order, each include inline; a bare `define of a name
    that an earlier root defined and this root undef'd since is the trigger."""
    owner, undone = {}, set()
    hit = [False]
    def walk(f, ri, depth):
        t = read(f)
        if t is None or depth > 32:
            return
        c = strip_comments(t)
        for m in re.finditer(r'`(define|undef|include|undefineall)\b[ \t]*("([^"]+)"|(\w+))?([^\n]*)', c):
            k, nm = m.group(1), m.group(4)
            if k == 'include' and m.group(3):
                for base in [os.path.dirname(f)] + incs:
                    q = os.path.normpath(os.path.join(base, m.group(3)))
                    if os.path.exists(q):
                        walk(q, ri, depth + 1); break
            elif k == 'undefineall':
                owner.clear(); undone.clear()
            elif k == 'undef' and nm:
                if nm in owner and owner[nm] != ri:
                    undone.add(nm)
                else:
                    owner.pop(nm, None)
            elif k == 'define' and nm:
                bare = not m.group(5).strip()
                if bare and nm in owner and owner[nm] != ri and nm in undone:
                    hit[0] = True
                if not (bare and nm in owner):
                    owner[nm] = ri
    for i, r in enumerate(roots):
        walk(r, i, 0)
    return hit[0]

if corpus == 'probe':
    pr = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', '..', '..', 'tests', 'probe')
    pr = os.path.normpath(pr)
    n = 0
    for dp, dn, fn in os.walk(pr):
        if 'dut.sv' in fn:
            rel = os.path.relpath(dp, pr)
            if isfenced(rel):
                continue
            trig = triggers([os.path.join(dp, 'dut.sv')], set())
            n += 1
            print('%s\t%s\t%s' % (rel, 'probe', ','.join(sorted(trig)) or '-'), file=out)
    print('ROWS %d' % n, file=out)
    sys.exit(0)
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
        if len(files) > 1 and ux_trigger(files, incs):
            trig.add('UX')
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
