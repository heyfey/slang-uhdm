#!/usr/bin/env python3
"""r10earl37 — the PORT-ACTUAL census.

For every `port` object in a uhdm-dump, print a ONE-LINE signature of its
vpiHighConn subtree: the HighConn's own kind / vpiName / span, then each
child relation (vpiActual = a hier_path's Path_elems, vpiIndex, vpiExpr,
Operands...) rendered as kind(name@span)[fullname].

Why a purpose-built census instead of `diff`: the two sides disagree on the
OBJECT KIND at the HighConn slot, so the dumps' line-by-line diff shifts and a
per-cell verdict cannot be read off it.  Keying on the ENCLOSING INSTANCE +
FORMAL name gives one stable row per grid cell.

The dump prints an object once per traversal that reaches it, so the same
HighConn appears in the DEF listing (under ref_module) and again in the ELAB
listing (under module_inst).  The view is therefore part of the key, taken from
the nearest enclosing ref_module / module_inst ancestor.

usage: pactcen.py <dump> [-p PORTNAMEREGEX]
Indent is used ONLY to find an object's own attributes and its children; it is
never part of the key (r10earl35 F5).
"""
import re
import sys

OBJ = re.compile(r'^(\s*)\\_([a-z_0-9]+): (?:\(([^)]*)\) )?(?:([A-Za-z0-9_@.\[\]]+) )?'
                 r'\(([^)]*)\)?')
# The dump's object line has two shapes:
#   \_kind: (name), line:L:C, endln:L:C
#   \_kind: defname (name), file:..., line:...
LINE_OBJ = re.compile(r'^(\s*)\\_([a-z_0-9]+): (.*)$')
LINE_REL = re.compile(r'^(\s*)\|(vpi[A-Za-z_]+):\s*$')
LINE_ATT = re.compile(r'^(\s*)\|(vpi[A-Za-z_]+|[A-Z]+):(.*)$')
SPAN = re.compile(r'line:(\d+):(\d+), endln:(\d+):(\d+)')
NAME = re.compile(r'\(([^()]*)\)(?:,|$)')


def objsig(rest):
    """(name, span) from an object line's tail."""
    m = SPAN.search(rest)
    span = '%s:%s-%s:%s' % m.groups() if m else '-'
    ns = NAME.findall(rest)
    nm = ns[-1] if ns else ''
    return nm, span


def parse(path):
    """-> list of (indent, kind, name, span, rawrest) for objects and
    (indent, 'REL', relname) / (indent, 'ATT', k, v) markers, in file order."""
    out = []
    with open(path, 'rt', errors='replace') as f:
        for ln in f:
            ln = ln.rstrip('\n')
            m = LINE_OBJ.match(ln)
            if m:
                ind = len(m.group(1))
                nm, span = objsig(m.group(3))
                out.append((ind, 'OBJ', m.group(2), nm, span))
                continue
            m = LINE_REL.match(ln)
            if m:
                out.append((len(m.group(1)), 'REL', m.group(2), '', ''))
                continue
            m = LINE_ATT.match(ln)
            if m:
                out.append((len(m.group(1)), 'ATT', m.group(2),
                            m.group(3), ''))
    return out


def render(rows, i):
    """Render the object at rows[i] (an OBJ row) with ONE level of children."""
    ind, _, kind, nm, span = rows[i]
    atts = {}
    kids = []          # (relname, kind, name, span, fullname)
    j = i + 1
    rel = None
    while j < len(rows):
        r = rows[j]
        if r[0] <= ind:
            break
        if r[1] == 'REL' and r[0] == ind + 2:
            rel = r[2]
        elif r[1] == 'ATT' and r[0] == ind + 2:
            atts[r[2]] = r[3]
        elif r[1] == 'OBJ' and r[0] == ind + 2:
            # a child object; grab its own vpiName/vpiFullName
            cn, cs, ck = r[3], r[4], r[2]
            cfull = ''
            k = j + 1
            while k < len(rows) and rows[k][0] > r[0]:
                if rows[k][1] == 'ATT' and rows[k][0] == r[0] + 2:
                    if rows[k][2] == 'vpiFullName':
                        cfull = rows[k][3]
                k += 1
            if rel and rel != 'vpiParent':
                kids.append((rel, ck, cn, cs, cfull))
        j += 1
    parts = ['%s name=%r @%s' % (kind, atts.get('vpiName', ''), span)]
    if 'vpiFullName' in atts:
        parts.append('full=%r' % atts['vpiFullName'])
    for rel, ck, cn, cs, cf in kids:
        parts.append('%s->%s(%s@%s)%s' % (rel, ck, cn, cs,
                                          '[full=%s]' % cf if cf else '[NOFULL]'))
    return ' | '.join(parts), j


def main():
    path = sys.argv[1]
    pat = None
    if len(sys.argv) > 3 and sys.argv[2] == '-p':
        pat = re.compile(sys.argv[3])
    rows = parse(path)
    # view/instance context: nearest enclosing ref_module or module_inst
    ctx = []          # stack of (indent, label)
    for i, r in enumerate(rows):
        if r[1] != 'OBJ':
            continue
        while ctx and ctx[-1][0] >= r[0]:
            ctx.pop()
        if r[2] in ('ref_module', 'module_inst', 'module_array'):
            # INSTRUMENT DEFECT FIXED BEFORE LANDING.  A `module_array`'s
            # parenthesised dump name is its vpiFullName, which for an array is
            # the DEFINITION name (`work@ch38`) — so TWO different arrays of the
            # same child collapsed onto ONE census key and a `join` on that key
            # produced a CARTESIAN PRODUCT of 8 meaningless rows per formal,
            # complete with two invented "REGRESSION" verdicts.  The instance
            # name lives in the object's own `|vpiName:` attribute; the SPAN is
            # appended too, so two arrays of the same child in the same scope
            # still key apart.
            nm = r[3]
            k = i + 1
            while k < len(rows) and rows[k][0] > r[0]:
                if rows[k][1] == 'ATT' and rows[k][0] == r[0] + 2 \
                        and rows[k][2] == 'vpiName':
                    nm = rows[k][3]
                    break
                k += 1
            ctx.append((r[0], '%s:%s@%s' % ('ELAB' if r[2] == 'module_inst'
                                            else 'DEF', nm, r[4])))
            continue
        if r[2] != 'port':
            continue
        inst = ctx[-1][1] if ctx else '?'
        pname = ''
        hc = None
        j = i + 1
        rel = None
        while j < len(rows) and rows[j][0] > r[0]:
            q = rows[j]
            if q[1] == 'ATT' and q[0] == r[0] + 2 and q[2] == 'vpiName':
                pname = q[3]
            elif q[1] == 'REL' and q[0] == r[0] + 2:
                rel = q[2]
            elif q[1] == 'OBJ' and q[0] == r[0] + 2 and rel == 'vpiHighConn':
                hc = j
                rel = None
            j += 1
        # A port printed as a back-reference (as some child's vpiParent) carries
        # NO attributes at all; it is a second print of one object, not a
        # second port, so it is dropped from the census.
        if not pname:
            continue
        if pat and not pat.search(inst + '.' + pname):
            continue
        if hc is None:
            print('%-28s %-10s HIGHCONN=<none>' % (inst, pname))
        else:
            sig, _ = render(rows, hc)
            print('%-28s %-10s %s' % (inst, pname, sig))


main()
