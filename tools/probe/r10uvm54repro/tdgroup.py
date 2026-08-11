#!/usr/bin/env python3
"""r10uvm54repro/tdgroup.py — the CLASS-NESTED class-handle TYPEDEF GROUP
instrument.

LHS is ALWAYS golden(Surelog); RHS is ALWAYS ours.  This script reads ONE dump;
the caller runs it on both sides and joins.

WHAT IT MEASURES.  For every `class_typespec` held by a `class_defn` under
`vpiTypedef` it reports, per (owning class, typedef name):

    span (line:col-endline:endcol) | vpiClassDefn (the GENERIC class) |
    vpiTypedefAlias target (kind, name, span) or NONE

and then GROUPS those rows by their `vpiClassDefn` so the base pick of a group
is a printed measurement rather than an impression.  A group's BASE is the
member with NO `vpiTypedefAlias` whose span every other member repeats.

WHY IT IS NOT A GREP.  uhdm-dump prints an object's children at SOME
occurrences and abbreviates the same object at others (the campaign has
mis-counted twice this way, and `objects` are NOT `dump lines`).  Rows are
therefore keyed by (owning class, typedef name) and every field is a UNION over
all occurrences; the occurrence count is printed separately so the two can
never be confused.

The dump's FIRST LINE is the DATABASE PATH and always differs between sides, so
every driver in this campaign pipes dumps through `sed '1d'`.  This parser also
tolerates a leading non-`\\_` line.

GUARDS — each one is an ops trap this campaign has paid for:
  * refuses to report on a dump with ZERO class_defn-owned class_typespecs (a
    driver that reaches nothing must never read as a clean answer): prints
    `UNMEASURED: ...` and exits 4.
  * prints `UNMEASURED` for a field it cannot resolve, and COUNTS those.
  * `--selftest` is the POSITIVE CONTROL: a built-in fixture in which one
    object is printed once WITH children and once ABBREVIATED, plus one member
    with an alias and one without.  NEGATIVE CONTROL for that guard: dropping
    the union (see the comment at `UNION`) makes the selftest FAIL and exit 1.

Usage:
  tdgroup.py <dump> rows [<name-regex>]    # one line per (class, typedef)
  tdgroup.py <dump> groups [<generic-re>]  # per generic class: base + members
  tdgroup.py <dump> parents                # the captured vpiParent per row, and
                                           # how many name a DIFFERENT class than
                                           # the listing one (the LAST-LISTER
                                           # refutation)
  tdgroup.py <dump> summary                # counts only
  tdgroup.py --selftest
"""
import re
import sys

NODE = re.compile(r'^(\s*)\\_([a-z_0-9]+): (.*)$')
PROP = re.compile(r'^(\s*)\|([A-Za-z_0-9]+):(.*)$')


class Node:
    __slots__ = ('kind', 'text', 'rel', 'parent', 'kids', 'props')

    def __init__(self, kind, text, rel, parent):
        self.kind = kind
        self.text = text
        self.rel = rel
        self.parent = parent
        self.kids = []
        self.props = {}

    def name(self):
        m = re.match(r'^\(([^)]*)\)', self.text)
        return m.group(1) if m else ''

    def span(self):
        m = re.search(r'line:(\d+):(\d+), endln:(\d+):(\d+)', self.text)
        if not m:
            m2 = re.search(r'line:(\d+):(\d+)', self.text)
            if m2:
                return '%s:%s-?' % (m2.group(1), m2.group(2))
            return ''
        return '%s:%s-%s:%s' % m.groups()

    def child(self, rel):
        for k in self.kids:
            if k.rel == rel:
                return k
        return None


