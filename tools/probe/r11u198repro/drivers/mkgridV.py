#!/usr/bin/env python3
"""r11u198: writes cases/V (the grid of § callArgVarSelStamp198): a multi-index select (var_select) as a user
function's actual, by context (module / generate continuous assignment, two-level generate, process, nested call,
operation operand, net declaration, port connection, package function, parameter root).  usage: mkgridV.py"""
import os
HERE = os.path.dirname(os.path.abspath(__file__))
LAW = '// § callArgVarSelStamp198\n'
PK = 'package pk; function automatic logic pf(logic x); return x; endfunction endpackage\n'
HDR = ('module top (input logic [3:0] a [2][2], input logic [1:0][3:0] p, input logic [3:0] b, input logic [1:0][1:0] w [2],'
       ' output logic y, output logic [3:0] y4, output logic [1:0] z [2], output logic [1:0][1:0] zz);\n'
       '  function automatic logic f(logic x); return x; endfunction\n'
       '  function automatic logic [3:0] g(logic [3:0] x); return x; endfunction\n'
       '  function automatic logic f2(logic u, logic v); return u & v; endfunction\n')
C = {
 'v01_mod_unpacked2d': 'assign y4 = g(a[0][1]);',
 'v02_mod_packed2d': 'assign y = f(p[1][2]);',
 'v03_genfor_genvar': 'for (genvar i = 0; i < 2; i++) begin : gl\n    assign z[i] = {1\'b0, f(p[i][1])};\n  end',
 'v04_gen2_ibex': 'for (genvar c = 0; c < 2; c++) begin : gc\n    for (genvar r = 0; r < 2; r++) begin : gr\n      logic [1:0][1:0] bp;\n      assign bp[c][r] = w[c][r][0];\n      assign zz[c][r] = f2(p[c][r], bp[c][r]);\n    end\n  end',
 'v05_mod_inop': 'assign y = b[0] & f(p[1][2]);',
 'v06_proc': 'always_comb y = f(p[1][2]);',
 'v07_nested': 'assign y = f(f(p[1][2]));',
 'v09_param_root': 'localparam logic [1:0][3:0] P = 8\'h5a;\n  assign y = f(P[1][2]);',
 'v11_second_arg': 'assign y = f2(b[0], p[1][2]);',
 'v13_nda': 'wire wn = f(p[1][2]);\n  assign y = wn;',
 'v15_pkgfunc': 'assign y = pk::pf(p[1][2]);',
 'v17_genif': 'if (1) begin : gi\n    assign y = f(p[1][2]);\n  end',
 'v18_genfor_whole': 'for (genvar i = 0; i < 1; i++) begin : gl\n    assign y = f(p[i][1]);\n  end',
 'v19_mod_var3': 'assign y = f(a[1][0][3]);',
 'v20_genfor_sel': 'for (genvar i = 0; i < 2; i++) begin : gl\n    assign z[i][0] = f(w[i][1][0]);\n  end',
 'v22_mod_inop_bitsel': 'assign y = b[0] & f(b[1]);',
 'v23_mod_inop_ref': 'assign y4 = b & g(b);',
 'v24_mod_inop_psel': 'assign y4 = b & g(p[1][3:0]);',
 'v25_genfor_inop': 'for (genvar i = 0; i < 2; i++) begin : gl\n    assign z[i] = {1\'b0, b[0] & f(p[i][1])};\n  end',
 'v26_mod_tern': 'assign y = b[0] ? f(p[1][2]) : 1\'b0;',
 'v27_mod_notop': 'assign y = ~f(p[1][2]);',
 'v28_mod_psel_whole': 'assign y4 = g(p[1][3:0]);',
 'v29_mod_varidx': 'assign y = f(p[b[0]][b[3:2]]);',
 'v30_genfor_exprIdx': 'for (genvar i = 0; i < 2; i++) begin : gl\n    assign z[i] = {1\'b0, f(p[i+0][2*i])};\n  end',
 'v31_mod_ips_whole': 'assign y4 = g({2\'b0, p[1][1+:2]});',
 'v32_mod_ipsarg': 'assign y = f2(p[0][1], a[1][0][2]);',
 'v33_genfor_inop_psel': 'for (genvar i = 0; i < 2; i++) begin : gl\n    assign z[i] = {1\'b0, b[0] & f(p[i][1:1])};\n  end',
 'v34_mod_inop_ips': 'assign y4 = b & g(p[1][0+:4]);',
 'v21_gen2_localarr': 'for (genvar c = 0; c < 2; c++) begin : gc\n    for (genvar r = 0; r < 2; r++) begin : gr\n      assign zz[c][r] = f(w[c][r][1]);\n    end\n  end',
}
for name, body in C.items():
    d = os.path.join(HERE, '..', 'cases', 'V', name); os.makedirs(d, exist_ok=True)
    open(os.path.join(d, 'dut.sv'), 'w').write(LAW + PK + HDR + '  ' + body + '\nendmodule\n')
SUB = 'module sub (input logic x, output logic o); assign o = x; endmodule\n'
d = os.path.join(HERE, '..', 'cases', 'V', 'v14_portconn'); os.makedirs(d, exist_ok=True)
open(os.path.join(d, 'dut.sv'), 'w').write(LAW + PK + SUB + HDR + '  sub u (.x(f(p[1][2])), .o(y));\nendmodule\n')
MID = ('module mid (input logic [1:0][3:0] p, output logic y);\n  function automatic logic f(logic x); return x; endfunction\n'
       '  for (genvar i = 0; i < 1; i++) begin : gl\n    assign y = f(p[i][1]);\n  end\n  assign yy = f(p[1][2]);\nendmodule\n')
d = os.path.join(HERE, '..', 'cases', 'V', 'v16_depth2'); os.makedirs(d, exist_ok=True)
open(os.path.join(d, 'dut.sv'), 'w').write(LAW + MID + 'module top (input logic [1:0][3:0] p, output logic y);\n  mid u (.p(p), .y(y));\nendmodule\n')
print('written')
