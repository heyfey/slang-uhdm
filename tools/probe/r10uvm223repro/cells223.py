#!/usr/bin/env python3
"""§ wildcardImportCopiesPkgVarsToDefNets223 — the CELL SCORER.

Reads a uhdm-dump and prints, for every instance object in the design's
definition listings (uhdmallInterfaces / uhdmallModules / uhdmallPrograms) and
for every instantiated instance (uhdmtopModules and their vpiInterface /
vpiModule children), the ORDERED list of its direct `vpiNet`, `vpiArrayNet`,
`vpiVariables` and `vpiProcess` children, keyed by kind+name+span.

Depth-keyed, not slot-keyed: the key is (owner, field, kind, name, span).
"""
import re
import sys

HEAD = re.compile(r'^(\s*)\\_(\w+): (.*?)(?:, )?(?:id:\d+, )?(?:file:\S+?, )?(line:\d+:\d+(?:, endln:\d+:\d+)?)?\s*$')
FIELD = re.compile(r'^(\s*)\|(vpi\w+):\s*$')

WANT = ('vpiNet', 'vpiArrayNet', 'vpiProcess', 'vpiVariables')
OWNERS = ('interface_inst', 'module_inst', 'program')


def scan(path):
    lines = open(path, 'rt', errors='replace').read().split('\n')
    # find owner headers at any indent, then collect their direct fields
    out = []
    i = 0
    n = len(lines)
    while i < n:
        m = HEAD.match(lines[i])
        if m and m.group(2) in OWNERS:
            ind = len(m.group(1))
            oname = (m.group(3) or '').strip()
            # direct children live at indent ind+2
            j = i + 1
            cells = []
            while j < n:
                mj = HEAD.match(lines[j])
                fj = FIELD.match(lines[j])
                if mj and len(mj.group(1)) <= ind:
                    break
                if fj and len(fj.group(1)) == ind + 2 and fj.group(2) in WANT:
                    if j + 1 < n:
                        mk = HEAD.match(lines[j + 1])
                        if mk:
                            cells.append((fj.group(2), mk.group(2),
                                          (mk.group(3) or '').strip(),
                                          mk.group(4) or ''))
                j += 1
            if cells:
                out.append((oname, cells))
        i += 1
    return out


def main():
    for p in sys.argv[1:]:
        print('##', p)
        for oname, cells in scan(p):
            for f, k, nm, sp in cells:
                print('  %-40s %-14s %-12s %-46s %s' % (oname, f, k, nm, sp))


if __name__ == '__main__':
    main()
