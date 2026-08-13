#!/usr/bin/env python3
"""r10earl36 — THE MOVER FENCE, computed from the PRISTINE dump and the SOURCE
before any patched sweep is read.

§ patDefBoundShadowedImport36 changes exactly one expression builder: the
`<ident>-<digits>` DEF-view bound of a DECLARATION-CARRIED packed dim over a
NAMED element type (the `identV && tfContext` arm of makeTypespec's
packed_array_typespec range).  Nothing else in the emitter is reachable.

So the COMPLETE candidate set is enumerable from the pristine dump alone:

  every  packed_array_typespec -> vpiRange -> range -> vpiLeftRange/vpiRightRange
         -> operation(vpiOpType:11) -> first operand that is a BARE ref_obj

and the patch fires on exactly the subset of those whose name is ALSO declared
by a package the declaring module WILDCARD-IMPORTS (`wildcardPkgParamNamed9`).
This script prints the candidate set; the caller intersects it with the source
by hand (the shadow test needs slang's scopes, which a dump does not carry).

PREDICTION FORM:  movers  =  candidates ∩ shadowed
                  every moved dump line is a removed `ref_obj:`/`|vpiName:` pair
                  or an added constant/ref_typespec/int_typespec group at the
                  SAME span; no other object kind and no other field can move.
"""
import re
import sys
from collections import Counter

OBJ = re.compile(r'^(\s*)\\_(\w+): *(\([^)]*\))?,? *(.*)$')
ATTR = re.compile(r'^(\s*)\|(\w+):(.*)$')
LOC = re.compile(r'line:(\d+):(\d+), endln:(\d+):(\d+)')


def main():
    dump = sys.argv[1]
    lines = open(dump, 'rt', errors='replace').read().split('\n')
    n = len(lines)
    # stack of (indent, kind) so we know whether a range sits under a
    # packed_array_typespec, and which relation we descended through.
    cands = Counter()
    stack = []          # (indent, kind)
    rel = []            # (indent, relation-name)
    for i in range(n):
        ln = lines[i]
        am = ATTR.match(ln)
        if am:
            ind = len(am.group(1))
            while rel and rel[-1][0] >= ind:
                rel.pop()
            rel.append((ind, am.group(2)))
            continue
        om = OBJ.match(ln)
        if not om:
            continue
        ind, kind, tail = len(om.group(1)), om.group(2), om.group(4)
        while stack and stack[-1][0] >= ind:
            stack.pop()
        # relations deeper than this object belong to it, not above it
        while rel and rel[-1][0] > ind:
            rel.pop()
        myrel = rel[-1][1] if rel and rel[-1][0] == ind else ''
        if kind == 'ref_obj' and myrel == 'vpiOperand':
            # ... under an operation, under a range, under a packed_array_ts
            kinds = [k for _, k in stack]
            if (len(kinds) >= 3 and kinds[-1] == 'operation'
                    and kinds[-2] == 'range'
                    and kinds[-3] == 'packed_array_typespec'):
                nm = ''
                if i + 2 < n:
                    for j in range(i + 1, min(i + 6, n)):
                        a2 = ATTR.match(lines[j])
                        if a2 and a2.group(2) == 'vpiName':
                            nm = a2.group(3)
                            break
                lm = LOC.search(tail)
                span = ('%s:%s' % (lm.group(1), lm.group(2))) if lm else '?'
                cands['%-24s @%s' % (nm, span)] += 1
        stack.append((ind, kind))
    print('CANDIDATE bare ref_obj bounds under a packed_array_typespec range')
    print('  (the COMPLETE set the patch can reach; movers are the SHADOWED subset)')
    tot = 0
    for k, v in sorted(cands.items()):
        print('  %s  x%d' % (k, v))
        tot += v
    print('CANDIDATES: %d distinct, %d prints' % (len(cands), tot))


if __name__ == '__main__':
    main()
