#!/usr/bin/env python3
"""r11u198: writes cases/M (the grid of § methodArgOpRefChainName198): references inside an OPERATION argument of a
method call that is a hier_path's last element (`c.f(n, i + 1)`), in a class method and a module function, by the
argument's shape (binary, nested, unary, ternary, concatenation, a nested call, a system call), the receiver (a
handle, an array element, `this`, `super`, an interface), statement position, the elaborated module.  usage: mkgridM.py"""
import os
HERE = os.path.dirname(os.path.abspath(__file__))
LAW = '// § methodArgOpRefChainName198\n'
CC = ('class C; int q[$]; function int f(int k, int j = 0); return k + j; endfunction\n'
      '  task t(int k); endtask endclass\n')
def cls(body, extra=''):
    return (LAW + CC + 'class B; function int m(int k); return k; endfunction endclass\n'
            'class D extends B;\n  C c; C arr[4]; string s; string args[$];' + extra + '\n'
            '  function int g(int n, int i);\n    int x;\n' + body + '\n    return x;\n  endfunction\nendclass\nmodule top; endmodule\n')
C = {
 'm01_cls_binop': cls('    x = c.f(n, i + 1);'),
 'm03_cls_nestedop': cls('    x = c.f((i + 1) * 2);'),
 'm04_cls_unary': cls('    x = c.f(-i);'),
 'm05_cls_ternary': cls('    x = c.f(i ? n : 0);'),
 'm06_cls_concat': cls('    x = c.f({i, n});'),
 'm07_cls_nestedcall': cls('    x = c.f(c.f(i + 1, n), n);'),
 'm08_cls_this': cls('    x = this.c.f(i + 1, n);'),
 'm09_cls_super': cls('    x = super.m(i + 1);'),
 'm10_cls_arrrecv': cls('    x = arr[i].f(n, n + 1);'),
 'm11_cls_stmt': cls('    void\'(c.f(i + 1));'),
 'm12_cls_sysinop': cls('    x = c.f($clog2(i) + 1, n);'),
 'm13_cls_builtin_nested': cls('    s = s.substr(i, args[i].len() - 1);'),
 'm17_cls_cmp': cls('    x = c.f(n, i == 2);'),
 'm19_cls_inif': cls('    if (c.f(i + 1) > 2) x = 1;'),
 'm20_cls_localop': cls('    int k = 3;\n    x = c.f(k * i, k);'),
 'm21_cls_propop': cls('    x = c.f(n + 1);', ' int n;'),
}
for name, txt in C.items():
    d = os.path.join(HERE, '..', 'cases', 'M', name); os.makedirs(d, exist_ok=True)
    open(os.path.join(d, 'dut.sv'), 'w').write(txt)
MOD = (LAW + 'class C; function int f(int k, int j = 0); return k + j; endfunction endclass\n'
       'module top (input int a, output int y);\n  C c; C arr[4];\n'
       '  function automatic int g(int n, int i);\n    return %s;\n  endfunction\n  assign y = g(a, 1);\nendmodule\n')
for name, e in {'m02_mod_binop': 'c.f(n, i + 1) + arr[i].f(n, n)', 'm16_mod_nestedop': 'c.f((n + i) * 2)'}.items():
    d = os.path.join(HERE, '..', 'cases', 'M', name); os.makedirs(d, exist_ok=True)
    open(os.path.join(d, 'dut.sv'), 'w').write(MOD % e)
IF = (LAW + 'interface ifc; function automatic int f(int k); return k; endfunction endinterface\n'
      'module top (input int a, output int y);\n  ifc bus();\n  function automatic int g(int i);\n    return bus.f(i + 1);\n  endfunction\n'
      '  assign y = g(a);\nendmodule\n')
d = os.path.join(HERE, '..', 'cases', 'M', 'm14_iface'); os.makedirs(d, exist_ok=True)
open(os.path.join(d, 'dut.sv'), 'w').write(IF)
PK = (LAW + 'package pk;\n' + CC + 'class D; C c;\n  function int g(int n, int i); return c.f(n, i + 1); endfunction\nendclass\nendpackage\nmodule top; endmodule\n')
d = os.path.join(HERE, '..', 'cases', 'M', 'm15_pkg'); os.makedirs(d, exist_ok=True)
open(os.path.join(d, 'dut.sv'), 'w').write(PK)
print('written')
