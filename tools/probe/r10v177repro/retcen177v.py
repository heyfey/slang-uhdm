#!/usr/bin/env python3
"""r10v177 — INDEPENDENT return-variable census, read off `uhdm-dump` text.

MEASUREMENT ONLY.  The official `uhdm-cmp` is the sole judge; this is a
line-comparable instrument that shares NO code with r10uvm177's `ct177cen`, so
a bug in that instrument cannot hide here (and vice versa).

One row per FUNCTION that has a `vpiReturn`, keyed by

    <top-level dump section> | <function name as the dump prints it> | <line:col>

with value

    <return variable's UHDM kind> <return typespec kind> <typespec name>

The SPAN of the return typespec is deliberately NOT in the value: `uhdm-cmp`
reads no span (RESUME §9).  The dump's synthesized `vpiFullName` is used only as
a KEY — never as a verdict.

A dump prints an object again wherever it is a BACK-REFERENCE (`|vpiParent:`,
`|vpiInstance:`, `|vpiActual:`, `|vpiTypedefAlias:` …).  Every such re-print is
skipped, or a function's row would be reset by its own child's parent pointer.
"""
import re
import subprocess
import sys

DUMP = "/home/heyfey/.local/bin/uhdm-dump"
BACKREF = {"vpiParent", "vpiInstance"}

OBJ = re.compile(r"^(\s*)\\_([a-z_0-9]+): (.*)$")
FLD = re.compile(r"^(\s*)\|([A-Za-z_0-9]+):(.*)$")
LOC = re.compile(r"line:(\d+):(\d+)")


def dump(path):
    env = {"LD_LIBRARY_PATH":
           "/home/heyfey/.local/lib64:/home/heyfey/.local/lib",
           "PATH": "/usr/bin:/bin"}
    r = subprocess.run([DUMP, path], capture_output=True, text=True, env=env)
    return r.stdout.splitlines()


def census(path):
    section = "-"
    stack = []            # (indent, kind, rest, parent_field)
    pend = {}             # indent -> most recently opened field at that indent
    rows = {}
    ret = None            # (key, indent of the return variable)
    for ln in dump(path):
        m = FLD.match(ln)
        if m:
            ind, name = len(m.group(1)), m.group(2)
            if ind == 0 and name.startswith("uhdm"):
                section = name
            pend[ind] = name
            for k in [k for k in pend if k > ind]:
                del pend[k]
            continue
        m = OBJ.match(ln)
        if not m:
            continue
        ind, kind, rest = len(m.group(1)), m.group(2), m.group(3)
        while stack and stack[-1][0] >= ind:
            stack.pop()
        pf = pend.get(ind, "-")
        stack.append((ind, kind, rest, pf))
        if ret and ind <= ret[1]:
            ret = None
        if pf in BACKREF:
            continue
        if kind == "function":
            loc = LOC.search(rest)
            key = (section, rest.split(",")[0].strip(),
                   loc.group(0) if loc else "-")
            rows.setdefault(key, ["-", "-", "-"])
        if pf == "vpiReturn":
            for i in range(len(stack) - 2, -1, -1):
                if stack[i][1] == "function":
                    loc = LOC.search(stack[i][2])
                    key = (section, stack[i][2].split(",")[0].strip(),
                           loc.group(0) if loc else "-")
                    rows.setdefault(key, ["-", "-", "-"])
                    rows[key][0] = kind
                    ret = (key, ind)
                    break
        elif ret and kind.endswith("typespec") and kind != "ref_typespec":
            key = ret[0]
            if rows.get(key, ["-", "-", "-"])[1] == "-":
                rows[key][1] = kind
                rows[key][2] = rest.split(",")[0].strip().strip("()")
    return rows


def fmt(rows):
    return ["%s\t%s\t%s\t%s" % (k[0], k[1], k[2], " ".join(rows[k]))
            for k in sorted(rows)]


if __name__ == "__main__":
    for line in fmt(census(sys.argv[1])):
        print(line)
