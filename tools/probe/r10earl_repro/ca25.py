#!/usr/bin/env python3
"""ca25.py <dump> [substr] -- project a uhdm-dump onto ONE LINE PER cont_assign
(and per process blocking-assign), showing the Rhs SHAPE in the four fields
uhdm-cmp actually reads.  Written for pass 25's whole-RHS enum fold: the
question is always "constant (with what ct/size/decompile) or ref_obj (bound to
what)?", and the raw dump buries that under 6 lines of parent chatter.

Output:  <line:col>  <owner-scope>  LHS=<shape>  RHS=<shape>
where <shape> is
    const{ct=<n> sz=<n> dec=<text> val=<text> loc=<line|-> }
    ref(<name>)->[<actual type>(<name>)|UNBOUND]
    <uhdmtype>(...)   for anything else, with its own first operand summarised
"""
import re
import sys


def parse(path):
    """Return a list of (depth, kind, header, fields) in file order."""
    out = []
    cur = None
    with open(path, errors="replace") as fh:
        for raw in fh:
            line = raw.rstrip("\n")
            m = re.match(r"^(\s*)\\_([a-z_0-9]+): (.*)$", line)
            if m:
                cur = {
                    "d": len(m.group(1)),
                    "t": m.group(2),
                    "h": m.group(3),
                    "f": {},
                    "kids": [],
                }
                out.append(cur)
                continue
            m = re.match(r"^(\s*)\|([A-Za-z0-9_]+):(.*)$", line)
            if m and cur is not None:
                cur["f"].setdefault(m.group(2), m.group(3))
                cur["lastrole"] = m.group(2)
                continue
            m = re.match(r"^(\s*)\|(BIN|HEX|OCT|DEC|INT|UINT|STRING|REAL):(.*)$", line)
            if m and cur is not None:
                cur["f"].setdefault("VAL", m.group(2) + ":" + m.group(3))
    return out


def tree(nodes):
    """Attach each node to its parent by indentation, recording the ROLE
    (vpiRhs / vpiLhs / vpiActual / ...) the parent's last |xxx: line named."""
    stack = []
    roots = []
    for n in nodes:
        while stack and stack[-1]["d"] >= n["d"]:
            stack.pop()
        if stack:
            p = stack[-1]
            n["role"] = p.get("pending", "?")
            p["kids"].append(n)
        else:
            n["role"] = "root"
            roots.append(n)
        stack.append(n)
    return roots


def rebuild(path):
    """Re-parse tracking the |role: marker that immediately precedes a child."""
    nodes = []
    stack = []
    roots = []
    pending = {}
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
    return roots, nodes


def loc(n):
    m = re.search(r"line:(\d+:\d+)", n["h"])
    return m.group(1) if m else "-"


def name(n):
    m = re.search(r"\(([^)]*)\)", n["h"])
    return m.group(1) if m else ""


def shape(n, depth=0):
    if n is None:
        return "<null>"
    t = n["t"]
    if t == "constant":
        return "const{ct=%s sz=%s dec=%s val=%s loc=%s}" % (
            n["f"].get("vpiConstType", "-"),
            n["f"].get("vpiSize", "-"),
            n["f"].get("vpiDecompile", "-"),
            n["f"].get("VAL", "-"),
            loc(n),
        )
    if t in ("ref_obj", "ref_var"):
        act = [k for k in n["kids"] if k["role"] == "vpiActual"]
        a = "UNBOUND"
        if act:
            a = "%s(%s)" % (act[0]["t"], name(act[0]))
            if act[0]["t"] == "enum_const":
                a += "{dec=%s sz=%s loc=%s}" % (
                    act[0]["f"].get("vpiDecompile", "-"),
                    act[0]["f"].get("vpiSize", "-"),
                    loc(act[0]),
                )
        return "%s(%s)@%s->%s" % (t, n["f"].get("vpiName", name(n)), loc(n), a)
    inner = ""
    if depth < 1:
        ops = [k for k in n["kids"] if k["role"] in ("vpiOperands", "vpiOperand", "vpiExpr",
                                                     "vpiIndex", "vpiActual")]
        if ops:
            inner = "[" + ", ".join(shape(o, depth + 1) for o in ops[:4]) + "]"
    return "%s@%s%s" % (t, loc(n), inner)


def scope_of(n):
    p = n.get("p")
    while p is not None:
        if p["t"] in ("named_begin", "gen_scope", "gen_scope_array", "module_inst",
                       "package", "begin", "always"):
            nm = name(p)
            if nm:
                return nm
        p = p.get("p")
    return "?"


def main():
    path = sys.argv[1]
    sub = sys.argv[2] if len(sys.argv) > 2 else ""
    roots, nodes = rebuild(path)
    for n in nodes:
        if n["t"] not in ("cont_assign", "assignment"):
            continue
        sc = scope_of(n)
        if sub and sub not in sc:
            continue
        lhs = [k for k in n["kids"] if k["role"] == "vpiLhs"]
        rhs = [k for k in n["kids"] if k["role"] == "vpiRhs"]
        print("%-10s %-44s L=%s  R=%s" % (
            loc(n), sc,
            shape(lhs[0]) if lhs else "<null>",
            shape(rhs[0]) if rhs else "<null>"))


main()
