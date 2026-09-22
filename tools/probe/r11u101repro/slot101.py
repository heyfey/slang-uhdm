#!/usr/bin/env python3
"""r11u101 PER-SLOT dump scorer and mover differencer.

Every object and every attribute of a `uhdm-dump` is one SLOT, keyed by its
POSITIONAL path from the design root -- (field, index) per level -- so a
listing golden writes as [a, b::x, b] and we write as [a, b] is scored cell by
cell, and the whole subtree of a def view that appears is scored too.

  object slot   value = kind + head token (`module_inst:work@sub::innermod`)
  attr slot     value = the attribute's value (`vpiName:r`)

vpiFullName, file/line/col spans and ids are NOT slots (no generated Compare
reads them, RESUME §9) and the weaklyReferenced tail is cut (unreachable to
the judge).  A slot is OK when golden and ours hold the same value,
GOLD-ONLY/OURS-ONLY when one side lacks it, WRONG when both hold different
values.

  score   : slot101.py score <gold.dump> <ours.dump>
  movers  : slot101.py move <tagA> <tagB> <arm-dir> [<arm-dir> ...]
            each arm dir holds gold.<tag>.dump + ours.<tag>.dump for both
            tags.  MOVED-WRONG = a slot OK under tagA and not under tagB;
            GAINED = the mirror.  Each is listed by name.
  dist    : whole-dump distance, `diff` of the two SORTED normalised dumps
            (ids stripped, weaklyReferenced tail cut).
  distsec : the display-free distance SECTIONED per top-level entry (a def
            view, a top, a package), summed -- the arbiter when one entry
            carries a pre-existing surplus (`--rows` names each entry).
  distnofn: the same with the display-only fullname face removed
            (`|vpiFullName:` lines and the `(fullname)` of object lines).
"""
import os
import re
import sys

OBJ = re.compile(r'^(\s*)\\_([A-Za-z_]+): ?(.*)$')
ATT = re.compile(r'^(\s*)\|([A-Za-z_]+):(.*)$')
SPAN = re.compile(r',? ?(file:[^,]*|line:\d+:\d+|endln:\d+:\d+)')


def head(text):
    t = SPAN.sub('', text).strip().rstrip(',').strip()
    # `work@sub (work@sub)` -> `work@sub`; `(work@sub.q)` -> '' (fullname only)
    t = re.sub(r'\s*\([^()]*\)\s*$', '', t)
    return t


def slots(path):
    lines = open(path, errors='replace').read().splitlines()
    out = {}
    stack = []            # [(indent, path-tuple)]
    counters = {}         # (path, field) -> next index
    pending = None        # (indent, field-path) from the last |field: marker
    for ln in lines:
        if ln.startswith('\\_weaklyReferenced'):
            break
        m = OBJ.match(ln)
        if m:
            ind = len(m.group(1))
            while stack and stack[-1][0] >= ind:
                stack.pop()
            base = stack[-1][1] if stack else ()
            fld = pending[1] if pending and pending[0] == ind else '?'
            k = (base, fld)
            i = counters.get(k, 0)
            counters[k] = i + 1
            p = base + ((fld, i),)
            out[p] = m.group(2) + ':' + head(m.group(3))
            stack.append((ind, p))
            pending = None
            continue
        a = ATT.match(ln)
        if a:
            ind = len(a.group(1))
            name, val = a.group(2), a.group(3)
            while stack and stack[-1][0] >= ind:
                stack.pop()
            base = stack[-1][1] if stack else ()
            if val.strip() == '':
                pending = (ind, name)
                continue
            if name == 'vpiFullName':
                continue
            k = (base, '@' + name)
            i = counters.get(k, 0)
            counters[k] = i + 1
            out[base + (('@' + name, i),)] = val
            continue
        if ln.startswith('design:'):
            stack = [(-1, ())]
            out[()] = 'design:' + head(ln[len('design:'):])
    return out


def fmt(p):
    return '/'.join('%s[%d]' % (f, i) for f, i in p) or 'ROOT'


def classify(g, o):
    cls = {}
    for p in set(g) | set(o):
        gv, ov = g.get(p), o.get(p)
        cls[p] = ('OK' if gv == ov else 'GOLD-ONLY' if ov is None
                  else 'OURS-ONLY' if gv is None else 'WRONG', gv, ov)
    return cls


