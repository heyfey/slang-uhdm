#!/usr/bin/env python3
"""r10buvm2repro/propcen.py — SPAN-KEYED CLASS-PROPERTY vpiExpr CENSUS, BOTH SIDES.

The campaign law "an object is not a dump occurrence" binds here: uhdm-dump
prints the SAME class property once per reference chain that reaches it, so a
raw grep over-counts.  This census keys every property by
(object kind, vpiFullName, span) and keeps the RICHEST occurrence — the one
listed under `class_defn |vpiVariables:`, which is the only place the property's
own field set is printed in full.

    usage: propcen.py <dump>  [--json]

Prints one row per DISTINCT class property:

    <kind> <fullname> <span> EXPR=<child-kind-or-NONE> [ctype=<n> size=<n> dec=<0|1>]

GUARDS:
  * an empty/missing dump is exit 6, never an empty census that reads as "no
    properties" (this is the msdist NO_OUTPUT lesson).
  * the dump's FIRST LINE (the database path) must already be stripped by the
    caller (wdump.sh does `sed 1d`); if line 1 still looks like a path we say so
    and exit 6 rather than silently mis-parsing.
  * `|vpiExpr:` is read as a FIELD OF THE PROPERTY at exactly one indent level
    deeper than the property header, so an expression belonging to a nested
    object can never be attributed to the property.
"""
import re
import sys
import json

OBJ = re.compile(r'^(?P<ind> *)\\_(?P<kind>[a-z_0-9]+): (?:\((?P<name>.*?)\))?,?(?P<rest>.*)$')
FLD = re.compile(r'^(?P<ind> *)\|(?P<f>[A-Za-z0-9_]+):(?P<v>.*)$')
SPAN = re.compile(r'line:(\d+):(\d+), endln:(\d+):(\d+)')


def main():
    if len(sys.argv) < 2:
        print("usage: propcen.py <dump> [--json]", file=sys.stderr)
        sys.exit(2)
    path = sys.argv[1]
    as_json = '--json' in sys.argv[2:]
    try:
        lines = open(path, encoding='utf-8', errors='replace').read().split('\n')
    except OSError as e:
        print("NO_OUTPUT: %s" % e)
        sys.exit(6)
    if not any(l.strip() for l in lines):
        print("NO_OUTPUT: empty dump %s" % path)
        sys.exit(6)
    if lines and lines[0].startswith('/') and ':' not in lines[0]:
        print("NO_OUTPUT: line 1 still looks like the database path; run sed 1d")
        sys.exit(6)

    # stack of (indent, kind, name, field-that-introduced-it)
    stack = []
    pending_field = None      # field name whose child object comes next
    props = {}                # key -> record
    cur = None                # record currently being filled (a class property)
    cur_ind = None

    for ln in lines:
        m = OBJ.match(ln)
        if m:
            ind = len(m.group('ind'))
            kind = m.group('kind')
            name = m.group('name') or ''
            rest = m.group('rest')
            sm = SPAN.search(rest)
            span = "%s:%s-%s:%s" % sm.groups() if sm else "-"
            while stack and stack[-1][0] >= ind:
                stack.pop()
            owner_kind = stack[-1][1] if stack else None
            owner_field = pending_field
            stack.append((ind, kind, name, owner_field))
            pending_field = None

            # a CLASS PROPERTY: an object listed as class_defn |vpiVariables:
            if owner_kind == 'class_defn' and owner_field == 'vpiVariables':
                key = (kind, name, span)
                rec = props.get(key)
                if rec is None:
                    rec = {'kind': kind, 'name': name, 'span': span,
                           'expr': None, 'nfields': 0}
                    props[key] = rec
                cur, cur_ind = rec, ind
                continue
            # the vpiExpr CHILD of the property currently being filled
            if cur is not None and ind == cur_ind + 2 and owner_field == 'vpiExpr':
                cur['expr'] = {'kind': kind, 'span': span}
                continue
            if cur is not None and ind <= cur_ind:
                cur, cur_ind = None, None
            continue
        f = FLD.match(ln)
        if f:
            ind = len(f.group('ind'))
            fname, val = f.group('f'), f.group('v')
            pending_field = fname if val == '' else None
            if cur is not None and ind == cur_ind + 2 and cur.get('expr') \
               and cur['expr'].get('_open'):
                pass
            # record the expr constant's own scalar fields
            if cur is not None and cur.get('expr') and ind == cur_ind + 4:
                e = cur['expr']
                if fname == 'vpiSize':
                    e['size'] = val.strip()
                elif fname == 'vpiConstType':
                    e['ctype'] = val.strip()
                elif fname == 'vpiDecompile':
                    e['dec'] = val
            if cur is not None and ind <= cur_ind:
                cur, cur_ind = None, None
            continue
        # a `decompile:`/blank/other line resets nothing structural
        pending_field = None

    rows = sorted(props.values(), key=lambda r: (r['name'], r['span'], r['kind']))
    if as_json:
        print(json.dumps(rows, indent=1, sort_keys=True))
        return
    for r in rows:
        e = r['expr']
        if e is None:
            tail = "EXPR=NONE"
        else:
            tail = "EXPR=%s@%s" % (e['kind'], e['span'])
            if 'ctype' in e:
                tail += " ctype=%s" % e['ctype']
            if 'size' in e:
                tail += " size=%s" % e['size']
            tail += " dec=%d" % (1 if e.get('dec') else 0)
        print("%-16s %-70s %-24s %s" % (r['kind'], r['name'], r['span'], tail))
    print("-- DISTINCT class properties: %d   with vpiExpr: %d   without: %d"
          % (len(rows), sum(1 for r in rows if r['expr']),
             sum(1 for r in rows if not r['expr'])))


if __name__ == '__main__':
    main()
