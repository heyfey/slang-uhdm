#!/usr/bin/env python3
"""r10earl53 — STREAMING hier_path census over a uhdm-dump.

The Earlgrey elab dump is ~4M lines; a full tree parse is affordable but slow,
and every question this pass asks is LOCAL to one object print:

    <ind>\\_hier_path: (<name>), line:L:C, endln:L:C     <- the object
    <ind+2>|<field>:                                    <- its fields
    <ind+2>\\_<kind>: ...                                <- a field's value

So the census streams: for each hier_path FULL PRINT (one that has at least one
field line under it), it records

  * the FIELD IT HANGS ON  (the `|vpiOperand:` / `|vpiRhs:` ... label that
    immediately precedes it) -- the CONTEXT, which is the discriminator this
    pass is looking for;
  * the PARENT OBJECT KIND (from the enclosing print, tracked on a stack);
  * whether it carries `|vpiTypespec:` and, if so, the KIND and NAME of the
    ref_typespec's own `vpiActual`;
  * whether it carries `|vpiExpr:` and that expr's kind/name.

TRAPS ENCODED:
  * AN OBJECT PRINT IS NOT AN OBJECT.  The same object is re-printed
    childlessly wherever it is referenced (vpiParent back-refs, vpiActual).  A
    print with NO field lines under it is a BACK-REFERENCE and is counted in
    its own column, never mixed with definitions.  Counting back-refs as
    objects triples every hier_path number in this dump.
  * `file:<path>` embeds the workdir -> never keyed on.
  * The first dump line is the database path; callers pass `sed 1d` dumps and
    this parser also tolerates a leading non-`\\_` line.

  usage: hpcensus53.py <dump> [--kind=hier_path] [--rows] [--full]
"""
import collections
import re
import sys

OBJ = re.compile(r'^(?P<ind>\s*)\\_(?P<kind>[A-Za-z_0-9]+): ?(?P<rest>.*)$')
FLD = re.compile(r'^(?P<ind>\s*)\|(?P<name>[A-Za-z_0-9]+):(?P<val>.*)$')
NAM = re.compile(r'^(?:\S+ )?\((?P<n>[^)]*)\)')
LOC = re.compile(r'line:(\d+):(\d+), endln:(\d+):(\d+)')


def nameof(rest):
    m = NAM.match(rest)
    return m.group('n') if m else ''


def spanof(rest):
    m = LOC.search(rest)
    return '%s:%s:%s:%s' % m.groups() if m else '-'


def census(path, want):
    """Stream the dump; return one record per PRINT of `want`.

    A STACK of open records is mandatory: a hier_path's own subtree re-prints
    THE SAME hier_path childlessly under `vpiParent` (and under its
    ref_typespec's `vpiParent`), and a single-slot `current record` is
    CLOBBERED by that inner print -- which reported `FULL=0, backref=46344`
    for a dump whose very first hier_path plainly has ten fields.  Never let a
    nested print of the same kind evict its own parent.
    """
    field_at = {}               # indent -> last field label seen at that indent
    stack = []                  # [(indent, kind, field)] of enclosing prints
    stack_named = []            # the same, carrying each print's NAME
    open_recs = []              # [(indent, rec)] of `want` prints still open
    rows = []

    def close_to(ind):
        while open_recs and open_recs[-1][0] >= ind:
            rows.append(open_recs.pop()[1])

    for line in open(path, errors='replace'):
        line = line.rstrip('\n')
        m = OBJ.match(line)
        if m:
            ind = len(m.group('ind'))
            kind = m.group('kind')
            rest = m.group('rest')
            close_to(ind)
            while stack and stack[-1][0] >= ind:
                stack.pop()
            hangs = field_at.get(ind, '-')
            parent = stack[-1][1] if stack else '-ROOT-'
            chain = '/'.join('%s:%s' % (f, k) for _, k, f in stack[-3:])
            # NEAREST enclosing module_inst / port names: the only stable KEY
            # for joining golden and ours (ids differ, and a hier_path's own
            # name repeats thousands of times across instances).
            inst = port = '-'
            for _, k, f, nm in reversed(stack_named):
                if port == '-' and k == 'port':
                    port = nm
                if k in ('module_inst', 'gen_scope', 'interface_inst'):
                    inst = nm
                    break
            # attribute this child to the innermost STILL-OPEN record that is
            # exactly one level up
            for ri, r in reversed(open_recs):
                if ri + 2 == ind:
                    r['nkids'] += 1
                    if hangs == 'vpiTypespec':
                        r['ts'] = kind + '(' + nameof(rest) + ')'
                        r['tsind'] = ind
                    elif hangs == 'vpiExpr':
                        r['expr'] = kind + '(' + nameof(rest) + ')'
                    break
                if ri + 4 == ind and r['ts'] and r.get('tsind') == ind - 2 \
                        and hangs == 'vpiActual' and r['tsactual'] is None:
                    r['tsactual'] = kind + '(' + nameof(rest) + ')'
                    break
            stack.append((ind, kind, hangs))
            while stack_named and stack_named[-1][0] >= ind:
                stack_named.pop()
            stack_named.append((ind, kind, hangs, nameof(rest)))
            if kind == want:
                open_recs.append((ind, {
                    'name': nameof(rest), 'span': spanof(rest),
                    'hangs': hangs, 'parent': parent, 'fields': [],
                    'ts': None, 'tsactual': None, 'expr': None, 'nkids': 0,
                    'chain': chain, 'inst': inst, 'port': port}))
            continue
        m = FLD.match(line)
        if m:
            ind = len(m.group('ind'))
            field_at[ind] = m.group('name')
            for k in [k for k in field_at if k > ind]:
                del field_at[k]
            for ri, r in reversed(open_recs):
                if ri + 2 == ind:
                    r['fields'].append(m.group('name'))
                    r['nkids'] += 1
                    break
    close_to(-1)
    return rows


