#!/usr/bin/env python3
"""r10svs2 CELL TABLE — the SECOND PATH ELEMENT of a dotted-call hier_path,
listed on BOTH sides at OWN CHILD DEPTH.

LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours, matching
`uhdm-cmp <golden.uhdm> <ours.uhdm>`.

WHAT A CELL IS.  One cell = one SOURCE SITE, keyed on (line, col) of the METHOD
TOKEN — never on an object, because the campaign law is that "an object is not a
dump occurrence": the same object prints at several depths and would be counted
several times.  Each cell records, per side:

    KIND      the object class of the second path element
              (ref_obj / method_func_call / <absent>)
    FULL      its vpiFullName, read at OWN CHILD DEPTH (header indent + 2) and
              NOT from the subtree -- an object's fields are not its subtree's
              fields.  '-' means the field is absent, which is a DIFFERENT
              reading from an empty string.
    SPAN      the ENCLOSING hier_path's own line:col-endcol, which is the second
              thing the law changes.

FOUR COUNTERS, kept separate on purpose; none subsumes another:

    EQ           both sides emit the element, and KIND, FULL and SPAN all agree
    DIFFER       both sides emit the SAME KIND but a FIELD (FULL or SPAN) differs
    DIFFERKIND   both sides emit an element of a DIFFERENT CLASS -- the very cell
                 this pass's law is about.  Scoring it EQ because two absent
                 fullnames "matched" would be a FALSE agreement.
    UNMEASURED   one side emits NO element at that site at all.  A louder reading
                 than an absent field, and never merged into DIFFER.
"""
import re
import sys

HDR = re.compile(r'^(\s*)\\_(hier_path): \(([^)]*)\)'
                 r'(?:, id:\d+)?, line:(\d+):(\d+), endln:(\d+):(\d+)')
ELEM = re.compile(r'^(\s*)\\_(ref_obj|method_func_call|func_call|hier_path)'
                  r': \(([^)]*)\)(?:, id:\d+)?'
                  r'(?:, line:(\d+):(\d+), endln:(\d+):(\d+))?')
FIELD = re.compile(r'^(\s*)\|(\w+):(.*)$')


def scan(path):
    """site (line,col of the 2nd element) -> (kind, fullname, hp_span)."""
    lines = open(path, encoding='utf-8', errors='replace').read().split('\n')
    out = {}
    for i, ln in enumerate(lines):
        m = HDR.match(ln)
        if not m:
            continue
        ind, _, hpname, hl, hc, _el, ec = m.groups()
        if '.' not in hpname:
            continue                      # not a dotted-call path
        span = '%s:%s-%s' % (hl, hc, ec)
        # OWN CHILD DEPTH for this header is len(ind) + 2.  Walk forward only
        # while we are at or below that depth, and collect the path ELEMENTS
        # that sit exactly at own child depth.
        cd = len(ind) + 2
        j = i + 1
        elems = []
        while j < len(lines):
            l2 = lines[j]
            if not l2.strip():
                j += 1
                continue
            lead = len(l2) - len(l2.lstrip())
            if lead <= len(ind) and l2.lstrip().startswith('\\_'):
                break                     # left the header's subtree
            f = FIELD.match(l2)
            if f and len(f.group(1)) == len(ind) and f.group(2) == 'vpiParent':
                j += 2                    # skip the parent back-reference
                continue
            e = ELEM.match(l2)
            if e and len(e.group(1)) == cd:
                # own-child-depth fields of THIS element live at cd + 2
                full = '-'
                k = j + 1
                while k < len(lines):
                    f2 = FIELD.match(lines[k])
                    if f2 and len(f2.group(1)) == cd + 2:
                        if f2.group(2) == 'vpiFullName':
                            full = f2.group(3)
                        k += 1
                        continue
                    e2 = ELEM.match(lines[k])
                    if e2 and len(e2.group(1)) <= cd:
                        break
                    if not lines[k].strip():
                        break
                    k += 1
                elems.append((e.group(2), e.group(4), e.group(5), full))
            j += 1
        if len(elems) < 2:
            continue
        kind, el, ec2, full = elems[-1]
        if el is None:
            continue
        out[(int(el), int(ec2))] = (kind, full, span)
    return out


def main():
    g, o = scan(sys.argv[1]), scan(sys.argv[2])
    sites = sorted(set(g) | set(o))
    print('%-9s | %-18s %-26s %-11s | %-18s %-26s %-11s | %s' %
          ('SITE', 'GOLD KIND', 'GOLD FULLNAME', 'GOLD HPSPAN',
           'OURS KIND', 'OURS FULLNAME', 'OURS HPSPAN', 'VERDICT'))
    n = {'EQ': 0, 'DIFFER': 0, 'DIFFERKIND': 0, 'UNMEASURED': 0}
    for s in sites:
        gv, ov = g.get(s), o.get(s)
        if gv is None or ov is None:
            v = 'UNMEASURED'
        elif gv[0] != ov[0]:
            v = 'DIFFERKIND'
        elif gv != ov:
            v = 'DIFFER'
        else:
            v = 'EQ'
        n[v] += 1
        gv = gv or ('<absent>', '-', '-')
        ov = ov or ('<absent>', '-', '-')
        print('%-9s | %-18s %-26s %-11s | %-18s %-26s %-11s | %s' %
              ('%d:%d' % s, gv[0], gv[1], gv[2], ov[0], ov[1], ov[2], v))
    print('CELLS=%d EQ=%d DIFFER=%d DIFFERKIND=%d '
          'UNMEASURED(one side emits no element)=%d' %
          (len(sites), n['EQ'], n['DIFFER'], n['DIFFERKIND'], n['UNMEASURED']))


if __name__ == '__main__':
    main()
