#!/usr/bin/env python3
"""r11u198: writes cases/L (the grid of § lvIdxCallArgIsRead198): a call ARGUMENT inside a plain lvalue's index
(`arr[fx(s.f[k])] <= ...`), by assignment kind (nonblocking, blocking, compound, continuous), the argument's shape
(member select, plain select, index operation, nested call, system call, a method call), the lvalue's shape (plain,
member path, part select) and context (process, generate scope, task).  usage: mkgridL.py"""
import os
HERE = os.path.dirname(os.path.abspath(__file__))
LAW = '// § lvIdxCallArgIsRead198\n'
HDR = ('module top (input logic clk, input logic [1:0] k, input logic [2:0] q [4], output logic [7:0] o, output logic [7:0] o2);\n'
       '  typedef struct packed { logic [3:0][2:0] f; } s_t;\n  s_t s, t;\n  logic [7:0] arr, arr2;\n'
       '  function automatic logic [2:0] fx(input logic [2:0] x); return x; endfunction\n')
FF = '  always @(posedge clk) begin\n    %s\n  end\n'
TAIL = '  assign o = arr;\n  assign o2 = arr2;\nendmodule\n'
C = {
 'l01_nb_member': FF % 'arr[fx(s.f[k])] <= 1\'b1;',
 'l02_blk_member': '  always_comb begin\n    arr = 8\'h0;\n    arr[fx(s.f[k])] = 1\'b1;\n  end\n',
 'l03_compound': FF % 'arr[fx(s.f[k])] |= 1\'b1;',
 'l04_nestedcall': FF % 'arr[fx(fx(s.f[k]))] <= 1\'b1;',
 'l05_syscall': FF % 'arr[$clog2(s.f[k])] <= 1\'b1;',
 'l06_plainsel': FF % 'arr[fx(q[k])] <= 1\'b1;',
 'l08_idxop': FF % 'arr[fx(s.f[k+1])] <= 1\'b1;',
 'l09_incdec_ctl': FF % 'arr[fx(s.f[k])]++;',
 'l11_ipsbase': FF % 'arr[fx(s.f[k]) +: 2] <= 2\'b0;',
 'l12_memberlhs': FF % 't.f[fx(s.f[k])] <= 3\'b0;',
 'l13_genscope': '  for (genvar g = 0; g < 1; g++) begin : gg\n    always @(posedge clk) arr[fx(s.f[k])] <= 1\'b1;\n  end\n',
 'l14_task': '  task automatic tk();\n    arr[fx(s.f[k])] = 1\'b1;\n  endtask\n  always @(posedge clk) tk();\n',
 'l15_callop_arg': FF % 'arr[fx(s.f[k] + 3\'d1)] <= 1\'b1;',
 'l16_two_args': FF % 'arr[fx(s.f[k]) + fx(s.f[0])] <= 1\'b1;',
 'l21_stream_lvalue': '  always_comb begin\n    arr = 8\'h0;\n    {<<{arr[fx(s.f[k]) +: 2]}} = 2\'b01;\n  end\n',
 'l22_two_level': FF % 't.f[fx(s.f[fx(s.f[k])])] <= 3\'b0;',
 'l23_rvalue_idx_ctl': FF % 'arr[0] <= arr[fx(s.f[k])];',
 'l18_callidx_nocallarg': FF % 'arr[fx(3\'(k))] <= 1\'b1;',
}
for name, body in C.items():
    d = os.path.join(HERE, '..', 'cases', 'L', name); os.makedirs(d, exist_ok=True)
    open(os.path.join(d, 'dut.sv'), 'w').write(LAW + HDR + body + TAIL)
print('written')
