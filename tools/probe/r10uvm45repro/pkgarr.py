#!/usr/bin/env python3
"""r10uvm45 — CENSUS FIRST: is the PACKAGE-SCOPE FIXED-SIZE UNPACKED ARRAY
VARIABLE actually present in the corpus, and in which tests?

Pass 44 localised `emitPkgArrayVar`'s `switch (ct.kind)` returning false on
`FixedSizeUnpackedArrayType`, so a package-level fixed unpacked array VARIABLE
is dropped entirely (arm t60a: golden 96 `array_typespec`s vs our 47).  Pass 44
also ranked its own #1 on a grep nobody had checked for selectivity and burned
the pass; the rule that bought is A POPULATION COUNT NEEDS A MEASURER TOO.  So
this selects the shape and nothing else:

  * inside `package <p>;` … `endpackage` (the corrected scope walk — the guard
    `if not line.endswith(';')` that pass 44's two scripts carried refused to
    push `package p;` at all and put every package hit in the `$unit` bucket);
  * a VARIABLE declaration, not a typedef / parameter / localparam / import /
    function prototype;
  * with an UNPACKED dimension that is a fixed SIZE or RANGE — a literal, a
    constant identifier, or `a:b` — and explicitly NOT `[]` (dynamic), `[$]`
    (queue) or `[<type-or-string>]` (associative), each of which
    `emitPkgArrayVar` already accepts;
  * in a file a SystemVerilog front end reads (not `.h`/`.c`/`.cpp` — the four
    C/C++ headers were a third of pass 43's bogus reach figure).

  usage: pkgarr.py <root> [root ...]
Prints the per-test distribution, because REACH IS PER TEST: a shape that only
occurs in a SLANG_REJECT / TIMEOUT / DEFERRED test cannot move a verdict, and
that is what sank both of the last two passes' ranked items.
"""
import os
import re
import sys
from collections import Counter

SV_EXT = ('.sv', '.svh', '.v', '.vh')
OPEN = re.compile(r'^\s*(?:\w+\s*:\s*)?(module|interface|package|class|program'
                  r'|checker|function|task|generate)\b')
CLOSE = re.compile(r'^\s*end(module|interface|package|class|program|checker'
                   r'|function|task|generate)\b')
# <type…> <name> [<dim>] ... ;   -- one leading unpacked dimension is enough to
# classify; extra dimensions do not change the canonical kind.
DECL = re.compile(r'^\s*(\w[\w:#\(\)\s,\.\'\$\-\+\[\]]*?)\s+(\w+)\s*'
                  r'\[([^\]]*)\]\s*(?:\[[^\]]*\]\s*)*(?:=[^;]*)?;')
NOT_A_VAR = ('typedef', 'parameter', 'localparam', 'import', 'export',
             'extern', 'function', 'task', 'return', 'assert', 'assume',
             'cover', 'const', 'class', 'virtual', 'pure', 'covergroup',
             'defparam', 'specparam', 'let')
TYPE_INDEX = re.compile(r'^\s*(int|integer|byte|shortint|longint|time|string'
                        r'|bit|logic|reg|real|shortreal|chandle|event'
                        r'|[A-Za-z_]\w*_t|[A-Za-z_]\w*::\w+)\s*$')


def fixed_dim(d):
    """Is the unpacked dimension a FIXED size/range (the dropped arm)?"""
    d = d.strip()
    if d == '' or d == '$':
        return False           # dynamic array / queue -- already handled
    if ':' in d:
        return True            # [a:b] -- always a fixed range
    if re.match(r'^[0-9]', d) or re.match(r'^\d*\'', d):
        return True            # [8] / [4'd3]
    if TYPE_INDEX.match(d):
        return False           # associative index -- already handled
    # A bare identifier is ambiguous: a constant size or an associative index
    # by typedef name.  Report it separately rather than guessing.
    return None


def scan(path):
    out = []
    stack = []
    # *** THE FALSE-POSITIVE MODE THIS COUNTER CORRECTS IN ITSELF. ***  The
    # first version of this script reported "4 FIXED package-scope unpacked
    # array variables in 3 files" and ALL FOUR were STRUCT MEMBERS inside a
    # `typedef struct { … }` — `logic [31:0] pair[2];` in HierPathUnpacked,
    # `bit [31:0] keys[8];` / `exp_digest[8]` in Opentitan's test_vectors_pkg.
    # The `typedef` line itself is (correctly) not pushed as a scope, so its
    # BODY looked like package scope.  A struct member is a completely different
    # emitter path from `emitPkgArrayVar`, so those hits could not have measured
    # the shape at all.  Track the aggregate-body brace depth and skip it.
    depth = 0
    try:
        with open(path, 'r', errors='replace') as f:
            for line in f:
                line = line.split('//')[0]
                if depth > 0:
                    depth += line.count('{') - line.count('}')
                    continue
                if re.match(r'^\s*typedef\s+.*\bstruct\b|^\s*typedef\s+.*\bunion\b'
                            r'|^\s*typedef\s+.*\benum\b', line) and '{' in line:
                    depth = line.count('{') - line.count('}')
                    continue
                if CLOSE.match(line):
                    if stack:
                        stack.pop()
                    continue
                head = line.strip()
                o = OPEN.match(line)
                if o and not head.startswith('typedef') \
                        and not head.startswith('extern') \
                        and not head.startswith('pure virtual'):
                    # `function`/`task` open a scope; a prototype ending in ';'
                    # after `extern`/`pure virtual` does not, and is excluded
                    # above.  Everything else pushes -- including `package p;`,
                    # which the pass-44 scripts' `endswith(';')` guard refused.
                    stack.append(o.group(1))
                    continue
                if not stack or stack[-1] != 'package':
                    continue
                m = DECL.match(line)
                if not m:
                    continue
                lead = m.group(1).strip().split()
                if not lead or lead[0] in NOT_A_VAR:
                    continue
                v = fixed_dim(m.group(3))
                out.append((v, m.group(2), m.group(3), head))
    except OSError:
        pass
    return out


def main():
    sure = Counter()
    maybe = Counter()
    rows = []
    for root in sys.argv[1:]:
        for dirpath, _dirs, names in os.walk(root):
            for n in names:
                if not n.endswith(SV_EXT):
                    continue
                p = os.path.join(dirpath, n)
                for v, name, dim, txt in scan(p):
                    if v is True:
                        sure[p] += 1
                        rows.append(('FIXED', p, name, dim, txt))
                    elif v is None:
                        maybe[p] += 1
                        rows.append(('AMBIG', p, name, dim, txt))
    print('FIXED  package-scope unpacked array VARIABLES: %d in %d files'
          % (sum(sure.values()), len(sure)))
    print('AMBIG  (bare identifier dim: constant size OR assoc index): %d in %d'
          % (sum(maybe.values()), len(maybe)))
    print()
    for kind, p, name, dim, txt in sorted(rows):
        print('%-5s %-70s %-22s [%s]' % (kind, p, name, dim))


if __name__ == '__main__':
    main()
