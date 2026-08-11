#!/usr/bin/env python3
"""caform.py -- flatten a uhdm-dump into one line per NODE, marking every node
DEF (printed in full, i.e. this is the object's definition site) or REF (printed
by reference, i.e. a BACK-REFERENCE to an object defined elsewhere).

WHY THIS EXISTS.  r10oth4's replform.py DELIBERATELY SKIPS back-reference
subtrees (its own lines 15-19).  That is correct for counting constant
DEFINITIONS, but it made golden's by-reference `cont_assign -> vpiRhs` row
INVISIBLE, rtab.sh rendered the cell empty, and the r10oth4 write-up filled the
empty cell in with a guess -- INVERTING the direction of its residue R1.  This
instrument prints back-references AS SUCH, because "the two edges point at ONE
object" is exactly the fact under measurement.

DUMP GRAMMAR (uhdm-dump), as relied on here:
  * an EDGE line is `<indent>|<name>:` with nothing after the colon;
  * a SCALAR line is `<indent>|<name>:<value>` (also `|HEX:5`, `|UINT:0`, ...);
  * a PAYLOAD HEADER is `<indent>\\_<kind>: <rest>` and sits at the *SAME*
    indent as the edge that introduced it;
  * a payload's CHILDREN sit at indent+2.  Therefore a payload with NO line at
    indent+2 after it is a BACK-REFERENCE.  This is the one rule the whole
    DEF/REF distinction rests on and it is the rule replform.py encodes as
    `skip_indent`.

FIRST LINE.  uhdm-dump's first line is the DATABASE PATH and always differs, so
callers pipe through `sed 1d`; this script ALSO tolerates and drops a leading
line that is not part of the tree.

OUTPUT, one node per line, TAB separated:
    <view> <module> <path> <DEF|REF> <kind> <span> <fields>
`path` is the edge chain from the nearest enclosing module_inst, with a
0-based occurrence index on each edge so repeated edges stay distinguishable.
`span` is the `line:a:b, endln:c:d` text normalised to `a:b-c:d`, or `-` when the
object carries NO location (golden's setRange typespecs are locationless and
that is a measured fact, not a missing measurement).
`fields` are the node's own SCALAR children as `k=v` sorted by name; an edge
child contributes nothing here (it becomes its own row).

POSITIVE CONTROL.  `--expect N` requires at least N rows and exits 3 otherwise,
so a driver that cannot read its own arm FAILS instead of reporting perfection.
`--kinds a,b` filters the printed rows by kind; the expect count is applied
AFTER the filter so the control still bites.
"""
import re
import sys
import argparse

HDR = re.compile(r'^(\s*)\\_([A-Za-z_0-9]+): ?(.*)$')
EDGE = re.compile(r'^(\s*)\|([A-Za-z_0-9]+):$')
SCALAR = re.compile(r'^(\s*)\|([A-Za-z_0-9]+):(.+)$')
SPAN = re.compile(r'line:(\d+):(\d+), endln:(\d+):(\d+)')

VIEWS = ('uhdmallModules', 'uhdmtopModules', 'uhdmallPackages',
         'uhdmtopPackages', 'weaklyReferenced', 'uhdmallClasses',
         'uhdmallInterfaces', 'uhdmallPrograms', 'uhdmallUdps')


