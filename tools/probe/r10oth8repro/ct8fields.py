#!/usr/bin/env python3
"""r10oth8 -- OWN-DEPTH field lister for uhdm-dump output.

    usage: ct8fields.py <dump> <kind> <name-substring> [--nested] [--json]

WHY THIS SCRIPT EXISTS, AND IT IS A CORRECTION OF A MEASUREMENT ERROR THE
CAMPAIGN ALREADY MADE.  The r10oth8 brief records that its author's FIRST field
extraction for this very target walked everything under the `array_var` without
checking depth, and therefore reported that BOTH sides carry `vpiSigned:1`
"merely in a different order".  They do not: golden's sits on the ARRAY_VAR and
ours sits on the NESTED element var.  A flattening instrument cannot see a MOVE
at all -- it sees a reorder.  So:

  * an object's OWN fields are the `|vpiFoo:value` lines at EXACTLY the header's
    indent + 2, and nothing deeper;
  * everything deeper is reported SEPARATELY, under `--nested`, prefixed with
    the owning child object's kind, so a nested field can never be silently
    counted as the parent's;
  * a name that resolves to NO object prints `UNMEASURED`, never an empty field
    list that would read as "no fields differ".

uhdm-dump's FIRST LINE IS THE DATABASE PATH.  This script does NOT strip it --
it is the caller's job (`sed 1d`), because the line is harmless to a
header-anchored scan and silently stripping it here would make the two
conventions disagree.  Every r10oth8 driver feeds it a `sed 1d`'d dump.

LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.  This script reads ONE dump
and says nothing about sides; the comparison lives in ct8grid.sh.
"""
import json
import re
import sys

HDR = re.compile(r'^( *)\\_(\w+): ?(.*)$')
FLD = re.compile(r'^( *)\|(\w+):(.*)$')


def indent_of(line):
    return len(line) - len(line.lstrip(' '))


def objects(lines, kind, namesub):
    """Yield (index, indent, headerline) for every <kind> header whose header
    text contains <namesub>.  An empty namesub matches every one."""
    for i, ln in enumerate(lines):
        m = HDR.match(ln.rstrip('\n'))
        if not m:
            continue
        if m.group(2) != kind:
            continue
        if namesub and namesub not in m.group(3):
            continue
        yield i, len(m.group(1)), ln.rstrip('\n')


def extent(lines, i, ind):
    """The half-open range of lines belonging to the object headed at i."""
    j = i + 1
    while j < len(lines):
        ln = lines[j].rstrip('\n')
        if ln.strip() == '':
            j += 1
            continue
        if indent_of(ln) <= ind:
            break
        j += 1
    return j


def own_and_nested(lines, i, ind):
    """(own scalar fields, nested scalar fields) for the object headed at i.

    OWN = `|name:value` with a NON-EMPTY value at indent ind+2.  A field whose
    value is empty is a REFERENCE slot (`|vpiParent:` then the object); those
    are listed separately as `refs` so a missing child link is still visible.
    NESTED = any `|name:value` deeper than ind+2, tagged with the kind of the
    nearest enclosing child-object header, which is what makes a moved field
    legible as a move.
    """
    end = extent(lines, i, ind)
    own, refs, nested = [], [], []
    stack = []  # (indent, kind) of child object headers currently open
    for j in range(i + 1, end):
        ln = lines[j].rstrip('\n')
        if not ln.strip():
            continue
        k = indent_of(ln)
        h = HDR.match(ln)
        if h:
            while stack and stack[-1][0] >= k:
                stack.pop()
            stack.append((k, h.group(2)))
            continue
        f = FLD.match(ln)
        if not f:
            continue
        while stack and stack[-1][0] >= k:
            stack.pop()
        name, val = f.group(2), f.group(3)
        if k == ind + 2:
            (own if val != '' else refs).append((name, val))
        else:
            owner = stack[-1][1] if stack else '?'
            if val != '':
                nested.append((owner, name, val))
    return own, refs, nested


def main():
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    flags = {a for a in sys.argv[1:] if a.startswith('--')}
    if len(args) < 2:
        print(__doc__)
        return 2
    dump, kind = args[0], args[1]
    namesub = args[2] if len(args) > 2 else ''
    with open(dump, encoding='utf-8', errors='replace') as fh:
        lines = fh.readlines()
    found = list(objects(lines, kind, namesub))
    if not found:
        print('UNMEASURED: no %s header contains %r in %s' % (kind, namesub, dump))
        return 3
    out = []
    for i, ind, hdr in found:
        own, refs, nested = own_and_nested(lines, i, ind)
        out.append({'line': i + 1, 'header': hdr.strip(), 'own': own,
                    'refs': refs, 'nested': nested})
    # --defn keeps only the DEFINITIONAL occurrence of each object.  uhdm-dump
    # re-prints a header wherever the object is REFERENCED (`vpiParent`,
    # `vpiActual`), and those occurrences carry no fields at all -- which is
    # the campaign's "back-reference flattening" trap in its other direction:
    # a reference occurrence read as the object says every field is missing.
    # The definitional one is the occurrence with fields; ties keep the first.
    if '--defn' in flags:
        best = {}
        for o in out:
            key = o['header'].split(', ')[0]
            score = len(o['own']) + len(o['refs'])
            if key not in best or score > best[key][0]:
                best[key] = (score, o)
        out = [v[1] for v in best.values()]
        if not any(o['own'] for o in out):
            print('UNMEASURED: every %s occurrence matching %r is a bare '
                  'back-reference (no fields anywhere)' % (kind, namesub))
            return 3
    if '--json' in flags:
        print(json.dumps(out, indent=1))
        return 0
    for o in out:
        print('== %s  (dump line %d)' % (o['header'], o['line']))
        print('   OWN   : ' + ' '.join('%s:%s' % f for f in o['own']))
        print('   refs  : ' + ' '.join(n for n, _ in o['refs']))
        if '--nested' in flags:
            for ow, n, v in o['nested']:
                print('   nested: [%s] %s:%s' % (ow, n, v))
    return 0


if __name__ == '__main__':
    sys.exit(main())
