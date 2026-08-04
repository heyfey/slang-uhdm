#!/usr/bin/env python3
"""r10bpfam: tabulate a module's param_assign RHS constants from a uhdm-dump.

Prints one row per param in the ELABORATED (uhdmtopModules) listing, or in the
def listing with --def: kind (constant/operation), vpiDecompile, vpiSize,
vpiConstType, and the vpiActual typespec class.  This is the CMP-relevant
projection for a param-fold model -- decompile/size/constType are exactly the
three constant extras uhdm-cmp reads.
"""
import re
import sys

path = sys.argv[1]
mod = sys.argv[2] if len(sys.argv) > 2 else 'top'
defview = '--def' in sys.argv
txt = open(path).read()
if not defview:
    txt = txt[txt.index('uhdmtopModules'):]
else:
    txt = txt[:txt.index('uhdmtopModules')]

pat = re.compile(r'\\_param_assign:.*?\|vpiLhs:\s*\n\s*\\_parameter: \(work@%s\.(\w+)\)' % mod, re.S)
for m in pat.finditer(txt):
    body, name = m.group(0), m.group(1)
    rhs = body.split('vpiRhs:', 1)[1] if 'vpiRhs:' in body else ''
    kind = 'operation' if rhs.lstrip().startswith('\\_operation') else (
        'constant' if rhs.lstrip().startswith('\\_constant') else rhs.lstrip()[:14])
    dec = re.search(r'\|vpiDecompile:(.*)', rhs)
    sz = re.search(r'\|vpiSize:(\d+)', rhs)
    ct = re.search(r'\|vpiConstType:(\d+)', rhs)
    ts = re.search(r'\|vpiActual:\s*\n\s*\\_(\w+):', rhs)
    d = dec.group(1) if dec else '-'
    print('%-8s %-9s sz=%-4s ct=%-3s ts=%-16s dec=%s' % (
        name, kind, sz.group(1) if sz else '-', ct.group(1) if ct else '-',
        ts.group(1) if ts else '-', d[:60]))
