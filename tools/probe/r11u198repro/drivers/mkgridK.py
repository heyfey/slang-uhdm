#!/usr/bin/env python3
"""r11u198: writes cases/K (the grid of § genCaCastRhsRefUnnamed198): the operand references of a CAST that is the
whole right-hand side of an elaborated generate-scope continuous assignment (`assign y[i] = 3'(s);`, arb_idx_cast's
`idx_t'(sel)`), by scope (module, for / if generate), target, cast kind (size, type, type parameter, signed) and
the cast's position (whole Rhs, nested in an operation), and a process control.  usage: mkgridK.py"""
import os
HERE = os.path.dirname(os.path.abspath(__file__))
LAW = '// § genCaCastRhsRefUnnamed198\n'
HDR = ('module top #(parameter type T = logic [2:0], parameter int N = 2) (input logic s, input logic [2:0] q [2], input logic [3:0] b, '
       'output logic [2:0] y [2], output logic [2:0] z, output logic [3:0] y4, output logic [2:0] yt [2]);\n'
       '  typedef logic [2:0] t3;\n')
FOR = '  for (genvar i = 0; i < 2; i++) begin : g\n    %s\n  end\n'
FOR1 = '  for (genvar i = 0; i < 1; i++) begin : g\n    %s\n  end\n'
IF = '  if (N > 1) begin : g\n    %s\n  end\n'
C = {
 'k01_module': '  assign y4 = 4\'(b);\n',
 'k02_for_sel': FOR % 'assign y[i] = 3\'(s);',
 'k03_for1_whole': FOR1 % 'assign z = 3\'(s);',
 'k04_if_sel': IF % 'assign y[0] = 3\'(s);',
 'k05_for_castop': FOR % 'assign y[i] = 3\'(s + q[i]);',
 'k06_for_tparam': FOR % 'assign yt[i] = T\'(s);',
 'k07_for_nested': FOR % 'assign y[i] = 3\'(s) + q[i];',
 'k08_for_signed': FOR % 'assign y[i] = signed\'(q[i]);',
 'k09_for_proc': FOR % 'always_comb y[i] = 3\'(s);',
 'k10_for_typedef': FOR % 'assign y[i] = t3\'(s);',
 'k11_if_whole': IF % 'assign z = 3\'(s);',
 'k13_module_sel': '  assign y[0] = 3\'(s);\n',
 'k14_for_genlocal': FOR % 'logic [2:0] w; assign w = 3\'(s); assign y[i] = w;',
 'k16_for_concat': FOR % 'assign y[i] = 3\'({s, q[i][0], s});',
 'k17_for_bitsel': FOR % 'assign y[i] = 3\'(q[i]);',
 'k18_for_tern': FOR % 'assign y[i] = 3\'(s ? q[i][1] : q[i][0]);',
 'k19_for_castcast': FOR % 'assign y[i] = 3\'(2\'(s));',
 'k20_for_unary': FOR % 'assign y[i] = 3\'(~q[i]);',
 'k21_for_psel': FOR % 'assign y[i] = 3\'(q[i][1:0]);',
 'k22_for_genlocal_namesake': '  logic [2:0] zn;\n  assign zn = 3\'d0;\n' + FOR % 'logic [2:0] zn; assign zn = 3\'(s); assign y[i] = zn;',
 'k12_for_ifnested_tparam': '  for (genvar i = 0; i < 2; i++) begin : g\n    if (i == 1) begin : h\n      assign yt[i] = T\'(q[i]);\n    end\n  end\n',
}
for name, body in C.items():
    d = os.path.join(HERE, '..', 'cases', 'K', name); os.makedirs(d, exist_ok=True)
    open(os.path.join(d, 'dut.sv'), 'w').write(LAW + HDR + body + 'endmodule\n')
print('written')
