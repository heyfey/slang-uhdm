#!/usr/bin/env python3
"""cast27.py <dump> [opType]

ONE LINE PER CAST OPERATION (vpiOpType 67 by default) in a uhdm-dump:
    <line>:<col>  op=<n>  size=<n>  ts=<actual typespec kind>{fields}
so the pass-27 frontier (golden `int_typespec {signed=0 val=UINT:2}` vs our
`integer_typespec` at the written span) reads off the table instead of a diff.

Also prints CONSTANT rows for the same source spans, because a cast whose
operand folds leaves a constant where the other side left an operation --
that is exactly what made qf26 fail to reproduce the corpus shape.

Duplicate (span, projection) tuples are counted with an xN, so the DEF view and
the ELAB view of one declaration collapse into a single row when they agree.
"""
import collections
import re
import sys

NODE = re.compile(r"^(\s*)\\_(\w+): ?(\([^)]*\))?,?"
                  r"(?: ?id:(\d+),?)?(?: ?file:([^,]*),?)?"
                  r"(?: ?line:(\d+):(\d+))?")
FLD = re.compile(r"^(\s*)\|(\w+):(.*)$")
REL = re.compile(r"^(\s*)\|(\w+):\s*$")

INTERESTING = ("vpiOpType", "vpiSize", "vpiConstType", "vpiDecompile",
               "vpiSigned", "UINT", "INT", "HEX", "BIN", "OCT")


def parse(path):
    """Returns a list of (indent, kind, name, line, col, fields, relname)."""
    out = []
    lastrel = [None] * 400
    for ln in open(path, errors="replace"):
        m = FLD.match(ln)
        if m and not m.group(3).strip():
            lastrel[len(m.group(1))] = m.group(2)
            continue
        m = NODE.match(ln)
        if m:
            ind = len(m.group(1))
            out.append([ind, m.group(2), (m.group(3) or "")[1:-1],
                        m.group(6) or "0", m.group(7) or "0", {},
                        lastrel[ind]])
            continue
        m = FLD.match(ln)
        if m and out:
            # uhdm-dump indents 2 per level and `\_` occupies the 2 columns a
            # field's `|` leaves blank, so a field at indent N belongs to the
            # deepest node at indent N-2.
            for n in reversed(out):
                if n[0] == len(m.group(1)) - 2:
                    n[5][m.group(2)] = m.group(3).strip()
                    break
    return out


def proj(fields):
    return " ".join("%s=%s" % (k, v) for k, v in fields.items()
                    if k in INTERESTING or k.isupper())


def main():
    nodes = parse(sys.argv[1])
    want = sys.argv[2] if len(sys.argv) > 2 else "67"
    acc = collections.OrderedDict()
    for i, n in enumerate(nodes):
        ind, kind, name, line, col, fields, rel = n
        row = None
        if kind == "operation" and fields.get("vpiOpType") == want:
            # find the actual typespec under this node's vpiTypespec ref
            ts = "-"
            for j in range(i + 1, len(nodes)):
                if nodes[j][0] <= ind:
                    break
                if nodes[j][1] == "ref_typespec" and nodes[j][0] == ind + 2:
                    for k in range(j + 1, len(nodes)):
                        if nodes[k][0] <= nodes[j][0]:
                            break
                        if nodes[k][0] == nodes[j][0] + 2 and \
                                nodes[k][6] == "vpiActual":
                            ts = "%s@%s:%s{%s}" % (nodes[k][1], nodes[k][3],
                                                   nodes[k][4], proj(nodes[k][5]))
                            break
                    break
            row = "op%s ts=%s %s" % (want, ts, proj(fields))
        elif kind == "constant":
            row = "CONST %s" % proj(fields)
        if row:
            key = ("%s:%s" % (line, col), row)
            acc[key] = acc.get(key, 0) + 1
    for (span, row), n in acc.items():
        print("%-10s x%-3d %s" % (span, n, row))


main()
