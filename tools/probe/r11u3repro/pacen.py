#!/usr/bin/env python3
"""r11u3 param_assign census.

Reads a uhdm-dump text and prints one line per ELABORATED param_assign whose
parent module_inst name is given (vpiFullName of the instance is taken from the
enclosing `\\_module_inst: ... (<full>)` line), with the Rhs constant's
value-kind fields:  inst | lhs | decompile | size | value | constType

Measurement-only: nothing here decides acceptance, uhdm-cmp does.
usage: pacen.py <dump>
"""
import re
import sys


def main(path):
    lines = open(path, encoding='utf-8', errors='replace').read().split('\n')
    inst = None
    i = 0
    out = []
    while i < len(lines):
        ln = lines[i]
        m = re.search(r'\\_module_inst: \S+ \(([^)]*)\)', ln)
        if m:
            inst = m.group(1)
        if ln.strip().startswith('\\_param_assign:') and ln.startswith(' '):
            # scan the following block for the Rhs constant fields and the Lhs name
            dec = sz = val = ct = lhs = ''
            j = i + 1
            depth_stop = 0
            while j < len(lines) and j < i + 60:
                s = lines[j].strip()
                if s.startswith('|vpiDecompile:') and not dec:
                    dec = s.split(':', 1)[1]
                elif s.startswith('|vpiSize:') and not sz:
                    sz = s.split(':', 1)[1]
                elif re.match(r'^\|(BIN|UINT|INT|HEX|OCT|REAL|STRING|SCAL):', s) and not val:
                    val = s[1:]
                elif s.startswith('|vpiConstType:') and not ct:
                    ct = s.split(':', 1)[1]
                elif s.startswith('|vpiLhs:'):
                    depth_stop = 1
                elif depth_stop and s.startswith('\\_parameter:'):
                    mm = re.search(r'\(([^)]*)\)', s)
                    lhs = mm.group(1) if mm else ''
                    break
                j += 1
            out.append('%-42s %-46s dec=%-36s size=%-4s %-38s ct=%s' %
                       (inst or '?', lhs, dec, sz, val, ct))
            i = j
        i += 1
    for o in out:
        print(o)


if __name__ == '__main__':
    main(sys.argv[1])