def parse(lines):
    """vpiParent back-edges are DROPPED: they would make the tree cyclic."""
    root = Node('ROOT', '', None, None)
    stack = [(-1, root)]
    pending_rel = None
    pending_indent = None
    for ln in lines:
        m = PROP.match(ln)
        if m:
            ind, key, val = len(m.group(1)), m.group(2), m.group(3)
            if val.strip():
                while len(stack) > 1 and stack[-1][0] >= ind:
                    stack.pop()
                stack[-1][1].props[key] = val.strip()
                pending_rel = None
            else:
                pending_rel = key
                pending_indent = ind
            continue
        m = NODE.match(ln)
        if not m:
            continue
        ind = len(m.group(1))
        kind, text = m.group(2), m.group(3)
        if pending_rel == 'vpiParent' and pending_indent == ind:
            # The back-edge is DROPPED from the tree (it would make the tree
            # cyclic) but its TEXT is kept: a class_defn lists its whole
            # DataTypeMap under vpiTypedef, so the printed enclosing node is
            # the LISTING class and only vpiParent names the DECLARING one.
            # Measured: without this, `work@env` (which lists 40+ imported
            # package typedefs) is credited with owning them.
            m2 = re.match(r'^\(([^)]*)\)', text)
            stack[-1][1].props['_PARENT'] = '%s %s' % (
                kind, m2.group(1) if m2 else '')
            pending_rel = None
            continue
        while len(stack) > 1 and stack[-1][0] >= ind:
            stack.pop()
        n = Node(kind, text, pending_rel, stack[-1][1])
        stack[-1][1].kids.append(n)
        stack.append((ind, n))
        pending_rel = None
    return root


def walk(n):
    for k in n.kids:
        yield k
        for x in walk(k):
            yield x


UNMEAS = 'UNMEASURED'


def collect(root):
    """-> dict[(owner_class_name, td_name)] = row dict, UNIONed over every
    occurrence.  UNION: an abbreviated occurrence contributes nothing, a
    detailed one fills the blanks; a field seen with two different values is
    reported as CONFLICT so a silent overwrite can never hide one."""
    rows = {}
    for n in walk(root):
        if n.kind != 'class_typespec' or n.rel != 'vpiTypedef':
            continue
        # KEY = the LISTING class_defn (the node under whose printed
        # vpiTypedef list this occurrence appears).  That is deliberately NOT
        # the object's own vpiParent: REFUTATION, measured — golden's
        # UhdmWriter::writeDataTypes does `tps->VpiParent(parent)` for EVERY
        # class that lists a SHARED typespec, so vpiParent ends up naming the
        # LAST LISTER.  In SimpleUVM golden the uvm_object_registry group's
        # base (`type_id` @453:12) carries `vpiParent class_defn (work@env)`
        # while its declaring class is a uvm_pkg class; keying on vpiParent
        # produced 6 spurious base-pick refutations and 10 phantom RHS_ONLY
        # keys.  The LISTING class is also the axis BaseClass::Compare walks
        # (class_defn -> Typespecs[i]), so it is the axis that decides cmp.
        owner = n.parent
        if owner is None or owner.kind != 'class_defn':
            continue
        key = (owner.name(), n.props.get('vpiName', n.name()))
        r = rows.setdefault(key, {'occ': 0, 'span': set(), 'generic': set(),
                                  'alias': set(), 'vpar': set()})
        r['occ'] += 1
        if n.props.get('_PARENT'):
            r['vpar'].add(n.props['_PARENT'])
        # UNION over occurrences (negative control: replace the three
        # `.add(...)` calls below with a plain assignment and --selftest fails).
        if n.span():
            r['span'].add(n.span())
        g = n.child('vpiClassDefn')
        if g is not None:
            r['generic'].add(g.name())
        a = n.child('vpiTypedefAlias')
        if a is not None:
            act = a.child('vpiActual')
            r['alias'].add('%s %s %s @%s' % (
                a.props.get('vpiFullName', '-'),
                act.kind if act is not None else UNMEAS,
                act.name() if act is not None else UNMEAS,
                act.span() if act is not None else UNMEAS))
    return rows


def fld(s):
    if not s:
        return UNMEAS
    if len(s) == 1:
        return next(iter(s))
    return 'CONFLICT{' + '|'.join(sorted(s)) + '}'


