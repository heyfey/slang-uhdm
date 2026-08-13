#!/usr/bin/env python3
"""r10uvm68 — THE CENSUS-PREDICT, run BEFORE the byte verifier.

Scans SOURCE (block comments, line comments and string literals stripped first)
for every site § atomVarSignedWritten68 can fire on:

  1. a `typedef` whose base is a SIGNED PREDEFINED INTEGER ATOM
     (int / integer / shortint / longint / byte, WITHOUT `unsigned`), and every
     typedef that chains onto one, transitively;
  2. a declaration THROUGH ONE OF THOSE NAMES that is NOT at module / class /
     package member scope — i.e. a subroutine return type, a subroutine body
     local, or a block local inside begin / fork / initial / always* — because
     module- and class-scope declarations are ALREADY gated (makeVar's
     `namedTy9`, r10c15) and cannot move.

It is deliberately INDEPENDENT of the patch: it reads TEXT, never UHDM.

STATED BOUND, so no number here is over-read:
  * EXACT on distinct SOURCE SITES it recognises;
  * a LOWER bound on dump-line movers, because one site moves once per VIEW
    (def + elab) and once per drainFuncRet BINDING REFERENCE, and this script
    counts neither;
  * an UPPER bound in the other direction on any site whose typedef name is
    shadowed, whose file is not in any test's source set, or which slang
    rejects;
  * it does not resolve `pkg::name` imports across files, so a typedef declared
    in file A and used at subroutine scope in file B is counted only when both
    files are scanned together (pass a DIRECTORY, not a single file);
  * `-v` prints every site with its file, line and the reason it was
    classified, so the classification is auditable rather than trusted.

  usage: census68src.py [-v] <file-or-dir> [...]
"""
import os
import re
import sys

VERBOSE = False

ATOMS = ('int', 'integer', 'shortint', 'longint', 'byte')
# `typedef <base> <name>;` with no unpacked dims — an ARRAY typedef is
# § arrayVarSignedWritten8's population, not this one.
TD = re.compile(r'\btypedef\s+(?P<base>[A-Za-z_]\w*(?:\s+unsigned|\s+signed)?)'
                r'\s+(?P<name>[A-Za-z_]\w*)\s*;')
# scope openers/closers we track to decide "is this declaration inside a
# subroutine or a statement block?"
OPEN = re.compile(r'\b(function|task|initial|final|always|always_comb|'
                  r'always_ff|always_latch|fork)\b')
CLOSE = re.compile(r'\b(endfunction|endtask|join|join_any|join_none)\b')


def strip(text):
    out = []
    i = 0
    n = len(text)
    while i < n:
        c = text[i]
        if c == '/' and i + 1 < n and text[i + 1] == '/':
            j = text.find('\n', i)
            j = n if j < 0 else j
            out.append('\n' * text.count('\n', i, j))
            i = j
        elif c == '/' and i + 1 < n and text[i + 1] == '*':
            j = text.find('*/', i + 2)
            j = n if j < 0 else j + 2
            out.append('\n' * text.count('\n', i, j))
            i = j
        elif c == '"':
            j = i + 1
            while j < n and text[j] != '"':
                j += 2 if text[j] == '\\' else 1
            out.append('""')
            i = min(j + 1, n)
        else:
            out.append(c)
            i += 1
    return ''.join(out)


def collect_typedefs(texts):
    """Transitive closure of typedef names whose base is a SIGNED atom."""
    direct = set()
    edges = {}
    for t in texts:
        for m in TD.finditer(t):
            base = ' '.join(m.group('base').split())
            name = m.group('name')
            if base in ATOMS:
                direct.add(name)
            elif base.endswith(' unsigned'):
                pass          # explicitly unsigned: golden gives it nothing
                              # on EITHER side, so it can never move
            else:
                edges.setdefault(base.split()[0], set()).add(name)
    seen = set(direct)
    frontier = list(direct)
    while frontier:
        b = frontier.pop()
        for nxt in edges.get(b, ()):
            if nxt not in seen:
                seen.add(nxt)
                frontier.append(nxt)
    return seen


def sites(path, text, names):
    """Yield (line, kind, name) for each firing site in ONE file."""
    if not names:
        return
    depth = 0            # >0 == inside a subroutine or statement block
    for ln, raw in enumerate(text.splitlines(), 1):
        # A `function <tdname> f(...)` return type fires even at depth 0.
        for m in re.finditer(r'\bfunction\s+(?:automatic\s+|static\s+)?'
                             r'(?P<t>[A-Za-z_]\w*(?:::[A-Za-z_]\w*)?)\s+'
                             r'[A-Za-z_]\w*\s*[;(]', raw):
            t = m.group('t').split('::')[-1]
            if t in names:
                yield (ln, 'RETURN', t)
        if depth > 0:
            for m in re.finditer(r'(?:^|[;\s])(?P<t>[A-Za-z_]\w*'
                                 r'(?:::[A-Za-z_]\w*)?)\s+[A-Za-z_]\w*\s*'
                                 r'(?:=[^;]*)?;', raw):
                t = m.group('t').split('::')[-1]
                if t in names:
                    yield (ln, 'LOCAL', t)
            for m in re.finditer(r'\bfor\s*\(\s*(?P<t>[A-Za-z_]\w*)\s+'
                                 r'[A-Za-z_]\w*\s*=', raw):
                if m.group('t') in names:
                    yield (ln, 'FORVAR', m.group('t'))
        depth += len(OPEN.findall(raw)) - len(CLOSE.findall(raw))
        if depth < 0:
            depth = 0


def main():
    global VERBOSE
    args = [a for a in sys.argv[1:] if a != '-v']
    VERBOSE = '-v' in sys.argv[1:]
    files = []
    for a in args:
        if os.path.isdir(a):
            for root, _d, fs in os.walk(a):
                for f in fs:
                    if f.endswith(('.sv', '.svh', '.v', '.vh')):
                        files.append(os.path.join(root, f))
        else:
            files.append(a)
    texts = {}
    for f in files:
        try:
            with open(f, 'rt', errors='replace') as fh:
                texts[f] = strip(fh.read())
        except OSError:
            pass
    names = collect_typedefs(texts.values())
    tot = {'RETURN': 0, 'LOCAL': 0, 'FORVAR': 0}
    perfile = {}
    for f, t in texts.items():
        hits = list(sites(f, t, names))
        if hits:
            perfile[f] = hits
            for _ln, k, _n in hits:
                tot[k] += 1
    print('scanned files=%d   signed-atom typedef NAMES=%d' % (len(texts), len(names)))
    if VERBOSE:
        print('  names: ' + ' '.join(sorted(names)))
    for f in sorted(perfile):
        print('%-70s sites=%d' % (f[-70:], len(perfile[f])))
        if VERBOSE:
            for ln, k, n in perfile[f]:
                print('      %-6s line %-6d via %s' % (k, ln, n))
    print('---- PREDICTED SITES: RETURN=%d LOCAL=%d FORVAR=%d  TOTAL=%d  in %d file(s)'
          % (tot['RETURN'], tot['LOCAL'], tot['FORVAR'],
             sum(tot.values()), len(perfile)))


if __name__ == '__main__':
    main()
