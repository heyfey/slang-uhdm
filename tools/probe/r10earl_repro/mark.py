#!/usr/bin/env python3
"""mark.py --on|--off <files...>
Marker-instrument every `->VpiDecompile(<expr>)` call so the emitted decompile
carries an @<FILE><LINE> tag naming the site that wrote it.  One build, then
read the tag off the object that is wrong.  --off restores.
Only rewrites SETTER calls (a non-empty argument list) on ONE line.
"""
import re, sys, os

TAG = '/*MK*/'

def on(path):
    src = open(path).read()
    if TAG in src:
        return 0
    abbr = os.path.basename(path)[0:2].upper()
    out = []
    n = 0
    for i, ln in enumerate(src.split('\n'), 1):
        m = re.search(r'->VpiDecompile\((.+)\);\s*$', ln)
        if m and m.group(1).strip():
            arg = m.group(1)
            if arg.count('(') != arg.count(')'):
                out.append(ln); continue
            ln = ln[:m.start()] + '->VpiDecompile(%s std::string(%s) + "@%s%d");' % (
                TAG, arg, abbr, i) + ln[m.end():]
            n += 1
        out.append(ln)
    open(path, 'w').write('\n'.join(out))
    return n

def off(path):
    src = open(path).read()
    if TAG not in src:
        return 0
    n = src.count(TAG)
    src = re.sub(r'->VpiDecompile\(' + re.escape(TAG) +
                 r' std::string\((.+)\) \+ "@[A-Z]{2}\d+"\);',
                 lambda m: '->VpiDecompile(%s);' % m.group(1), src)
    open(path, 'w').write(src)
    return n

mode = sys.argv[1]
for p in sys.argv[2:]:
    k = on(p) if mode == '--on' else off(p)
    print('%s %s: %d' % (mode, p, k))
