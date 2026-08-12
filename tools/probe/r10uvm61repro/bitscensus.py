#!/usr/bin/env python3
"""r10uvm61repro/bitscensus.py — SPAN-FREE census of sys_func_call folds.

WHY SPAN-FREE: the UHDM dump prints NO file per object, and uvm-1.2 is many
files, so `line:145:55` is ambiguous across the design.  Every key here is a
SCOPE PATH (vpiFullName of the enclosing named thing), which is unique.

WHY A TREE: the dump repeats each object once as a child and again inside each
back-reference (|vpiParent:, |vpiActual:, ...).  Counting raw lines
double-counts.  Only the FIRST, deepest-indented definitional occurrence under
a |vpiXxx: edge that is NOT a back-reference edge is counted.

  usage: bitscensus.py <dump> [--func $bits] [--rows] [--scopes]

Prints one CELL line per (scope-kind, function, folded?) and, with --rows, one
row per site.
"""
import re
import sys

BACKREF = {"vpiParent", "vpiActual", "vpiInstance", "vpiTypespec", "vpiTask",
           "vpiFunction", "vpiClassDefn", "vpiBaseTypespec", "vpiElemTypespec",
           "vpiIndexTypespec", "vpiLeftRange", "vpiRightRange", "vpiModule"}

OBJ = re.compile(r'^(\s*)\\_([a-z_0-9]+): (?:\(([^)]*)\), )?line:(\d+):(\d+), endln:(\d+):(\d+)')
FIELD = re.compile(r'^(\s*)\|([A-Za-z_0-9]+):(.*)$')

SCOPEKINDS = {"class_defn", "function", "task", "module_inst", "package",
              "class_typespec", "program", "gen_scope", "process_stmt",
              "always", "initial", "cont_assign", "param_assign", "interface_inst"}


def parse(path):
    """Yield (indent, kind, name, span, lineno, fields, parent_stack)."""
    nodes = []
    with open(path, errors="replace") as fh:
        lines = fh.readlines()
    stack = []          # (indent, kind, name, edge)
    lastedge = [None]   # edge label most recently seen at each indent
    edge_at = {}
    for i, ln in enumerate(lines):
        m = OBJ.match(ln)
        if m:
            ind = len(m.group(1))
            kind, name = m.group(2), m.group(3) or ""
            span = "%s:%s-%s:%s" % (m.group(4), m.group(5), m.group(6), m.group(7))
            while stack and stack[-1][0] >= ind:
                stack.pop()
            edge = edge_at.get(ind - 2)
            nodes.append((i, ind, kind, name, span, edge, list(stack)))
            stack.append((ind, kind, name, edge))
            continue
        f = FIELD.match(ln)
        if f:
            edge_at[len(f.group(1))] = f.group(2)
    return nodes, lines


def scope_of(stack, lines, idx):
    """Nearest enclosing named scope: kind + its vpiFullName if present."""
    for ind, kind, name, edge in reversed(stack):
        if kind in SCOPEKINDS and name:
            return kind, name
    for ind, kind, name, edge in reversed(stack):
        if name:
            return kind, name
    return "TOP", ""


def main():
    path = sys.argv[1]
    want = None
    rows = "--rows" in sys.argv
    for i, a in enumerate(sys.argv):
        if a == "--func":
            want = sys.argv[i + 1]
    nodes, lines = parse(path)
    seen = set()
    cells = {}
    out = []
    for (i, ind, kind, name, span, edge, stack) in nodes:
        if kind != "sys_func_call":
            continue
        if edge in BACKREF:
            continue                    # a back-reference, not the definition
        if want and name != want:
            continue
        key = (name, span, tuple(s[2] for s in stack))
        if key in seen:
            continue
        seen.add(key)
        sk, sn = scope_of(stack, lines, i)
        pedge = edge or "-"
        cells.setdefault((name, sk, pedge), 0)
        cells[(name, sk, pedge)] += 1
        out.append((name, span, sk, sn, pedge))
    for k in sorted(cells):
        print("CELL\t%s\t%s\t%s\t%d" % (k[0], k[1], k[2], cells[k]))
    if rows:
        for r in sorted(out, key=lambda x: (x[0], x[3], x[1])):
            print("ROW\t%s\t%s\t%s\t%s\t%s" % r)


main()