def cmd_rows(rows, pat):
    rx = re.compile(pat) if pat else None
    n = 0
    unm = 0
    for (owner, td) in sorted(rows):
        if rx and not (rx.search(owner) or rx.search(td)):
            continue
        r = rows[(owner, td)]
        line = '%-52s %-14s occ=%-4d span=%-24s generic=%-38s alias=%s' % (
            owner, td, r['occ'], fld(r['span']), fld(r['generic']),
            fld(r['alias']) if r['alias'] else 'NONE')
        if UNMEAS in line:
            unm += 1
        print(line)
        n += 1
    print('-- rows printed=%d  UNMEASURED fields on %d rows' % (n, unm))


def cmd_groups(rows, pat):
    rx = re.compile(pat) if pat else None
    byg = {}
    for k, r in rows.items():
        g = fld(r['generic'])
        byg.setdefault(g, []).append((k, r))
    for g in sorted(byg):
        if rx and not rx.search(g):
            continue
        mem = byg[g]
        bases = [k for k, r in mem if not r['alias']]
        spans = sorted({fld(r['span']) for _, r in mem})
        print('GENERIC %s   members=%d  distinct spans=%d  no-alias members=%d'
              % (g, len(mem), len(spans), len(bases)))
        for b in sorted(bases):
            br = dict(mem)[b]
            print('    BASE?  owner=%-46s td=%-14s span=%s'
                  % (b[0], b[1], fld(br['span'])))
        if len(spans) > 1:
            print('    SPANS: %s' % ', '.join(spans))
        for k, r in sorted(mem):
            if r['alias']:
                print('    member owner=%-44s td=%-14s span=%-22s -> %s'
                      % (k[0], k[1], fld(r['span']), fld(r['alias'])))


def cmd_parents(rows):
    """The captured vpiParent per row — the field that PROVES why the key is the
    LISTING class and not vpiParent.  A row whose vpiParent names a DIFFERENT
    class than its listing owner is printed as LAST-LISTER."""
    n = mismatch = 0
    for (owner, td) in sorted(rows):
        r = rows[(owner, td)]
        vp = fld(r['vpar'])
        tag = ''
        if vp.startswith('class_defn ') and vp[len('class_defn '):] != owner:
            tag = '  <- LAST-LISTER (vpiParent != listing class)'
            mismatch += 1
        print('%-52s %-16s vpiParent=%s%s' % (owner, td, vp, tag))
        n += 1
    print('-- rows=%d  rows whose vpiParent is NOT the listing class=%d'
          % (n, mismatch))


def cmd_summary(rows):
    tot = len(rows)
    withal = sum(1 for r in rows.values() if r['alias'])
    byg = {}
    for k, r in rows.items():
        byg.setdefault(fld(r['generic']), []).append(r)
    multi = sum(1 for g, m in byg.items() if len(m) > 1)
    print('class-nested class-handle typedef objects (class_defn/vpiTypedef): %d'
          % tot)
    print('  carrying vpiTypedefAlias : %d' % withal)
    print('  distinct generic classes : %d  (of which >1 member: %d)'
          % (len(byg), multi))
    collapsed = 0
    for g, m in byg.items():
        if len(m) > 1 and len({fld(r['span']) for r in m}) == 1:
            collapsed += 1
    print('  multi-member groups whose members SHARE ONE SPAN: %d' % collapsed)


