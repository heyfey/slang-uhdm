#!/usr/bin/env python3
"""r10uvm67 — THE CENSUS-PREDICT, run BEFORE the byte verifier.

Scans SOURCE (block comments, line comments and string literals stripped first)
for every site § retLocalPkgRangeBind67 can fire on:

    a subroutine declared at PACKAGE scope,
    whose RETURN TYPE carries a packed RANGE,
    whose range text contains an IDENTIFIER (not only digits/operators),
    and whose BODY names the subroutine (so `drainFuncRet` mints a
    per-reference body-local return variable at all).

It is deliberately INDEPENDENT of the patch: it reads text, never UHDM.

STATED BOUND, so no number here is over-read:
  * EXACT on distinct SOURCE SITES;
  * a LOWER bound on dump-line movers — each site moves once per VIEW and once
    per BINDING REFERENCE, and this script counts neither;
  * it cannot know whether a file's test compiles, is in a test's source set,
    or whether the identifier resolves to a PACKAGE PARAMETER (an identifier
    that resolves to a localparam of the same package counts here too — that is
    the same law) versus a genvar/typedef (over-count).
  * `-v` prints every site and every skip WITH ITS REASON, so the
    classification is auditable rather than trusted.

  usage: census67src.py [-v] <file-or-dir> [...]
"""
import os
import re
import sys

VERBOSE = False

# `function` / `task` at package scope, capturing the text between the keyword
# and the routine name — that text is the return type.
FUNC = re.compile(r'\bfunction\b(?P<ret>[^;()]*?)\b(?P<name>[A-Za-z_]\w*)\s*(?P<tail>[;(])')
PKG = re.compile(r'\bpackage\b\s+(?:static\s+|automatic\s+)?(?P<name>[A-Za-z_]\w*)\s*;')
ENDPKG = re.compile(r'\bendpackage\b')
CLASSB = re.compile(r'\bclass\b\s+[A-Za-z_]\w*')
ENDCLASS = re.compile(r'\bendclass\b')
# A `\include`d body has NO `package` line of its own — uvm_globals.svh, which
# holds the witness (`function bit[UVM_LARGE_STRING:0] uvm_string_to_bits`), is
# pulled into uvm_pkg.sv between `package uvm_pkg;` and `endpackage`.  A
# file-local scan therefore reads it as "not package scope" and predicts ZERO
# where the truth is the head itself.  THE FIRST VERSION OF THIS SCRIPT DID
# EXACTLY THAT AND PREDICTED 0 SITES FOR UVM; the fix is to classify a file with
# no container of its own as an INCLUDE BODY and count its top-level routines as
# package-scope CANDIDATES, reported in their own column and never merged with
# the certain ones.
CONTAINER = re.compile(r'\b(module|interface|program|checker|primitive)\b\s+[A-Za-z_]\w*')
RANGEID = re.compile(r'\[[^\]]*\]')
IDENT = re.compile(r'[A-Za-z_]\w*')


def strip(text):
    """Comments and string literals out, newlines preserved."""
    out, i, n = [], 0, len(text)
    while i < n:
        c = text[i]
        if c == '/' and i + 1 < n and text[i + 1] == '/':
            j = text.find('\n', i)
            j = n if j < 0 else j
            out.append(' ' * (j - i))
            i = j
        elif c == '/' and i + 1 < n and text[i + 1] == '*':
            j = text.find('*/', i + 2)
            j = n if j < 0 else j + 2
            out.append(''.join(ch if ch == '\n' else ' ' for ch in text[i:j]))
            i = j
        elif c == '"':
            j = i + 1
            while j < n and text[j] != '"':
                j += 2 if text[j] == '\\' else 1
            j = min(j + 1, n)
            out.append(' ' * (j - i))
            i = j
        else:
            out.append(c)
            i += 1
    return ''.join(out)