def main():
    args = [a for a in sys.argv[1:]]
    want = 'hier_path'
    show_rows = False
    show_ctx = False
    show_key = False
    for a in list(args):
        if a.startswith('--kind='):
            want = a.split('=', 1)[1]
            args.remove(a)
        elif a == '--rows':
            show_rows = True
            args.remove(a)
        elif a == '--ctx':
            show_ctx = True
            args.remove(a)
        elif a == '--key':
            show_key = True
            args.remove(a)
    dump = args[0]
    rows = census(dump, want)
    full = [r for r in rows if r['nkids'] > 0]
    backref = [r for r in rows if r['nkids'] == 0]
    print('%s: prints=%d  FULL=%d  backref(childless)=%d' %
          (dump, len(rows), len(full), len(backref)))
    c = collections.Counter()
    for r in full:
        c[(r['hangs'], r['parent'], (r['expr'] or '-').split('(')[0],
           'TS' if r['ts'] else 'no-TS')] += 1
    print('%-18s %-18s %-16s %-7s %s' %
          ('HANGS-ON', 'PARENT-KIND', 'vpiExpr-KIND', 'TS?', 'N'))
    for k, n in sorted(c.items(), key=lambda kv: -kv[1]):
        print('%-18s %-18s %-16s %-7s %d' % (k[0], k[1], k[2], k[3], n))
    ca = collections.Counter(r['tsactual'] for r in full if r['ts'])
    if ca:
        print('-- ref_typespec vpiActual kinds:')
        for k, n in sorted(ca.items(), key=lambda kv: -kv[1])[:20]:
            print('   %-40s %d' % (k, n))
    if show_key:
        for r in full:
            print('%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s' %
                  (r['inst'], r['port'], r['name'], r['span'], r['hangs'],
                   'TS' if r['ts'] else '.', r['tsactual'] or '-',
                   r['expr'] or '-'))
        return
    if show_ctx:
        cc = collections.Counter()
        for r in full:
            cc[(r['chain'], 'TS' if r['ts'] else 'no-TS')] += 1
        print('-- ANCESTOR CHAIN (3 deep) x TS')
        for k, n in sorted(cc.items(), key=lambda kv: -kv[1]):
            print('   %-6s %-70s %d' % (k[1], k[0], n))
    if show_rows:
        for r in full:
            print('ROW %-28s %-16s hangs=%-16s parent=%-16s ts=%-30s act=%-34s expr=%s' %
                  (r['name'][:28], r['span'], r['hangs'], r['parent'],
                   r['ts'], r['tsactual'], r['expr']), '|', r['chain'])


if __name__ == '__main__':
    main()