def parse(lines):
    """Return a list of node dicts in document order."""
    nodes = []
    # stack of frames: (indent, node) for payloads currently open
    stack = []
    view = '-'
    pending_edge = None          # (indent, name)
    for idx, raw in enumerate(lines):
        line = raw.rstrip('\n')
        if not line.strip():
            continue
        m = EDGE.match(line)
        if m:
            ind, name = len(m.group(1)), m.group(2)
            if ind == 0 and name in VIEWS:
                view = name
                stack = []
                pending_edge = None
                continue
            # close payloads that are deeper than this edge
            while stack and stack[-1][0] >= ind:
                stack.pop()
            pending_edge = (ind, name)
            continue
        m = HDR.match(line)
        if m:
            ind, kind, rest = len(m.group(1)), m.group(2), m.group(3)
            if ind == 0 and kind in VIEWS:      # `\_weaklyReferenced:` form
                view = kind
                stack = []
                pending_edge = None
                continue
            while stack and stack[-1][0] >= ind:
                stack.pop()
            edge = pending_edge[1] if pending_edge and pending_edge[0] == ind \
                else ('vpiRoot' if not stack else '?')
            pending_edge = None
            # DEF vs REF: is there a line at indent+2 immediately following?
            ref = True
            for nxt in lines[idx + 1:]:
                s = nxt.rstrip('\n')
                if not s.strip():
                    continue
                nind = len(s) - len(s.lstrip())
                ref = nind <= ind
                break
            sm = SPAN.search(rest)
            span = '%s:%s-%s:%s' % sm.groups() if sm else '-'
            name = ''
            nm = re.match(r'^([^,]*?)\s*(?:,|$)', rest)
            if nm:
                name = nm.group(1).strip()
            node = {'view': view, 'kind': kind, 'span': span, 'edge': edge,
                    'ref': ref, 'name': name, 'fields': {}, 'indent': ind,
                    'parent': stack[-1][1] if stack else None,
                    'kidcount': {}}
            nodes.append(node)
            if not ref:
                stack.append((ind, node))
            continue
        m = SCALAR.match(line)
        if m:
            ind, name, val = len(m.group(1)), m.group(2), m.group(3)
            # a scalar belongs to the nearest OPEN payload at indent-2
            owner = None
            for i2, nd in reversed(stack):
                if i2 < ind:
                    owner = nd
                    break
            if owner is not None:
                owner['fields'][name] = val
            continue
    return nodes


def paths(nodes):
    """Attach module attribution and an indexed edge path to every node."""
    for nd in nodes:
        # nearest enclosing module-ish payload defines the module column
        mod = '-'
        p = nd
        chain = []
        while p is not None:
            if p is not nd or True:
                pass
            p2 = p['parent']
            if p2 is None:
                break
            # index this edge among p2's children using the same edge name
            chain.append(p)
            p = p2
        # module = outermost payload whose kind ends in _inst / is a package
        top = nd
        while top['parent'] is not None:
            top = top['parent']
        # walk down from nd collecting edges up to the nearest module_inst
        segs = []
        p = nd
        while p is not None and p['parent'] is not None:
            segs.append(p)
            if p['parent']['kind'].endswith('_inst') or \
               p['parent']['kind'] in ('package', 'class_defn'):
                mod = p['parent']['name'] or p['parent']['kind']
                break
            p = p['parent']
        segs.reverse()
        parts = []
        for sg in segs:
            k = sg['edge']
            n = sg['parent']['kidcount'].get(k, 0) if sg['parent'] else 0
            if 'assigned_idx' not in sg:
                sg['assigned_idx'] = n
                if sg['parent']:
                    sg['parent']['kidcount'][k] = n + 1
            parts.append('%s[%d]' % (k, sg['assigned_idx']))
        nd['module'] = mod
        nd['path'] = '/'.join(parts) if parts else nd['edge']
    return nodes


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('dump')
    ap.add_argument('--expect', type=int, default=1)
    ap.add_argument('--kinds', default='')
    ap.add_argument('--module', default='')
    args = ap.parse_args()
    with open(args.dump) as fh:
        lines = fh.readlines()
    # tolerate a leading database-path line (uhdm-dump's first line)
    if lines and not lines[0].startswith(('|', '\\', ' ')) and \
       'uhdmallModules' not in lines[0] and ':' in lines[0] and \
       not lines[0].startswith('design:'):
        lines = lines[1:]
    nodes = paths(parse(lines))
    kinds = set(k for k in args.kinds.split(',') if k)
    out = []
    for nd in nodes:
        if kinds and nd['kind'] not in kinds:
            continue
        if args.module and args.module not in nd['module']:
            continue
        fl = ','.join('%s=%s' % kv for kv in sorted(nd['fields'].items())
                      if kv[0] != 'vpiParent')
        out.append('\t'.join([nd['view'], nd['module'], nd['path'],
                              'REF' if nd['ref'] else 'DEF',
                              nd['kind'], nd['span'], fl or '-']))
    if len(out) < args.expect:
        sys.stderr.write('caform: INSTRUMENT_BLIND: %d rows < --expect %d\n'
                         % (len(out), args.expect))
        print('\n'.join(out))
        return 3
    print('\n'.join(out))
    return 0


if __name__ == '__main__':
    sys.exit(main())
