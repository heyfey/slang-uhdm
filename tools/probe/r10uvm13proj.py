#!/usr/bin/env python3
"""Project a uhdm-dump onto enum-read sites: (view, loc) -> node kind + actual kind."""
import re, sys

def parse(path):
    rows = []
    view = "?"
    stack = []  # (indent, label)
    lines = open(path).read().split("\n")
    for i, ln in enumerate(lines):
        m = re.match(r'^(\s*)\\_(\w+): (.*)$', ln)
        if m:
            ind = len(m.group(1))
            kind = m.group(2)
            rest = m.group(3)
            if ind == 0:
                view = kind + " " + rest.split(",")[0]
            while stack and stack[-1][0] >= ind:
                stack.pop()
            # is this node under a vpiActual/vpiParent/etc?
            rel = ""
            for j in range(i-1, max(0, i-3), -1):
                mm = re.match(r'^\s*\|(\w+):\s*$', lines[j])
                if mm:
                    rel = mm.group(1); break
            stack.append((ind, kind, rest, rel))
            loc = ""
            lm = re.search(r'line:(\d+):(\d+)', rest)
            if lm: loc = lm.group(1)+":"+lm.group(2)
            rows.append((i, ind, kind, rest, rel, loc, view, list(stack)))
    return rows, lines

def actual_of(rows, idx, lines):
    """find the child of rows[idx] introduced by |vpiActual:"""
    i, ind, kind, rest, rel, loc, view, st = rows[idx]
    for k in range(idx+1, len(rows)):
        i2, ind2, kind2, rest2, rel2, loc2, view2, st2 = rows[k]
        if ind2 <= ind: break
        if ind2 == ind+2 and rel2 == "vpiActual":
            return kind2 + " " + rest2.split(",")[0]
    return "NONE"

SITES = sys.argv[2:] if len(sys.argv) > 2 else []
rows, lines = parse(sys.argv[1])
vi = 0
prevview = None
for idx,(i, ind, kind, rest, rel, loc, view, st) in enumerate(rows):
    if not SITES or loc in SITES:
        if kind in ("ref_obj","constant","enum_const","operation","logic_net"):
            if rel in ("vpiParent","vpiInstance","vpiTypespec"): continue
            nm = re.search(r'\((.*?)\)', rest)
            extra = ""
            if kind == "constant":
                for j in range(i+1, min(i+8, len(lines))):
                    if re.match(r'^\s*\|', lines[j]):
                        extra += lines[j].strip()+" "
                    elif lines[j].strip().startswith("\\_"): break
                extra = re.sub(r'vpi(Parent|Line|Column|EndLine|EndColumn|File):\S*\s*','',extra)
            print("%-28s %-8s %-11s %-22s %s %s" % (view[:28], loc, kind, (nm.group(1) if nm else "")[:22], actual_of(rows, idx, lines) if kind=="ref_obj" else "", extra))