def scan(path):
    """Yields (line, pkg, routine, rangetext, reason-or-None).

    `pkg` is the package name when the file declares one, or
    `<INCLUDE-BODY>` when the file declares no container at all and its
    top-level routines are therefore package-scope only by inclusion.
    """
    try:
        with open(path, 'rt', errors='replace') as fh:
            src = strip(fh.read())
    except OSError:
        return
    # package spans: [(start, end, name)]
    spans = []
    for m in PKG.finditer(src):
        e = ENDPKG.search(src, m.end())
        spans.append((m.end(), e.start() if e else len(src), m.group('name')))

    def pkg_of(pos):
        for a, b, nm in spans:
            if a <= pos < b:
                return nm
        return None

    # class spans inside packages — a class METHOD is a different listing and
    # this pass does not touch it; counted as a skip, with the reason.
    cspans = []
    for m in CLASSB.finditer(src):
        e = ENDCLASS.search(src, m.end())
        cspans.append((m.start(), e.end() if e else len(src)))

    def in_class(pos):
        return any(a <= pos < b for a, b in cspans)

    # An INCLUDE BODY: no package, module, interface, program, checker or
    # primitive of its own.  Its top-level routines are package-scope exactly
    # when the file is included inside a package — which a per-file scan cannot
    # settle, so they are reported as CANDIDATES in their own column.
    include_body = not spans and not CONTAINER.search(src)

    for m in FUNC.finditer(src):
        pos = m.start()
        line = src.count('\n', 0, pos) + 1
        pkg = pkg_of(pos)
        name = m.group('name')
        ret = m.group('ret')
        if pkg is None and include_body:
            pkg = '<INCLUDE-BODY>'
        if pkg is None:
            yield (line, '-', name, ret.strip(), 'skip(not package scope)')
            continue
        if in_class(pos):
            yield (line, pkg, name, ret.strip(), 'skip(CLASS method)')
            continue
        rngs = RANGEID.findall(ret)
        if not rngs:
            yield (line, pkg, name, ret.strip(), 'skip(return type has no range)')
            continue
        ids = [i for r in rngs for i in IDENT.findall(r)]
        if not ids:
            yield (line, pkg, name, ret.strip(), 'skip(range is all literals)')
            continue
        # the body must NAME the routine, or drainFuncRet mints no local
        end = src.find('endfunction', m.end())
        body = src[m.end():end if end > 0 else len(src)]
        if not re.search(r'\b%s\b' % re.escape(name), body):
            yield (line, pkg, name, ' '.join(rngs),
                   'skip(body never names the return)')
            continue
        yield (line, pkg, name, ' '.join(rngs), None)


def main():
    global VERBOSE
    args = [a for a in sys.argv[1:] if a != '-v']
    VERBOSE = '-v' in sys.argv[1:]
    files = []
    for a in args:
        if os.path.isdir(a):
            for r, _d, fs in os.walk(a):
                for f in fs:
                    if f.endswith(('.sv', '.svh', '.v', '.vh')):
                        files.append(os.path.join(r, f))
        else:
            files.append(a)
    hits, cand, byfile = 0, 0, {}
    for f in sorted(files):
        for line, pkg, name, rng, reason in scan(f):
            if reason:
                if VERBOSE:
                    print('  %s:%d %s %s  %s' % (f, line, pkg, name, reason))
                continue
            if pkg == '<INCLUDE-BODY>':
                cand += 1
            else:
                hits += 1
            byfile[f] = byfile.get(f, 0) + 1
            if VERBOSE:
                print('  SITE%s %s:%d  %s::%s  range=%s'
                      % ('?' if pkg == '<INCLUDE-BODY>' else ' ', f, line, pkg,
                         name, rng))
    print('SITES=%d (certain package scope)  INCLUDE-BODY CANDIDATES=%d  '
          'FILES=%d' % (hits, cand, len(byfile)))
    for f, n in sorted(byfile.items(), key=lambda kv: (-kv[1], kv[0])):
        print('  %3d  %s' % (n, f))


if __name__ == '__main__':
    main()
