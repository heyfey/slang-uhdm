#!/usr/bin/env python3
"""genls.py <outdir>: an Earlgrey-like multi-file case for § lawSCopyIdOrder186 (LAW S's per-declaration copies of
package SCALAR typedefs at variable bindings): NP packages of NT bare scalar typedefs each, NM modules (one file each)
declaring module variables, function locals and formals of every typedef through a wildcard import and by qualified
name, a top instancing every module twice.  Several files parse on slang's worker threads, so the address order of
the bound objects can differ from their creation order between runs."""
import os, sys
o = sys.argv[1]; os.makedirs(o, exist_ok=True)
NP, NT, NM = 6, 16, 8
files = []
for p in range(NP):
    f = f'pkg{p}.sv'; files.append(f)
    with open(f'{o}/{f}', 'w') as w:
        w.write(f'package p{p};\n')
        for t in range(NT):
            w.write(f'  typedef logic [{t % 7 + 1}:0] t{p}_{t}_t;\n' if t % 3 else f'  typedef bit t{p}_{t}_t;\n')
        w.write(f'endpackage\n')
for m in range(NM):
    f = f'mod{m}.sv'; files.append(f)
    with open(f'{o}/{f}', 'w') as w:
        w.write(f'module m{m} (input logic clk);\n')
        for p in range(NP):
            if (p + m) % 2: w.write(f'  import p{p}::*;\n')
        for p in range(NP):
            for t in range(0, NT, 2):
                q = f't{p}_{t}_t' if (p + m) % 2 else f'p{p}::t{p}_{t}_t'
                w.write(f'  {q} v{p}_{t};\n')
            q = f'p{p}::t{p}_{(m % NT)}_t'
            w.write(f'  function automatic {q} f{p}(input {q} a);\n    {q} l;\n    l = a;\n    return l;\n  endfunction\n')
        w.write('endmodule\n')
with open(f'{o}/dut.sv', 'w') as w:
    w.write('// § lawSCopyIdOrder186: an Earlgrey-like multi-file design (packages of bare scalar typedefs, eight modules binding them); determinism measured by concurrent runs (drivers/lsdet.sh)\n')
    w.write('module top (input logic clk);\n')
    for m in range(NM):
        w.write(f'  m{m} u{m}a (.clk(clk));\n  m{m} u{m}b (.clk(clk));\n')
    w.write('endmodule\n')
files.append('dut.sv')
open(f'{o}/files', 'w').write('\n'.join(files) + '\n')
