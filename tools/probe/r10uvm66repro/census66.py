#!/usr/bin/env python3
"""r10uvm66 — THE CENSUS-PREDICT for § declInitWrittenNewNoStmt66.

  usage: census66.py <dir-or-file> [<dir-or-file> ...]

Counts, FROM SOURCE ALONE, every site the law can fire on: a variable
DECLARATION, inside a statement list, whose written initializer is a `new`
construction.  It is deliberately INDEPENDENT OF THE PATCH — predicting from the
patched binary's own output is the measurement restated, not a prediction.

WHAT IT EXCLUDES, and why each exclusion is a measured cell and not a guess:

  * A PLAIN ASSIGNMENT STATEMENT `h = new(...)` — one identifier before the `=`,
    no type.  § thisSuperNewAssignNoStmt3 owns that family and golden KEEPS the
    bare-local spelling (a1 m07).  The census requires TWO name tokens (a type
    and a declarator) before the `=`.
  * A CLASS-MEMBER or MODULE/PACKAGE-SCOPE declaration (`a2c h = new();` written
    at member level) — not a statement list at all, and golden emits no
    statement for it either way (a2 n16/n17).  Tracked by procedural depth.
  * A CLASS CONSTRUCTOR's own body — golden KEEPS the assignment there
    (a2 n01), so `function new` opens a NON-counting region.

WHAT IT CANNOT KNOW, stated as its own bound: how many VIEWS (def / elab /
package clone / out-of-body hoist) each subroutine is emitted in, and whether the
file's test compiles at all.  So the count is EXACT ON DISTINCT SOURCE SITES and
a LOWER BOUND on dump-line movers.

The scanner strips block comments, line comments and string literals first, then
tracks procedural depth with the SystemVerilog block keywords.  It is a scanner,
not a parser: `-v` prints every site so the reader can audit the classification
instead of trusting the total.
"""
import os
import re
import sys

DECL_NEW = re.compile(
    r'^\s*(?:automatic\s+|static\s+|const\s+|var\s+|local\s+|protected\s+|rand\s+|randc\s+)*'
    r'(?P<type>[A-Za-z_$][\w$]*'
    r'(?:\s*::\s*[A-Za-z_$][\w$]*)*'
    r'(?:\s*#\s*\([^;]*?\))?'
    r'(?:\s*\[[^;\]]*\])*'
    r')'
    r'\s+(?P<name>[A-Za-z_$][\w$]*)'
    r'(?P<dims>(?:\s*\[[^;\]]*\])*)'
    r'\s*=\s*new\b')

# Keywords that can look like a "type" in front of a name but are not.
NOT_A_TYPE = {
    'return', 'if', 'else', 'begin', 'end', 'case', 'endcase', 'for', 'while',
    'do', 'foreach', 'repeat', 'forever', 'assign', 'wait', 'fork', 'join',
    'typedef', 'parameter', 'localparam', 'import', 'export', 'extern',
    'function', 'task', 'endfunction', 'endtask', 'class', 'endclass',
    'module', 'endmodule', 'package', 'endpackage', 'this', 'super', 'new',
    'default', 'unique', 'priority', 'randcase', 'constraint', 'covergroup',
}

OPEN_PROC = re.compile(r'\b(function|task|initial|always|always_comb|'
                       r'always_ff|always_latch|final)\b')
CLOSE_PROC = re.compile(r'\b(endfunction|endtask)\b')
CTOR = re.compile(r'\bfunction\b[^;()]*\bnew\b')


def strip(text):
    """Remove block comments, line comments and string literals."""
    out = []
    i, n = 0, len(text)
    while i < n:
        c = text[i]
        if c == '/' and i + 1 < n and text[i + 1] == '*':
            j = text.find('*/', i + 2)
            j = n if j < 0 else j + 2
            out.append(re.sub(r'[^\n]', ' ', text[i:j]))
            i = j
        elif c == '/' and i + 1 < n and text[i + 1] == '/':
            j = text.find('\n', i)
            j = n if j < 0 else j
            out.append(' ' * (j - i))
            i = j
        elif c == '"':
            j = i + 1
            while j < n and text[j] != '"':
                j += 2 if text[j] == '\\' else 1
            j = min(j + 1, n)
            out.append(re.sub(r'[^\n]', ' ', text[i:j]))
            i = j
        else:
            out.append(c)
            i += 1
    return ''.join(out)


def scan_file(path, verbose):
    try:
        text = open(path, errors='replace').read()
    except OSError:
        return []
    lines = strip(text).split('\n')
    hits = []
    # procedural depth: a stack of (kind, is_ctor); a `new` site counts only
    # when the innermost enclosing subroutine is NOT a constructor and the depth
    # is at least one procedural region.
    stack = []
    for ln, raw in enumerate(lines, 1):
        for m in OPEN_PROC.finditer(raw):
            kw = m.group(1)
            if kw in ('function', 'task'):
                # a pure virtual / extern prototype opens nothing
                if re.search(r'\b(pure|extern)\b', raw[:m.start()]):
                    continue
                stack.append((kw, bool(CTOR.search(raw))))
            else:
                stack.append((kw, False))
        m = DECL_NEW.search(raw)
        if m and m.group('type').split()[0] not in NOT_A_TYPE:
            in_proc = bool(stack)
            in_ctor = bool(stack) and stack[-1][1]
            if in_proc and not in_ctor:
                hits.append((path, ln, raw.strip()[:90]))
                if verbose:
                    print('  SITE %s:%d  %s' % (path, ln, raw.strip()[:90]))
            elif verbose:
                why = 'member-level' if not in_proc else 'CONSTRUCTOR body'
                print('  skip(%s) %s:%d  %s' % (why, path, ln,
                                                raw.strip()[:70]))
        for _ in CLOSE_PROC.finditer(raw):
            if stack:
                stack.pop()
        if re.match(r'\s*end\s*$', raw) and stack and \
                stack[-1][0] in ('initial', 'always', 'always_comb',
                                 'always_ff', 'always_latch', 'final'):
            stack.pop()
    return hits


def main():
    verbose = '-v' in sys.argv
    roots = [a for a in sys.argv[1:] if a != '-v']
    allhits = []
    for root in roots:
        if os.path.isfile(root):
            allhits += scan_file(root, verbose)
            continue
        for dp, _dn, fn in os.walk(root):
            for f in fn:
                if f.endswith(('.sv', '.svh', '.v', '.vh')):
                    allhits += scan_file(os.path.join(dp, f), verbose)
    percount = {}
    for p, _l, _t in allhits:
        percount[p] = percount.get(p, 0) + 1
    print('== per FILE')
    for p in sorted(percount, key=lambda x: (-percount[x], x)):
        print('%5d  %s' % (percount[p], p))
    print('== TOTAL SITES: %d in %d files' % (len(allhits), len(percount)))
    print('BOUND: exact on distinct SOURCE SITES; a LOWER bound on dump-line '
          'movers (a source scan cannot know how many VIEWS a subroutine is '
          'emitted in, nor whether its test compiles).')


main()
