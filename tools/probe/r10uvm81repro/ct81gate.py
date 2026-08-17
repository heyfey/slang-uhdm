#!/usr/bin/env python3
"""r10uvm81 — STATED GATE == CODE GATE.

    usage: ct81gate.py <src/ExprEmit.cpp>

Asserts, ROW BY ROW, that every clause this pass's README states about its two
laws is present in the CODE.  COMMENTS ARE STRIPPED FIRST: a guard that greps
its own write-up is this campaign's oldest trap, and both laws here are carried
almost entirely by comment text, so an unstripped audit would pass on a file
with no code in it at all.

Exit 0 = every row PASS; exit 5 = a row failed (each failing row is NAMED);
exit 4 = the file does not contain the law sites at all (an audit that cannot
find what it audits must not report success).
"""
import re
import sys


def strip_comments(text):
    out, i, n = [], 0, len(text)
    while i < n:
        if text.startswith('//', i):
            j = text.find('\n', i)
            i = n if j < 0 else j
        elif text.startswith('/*', i):
            j = text.find('*/', i + 2)
            i = n if j < 0 else j + 2
        elif text[i] == '"':
            j = i + 1
            while j < n and text[j] != '"':
                j += 2 if text[j] == '\\' else 1
            out.append(text[i:j + 1])
            i = j + 1
        else:
            out.append(text[i])
            i += 1
    return ''.join(out)


def main():
    if len(sys.argv) != 2:
        print(__doc__)
        return 2
    raw = open(sys.argv[1], errors='replace').read()
    code = strip_comments(raw)

    # The audit is vacuous unless BOTH law sites are in the file.
    anchors = ['pkgVarOverFormal81', 'joinRef(prefix, nv.symbol.name)']
    missing = [a for a in anchors if a not in code]
    if missing:
        print('AUDIT CANNOT RUN: law site(s) absent from the code: %s' % missing)
        return 4

    # SLICE, don't grep the whole file.  ExprEmit.cpp is 20k lines and names
    # like `SymbolKind::Package` and `uhdmio_decl` occur all over it, so a
    # whole-file count measures the FILE, not the LAW.  The slice is law 1's two
    # helpers plus its single call site; law 2's rows stay whole-file because
    # its needles are unique by construction.
    def slice_between(start, end):
        i = code.find(start)
        j = code.find(end, i + 1) if i >= 0 else -1
        return code[i:j] if (i >= 0 and j > i) else ''

    law1 = (slice_between('static UHDM::variables* pkgVarOverFormal81',
                          'UHDM::any* UhdmExporter::emitExpr') +
            slice_between('subHomeIsPkg81(currentSubSym, pkgScopeInst)',
                          'ref->VpiParent(parent);'))
    if len(law1) < 500:
        print('AUDIT CANNOT RUN: law-1 slice is empty (%d chars)' % len(law1))
        return 4

    rows = [
        # (prose, needle, expected count, which slice)
        # ---- LAW 1: pkgSubRefBindsPkgVarOverFormal81 -------------------
        ('L1 ONE overwrite site',
         'ref->Actual_group(pv81)', 1),
        ('L1 the binding it replaces must be a FORMAL',
         'UHDM::uhdmio_decl', 1),
        ('L1 the listing must be a PACKAGE\'s',
         'UHDM::uhdmpackage', 1),
        ('L1 the listing read is the package\'s Variables()',
         'UHDM::package*)pkgInst)->Variables()', 1),
        ('L1 the subroutine must be the PACKAGE\'S OWN (import-copy gate)',
         'subHomeIsPkg81(currentSubSym, pkgScopeInst)', 1),
        ('L1 the home test walks up to a PACKAGE symbol',
         'SymbolKind::Package', 1),
        ('L1 the if/case PREDICATE keeps the formal',
         '!condPredEarlyBound81(expr.syntax)', 1),
        ('L1 the predicate arm names the CONDITIONAL statement',
         'SyntaxKind::ConditionalStatement', 2),
        ('L1 the predicate arm names the CASE statement',
         'SyntaxKind::CaseStatement', 2),
        # ---- the VERIFIER's three added clauses (arms v81c/v81d/v81g) ----
        ('L1V a CASE **ITEM** expression is early-bound too',
         'SyntaxKind::StandardCaseItem', 2),
        ('L1V an item CLAUSE (statement) is NOT',
         'StandardCaseItemSyntax>().clause', 1),
        ('L1V `case … inside` items are the EXCEPTION (late)',
         'cs81.matchesOrInside', 1),
        ('L1V the IMMEDIATE-ASSERTION expression is early-bound',
         'SyntaxKind::ImmediateAssertStatement', 1),
        ('L1V …and its ASSUME twin',
         'SyntaxKind::ImmediateAssumeStatement', 1),
        ('L1V …and its COVER twin',
         'SyntaxKind::ImmediateCoverStatement', 1),
        ('L1V the assertion ACTION BLOCK is NOT early-bound',
         'ImmediateAssertionStatementSyntax>()', 1),
        ('L1 a LOOP above the predicate refuses',
         'SyntaxKind::LoopStatement', 1),
        ('L1 a FOR loop above the predicate refuses',
         'SyntaxKind::ForLoopStatement', 1),
        ('L1 a FOREACH loop above the predicate refuses',
         'SyntaxKind::ForeachLoopStatement', 1),
        ('L1 an ELSE clause above the predicate refuses',
         'SyntaxKind::ElseClause', 1),
        ('L1 the predicate reads the SYNTAX tree, not slang\'s bound statement',
         'p->parent', 1),
        ('L1 no OTHER Actual_group write was added by this law',
         'Actual_group(pv81)', 1),
        # ---- LAW 2: selIdxNestPrefixJoinsByScope80 ---------------------
        ('L2 the nested index prefix is joined with joinRef',
         'idxPrefix = joinRef(prefix, nv.symbol.name);', 1),
        ('L2 the HARD "." join is GONE',
         'idxPrefix = prefix + "."', 0),
    ]

    bad = 0
    for prose, needle, want in rows:
        hay = law1 if prose.startswith('L1') else code
        got = hay.count(needle)
        ok = (got == want)
        bad += 0 if ok else 1
        print('%-4s %-62s %-46s x%d (want x%d)'
              % ('PASS' if ok else 'FAIL', prose, needle, got, want))
    print('---- %d/%d rows PASS' % (len(rows) - bad, len(rows)))
    return 0 if bad == 0 else 5


if __name__ == '__main__':
    sys.exit(main())
