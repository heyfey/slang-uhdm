#!/usr/bin/env python3
"""ord27.py <dump> [opType]

ONE LINE PER OPERATION of the given vpiOpType (default 96 = vpiAssignmentPatternOp):
    <line>:<col>  n=<count>  [operand1, operand2, ...]
where each operand is printed as `<kind>:<name>@<line>:<col>`, IN VECTOR ORDER.
This is the projection for an ORDER law -- a positional operand mismatch that
uhdm-cmp reports as `ref_obj 'x' vs ref_obj 'y'` reads off two of these lines
side by side.  Duplicate (span, projection) tuples collapse with an xN, so the
DEF and ELAB view of one pattern are one row when they agree.
"""
import collections
import re
import sys

NODE = re.compile(r"^(\s*)\\_(\w+): ?(\([^)]*\))?,?"
                  r"(?: ?id:(\d+),?)?(?: ?file:([^,]*),?)?"
                  r"(?: ?line:(\d+):(\d+))?")
FLD = re.compile(r"^(\s*)\|(\w+):(.*)$")


def parse(path):
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
            for n in reversed(out):
                if n[0] == len(m.group(1)) - 2:
                    n[5][m.group(2)] = m.group(3).strip()
                    break
    return out


def main():
    nodes = parse(sys.argv[1])
    want = sys.argv[2] if len(sys.argv) > 2 else "96"
    acc = collections.OrderedDict()
    for i, n in enumerate(nodes):
        ind, kind, name, line, col, fields, rel = n
        if kind != "operation" or fields.get("vpiOpType") != want:
            continue
        ops = []
        for j in range(i + 1, len(nodes)):
            if nodes[j][0] <= ind:
                break
            if nodes[j][0] == ind + 2 and nodes[j][6] == "vpiOperand":
                nm = nodes[j][2]
                nm = nm.split(".")[-1] if nm else ""
                ops.append("%s:%s@%s:%s" % (nodes[j][1][:9], nm,
                                            nodes[j][3], nodes[j][4]))
        key = ("%s:%s" % (line, col), "n=%d [%s]" % (len(ops), ", ".join(ops)))
        acc[key] = acc.get(key, 0) + 1
    for (span, row), n in acc.items():
        print("%-10s x%-3d %s" % (span, n, row))


main()
