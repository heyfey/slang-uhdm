#!/usr/bin/env python3
"""pav28.py <dump>

ONE LINE PER param_assign in a uhdm-dump, projected onto exactly the fields
uhdm-cmp reads for its Rhs constant:

    <PARAM-fullname> @<line>:<col>  rhs=constant @<l>:<c> ct=<n>(<name>) sz=<n> dec=<...>

The pass-28 frontier is a constant's vpiConstType + vpiDecompile (and, as it
turned out, vpiSize) disagreeing at an ELABORATED param_assign whose parameter
is OVERRIDDEN, so the parameter's FULLNAME is the key: the same declaration
reads differently in the def view and in each elaborated instance, and the
fullname is what distinguishes them.

PARSING RULES, both of which cost a rewrite when got wrong:
  * uhdm-dump indents 2 per level and `\\_` occupies the two columns a field's
    `|` leaves blank, so a field at indent N belongs to the deepest open node
    at indent N-2.
  * uhdm-dump prints vpiParent (and other) BACK-POINTERS as one-line nodes.  A
    back-pointed `param_assign` under a constant's vpiParent looks exactly like
    a real one; treat it as real and every row's projection silently comes back
    empty.  Nodes reached through vpiParent are skipped here.

POSITIVE CONTROL (the reason this docstring exists): run with -c and the script
prints the row count and how many rows carry a ct= field.  A run where
`withct` is 0 is a BROKEN PROBE, not a clean database.
"""
import re
import sys

NODE = re.compile(r"^(\s*)\\_(\w+): ?(\([^)]*\))?,?"
                  r"(?: ?id:(\d+),?)?(?: ?file:([^,]*),?)?"
                  r"(?: ?line:(\d+):(\d+))?")
FLD = re.compile(r"^(\s*)\|(\w+):(.*)$")

CT = {1: "DEC", 2: "REAL", 3: "BIN", 4: "OCT", 5: "HEX", 6: "STR",
      7: "INT", 8: "TIME", 9: "UINT", 10: "SCALAR", 11: "NULL"}


def main(path, control=False):
    open_nodes = []          # [indent, kind, name, line, col, fields]
    lastrel = {}
    rows = []
    pending = None           # [name, line, col, rhsdesc, rhsnode]
    pend_ind = -1            # indent of the param_assign `pending` describes

    def flush():
        nonlocal pending, pend_ind
        if pending is None:
            return
        rows.append("%-40s @%-8s %s" % (pending[0], pending[1] + ":" +
                                        pending[2], pending[3]))
        pending, pend_ind = None, -1

    for raw in open(path, errors="replace"):
        m = FLD.match(raw)
        if m and not m.group(3).strip():
            lastrel[len(m.group(1))] = m.group(2)
            continue
        m = NODE.match(raw)
        if m:
            ind = len(m.group(1))
            kind = m.group(2)
            name = (m.group(3) or "()")[1:-1]
            line, col = m.group(6) or "0", m.group(7) or "0"
            rel = lastrel.get(ind)
            if rel == "vpiParent":
                continue                      # one-line BACK-POINTER
            while open_nodes and open_nodes[-1][0] >= ind:
                open_nodes.pop()
            node = [ind, kind, name, line, col, {}]
            open_nodes.append(node)
            # THE ROW ENDS WHEN THE param_assign SUBTREE DOES.  Without this a
            # trailing cont_assign's own vpiLhs/vpiRhs overwrite the LAST
            # param_assign of every instance, and that row disappears from the
            # grid instead of reading wrong -- a silently MISSING row.
            if pending is not None and ind <= pend_ind and kind != "param_assign":
                flush()
            if kind == "param_assign":
                flush()
                pending = ["?", line, col, "rhs=<none>", None]
                pend_ind = ind
            elif pending is not None and rel == "vpiRhs":
                if kind == "constant":
                    pending[3] = "rhs=constant @%s:%s" % (line, col)
                    pending[4] = node
                else:
                    pending[3] = ("rhs=%s '%s' @%s:%s"
                                  % (kind, name, line, col))
                    pending[4] = None
            elif pending is not None and rel == "vpiLhs":
                pending[0] = name or "?"
            continue
        m = FLD.match(raw)
        if m and open_nodes:
            want = len(m.group(1)) - 2
            for n in reversed(open_nodes):
                if n[0] == want:
                    n[5][m.group(2)] = m.group(3).strip()
                    if pending is not None and n is pending[4]:
                        f = n[5]
                        ct = f.get("vpiConstType", "?")
                        try:
                            cts = CT.get(int(ct), ct)
                        except ValueError:
                            cts = ct
                        pending[3] = ("rhs=constant @%s:%s ct=%s(%s) sz=%s "
                                      "dec=%s" % (n[3], n[4], ct, cts,
                                                  f.get("vpiSize", "?"),
                                                  f.get("vpiDecompile", "?")))
                    break
    flush()
    if control:
        print("ROWS=%d withct=%d" % (len(rows),
                                     sum(1 for r in rows if " ct=" in r)))
        return
    for r in rows:
        print(r)


if __name__ == "__main__":
    a = [x for x in sys.argv[1:] if x != "-c"]
    main(a[0], "-c" in sys.argv[1:])
