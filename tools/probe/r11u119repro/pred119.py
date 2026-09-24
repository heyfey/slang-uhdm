#!/usr/bin/env python3
"""r11u119 a-priori mover predictor, from PRISTINE databases only.

  pred119.py <census.tsv> <workdir> [corpus]  -> prints predicted movers

A row is predicted to move when
  L2/L1/L4: its census line (cen119.py, pristine vs golden) carries an IMPL,
            POPNET, DECLEND or REAL face;
  L3:       a source file it locates objects in has a line where the OLD
            number-literal fold (pre-r11u119 numLitWsShift) and the NEW one
            (ppFold119Line) disagree at a column at or before an object
            column located on that line in the pristine database.
Both fold rules are re-implemented here from UhdmExporter.cpp.
"""
import os, re, subprocess, sys
LD = os.environ.get('LOCDUMP', '/tmp/r11u119_scr/locdump')
cen, wd = sys.argv[1], sys.argv[2]
ISVAL = set('0123456789abcdefABCDEFxXzZ?_')

def old_fold(ln, has_tick):
    out = []
    p = 0
    while p < len(ln):
        if ln[p] != ' ':
            p += 1; continue
        q = p
        while q < len(ln) and ln[q] == ' ':
            q += 1
        run = q - p
        if run >= 2 and p > 0:
            j = p
            while j > 0 and ln[j - 1] in ISVAL:
                j -= 1
            based = j < p and j > 0 and (ln[j - 1] == "'" or (ln[j - 1] in 'sS' and j > 1 and ln[j - 2] == "'"))
            plain = False
            if not based and j < p and has_tick:
                digits = ln[j].isdigit() and all(c.isdigit() or c == '_' for c in ln[j:p])
                pc = ln[j - 1] if j > 0 else ' '
                plain = digits and not (pc.isalnum() or pc in "_$'.")
            if based or plain:
                out.append((q, -(run - 1)))
        p = q
    return out

def new_fold(ln, st):
    out = []
    n = len(ln)
    isid = lambda c: c.isalnum() or c in '_$'
    def fold(b, e, sb=0, se=0):
        for k in range(b, e):
            if ln[k] == ' ' and k + 1 < e and not (sb <= k < se):
                out.append((k + 1, -1))
    def vstart(v):
        while v < n and ln[v] == ' ':
            v += 1
        return v
    def first(ch, base):
        if base == 'b': return ch in '01xXzZ?'
        if base == 'o': return ch in '01234567xXzZ?'
        return ch.isdigit() or ch in 'abcdefABCDEFxXzZ?'
    def vend(v, base):
        v = vstart(v)
        if base == 'd':
            if v < n and ln[v].isdigit():
                while v < n and (ln[v].isdigit() or ln[v] in '_ '):
                    v += 1
                return v
            if v < n and ln[v] in 'xXzZ?':
                v += 1
                while v < n and ln[v] == '_':
                    v += 1
            return v
        while v < n and ln[v] == '_':
            v += 1
        while v < n and first(ln[v], base):
            v += 1
        while v < n and (ln[v] in ' _' or (ln[v] != '?' and first(ln[v], base))):
            v += 1
        return v
    def base_at(t):
        if t >= n or ln[t] != "'":
            return 0, 0
        u = t + 1
        if u < n and ln[u] in 'sS':
            u += 1
        if u >= n:
            return 0, 0
        b = ln[u].lower()
        return (b, u + 1) if b in 'bodh' else (0, 0)
    i = 0
    while i < n:
        if st['md'] > 0:
            c = ln[i]
            if c == '"':
                j = i + 1
                while j < n and ln[j] != '"':
                    j += 2 if ln[j] == '\\' else 1
                i = j + 1; continue
            if c in '({[': st['md'] += 1
            elif c in ')}]': st['md'] -= 1
            i += 1; continue
        if st['blk']:
            e = ln.find('*/', i)
            if e < 0: return out
            st['blk'] = False; i = e + 2; continue
        ch = ln[i]
        if ln.startswith('//', i): return out
        if ln.startswith('/*', i): st['blk'] = True; i += 2; continue
        if ch == '"':
            j = i + 1
            while j < n and ln[j] != '"':
                j += 2 if ln[j] == '\\' else 1
            i = j + 1; continue
        if ch == '\\':
            while i < n and ln[i] not in ' \t': i += 1
            continue
        if ch == '`':
            j = i + 1
            while j < n and isid(ln[j]): j += 1
            i = j; k = j
            while k < n and ln[k] in ' \t': k += 1
            if k < n and ln[k] == '(' and j > 1:
                st['md'] = 1; i = k + 1
            continue
        if ch.isalpha() or ch == '_':
            while i < n and isid(ln[i]): i += 1
            continue
        if ch == '#':
            j = i + 1
            if j < n and ln[j] == '#': j += 1
            k = j
            while k < n and ln[k] == ' ': k += 1
            if k < n and ln[k].isdigit():
                while k < n and (ln[k].isdigit() or ln[k] in '_.'): k += 1
                i = k
            else:
                i = j
            continue
        if ch.isdigit():
            fx = i
            while fx < n and ln[fx].isdigit(): fx += 1
            fe = 0
            if fx + 1 < n and ln[fx] == '.' and ln[fx + 1].isdigit():
                fe = fx + 1
                while fe < n and ln[fe].isdigit(): fe += 1
            un = i + 1
            while un < n and (ln[un].isdigit() or ln[un] in '_ '): un += 1
            be, ba = 0, 0
            if ch != '0':
                sz = i + 1
                while sz < n and (ln[sz].isdigit() or ln[sz] == '_'): sz += 1
                t = sz
                while t < n and ln[t] == ' ': t += 1
                b, a = base_at(t)
                if b:
                    be, ba = vend(a, b), a
            best = max(fe, un, be)
            if best == fe and fe > 0:
                i = fe; continue
            if best == be and be > 0:
                fold(i, best, ba, vstart(ba))
            else:
                fold(i, best)
            i = best; continue
        if ch == "'":
            b, a = base_at(i)
            if b:
                e = vend(a, b); fold(i, e, a, vstart(a)); i = e; continue
            i += 1; continue
        i += 1
    return out

