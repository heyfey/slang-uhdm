#!/usr/bin/env python3
# r11u58 CENSUS with a SHAPE LISTER beside it — the EXCLUSION FACES.
#
# The r11u54 pair built a VIEW-ONLY reading of road D and it moved EIGHTEEN
# equal rows to not-equal.  Those eighteen are this pass's named MUST-NOT-MOVE
# set.  This census answers, row by row and from the SOURCES, whether each one
# carries the read § pkgElabPatMemberStamp58 gates on:
#   the package pattern parameter's name written as `pkg::NAME` inside a CALL
#   that stands inside a parameter context.
# A row that carries NO such read cannot reach the stamp at all; a row that
# does is named here and must be scored cell by cell against golden.
#
# usage: cen58.py            (the 18 named rows)
#        cen58.py --all      (every directory carrying a package pattern param)
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import pred58  # noqa: E402  (reuses its scanners; it does not run on import)

NAMED = [
    ('uhdm2rtlil', 'ff_dead_both_branches'),
    ('uhdm2rtlil', 'ff_dead_guarded_reset'),
    ('uhdm2rtlil', 'struct_param_repl_count'),
    ('uhdm2rtlil', 'iface_scalar_localparam'),
    ('uhdm2rtlil', 'iface_nested_param_field'),
    ('uhdm2rtlil', 'iface_struct_field_param_width'),
    ('uhdm2rtlil', 'iface_struct_field_partsel'),
    ('uhdm2rtlil', 'ImportedDoubleCastedParameter'),
    ('uhdm2rtlil', 'TypedefStructParamWithRangeInSubmodule'),
    ('uhdm2rtlil',
     'NestedStructArrayParameterInitializedByPatternPassedAsPort'),
    ('surelog', 'AssignmentPatternInAssignmentPattern'),
    ('surelog', 'Earlgrey_0_1'),
    ('surelog', 'FuncStructVal'),
    ('surelog', 'GenForIfaceLocalparamNestedGen'),
    ('surelog', 'GenForStructParamBound'),
    ('surelog', 'GenIfIfaceParamStructField'),
    ('surelog', 'InterfaceParamOverrideProp'),
    # The r11u54 README names SEVENTEEN of the eighteen and prints the last as
    # "(+1)".  `NoReducTypespec` stands in for it here: it is the other row the
    # § patElabUintResize note in src/ParamEmit.cpp names as one that regresses
    # the moment a LITERAL pattern element is re-sized, so it is exactly the
    # kind of row the view-only reading of road D moves.
    ('surelog', 'NoReducTypespec'),
]


def dirs_for(corpus, name):
    for c, root in pred58.ROOTS:
        if c != corpus:
            continue
        d = os.path.join(root, name)
        if os.path.isdir(d):
            yield d


def scan(d0):
    pats, quals = set(), set()
    for p in pred58.sources_of(d0):
        try:
            t = pred58.strip_comments(open(p, errors='replace').read())
        except OSError:
            continue
        pats |= pred58.pkg_pattern_params(t)
        quals |= pred58.param_context_quals(t)
    return pats, quals


def main():
    if '--all' in sys.argv:
        pred58.main()
        return
    seen = set()
    gated = 0
    for corpus, name in NAMED:
        if (corpus, name) in seen:
            continue
        seen.add((corpus, name))
        found = False
        for d0 in dirs_for(corpus, name):
            found = True
            pats, quals = scan(d0)
            hit = sorted(pats & quals)
            gated += 1 if hit else 0
            print(f'{corpus:11s} {name:58s} '
                  f'pkgPatternParams={len(pats):3d} '
                  f'GATED={",".join(hit) if hit else "-"}')
        if not found:
            print(f'{corpus:11s} {name:58s} NO-DIRECTORY')
    print(f'-- named={len(seen)} gated={gated}', file=sys.stderr)


main()
