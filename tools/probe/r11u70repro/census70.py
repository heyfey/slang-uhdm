#!/usr/bin/env python3
"""r11u70 CENSUS — the law's population is a SOURCE fact (`T'{...}`, the cast
spelling), because a database cannot tell a cast pattern from a plain one:
that is the whole of the head.  So the census scans every source file both
corpora can hand a compiler, strips comments, and reports every `<name>'{`
occurrence with its test directory, its key form (named / positional /
default) and whether it sits in a parameter declaration.

usage: census70.py <root> ...
"""
import os, re, sys

EXT = ('.sv', '.svh', '.v', '.vh', '.svi', '.vs', '.inc', '.h', '.sva')
CAST = re.compile(r"(?<![0-9a-zA-Z_$'])([A-Za-z_][A-Za-z0-9_$]*)\s*'\s*\{")

def strip_comments(txt):
    out = []
    i = 0
    n = len(txt)
    while i < n:
        c = txt[i]
        if c == '/' and i + 1 < n and txt[i + 1] == '/':
            j = txt.find('\n', i)
            if j < 0: j = n
            out.append(' ' * (j - i))
            i = j
        elif c == '/' and i + 1 < n and txt[i + 1] == '*':
            j = txt.find('*/', i + 2)
            j = n if j < 0 else j + 2
            out.append(re.sub(r'[^\n]', ' ', txt[i:j]))
            i = j
        elif c == '"':
            j = i + 1
            while j < n and txt[j] != '"':
                j += 2 if txt[j] == '\\' else 1
            j = min(j + 1, n)
            out.append(' ' * (j - i))
            i = j
        else:
            out.append(c)
            i += 1
    return ''.join(out)

def keyform(txt, pos):
    """look inside the braces that start at pos for the key form"""
    depth = 0
    i = pos
    while i < len(txt):
        if txt[i] == '{': depth += 1
        elif txt[i] == '}':
            depth -= 1
            if depth == 0: break
        i += 1
    body = txt[pos + 1:i]
    head = body.split(',')[0]
    if re.match(r'\s*default\s*:', head): return 'default'
    if re.match(r"\s*[A-Za-z_][A-Za-z0-9_$]*\s*:", head): return 'named'
    return 'positional'

def main(roots):
    hits = 0
    for root in roots:
        for dirpath, dirnames, filenames in os.walk(root):
            for fn in filenames:
                if not fn.endswith(EXT): continue
                p = os.path.join(dirpath, fn)
                try:
                    raw = open(p, errors='replace').read()
                except OSError:
                    continue
                if "'" not in raw or '{' not in raw: continue
                txt = strip_comments(raw)
                for m in CAST.finditer(txt):
                    nm = m.group(1)
                    # `2'{`-style is not a cast of a type; the regex already
                    # refuses a digit start, keep the guard explicit anyway.
                    if nm[0].isdigit(): continue
                    ln = txt.count('\n', 0, m.start()) + 1
                    line = raw.splitlines()[ln - 1].strip()
                    kf = keyform(txt, m.end() - 1)
                    holder = 'param' if re.search(
                        r'\b(localparam|parameter)\b', line) else 'other'
                    rel = os.path.relpath(p, root)
                    print('%s | %s:%d | cast=%s keys=%s holder=%s | %s' %
                          (os.path.basename(root), rel, ln, nm, kf, holder,
                           line[:110]))
                    hits += 1
    print('TOTAL %d' % hits)

if __name__ == '__main__':
    main(sys.argv[1:])
