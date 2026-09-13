#!/usr/bin/env python3
"""pacen.py <dump...> -- per-param_assign census out of a uhdm-dump text.

Prints, per dump SECTION, the Lhs parameter name, the Rhs object KIND and the
fields `constant::Compare` reads (decompile / size / value / constType).  That
is the projection this pass moves: a package localparam built by a member-by-
member const function goes from our decimal UINT fold to golden's ASSEMBLED
packed BIN constant at the struct's packed width (bare decompile, ct 3).
"""
import re
import sys

OBJ = re.compile(r'^(\s*)\\_(\w+): ')
PAS = re.compile(r'^(\s*)\\_param_assign: ')
PAR = re.compile(r'^\s*\\_parameter: \((.*?)\)')
VAL = re.compile(r'^\|(UINT|INT|BIN|DEC|HEX|OCT|STRING|REAL):')


def clip(s, n=34):
    return s if len(s) <= n else s[:n // 2] + '..' + s[-(n // 2):]


def cells(path):
    lines = open(path, encoding='utf-8', errors='replace').read().split('\n')
    sec = '?'
    out = []
    for i, l in enumerate(lines):
        if l.startswith('|uhdm') and l.endswith(':'):
            sec = l.strip('|:')
        m = PAS.match(l)
        if not m:
            continue
        base = len(m.group(1))
        kind = dec = siz = val = ct = lhs = ''
        j = i + 1
        while j < len(lines):
            s = lines[j]
            if s.strip() and (len(s) - len(s.lstrip())) <= base:
                break
            ind = len(s) - len(s.lstrip())
            if s.strip() == '|vpiLhs:' and ind == base + 2:
                k = PAR.match(lines[j + 1] if j + 1 < len(lines) else '')
                if k:
                    lhs = k.group(1)
            if s.strip() == '|vpiRhs:' and ind == base + 2 and not kind:
                k = OBJ.match(lines[j + 1] if j + 1 < len(lines) else '')
                if k:
                    kind = k.group(2)
                    oi = len(k.group(1))
                    for t in range(j + 2, len(lines)):
                        ts = lines[t]
                        if not ts.strip():
                            continue
                        ti = len(ts) - len(ts.lstrip())
                        if ti <= oi:
                            break
                        if ti != oi + 2:
                            continue
                        b = ts.strip()
                        if b.startswith('|vpiDecompile:'):
                            dec = b.split(':', 1)[1]
                        elif b.startswith('|vpiSize:'):
                            siz = b.split(':', 1)[1]
                        elif b.startswith('|vpiConstType:'):
                            ct = b.split(':', 1)[1]
                        elif VAL.match(b):
                            val = b[1:]
            j += 1
        out.append((sec, lhs, kind, clip(dec), siz, clip(val), ct))
    return out


for p in sys.argv[1:]:
    print('##', p)
    for sec, lhs, kind, dec, siz, val, ct in cells(p):
        print('   %-16s %-34s %-12s dec=%-36s sz=%-5s %-40s ct=%s'
              % (sec, lhs, kind, dec, siz, val, ct))