SELFTEST = r"""
\_design: (work@t)
  |vpiClassDefn:
  \_class_defn: (p::a_cls)
    |vpiTypedef:
    \_class_typespec: (type_id), line:10:3, endln:10:9
      |vpiParent:
      \_class_defn: (p::a_cls)
      |vpiName:type_id
      |vpiClassDefn:
      \_class_defn: (p::gen)
  |vpiClassDefn:
  \_class_defn: (p::b_cls)
    |vpiTypedef:
    \_class_typespec: (type_id), line:10:3, endln:10:9
      |vpiParent:
      \_class_defn: (p::b_cls)
      |vpiName:type_id
      |vpiTypedefAlias:
      \_ref_typespec: (p::b_cls::type_id)
        |vpiParent:
        \_class_typespec: (type_id), line:10:3, endln:10:9
        |vpiFullName:p::b_cls::type_id
        |vpiActual:
        \_class_typespec: (type_id), line:10:3, endln:10:9
      |vpiClassDefn:
      \_class_defn: (p::gen)
  |vpiClassDefn:
  \_class_defn: (p::c_cls)
    |vpiTypedef:
    \_class_typespec: (type_id), line:10:3, endln:10:9
      |vpiParent:
      \_class_defn: (p::a_cls)
      |vpiName:type_id
      |vpiClassDefn:
      \_class_defn: (p::gen)
  |vpiModule:
  \_module_inst: (work@t)
    |vpiVariables:
    \_class_var: (v)
      |vpiTypespec:
      \_ref_typespec: (x)
        |vpiActual:
        \_class_typespec: (type_id), line:10:3, endln:10:9
"""


def selftest():
    root = parse(SELFTEST.split('\n'))
    rows = collect(root)
    ok = True

    def chk(cond, msg):
        nonlocal ok
        if not cond:
            print('SELFTEST FAIL: ' + msg)
            ok = False

    # p::c_cls LISTS p::a_cls's type_id (a class_defn lists its whole
    # DataTypeMap and vpiParent names the LAST LISTER): the key is the LISTING
    # class, so that occurrence is its OWN row, and the vpiParent it carries
    # must be REPORTED, not used as the key.
    chk(len(rows) == 3, 'expected 3 LISTING-keyed rows, got %d: %s'
        % (len(rows), sorted(rows)))
    c = rows.get(('p::c_cls', 'type_id'))
    chk(c is not None and fld(c['vpar']) == 'class_defn p::a_cls',
        'the vpiParent back-edge must be CAPTURED and reported (got %s)'
        % (fld(c['vpar']) if c else 'no row'))
    a = rows.get(('p::a_cls', 'type_id'))
    b = rows.get(('p::b_cls', 'type_id'))
    chk(a is not None and b is not None, 'both owners must be keyed')
    if a and b:
        # UNION check: a_cls's object is ALSO printed abbreviated as the
        # class_var's vpiActual, which must not create a second row nor wipe
        # the detailed occurrence's fields.
        chk(fld(a['generic']) == 'p::gen',
            'union of occurrences lost vpiClassDefn (got %s)' % fld(a['generic']))
        chk(not a['alias'], 'a_cls must have NO alias (it is the base)')
        chk(bool(b['alias']), 'b_cls must carry an alias')
        chk(fld(a['span']) == '10:3-10:9', 'span parse wrong: %s' % fld(a['span']))
    byg = {}
    for k, r in rows.items():
        byg.setdefault(fld(r['generic']), []).append(r)
    chk(len(byg) == 1, 'both members must group under ONE generic')
    print('SELFTEST %s' % ('PASS' if ok else 'FAIL'))
    return 0 if ok else 1


def main():
    if len(sys.argv) > 1 and sys.argv[1] == '--selftest':
        sys.exit(selftest())
    if len(sys.argv) < 3:
        print(__doc__)
        sys.exit(2)
    path, cmd = sys.argv[1], sys.argv[2]
    pat = sys.argv[3] if len(sys.argv) > 3 else None
    with open(path, 'rt', errors='replace') as f:
        root = parse(f.read().split('\n'))
    rows = collect(root)
    if not rows:
        print('UNMEASURED: no class_defn/vpiTypedef class_typespec in %s '
              '(the instrument reached NOTHING; this is not a clean answer)'
              % path)
        sys.exit(4)
    if cmd == 'rows':
        cmd_rows(rows, pat)
    elif cmd == 'groups':
        cmd_groups(rows, pat)
    elif cmd == 'parents':
        cmd_parents(rows)
    elif cmd == 'summary':
        cmd_summary(rows)
    else:
        print('unknown cmd %s' % cmd)
        sys.exit(2)


main()
