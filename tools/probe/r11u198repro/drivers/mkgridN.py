#!/usr/bin/env python3
"""r11u198: writes cases/N (the grid of § genHopFoldSelName198): a parameter read one scope hop above an elaborated
generate-scope continuous assignment (a parent generate block's localparam, the instance's parameter from a top-level
generate block), folded in a select position: bare bit-select index, index operation operand, part-select bound,
indexed part-select base / width, var_select index, Lhs index, process, distance 0 / 2 controls.  usage: mkgridN.py"""
import os
HERE = os.path.dirname(os.path.abspath(__file__))
LAW = '// § genHopFoldSelName198\n'
HDR = ('module top #(parameter int N = 2, parameter int unsigned P = 3) (input logic [15:0] a, input logic s, '
       'input logic [3:0] m [8], input logic [31:0] w, output logic [3:0] y, output logic [1:0] y2 [4], output logic [7:0] z);\n')
def nest(body, lp='localparam int unsigned L = i*2;'):
    return ('  for (genvar i = 0; i < 4; i++) begin : g\n    %s\n    if (N > 1) begin : h\n      %s\n    end\n  end\n' % (lp, body))
C = {
 'n01_bitidx_bare': nest('assign y[i] = a[L];'),
 'n02_bitidx_op': nest('assign y[i] = a[L+1];'),
 'n03_psel_bound': nest('assign y2[i] = a[L+1:L];'),
 'n04_ips_base': nest('assign y2[i] = a[L+:2];'),
 'n05_ips_width': nest('assign y2[i] = a[i+:L2];', 'localparam int unsigned L2 = 2;'),
 'n06_varsel_idx': nest('assign y[i] = m[L][1];'),
 'n07_bitidx_incat': nest('assign y2[i] = {s, a[L]};'),
 'n08_proc': nest('always_comb y[i] = a[L];'),
 'n09_dist2_ctl': '  for (genvar i = 0; i < 4; i++) begin : g\n    localparam int unsigned L = i*2;\n    if (N > 1) begin : h\n      if (1) begin : k\n        assign y[i] = a[L];\n      end\n    end\n  end\n',
 'n10_dist0_ctl': '  for (genvar i = 0; i < 4; i++) begin : g\n    localparam int unsigned L = i*2;\n    assign y[i] = a[L];\n  end\n',
 'n11_ifif_bare': '  if (N > 1) begin : g\n    localparam int unsigned L = 3;\n    if (1) begin : h\n      assign y[0] = a[L];\n      assign y[1] = a[L+1];\n    end\n  end\n',
 'n12_int_bitidx': nest('assign y[i] = a[L];', 'localparam int L = i*2;'),
 'n13_varsel_op': nest('assign y[i] = m[L+1][1];'),
 'n14_lhs_idx': nest('assign z[L] = s;'),
 'n15_psel_bound_op': nest('assign y2[i] = w[L+19:L+18];'),
 'n16_modparam_topgen': '  if (N > 1) begin : g\n    assign y[0] = a[P];\n    assign y[1] = a[P+1];\n    assign z[3:0] = w[31:P+28];\n  end\n',
}
for name, body in C.items():
    d = os.path.join(HERE, '..', 'cases', 'N', name); os.makedirs(d, exist_ok=True)
    open(os.path.join(d, 'dut.sv'), 'w').write(LAW + HDR + body + 'endmodule\n')
CH = ('module ch #(parameter int unsigned P = 10, parameter int N = 2) (input logic [15:0] a, input logic [31:0] w, output logic [3:0] y, output logic [3:0] z);\n'
      '  if (N > 1) begin : g\n    assign y[0] = a[P];\n    assign y[1] = a[P+1];\n    assign z = w[31:P+18];\n  end\nendmodule\n')
TOP = ('module top (input logic [15:0] a, input logic [31:0] w, output logic [3:0] y, output logic [3:0] z);\n'
       '  ch #(.P(5)) u (.a(a), .w(w), .y(y), .z(z));\nendmodule\n')
d = os.path.join(HERE, '..', 'cases', 'N', 'n17_child_modparam'); os.makedirs(d, exist_ok=True)
open(os.path.join(d, 'dut.sv'), 'w').write('// § ovrParamBoundOpSelName198\n' + CH + TOP)
print('written')
