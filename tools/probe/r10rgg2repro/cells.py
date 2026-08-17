#!/usr/bin/env python3
"""r10rgg2/cells.py — print every `constant` OCCURRENCE in a uhdm-dump keyed by
its source position, with the fields uhdm-cmp reads (value / size / const type
/ decompile).

The dump nests already-visited objects under `|vpiParent:` etc., so fields are
attributed by INDENTATION: a constant printed at indent d owns exactly the
`|field:` lines at indent d+2 that precede the next line at indent <= d.
Without that, a parent's fields get stolen by the child.

GUARD: prints EMPTY and exits 2 when no constant was found at all, so a cell
can never read as agreement because nothing was measured."""
import re
import sys


def indent(line):
    return len(line) - len(line.lstrip(' '))


def main():
    path = sys.argv[1] if len(sys.argv) > 1 else '-'
    src = sys.stdin if path == '-' else open(path)
    lines = src.read().split('\n')
    out = []
    for i, line in enumerate(lines):
        m = re.match(r'( *)\\_constant: , line:(\d+):(\d+), endln:', line)
        if not m:
            continue
        d = len(m.group(1))
        pos = (int(m.group(2)), int(m.group(3)))
        f = {}
        for line2 in lines[i + 1:]:
            if not line2.strip():
                break
            i2 = indent(line2)
            if i2 <= d:
                break
            if i2 != d + 2 or not line2.lstrip().startswith('|'):
                continue
            s = line2.strip()[1:]
            k, _, v = s.partition(':')
            if k in ('UINT', 'INT', 'BIN', 'HEX', 'OCT', 'DEC', 'REAL',
                     'STRING', 'SCAL'):
                f.setdefault('val', k + ':' + v)
            elif k == 'vpiSize':
                f.setdefault('size', v)
            elif k == 'vpiConstType':
                f.setdefault('ct', v)
            elif k == 'vpiDecompile':
                f.setdefault('dec', v)
        out.append((pos, f))
    if not out:
        print('EMPTY')
        return 2
    seen = {}
    for pos, f in out:
        key = (pos, f.get('val'), f.get('size'), f.get('ct'))
        seen.setdefault(key, 0)
        seen[key] += 1
    for key in sorted(seen, key=lambda k: (k[0], str(k[1]))):
        pos, val, size, ct = key
        print('%4d:%-3d  %-26s size=%-5s ct=%-3s x%d'
              % (pos[0], pos[1], val, size, ct, seen[key]))
    return 0


sys.exit(main())
