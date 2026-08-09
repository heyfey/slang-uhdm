#!/usr/bin/env python3
"""fcproj18.py <dump> -- project a uhdm-dump onto its func_call / task_call
objects: for each, the source span, the vpiName and whether the NEXT line
after the name is a vpiFunction / vpiTask binding.  The def view and the elab
view of the same call appear as separate rows in file order, which is exactly
what the § defGenCallNoBind matrix needs."""
import re
import sys

for path in sys.argv[1:]:
    print("=== " + path)
    lines = open(path, errors="replace").read().splitlines()
    for i, ln in enumerate(lines):
        m = re.search(r"\\_(func_call|task_call): \(?([^)]*)\)?, line:(\d+):(\d+)", ln)
        if not m:
            continue
        kind, nm, l, c = m.group(1), m.group(2), m.group(3), m.group(4)
        if nm.startswith(","):
            nm = ""
        indent = len(ln) - len(ln.lstrip())
        bound = ""
        # the binding is a sibling field of the same object: scan forward at a
        # deeper indent until the indent falls back to this object's level.
        for j in range(i + 1, min(i + 60, len(lines))):
            s = lines[j]
            ind = len(s) - len(s.lstrip())
            if ind <= indent and s.strip().startswith("\\_"):
                break
            if "|vpiFunction:" in s or "|vpiTask:" in s:
                bound = s.strip().rstrip(":").lstrip("|")
                break
        # NO DEDUP: the dump line number `d<N>` is the only thing that tells
        # the DEF-view row from the ELAB-view row of the same call, and
        # deduplicating on (name, span, bound) is what made the first read of
        # fc18.sv ambiguous.
        print("  d%-6d %-10s %-8s name=%-30s %s" %
              (i, kind, l + ":" + c, "'" + nm + "'", bound or "-"))
