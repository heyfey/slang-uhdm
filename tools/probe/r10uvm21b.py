#!/usr/bin/env python3
"""r10uvm21b.py <dir> -- the REVERSE-direction edit for § classPropUnitImport21.

SimpleUVM declares `import uvm_pkg::*;` and its classes at COMPILATION-UNIT
scope; SeqDriver puts both inside `package adpcm_pkg`.  This rewrites a copy of
SimpleUVM's testbench.sv into the SeqDriver shape -- classes and the import
moved into a package, the module importing both -- WITHOUT touching a line of
uvm-1.2.  Golden's loop-variable histogram then flips from SimpleUVM's to
SeqDriver's exactly (see tools/probe/r10uvm21repro/README.md).

Use with tools/probe/r10uvm21ab.sh:

    R10P=/tmp/r10uvm21_20a tools/probe/r10uvm21ab.sh \\
      ~/git-repos/Surelog/third_party/tests/SimpleUVM su_pkg \\
      'python3 tools/probe/r10uvm21b.py $0 >/dev/null'
"""
import sys

p = sys.argv[1] + '/testbench.sv'
s = open(p).read()
assert s.startswith('import uvm_pkg::*;\n'), 'not the SimpleUVM testbench'
s = s[len('import uvm_pkg::*;\n'):]
i = s.index('//-----------\n// module top')
head, tail = s[:i], s[i:]
head = ('package tb_pkg;\n'
        '  import uvm_pkg::*;\n'
        '  `include "uvm_macros.svh"\n' + head + '\nendpackage: tb_pkg\n\n')
head = head.replace('`include "uvm_macros.svh"\n\n//----------------',
                    '//----------------', 1)
tail = tail.replace('module top;\n',
                    'module top;\n  import uvm_pkg::*;\n  import tb_pkg::*;\n', 1)
open(p, 'wt').write(head + tail)
print(open(p).read()[:400])
