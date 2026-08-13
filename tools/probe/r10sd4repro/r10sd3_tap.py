#!/usr/bin/env python3
"""r10sd3 THROWAWAY instrumentation: wrap every `->Instance(<arg>)` SETTER call
in `sd3tap(__FILE__,__LINE__, <arg>)` so the emitter itself reports which source
site stamps a class_defn into a vpiInstance slot.  Debug worktree only; never
shipped."""
import re, sys, os

root = sys.argv[1]
files = []
for d in ('src',):
    for fn in sorted(os.listdir(os.path.join(root, d))):
        if fn.endswith('.cpp'):
            files.append(os.path.join(root, d, fn))

total = 0
for path in files:
    txt = open(path).read()
    out = []
    i = 0
    n = 0
    while True:
        j = txt.find('->Instance(', i)
        if j < 0:
            out.append(txt[i:])
            break
        k = j + len('->Instance(')
        if txt[k] == ')':          # getter
            out.append(txt[i:k])
            i = k
            continue
        # find matching close paren
        depth = 1
        p = k
        while p < len(txt) and depth:
            c = txt[p]
            if c == '(':
                depth += 1
            elif c == ')':
                depth -= 1
                if depth == 0:
                    break
            p += 1
        out.append(txt[i:k])
        out.append('sd3tap(__FILE__,__LINE__,')
        out.append(txt[k:p])
        out.append(')')
        i = p
        n += 1
    new = ''.join(out)
    if n:
        open(path, 'w').write(new)
        total += n
        print(f'{os.path.basename(path)}: {n}')
print('TOTAL wrapped:', total)
