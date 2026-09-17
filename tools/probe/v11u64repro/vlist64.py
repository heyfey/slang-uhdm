#!/usr/bin/env python3
"""v11u64 independent SHAPE LISTER — parses uhdm-dump text into a tree and
prints, for every assignment-pattern operation (vpiOpType:75), the
compare-visible operand shape: per operand the kind, vpiSize, vpiConstType and
value line.  Keyed by the operation's written line:col; payloads per key are a
SORTED MULTISET (positional keys are not order-stable across Restores).

usage: vlist64.py <dump.txt>
"""
import re
import sys
from collections import defaultdict


class Obj:
    __slots__ = ("kind", "header", "fields", "indent")

    def __init__(self, kind, header, indent):
        self.kind = kind
        self.header = header
        self.indent = indent
        self.fields = []  # (name, value_str_or_Obj)


HDR = re.compile(r"^(\s*)\\_([a-zA-Z_0-9]+): ?(.*)$")
FLD = re.compile(r"^(\s*)\|([A-Za-z_0-9]+):(.*)$")


def parse(lines):
    roots = []
    stack = []  # list of (indent, Obj)
    pending = None  # (indent, Obj, fieldname) awaiting a child object
    for ln in lines:
        m = HDR.match(ln)
        if m:
            ind = len(m.group(1))
            o = Obj(m.group(2), m.group(3).rstrip(), ind)
            while stack and stack[-1].indent >= ind:
                stack.pop()
            if pending is not None and pending[0] == ind:
                pending[1].fields.append((pending[2], o))
                pending = None
            elif stack:
                stack[-1].fields.append(("?", o))
            else:
                roots.append(o)
            stack.append(o)
            continue
        m = FLD.match(ln)
        if m:
            ind = len(m.group(1))
            val = m.group(3).rstrip()
            while stack and stack[-1].indent >= ind:
                stack.pop()
            owner = stack[-1] if stack else None
            if owner is None:
                continue
            if val == "":
                pending = (ind, owner, m.group(2))
            else:
                owner.fields.append((m.group(2), val))
                pending = None
            continue
    return roots


def get(o, name):
    for n, v in o.fields:
        if n == name:
            return v
    return None


def getall(o, name):
    return [v for n, v in o.fields if n == name]


def loc(o):
    m = re.search(r"line:(\d+):(\d+)", o.header)
    return "%s:%s" % (m.group(1), m.group(2)) if m else "?"


VALKEYS = ("UINT", "INT", "BIN", "HEX", "OCT", "DEC", "REAL", "STRING", "SCAL")


def summarize(o, depth=0):
    if not isinstance(o, Obj):
        return str(o)
    if o.kind == "tagged_pattern":
        p = get(o, "vpiPattern")
        ts = get(o, "vpiTypespec")
        tn = ""
        if isinstance(ts, Obj):
            a = get(ts, "vpiActual")
            if isinstance(a, Obj):
                tn = re.sub(r"[,;].*", "", a.header).strip()
        return "tagged[%s]{%s}" % (tn, summarize(p, depth + 1))
    bits = [o.kind]
    nm = re.match(r"\(([^)]*)\)", o.header)
    if nm:
        bits.append("nm=" + nm.group(1))
    sz = get(o, "vpiSize")
    if sz is not None:
        bits.append("sz=" + str(sz))
    ct = get(o, "vpiConstType")
    if ct is not None:
        bits.append("ct=" + str(ct))
    for n, v in o.fields:
        if n in VALKEYS and not isinstance(v, Obj):
            bits.append("%s:%s" % (n, v))
    dc = get(o, "vpiDecompile")
    if dc is not None and not isinstance(dc, Obj):
        bits.append("dc=" + str(dc))
    if o.kind == "operation":
        ops = getall(o, "vpiOperand")
        bits.append(
            "opType=%s" % get(o, "vpiOpType")
        )
        if depth < 3:
            bits.append("[" + " ".join(summarize(x, depth + 1) for x in ops) + "]")
    return "(" + " ".join(bits) + ")"


def walk(o, out, seen):
    if id(o) in seen:
        return
    seen.add(id(o))
    if o.kind == "operation" and get(o, "vpiOpType") == "75":
        ops = getall(o, "vpiOperand")
        payload = " ".join(summarize(x, 1) for x in ops)
        out["op@" + loc(o)].append("[%d] %s" % (len(ops), payload))
    for n, v in o.fields:
        if isinstance(v, Obj) and n not in ("vpiParent",):
            walk(v, out, seen)


def main():
    lines = open(sys.argv[1], encoding="utf-8", errors="replace").read().splitlines()
    roots = parse(lines)
    out = defaultdict(list)
    seen = set()
    for r in roots:
        walk(r, out, seen)
    for k in sorted(out):
        for p in sorted(out[k]):
            print("%s | %s" % (k, p))


main()
