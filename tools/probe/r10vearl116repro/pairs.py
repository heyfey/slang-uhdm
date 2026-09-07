#!/usr/bin/env python3
"""r10vearl116 — THE INDEX-JOIN CHECK.  MEASUREMENT ONLY.

Walks a uhdm-dump by indentation and, for every cont_assign whose Rhs is an
assignment-pattern operation, prints its operands IN ORDER as
    <member key> -> <pattern object name>   ROOT=<Root_value target name>
so a POSITIONAL MIS-JOIN between UHDM operands and slang memberSetters shows up
as a key paired with the wrong member's value or the wrong root object.
usage: pairs.py <dump.txt> <label>
"""
import re
import sys


def indent(l):
    return len(l) - len(l.lstrip(' '))


def main():
    lines = open(sys.argv[1]).read().split('\n')
    label = sys.argv[2]
    # locate cont_assign starts
    for i, l in enumerate(lines):
        m = re.search(r'\\_cont_assign: , line:(\d+):', l)
        if not m:
            continue
        line_no = m.group(1)
        base = indent(l)
        # collect the block
        j = i + 1
        blk = []
        while j < len(lines) and (lines[j].strip() == '' or indent(lines[j]) > base):
            blk.append(lines[j])
            j += 1
        # find operands at the operation level
        out = []
        for k, b in enumerate(blk):
            if '\\_tagged_pattern:' not in b:
                continue
            tind = indent(b)
            # sub-block of this tagged_pattern
            sub = []
            k2 = k + 1
            while k2 < len(blk) and (blk[k2].strip() == '' or indent(blk[k2]) > tind):
                sub.append(blk[k2])
                k2 += 1
            key = '?'
            for s in sub:
                mk = re.search(r'\\_string_typespec: \(([^)]*)\)', s)
                if mk:
                    key = mk.group(1)
                    break
            pat = '?'
            for s in sub:
                mp = re.search(r'\|vpiPattern:', s)
                if mp:
                    idx = sub.index(s)
                    if idx + 1 < len(sub):
                        mv = re.search(r'\\_(\w+): \(([^)]*)\)', sub[idx + 1])
                        if mv:
                            pat = mv.group(1) + '(' + mv.group(2) + ')'
                        else:
                            mv2 = re.search(r'\\_(\w+):', sub[idx + 1])
                            pat = mv2.group(1) if mv2 else '?'
                    break
            root = '<none>'
            for s in sub:
                if '|vpiExpr:' in s:
                    idx = sub.index(s)
                    if idx + 1 < len(sub):
                        mr = re.search(r'\\_(\w+): \(([^)]*)\)', sub[idx + 1])
                        if mr:
                            root = mr.group(2)
                    break
            out.append((key, pat, root))
        if out:
            print(f'{label} cont_assign line:{line_no}')
            for key, pat, root in out:
                print(f'    {key:<8} -> {pat:<34} ROOT={root}')


main()
