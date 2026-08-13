#!/usr/bin/env python3
"""r10earl39 — THE CALL-ARGUMENT FORMAL-TYPESPEC CENSUS.

One row per object that sits in a `vpiArgument` slot of a user `func_call` /
`task_call`, recording

    ts=0/1          whether WE/GOLDEN hang a `vpiTypespec` (-> ref_typespec ->
                    the FORMAL's typespec) on that actual
    ctx=...         the ORDERED chain of structural ancestors, which is the only
                    thing that can carry golden's predicate (def vs elab view,
                    module vs package, always vs cont-assign, and — the axis
                    this pass is about — whether a generate BRANCH sits between
                    the module and the process)

Why a purpose-built census and not a grep: the surplus is a CHILD OBJECT, so a
plain line diff of two 4.8M-line dumps shifts for the rest of the enclosing
block and cannot be counted.  This reads the objects.

Traps encoded:
  * uhdm-dump prints an object's PARENT as a shallow back-reference under
    `|vpiParent:`.  Those stubs are DROPPED (they would double every row).
  * The dump is INDENTATION-structured: an object at indent I is introduced by
    a field label at indent I, which belongs to the object at indent I-2.
  * The view (`uhdmallModules` = def, `uhdmtopModules` = elab) is recorded from
    the marker lines but the row key does NOT depend on the state machine
    (r10earl38's F4: a running def/elab state machine silently dropped 40% of
    the rows on Earlgrey, whose dump has 190 allModules markers).  The
    ELABORATED fullname carries `[i]` on every gen-for block, so the two views
    separate themselves.

usage: argts39.py [--all-objs] <dump>            (dump must be `sed 1d`-ed)
"""
import re
import sys

OBJ = re.compile(r'^( *)\\_([A-Za-z_0-9]+): *(\([^)]*\))?(.*)$')
FLD = re.compile(r'^( *)\|([A-Za-z_0-9]+):(.*)$')

# Ancestors that carry the axes: view root, scope kind, process kind, generate
# construct, statement kind.  Everything else (operations, selects, constants)
# is noise for this law.
CTX_KINDS = {
    'module_inst', 'package', 'interface_inst', 'program',
    'function', 'task',
    'always', 'initial', 'final', 'cont_assign',
    'gen_scope', 'gen_scope_array', 'gen_for', 'gen_if', 'gen_if_else',
    'gen_case', 'gen_region', 'named_begin', 'begin',
    'param_assign', 'class_defn', 'class_typespec',
    'func_call', 'task_call', 'method_func_call', 'sys_func_call',
    'assignment', 'if_stmt', 'case_stmt', 'for_stmt',
}
CALL_KINDS = {'func_call', 'task_call', 'method_func_call'}


def census(path, all_objs=False):
    rows = []
    # stack entries: [indent, kind, name, span, label, has_ts, argidx]
    stack = []
    labels = {}          # indent -> last field label seen at that indent
    skip_indent = None   # inside a |vpiParent: back-reference subtree
    for raw in open(path, errors='replace'):
        line = raw.rstrip('\n')
        m = FLD.match(line)
        if m:
            ind = len(m.group(1))
            if skip_indent is not None and ind > skip_indent:
                continue
            skip_indent = None
            labels[ind] = m.group(2)
            if m.group(2) == 'vpiParent':
                skip_indent = ind
                continue
            # a field belongs to the object at indent-2
            if m.group(2) == 'vpiTypespec':
                for e in reversed(stack):
                    if e[0] == ind - 2:
                        e[5] = 1
                        break
            continue
        m = OBJ.match(line)
        if not m:
            continue
        ind = len(m.group(1))
        if skip_indent is not None and ind > skip_indent:
            continue
        skip_indent = None
        kind = m.group(2)
        name = (m.group(3) or '()')[1:-1]
        tail = m.group(4) or ''
        sp = re.search(r'line:(\d+:\d+), endln:(\d+:\d+)', tail)
        span = '%s-%s' % (sp.group(1), sp.group(2)) if sp else '-'
        while stack and stack[-1][0] >= ind:
            emit(rows, stack.pop(), all_objs)
        label = labels.get(ind, '?')
        argidx = 0
        if stack and label == 'vpiArgument':
            argidx = stack[-1][6]
            stack[-1][6] += 1
        ctx = [e for e in stack]
        stack.append([ind, kind, name, span, label, 0, 0, ctx])
    while stack:
        emit(rows, stack.pop(), all_objs)
    return rows


def emit(rows, e, all_objs):
    ind, kind, name, span, label, has_ts, _n, ctx = e
    if not all_objs:
        if label != 'vpiArgument':
            return
        if not ctx or ctx[-1][1] not in CALL_KINDS:
            return
    callname = ctx[-1][2] if ctx else ''
    chain = '/'.join(c[1] for c in ctx if c[1] in CTX_KINDS)
    rows.append('%-14s %-22s ts=%d call=%-46s ctx=%s name=%s' %
                (kind, span, has_ts, callname, chain, name))


def main():
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    all_objs = '--all-objs' in sys.argv[1:]
    rows = census(args[0], all_objs)
    rows.sort()
    for r in rows:
        print(r)


if __name__ == '__main__':
    main()