def score(gold, ours, rows=True):
    c = classify(slots(gold), slots(ours))
    n = {}
    for p, (k, gv, ov) in sorted(c.items(), key=lambda x: fmt(x[0])):
        n[k] = n.get(k, 0) + 1
        if rows and k != 'OK':
            print('  %s %s gold=%s ours=%s' % (k, fmt(p), gv, ov))
    return n


def norm_sorted(path, nofn=False):
    out = []
    for ln in open(path, errors='replace').read().splitlines()[1:]:
        if ln.startswith('\\_weaklyReferenced'):
            break
        ln = re.sub(r', id:\d+', '', ln)
        if nofn:
            # the display-only face: vpiFullName, and the (fullname) an
            # object line prints -- the defname before it is kept
            if ln.lstrip().startswith('|vpiFullName:'):
                continue
            ln = re.sub(r' ?\([^()]*\)', '', ln)
        out.append(ln)
    return sorted(out)


def dist(a, b, nofn=False):
    import difflib
    x, y = norm_sorted(a, nofn), norm_sorted(b, nofn)
    return sum(1 for l in difflib.ndiff(x, y) if l[:1] in '+-')


def move(ta, tb, dirs):
    mw = ga = 0
    for d in dirs:
        arm = os.path.basename(d.rstrip('/'))
        f = [os.path.join(d, '%s.%s.dump' % (s, t))
             for t in (ta, tb) for s in ('gold', 'ours')]
        if not all(os.path.exists(x) for x in f):
            print('  SKIP-NOFILE %s' % arm)
            continue
        ca = classify(slots(f[0]), slots(f[1]))
        cb = classify(slots(f[2]), slots(f[3]))
        for p in sorted(set(ca) | set(cb), key=fmt):
            oka = p in ca and ca[p][0] == 'OK'
            okb = p in cb and cb[p][0] == 'OK'
            if oka and not okb:
                mw += 1
                print('  MOVED-WRONG %s %s gold=%s ours=%s'
                      % (arm, fmt(p), cb.get(p, (0, None, None))[1],
                         cb.get(p, (0, None, None))[2]))
            elif okb and not oka:
                ga += 1
                print('  GAINED %s %s gold=%s ours=%s'
                      % (arm, fmt(p), cb[p][1], cb[p][2]))
    print('SLOT MOVED-WRONG=%d GAINED=%d (arms=%d, %s -> %s)'
          % (mw, ga, len(dirs), ta, tb))


def sections(path, nofn=True):
    """{(section, head, occurrence): sorted normalised lines} -- one entry
    per top-level object of the design (a def view, a top, a package...), so a
    surplus in ONE entry can never cancel or inflate a match in another (the
    multiset trap of a whole-file order-blind diff)."""
    lines = norm_lines(path, nofn)
    out, cur, sec, seen = {}, None, 'ROOT', {}
    for ln in lines:
        if ln.startswith('|uhdm'):
            sec = ln.rstrip(':')
            cur = None
            continue
        if ln.startswith('\\_'):
            key = (sec, ln)
            n = seen.get(key, 0)
            seen[key] = n + 1
            cur = key + (n,)
            out[cur] = [ln]
            continue
        if cur is not None:
            out[cur].append(ln)
    return {k: sorted(v) for k, v in out.items()}


def norm_lines(path, nofn):
    out = []
    for ln in open(path, errors='replace').read().splitlines()[1:]:
        if ln.startswith('\\_weaklyReferenced'):
            break
        ln = re.sub(r', id:\d+', '', ln)
        if nofn:
            if ln.lstrip().startswith('|vpiFullName:'):
                continue
            ln = re.sub(r' ?\([^()]*\)', '', ln)
        out.append(ln)
    return out


def distsec(a, b, rows=False):
    import difflib
    x, y = sections(a), sections(b)
    tot = 0
    for k in sorted(set(x) | set(y), key=str):
        d = sum(1 for l in difflib.ndiff(x.get(k, []), y.get(k, []))
                if l[:1] in '+-')
        if d and rows:
            print('  %4d %s %s #%d' % (d, k[0], k[1], k[2]))
        tot += d
    return tot


if __name__ == '__main__':
    if sys.argv[1] == 'score':
        print(score(sys.argv[2], sys.argv[3]))
    elif sys.argv[1] == 'dist':
        print(dist(sys.argv[2], sys.argv[3]))
    elif sys.argv[1] == 'distsec':
        print(distsec(sys.argv[2], sys.argv[3], '--rows' in sys.argv))
    elif sys.argv[1] == 'distnofn':
        print(dist(sys.argv[2], sys.argv[3], True))
    else:
        move(sys.argv[2], sys.argv[3], sys.argv[4:])
