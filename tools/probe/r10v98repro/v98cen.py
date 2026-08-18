#!/usr/bin/env python3
"""v98 verifier census — INDEPENDENT of the pass's ct98cen.
One row per ref_typespec site in an uhdm-dump:
  KEY   = the site's vpiFullName (view-general; synthesised by the dump)
  VALUE = the bound typespec's KIND | NAME [| SPAN]
SPAN is a DECLARATION IDENTIFIER for diagnosis only; no generated Compare reads
it, so a span-only move is judge-invisible.  --nospan drops it.
"""
import sys, re, collections
NODE = re.compile(r'^(\s*)\\_(\w+): \(([^)]*)\)(.*)$')
def classdefns(lines):
    """span-keyed Class_defn table, harvested anywhere in the dump: the judge
    READS class_typespec::Class_defn, so a span-blind payload without it is
    blind to the very field this pass moves."""
    d = {}
    stack = []
    pend = None
    for l in lines:
        m = NODE.match(l)
        if m:
            ind, kind, label, tail = len(m.group(1)), m.group(2), m.group(3), m.group(4)
            if pend is not None and ind == pend[0] and kind == 'class_defn':
                d.setdefault(pend[1], label)
                pend = None
            while stack and stack[-1][0] >= ind:
                stack.pop()
            sm = re.search(r'line:(\d+:\d+)(?:, endln:(\d+:\d+))?', tail)
            sp = (sm.group(1) + '-' + (sm.group(2) or '')) if sm else ''
            stack.append((ind, kind, label, sp))
            continue
        s = l.strip()
        if s == '|vpiClassDefn:':
            ind = len(l) - len(l.lstrip())
            for (i, k, lab, sp) in reversed(stack):
                if i < ind and k == 'class_typespec':
                    pend = (ind, (lab, sp)); break
        elif s.startswith('|'):
            pend = None
    return d

def rows(path, nospan=False):
    out = collections.defaultdict(list)
    lines = open(path, errors='replace').read().split('\n')
    CD = classdefns(lines)
    stack = []          # (indent, kind, label)
    pend = None         # (indent_of_vpiActual, site_label)
    for l in lines:
        m = NODE.match(l)
        if m:
            ind, kind, label, tail = len(m.group(1)), m.group(2), m.group(3), m.group(4)
            if pend is not None and ind == pend[0]:
                sm = re.search(r'line:(\d+:\d+)(?:, endln:(\d+:\d+))?', tail)
                fsp = (sm.group(1) + '-' + (sm.group(2) or '')) if sm else ''
                sp = ('@' + fsp) if (sm and not nospan) else ''
                extra = ''
                if kind == 'class_typespec':
                    extra = '|defn=' + CD.get((label, fsp), '?')
                out[pend[1]].append('%s|%s%s%s' % (kind, label, sp, extra))
                pend = None
            while stack and stack[-1][0] >= ind:
                stack.pop()
            stack.append((ind, kind, label))
            continue
        s = l.strip()
        if s == '|vpiActual:':
            ind = len(l) - len(l.lstrip())
            site = None
            for (i, k, lab) in reversed(stack):
                if i < ind and k == 'ref_typespec':
                    site = lab; break
            if site is not None:
                pend = (ind, site)
        elif s.startswith('|'):
            pend = None
    return out
if __name__ == '__main__':
    a = sys.argv[1:]
    nospan = '--nospan' in a
    a = [x for x in a if not x.startswith('--')]
    d = rows(a[0], nospan)
    for k in sorted(d):
        print('%s\t%s' % (k, ';'.join(sorted(d[k]))))