cache = {}
def file_diffs(path):
    """line -> first column (1-based, original) where old and new disagree."""
    if path in cache:
        return cache[path]
    res = {}
    try:
        text = open(path, errors='replace').read()
    except OSError:
        cache[path] = res; return res
    has_tick = '`' in text
    st = {'blk': False, 'md': 0}
    indef = False
    for li, ln in enumerate(text.split('\n'), 1):
        ln = ln.rstrip('\r')
        fs = ln.lstrip(' \t')
        if indef or fs.startswith('`define'):
            indef = ln.endswith('\\')
            continue
        o = old_fold(ln, has_tick)
        nw = new_fold(ln, st)
        if sorted(o) == sorted(nw):
            continue
        # smallest original column c0 where the two shifts differ
        cols = sorted(set([u for u, _ in o] + [u for u, _ in nw]))
        for c in cols:
            c0 = c + 1
            so = sum(d for u, d in o if u < c0); sn = sum(d for u, d in nw if u < c0)
            if so != sn:
                res[li] = c0; break
    cache[path] = res
    return res

pred = set()
rows = {}
for l in open(cen):
    n, stt, f = (l.rstrip('\n').split('\t') + ['', ''])[:3]
    rows[n] = f
    if re.search(r'\b(IMPL|DECLEND|REAL|POPNET)=', f):
        pred.add(n)
corpus = len(sys.argv) > 3
for n in rows:
    db = os.path.join(wd, n, 'slang.uhdm')
    if not os.path.isfile(db):
        continue
    r = subprocess.run([LD, db, '--full'], capture_output=True, text=True).stdout
    for l in r.splitlines():
        m = re.match(r'^\S+ (/\S+) (\d+)\.(\d+)-(\d+)\.(\d+)', l)
        if not m:
            continue
        f, a, b, c, d = m.group(1), *map(int, m.groups()[1:])
        fd = file_diffs(f)
        if (a in fd and b >= fd[a] - 4) or (c in fd and d >= fd[c] - 4) or \
           any(ll in fd for ll in range(a + 1, c)):
            pred.add(n); break
for n in sorted(pred):
    print(n)
