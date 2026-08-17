#!/usr/bin/env python3
"""r10uvm80 — STATED GATE == CODE GATE audit for § blockDeclAutomaticIsWrittenKw80.

  usage: ct80gate.py <src/StmtEmit.cpp>          exit 0 = PASS, 5 = FAIL, 4 = no law

Reads CODE, not prose: every `//` comment is stripped before any row is counted,
because a guard that greps its own write-up is this campaign's oldest trap.  It
has a real negative control — run it on a PRISTINE StmtEmit.cpp and it must FAIL
with every row named.  An audit that cannot find the block-local loop at all
exits 4 rather than reporting success.

Each row below is one sentence of the README's law, in the same words:

  1  the predicate exists, ONCE                  `bool writtenAutomaticKw80(`  x1
  2  it reads the WRITTEN keyword                AutomaticKeyword             x1
  3  ...on the DATA DECLARATION, not the symbol  SyntaxKind::DataDeclaration  x1
  4  ...through the DECLARATOR's parent          SyntaxKind::Declarator       x1
  5  slang's semantic lifetime is NOT read       `VariableLifetime` in this
                                                 predicate                    x0
  6  it is computed ONCE per declaration         `auto80 = writtenAutomaticKw80` x1
  7  and read at FOUR factories                  `if (auto80)`                x4
  8  every stamp is GATED                        VpiAutomatic(true) not
                                                 preceded by `if (auto80)`    x0
"""
import re
import sys


def strip_comments(text):
    out = []
    for line in text.splitlines():
        out.append(re.sub(r'//.*$', '', line))
    return '\n'.join(out)


def main():
    if len(sys.argv) < 2:
        print('usage: ct80gate.py <src/StmtEmit.cpp>')
        return 2
    raw = open(sys.argv[1], errors='replace').read()
    src = strip_comments(raw)

    if 'blockSymbol->members()' not in src:
        print('AUDIT-BROKEN: no block-local loop in this file — refusing to '
              'report success')
        return 4

    rows = []

    def row(name, ok, got, want):
        rows.append((name, ok, got, want))

    n = len(re.findall(r'\bbool\s+writtenAutomaticKw80\s*\(', src))
    row('1 predicate defined once', n == 1, n, 1)

    body = ''
    m = re.search(r'bool\s+writtenAutomaticKw80\s*\([^)]*\)\s*\{', src)
    if m:
        depth, i = 0, m.end() - 1
        while i < len(src):
            if src[i] == '{':
                depth += 1
            elif src[i] == '}':
                depth -= 1
                if depth == 0:
                    break
            i += 1
        body = src[m.end():i]

    n = body.count('TokenKind::AutomaticKeyword')
    row('2 reads the written automatic keyword', n == 1, n, 1)
    n = body.count('SyntaxKind::DataDeclaration')
    row('3 on the data_declaration node', n == 1, n, 1)
    n = body.count('SyntaxKind::Declarator')
    row('4 reached through the declarator parent', n == 1, n, 1)
    n = body.count('VariableLifetime')
    row("5 slang's semantic lifetime NOT read", n == 0, n, 0)

    n = len(re.findall(r'auto80\s*=\s*writtenAutomaticKw80\(', src))
    row('6 computed once per declaration', n == 1, n, 1)
    n = len(re.findall(r'if\s*\(auto80\)', src))
    row('7 read at four factories', n == 4, n, 4)

    # Every VpiAutomatic(true) added by this pass must sit directly under an
    # `if (auto80)`.  Count the ungated ones in the block-local loop's region.
    start = src.index('blockSymbol->members()')
    end = src.index('if (!vars->empty())', start)
    region = src[start:end]
    stamps = [mm.start() for mm in re.finditer(r'VpiAutomatic\(true\)', region)]
    ungated = 0
    for pos in stamps:
        before = region[max(0, pos - 200):pos]
        if 'if (auto80)' not in before:
            ungated += 1
    row('8 every stamp in the block loop is gated', ungated == 0, ungated, 0)
    row('9 four stamps in the block loop', len(stamps) == 4, len(stamps), 4)

    bad = 0
    for name, ok, got, want in rows:
        print('%-4s %-46s got=%-4s want=%s' % ('PASS' if ok else 'FAIL', name,
                                               got, want))
        if not ok:
            bad += 1
    print('ct80gate: %d/%d rows PASS' % (len(rows) - bad, len(rows)))
    return 0 if bad == 0 else 5


if __name__ == '__main__':
    sys.exit(main())
