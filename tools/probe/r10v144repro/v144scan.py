#!/usr/bin/env python3
# r10v144 (VERIFIER) -- WHOLE-DUMP ref_obj BINDING CENSUS out of a `uhdm-dump`.
#
# Wider than r10uvm144's argscan144.py, deliberately: argscan only reads a
# ref_obj that is the DIRECT child of a call's |vpiArgument:.  This one reads
# EVERY ref_obj in the dump -- operands, concat elements, condition operands,
# assignment RHS, hier_path elements, event-control carriers -- and prints
#     REF <name> <line>:<col> <actual-kind> <actual-name>
# keyed on the object's OWN fields only (|vpiName + line:col + the ACTUAL's
# UHDM kind and its own |vpiName).  NEVER the dump-synthesized vpiFullName,
# which is built from the parent chain and is not read by uhdm-cmp.
#
# MEASUREMENT ONLY -- the judge is the official uhdm-cmp.
#   usage: v144scan.py <dump>
import sys, re

def ind(s):
    return len(s) - len(s.lstrip(' '))

def main():
    lines = open(sys.argv[1], errors='replace').read().split('\n')
    n = len(lines)
    out = []
    for i, l in enumerate(lines):
        m = re.match(r'(\s*)\\_ref_obj: .*?line:(\d+):(\d+)', l)
        if not m:
            continue
        base = ind(l)
        pos = m.group(2) + ':' + m.group(3)
        rname, act, aname = '', 'NONE', ''
        j = i + 1
        while j < n and lines[j].strip() and ind(lines[j]) > base:
            if ind(lines[j]) == base + 2:
                s = lines[j].strip()
                if s.startswith('|vpiName:'):
                    rname = s[9:]
                elif s == '|vpiActual:':
                    mm = re.match(r'\s*\\_(\w+):', lines[j + 1])
                    if mm:
                        act = mm.group(1)
                        ab = ind(lines[j + 1])
                        t = j + 2
                        while t < n and lines[t].strip() and ind(lines[t]) > ab:
                            if (ind(lines[t]) == ab + 2 and
                                    lines[t].strip().startswith('|vpiName:')):
                                aname = lines[t].strip()[9:]
                                break
                            t += 1
            j += 1
        out.append('REF\t%s\t%s\t%s\t%s' % (rname, pos, act, aname))
    for r in sorted(out):
        print(r)

main()
