#!/usr/bin/env python3
"""r11u36 SHAPE LISTER + a-priori MOVER PREDICTOR for the interface-ARRAY
ELEMENT port view.

Reads a uhdm-dump and reports, per interface_inst FULLNAME, the MAXIMUM
`vpiParamAssign` and `vpiParameter` child counts seen across that name's
occurrences (the dump abbreviates repeated objects, so a name's shallow
occurrence always reads par=0 pa=0 -- a min/first reading manufactures
phantoms).

  --shapes   every interface_inst: NAME par=<n> pa=<n> elem=<0|1>
  --elems    only the ARRAY-ELEMENT names (VpiName ends in `[<digits>]`)

`elem` is keyed on the object's own VpiName, not the fullname tail, so a
scalar view inside an array-element HOLDER (`...arr[0].q`) is not counted.
"""
import re
import sys

NAME_RE = re.compile(r'^(\s*)\\_interface_inst: (\S+) \(([^)]*)\)')
ELEM_RE = re.compile(r'\[\d+\]$')


def indent(line):
    return len(line) - len(line.lstrip(' '))


def scan(path):
    lines = open(path, errors='replace').read().split('\n')
    # name -> [max par, max pa, elem]
    acc = {}
    i = 0
    n = len(lines)
    while i < n:
        m = NAME_RE.match(lines[i])
        if not m:
            i += 1
            continue
        base = indent(lines[i])
        full = m.group(3)
        j = i + 1
        npar = npa = 0
        vpiname = None
        while j < n:
            lj = lines[j]
            if lj.strip() == '':
                j += 1
                continue
            ind = indent(lj)
            if ind <= base:
                break
            if ind == base + 2:
                s = lj.strip()
                if s == '|vpiParameter:':
                    npar += 1
                elif s == '|vpiParamAssign:':
                    npa += 1
                elif s.startswith('|vpiName:'):
                    vpiname = s[len('|vpiName:'):]
            j += 1
        cur = acc.setdefault(full, [0, 0, 0])
        cur[0] = max(cur[0], npar)
        cur[1] = max(cur[1], npa)
        if vpiname and ELEM_RE.search(vpiname):
            cur[2] = 1
        i += 1
    return acc


def main():
    mode = sys.argv[1]
    acc = scan(sys.argv[2])
    for name in sorted(acc):
        par, pa, elem = acc[name]
        if mode == '--elems' and not elem:
            continue
        print('%-64s par=%d pa=%d elem=%d' % (name, par, pa, elem))


if __name__ == '__main__':
    main()
