#!/usr/bin/env python3
"""r10buvm24repro/fence24.py — THE FENCE, enumerated from the SOURCES of a
pristine sweep BEFORE the patched sweep exists.  MEASUREMENT ONLY.

§ emptyArgSlotIntZero24 can only reach a call that WROTE an argument slot and
left it EMPTY.  That is a purely LEXICAL property of the source: once comments
and string literals are gone, an empty slot is

    `,` followed by `,`   (an empty MIDDLE slot,  `f(a,,b)`)
    `,` followed by `)`   (an empty TRAILING slot, `f(a,b,)`)
    `(` followed by `,`   (an empty LEADING slot,  `f(,b,c)`)

and `()` — an EMPTY ARGUMENT LIST — is deliberately NOT one of them.

The scan is a deliberate SUPERSET: it also fires on an empty MODULE PORT
CONNECTION (`m u(a, , c)`), on an empty slot in a macro TEXT, and on any other
parenthesised list, none of which this law touches.  So the predicted mover set
CONTAINS the real one, and the half of the fence that must be airtight — "a
test whose sources hold no empty slot at all cannot move" — is.

    fence24.py <sweep workdir> [<corpus root> ...]

Sources come off the slang command line recorded in each `cmds.txt`; RELATIVE
source names are resolved against the test directory, recovered from the
workdir name (verify_golden.py names it `<test>-<sha1(dirpath)[:8]>`) by
hashing every directory under the corpus roots.  `include`s are followed
through the recorded `+incdir+` list and the includer's own directory.
"""
import hashlib, os, re, sys

def strip_comments(text):
    out, i, n = [], 0, len(text)
    while i < n:
        c = text[i]
        if c == '/' and i + 1 < n and text[i+1] == '/':
            j = text.find('\n', i)
            i = n if j < 0 else j
        elif c == '/' and i + 1 < n and text[i+1] == '*':
            j = text.find('*/', i + 2)
            i = n if j < 0 else j + 2
        else:
            out.append(c)
            i += 1
    return ''.join(out)

def strip_strings(text):
    out, i, n = [], 0, len(text)
    while i < n:
        c = text[i]
        if c == '"':
            j = i + 1
            while j < n and text[j] not in '"\n':
                j += 2 if text[j] == '\\' else 1
            # A string literal is replaced by a PLACEHOLDER TOKEN, never
            # deleted: deleting it turns `$display("%d", x)` into `(, x)` and
            # the scan then reports an empty LEADING slot on half the corpus.
            out.append('0')
            i = j + 1
        else:
            out.append(c)
            i += 1
    return ''.join(out)

EMPTY = re.compile(r',\s*[,)]|\(\s*,')
INC = re.compile(r'`include\s+"([^"]+)"')

def scan(path, incdirs, seen, hits):
    p = os.path.realpath(path)
    if p in seen or not os.path.isfile(p):
        return
    seen.add(p)
    try:
        raw = open(p, encoding='utf-8', errors='replace').read()
    except OSError:
        return
    nc = strip_comments(raw)
    n = len(EMPTY.findall(strip_strings(nc)))
    if n:
        hits.append((p, n))
    for m in INC.finditer(nc):
        for d in [os.path.dirname(p)] + incdirs:
            c = os.path.join(d, m.group(1))
            if os.path.isfile(c):
                scan(c, incdirs, seen, hits)
                break

def dirmap(roots):
    m = {}
    for r in roots:
        for root, dirs, files in os.walk(r):
            m.setdefault(hashlib.sha1(root.encode()).hexdigest()[:8], root)
    return m

def main():
    wd = sys.argv[1]
    dm = dirmap(sys.argv[2:]) if len(sys.argv) > 2 else {}
    tot, hot, nosrc = 0, [], []
    for root, dirs, files in os.walk(wd):
        if 'cmds.txt' not in files:
            continue
        tot += 1
        line = ''
        for ln in open(os.path.join(root, 'cmds.txt'), encoding='utf-8',
                       errors='replace'):
            if ln.startswith('slang:'):
                line = ln
        toks = line.split()[1:]
        incdirs = []
        for t in toks:
            if t.startswith('+incdir+'):
                incdirs += [x for x in t[len('+incdir+'):].split('+') if x]
            elif t.startswith('-I'):
                incdirs.append(t[2:])
        base = os.path.basename(root)
        tdir = dm.get(base.rsplit('-', 1)[-1], '')
        srcs = [t for t in toks if t.endswith(('.sv', '.v', '.svh', '.vh'))
                and not t.startswith(('+', '-'))]
        srcs = [t if os.path.isabs(t) else os.path.join(tdir, t) for t in srcs]
        incdirs = [d if os.path.isabs(d) else os.path.join(tdir, d)
                   for d in incdirs]
        missing = [t for t in srcs if not os.path.isfile(t)]
        seen, hits = set(), []
        for t in srcs:
            scan(t, incdirs, seen, hits)
        rel = os.path.relpath(root, wd)
        if missing:
            nosrc.append((rel, missing))
        if hits:
            hot.append((rel, sum(h[1] for h in hits),
                        sorted(set(os.path.basename(h[0]) for h in hits))))
    for rel, n, files in sorted(hot):
        print('EMPTYSLOT\t%s\t%d\t%s' % (rel, n, ' '.join(files)))
    for rel, miss in sorted(nosrc):
        print('UNRESOLVED\t%s\t%s' % (rel, ' '.join(os.path.basename(m) for m in miss)))
    print('SCANNED %d test-modes;  WITH EMPTY SLOTS %d;  UNRESOLVED SOURCES %d'
          % (tot, len(hot), len(nosrc)))

main()
