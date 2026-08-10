#!/usr/bin/env python3
"""dv25.py <dump> [scope-substr] -- ONE LINE PER DECLARED OBJECT (var/net),
projecting its RANGES and TYPESPEC onto the fields uhdm-cmp reads, with an
explicit marker for a ref_typespec that IS or IS NOT there.  Written for pass
25's second frontier: `pl_t g_pl [NCH];` in a gen scope, where the folded
dimension's operand constant carries a ref_typespec in ours and none in golden.

Shape grammar (same as ca25.py plus TS= markers):
    const{ct sz dec val}TS[<actual typespec type>|<null>]
    op(<optype>)[<operand>, ...]
"""
import re
import sys

VARKINDS = {
    "array_var", "logic_var", "enum_var", "packed_array_var", "int_var",
    "integer_var", "bit_var", "byte_var", "struct_var", "logic_net",
    "array_net", "enum_net", "packed_array_net", "struct_net", "bit_var",
}


def rebuild(path):
    nodes, stack, roots, pending = [], [], [], {}
    with open(path, errors="replace") as fh:
        for raw in fh:
            line = raw.rstrip("\n")
            m = re.match(r"^(\s*)\\_([a-z_0-9]+): (.*)$", line)
            if m:
                d = len(m.group(1))
                n = {"d": d, "t": m.group(2), "h": m.group(3), "f": {}, "kids": []}
                while stack and stack[-1]["d"] >= d:
                    stack.pop()
                if stack:
                    p = stack[-1]
                    n["role"] = pending.get(id(p), "?")
                    p["kids"].append(n)
                    n["p"] = p
                else:
                    n["role"] = "root"
                    roots.append(n)
                stack.append(n)
                nodes.append(n)
                continue
            m = re.match(r"^(\s*)\|([A-Za-z0-9_]+):(.*)$", line)
            if m and stack:
                d = len(m.group(1))
                while stack and stack[-1]["d"] >= d:
                    stack.pop()
                if not stack:
                    continue
                owner = stack[-1]
                key, val = m.group(2), m.group(3)
                if key in ("BIN", "HEX", "OCT", "DEC", "INT", "UINT", "STRING", "REAL"):
                    owner["f"].setdefault("VAL", key + ":" + val)
                else:
                    owner["f"].setdefault(key, val)
                pending[id(owner)] = key
    return nodes


def loc(n):
    m = re.search(r"line:(\d+:\d+)", n["h"])
    return m.group(1) if m else "-"


def nm(n):
    m = re.search(r"\(([^)]*)\)", n["h"])
    return m.group(1) if m else ""


def tsmark(n):
    ts = [k for k in n["kids"] if k["role"] in ("vpiTypespec", "Typespec")]
    if not ts:
        return "TS-"
    a = [k for k in ts[0]["kids"] if k["role"] == "vpiActual"]
    if not a:
        a = [k for k in ts[0]["kids"] if k["t"].endswith("typespec")]
    return "TS[%s]" % (a[0]["t"] if a else "null")


def shape(n, depth=0):
    if n is None:
        return "<null>"
    t = n["t"]
    if t == "constant":
        return "const{ct=%s sz=%s dec=%s val=%s}%s" % (
            n["f"].get("vpiConstType", "-"), n["f"].get("vpiSize", "-"),
            n["f"].get("vpiDecompile", "-"), n["f"].get("VAL", "-"), tsmark(n))
    if t in ("ref_obj", "ref_var"):
        act = [k for k in n["kids"] if k["role"] == "vpiActual"]
        return "ref(%s)->%s%s" % (n["f"].get("vpiName", nm(n)),
                                  act[0]["t"] if act else "UNBOUND", tsmark(n))
    if t == "operation":
        ops = [k for k in n["kids"] if k["role"] in ("vpiOperands", "vpiOperand")]
        body = ", ".join(shape(o, depth + 1) for o in ops) if depth < 3 else "..."
        return "op(%s)%s[%s]" % (n["f"].get("vpiOpType", "-"), tsmark(n), body)
    return "%s@%s%s" % (t, loc(n), tsmark(n))


def rangestr(n):
    rs = [k for k in n["kids"] if k["role"] in ("vpiRange", "Ranges")]
    if not rs:
        return "-"
    out = []
    for r in rs:
        le = [k for k in r["kids"] if k["role"] == "vpiLeftRange"]
        re_ = [k for k in r["kids"] if k["role"] == "vpiRightRange"]
        out.append("[%s : %s]" % (shape(le[0]) if le else "?",
                                  shape(re_[0]) if re_ else "?"))
    return " ".join(out)


def scope_of(n):
    p = n.get("p")
    while p is not None:
        if p["t"] in ("named_begin", "gen_scope", "gen_scope_array",
                      "module_inst", "interface_inst", "package"):
            s = nm(p)
            if s:
                return s
        p = p.get("p")
    return "?"


def main():
    path, sub = sys.argv[1], (sys.argv[2] if len(sys.argv) > 2 else "")
    for n in rebuild(path):
        if n["t"] not in VARKINDS:
            continue
        # Skip the two REPEAT forms uhdm-dump emits: a |vpiParent: back-edge and
        # a re-print of an already-dumped object (header line, no fields).
        if n.get("role") == "vpiParent" or not n["kids"]:
            continue
        sc = scope_of(n)
        if sub and sub not in sc:
            continue
        print("%-34s %-14s %-18s %-8s %s" % (
            sc, nm(n).split(".")[-1] or n["f"].get("vpiName", ""),
            n["t"], tsmark(n), rangestr(n)))


main()
