#!/usr/bin/env python3
"""r11u121 grid generator: casts to a TYPE PARAMETER x contexts x target types (grid/t),
written as one dut.sv per arm."""
import os, sys
root = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'grid')
H = ('module dut #(parameter int unsigned W = 2, parameter type idx_t = {d}) '
     '(input logic a, b, s, input logic [3:0] v, output logic [7:0] y, output logic [7:0] n [2]);\n')
arms = {}
def arm(name, body, d='logic [W-1:0]', pre='', post=''):
    arms['t/' + name] = pre + H.format(d=d) + body + 'endmodule\n' + post
# contexts, default target
arm('t01_mod_direct',  '  assign y = idx_t\'(a);\n  assign n[0] = 0; assign n[1] = 0;\n')
arm('t02_mod_tern',    '  assign y = s ? idx_t\'(a) : idx_t\'(b);\n  assign n[0] = 0; assign n[1] = 0;\n')
arm('t03_mod_op',      '  assign y = idx_t\'(a) + 2\'d1;\n  assign n[0] = 0; assign n[1] = 0;\n')
arm('t04_mod_comb',    '  always_comb y = idx_t\'(a);\n  assign n[0] = 0; assign n[1] = 0;\n')
arm('t05_mod_combtern','  always_comb y = s ? idx_t\'(a) : idx_t\'(b);\n  assign n[0] = 0; assign n[1] = 0;\n')
arm('t06_for_direct',  '  for (genvar k = 0; k < 2; k++) begin : g\n    assign n[k] = idx_t\'(v[k]);\n  end\n  assign y = 0;\n')
arm('t07_for_tern',    '  for (genvar k = 0; k < 2; k++) begin : g\n    assign n[k] = s ? idx_t\'(a) : idx_t\'(b);\n  end\n  assign y = 0;\n')
arm('t08_for_op',      '  for (genvar k = 0; k < 2; k++) begin : g\n    assign n[k] = idx_t\'(v[k]) + 2\'d1;\n  end\n  assign y = 0;\n')
arm('t09_for_concat',  '  for (genvar k = 0; k < 2; k++) begin : g\n    assign n[k] = {idx_t\'(v[k]), 1\'b0};\n  end\n  assign y = 0;\n')
arm('t10_for_ternconcat', '  for (genvar k = 0; k < 2; k++) begin : g\n    assign n[k] = s ? idx_t\'({1\'b1, v[k]}) : idx_t\'({1\'b0, v[0]});\n  end\n  assign y = 0;\n')
arm('t11_for_comb',    '  for (genvar k = 0; k < 2; k++) begin : g\n    always_comb n[k] = idx_t\'(v[k]);\n  end\n  assign y = 0;\n')
arm('t12_for_combtern','  for (genvar k = 0; k < 2; k++) begin : g\n    always_comb n[k] = s ? idx_t\'(a) : idx_t\'(b);\n  end\n  assign y = 0;\n')
arm('t13_ifinfor_tern','  for (genvar k = 0; k < 2; k++) begin : g\n    if (k == 0) begin : gi\n      assign n[k] = idx_t\'(v[k]);\n    end else begin : ge\n      assign n[k] = s ? idx_t\'({1\'b1, v[k]}) : idx_t\'({1\'b0, v[0]});\n    end\n  end\n  assign y = 0;\n')
arm('t14_if_tern',     '  if (W == 2) begin : g\n    assign y = s ? idx_t\'(a) : idx_t\'(b);\n  end\n  assign n[0] = 0; assign n[1] = 0;\n')
arm('t15_if_comb',     '  if (W == 2) begin : g\n    always_comb y = idx_t\'(a);\n  end\n  assign n[0] = 0; assign n[1] = 0;\n')
arm('t16_forfor_tern', '  for (genvar k = 0; k < 2; k++) begin : g\n    for (genvar j = 0; j < 1; j++) begin : h\n      assign n[k] = s ? idx_t\'(a) : idx_t\'(b);\n    end\n  end\n  assign y = 0;\n')
arm('t17_for_opnest',  '  for (genvar k = 0; k < 2; k++) begin : g\n    assign n[k] = ~idx_t\'(v[k]);\n  end\n  assign y = 0;\n')
arm('t18_for_ternnest','  for (genvar k = 0; k < 2; k++) begin : g\n    assign n[k] = s ? (b ? idx_t\'(a) : idx_t\'(b)) : 8\'d0;\n  end\n  assign y = 0;\n')
arm('t19_for_ternop',  '  for (genvar k = 0; k < 2; k++) begin : g\n    assign n[k] = s ? idx_t\'(a) + 2\'d1 : idx_t\'(b);\n  end\n  assign y = 0;\n')
arm('t20_for_condonly','  for (genvar k = 0; k < 2; k++) begin : g\n    assign n[k] = idx_t\'(a) ? v : 4\'d0;\n  end\n  assign y = 0;\n')
# target types (ternary in for, the arb shape, plus module-scope direct)
for tag, d in (('w1', 'logic [0:0]'), ('w4', 'logic [3:0]'), ('wW4', 'logic [W+1:0]'),
               ('int', 'int'), ('bit3', 'bit [2:0]'), ('byte', 'byte'), ('sgn', 'logic signed [W-1:0]'),
               ('pk', 'logic [1:0][1:0]')):
    arm('t2x_for_tern_' + tag, '  for (genvar k = 0; k < 2; k++) begin : g\n    assign n[k] = s ? idx_t\'(a) : idx_t\'(b);\n  end\n  assign y = 0;\n', d=d)
    arm('t3x_mod_direct_' + tag, '  assign y = idx_t\'(a);\n  assign n[0] = 0; assign n[1] = 0;\n', d=d)
# typedef default, body localparam type, override through instantiation
arm('t40_tddefault_for_tern', '  for (genvar k = 0; k < 2; k++) begin : g\n    assign n[k] = s ? idx_t\'(a) : idx_t\'(b);\n  end\n  assign y = 0;\n',
    d='w_t', pre='typedef logic [2:0] w_t;\n')
arm('t41_bodylp_for_tern', '  localparam type lt_t = logic [2:0];\n  for (genvar k = 0; k < 2; k++) begin : g\n    assign n[k] = s ? lt_t\'(a) : lt_t\'(b);\n  end\n  assign y = 0;\n')
arm('t42_bodylp_mod_direct', '  localparam type lt_t = logic [2:0];\n  assign y = lt_t\'(a);\n  assign n[0] = 0; assign n[1] = 0;\n')
arms['t/t43_override_for_tern'] = (
    'module sub #(parameter type idx_t = logic [1:0]) (input logic a, b, s, output logic [7:0] n [2]);\n'
    '  for (genvar k = 0; k < 2; k++) begin : g\n    assign n[k] = s ? idx_t\'(a) : idx_t\'(b);\n  end\nendmodule\n'
    'module dut (input logic a, b, s, output logic [7:0] n [2], output logic [7:0] m [2]);\n'
    '  sub #(.idx_t(logic [3:0])) u (.a(a), .b(b), .s(s), .n(n));\n'
    '  sub u2 (.a(a), .b(b), .s(s), .n(m));\nendmodule\n')
arms['t/t44_override_mod_direct'] = (
    'module sub #(parameter type idx_t = logic [1:0]) (input logic a, output logic [7:0] y);\n'
    '  assign y = idx_t\'(a);\nendmodule\n'
    'module dut (input logic a, output logic [7:0] y, output logic [7:0] z);\n'
    '  sub #(.idx_t(logic [3:0])) u (.a(a), .y(y));\n  sub u2 (.a(a), .y(z));\nendmodule\n')
arms['t/t45_arb'] = open(os.path.join(os.environ['UHDM2RTLIL_TESTS'], 'arb_idx_cast', 'dut.sv')).read()
for k, v in arms.items():
    d = os.path.join(root, k)
    os.makedirs(d, exist_ok=True)
    with open(os.path.join(d, 'dut.sv'), 'w') as f:
        f.write(v)
print(len(arms), 'arms')
# grid/s: a member select on a qualified / imported / local struct parameter (R3)
PK = ('package mask_pkg;\n  typedef struct packed { logic [7:0] f; logic [7:0] g; } s_t;\n'
      '  localparam s_t CFG = \'{f: 8\'h3C, g: 8\'hC3};\nendpackage\n')
def sarm(name, body, hdr='module top (input logic s, input logic [2:0] k, output logic [7:0] o);\n', pre=PK):
    arms['s/' + name] = pre + hdr + body + 'endmodule\n'
sarm('s01_q_ps_tern',   '  assign o = s ? mask_pkg::CFG.f[3:0] : \'0;\n')
sarm('s02_q_ps_direct', '  assign o = mask_pkg::CFG.f[3:0];\n')
sarm('s03_q_bs_direct', '  assign o = mask_pkg::CFG.f[2];\n')
sarm('s04_q_nosel',     '  assign o = mask_pkg::CFG.f;\n')
sarm('s05_q_ps_g',      '  assign o = mask_pkg::CFG.g[7:4];\n')
sarm('s06_q_ips',       '  assign o = mask_pkg::CFG.f[k +: 2];\n')
sarm('s07_q_ps_comb',   '  always_comb o = mask_pkg::CFG.f[3:0];\n')
sarm('s08_imp_ps',      '  import mask_pkg::*;\n  assign o = CFG.f[3:0];\n')
sarm('s09_loc_ps', '  typedef struct packed { logic [7:0] f; logic [7:0] g; } l_t;\n  localparam l_t LCFG = \'{f: 8\'h3C, g: 8\'hC3};\n  assign o = LCFG.f[3:0];\n', pre='')
sarm('s10_q_ps_op',     '  assign o = mask_pkg::CFG.f[3:0] + 8\'d1;\n')
sarm('s11_q_ps_gen',    '  for (genvar i = 0; i < 1; i++) begin : g\n    assign o = mask_pkg::CFG.f[3:0];\n  end\n')
sarm('s12_q_bs_var',    '  assign o = mask_pkg::CFG.f[k];\n')
for k, v in list(arms.items()):
    if not k.startswith('s/'): continue
    d = os.path.join(root, k); os.makedirs(d, exist_ok=True)
    open(os.path.join(d, 'dut.sv'), 'w').write(v)
# grid/v: a qualified package VARIABLE read (R5)
PV = 'package mask_pkg;\n  logic [31:0] v;\n  logic [7:0] u [4];\nendpackage\n'
def varm(name, body):
    arms['v/' + name] = PV + 'module top (input logic s, input logic [1:0] k, output logic [7:0] o);\n' + body + 'endmodule\n'
varm('v01_ps_tern',   '  assign o = s ? mask_pkg::v[7:0] : \'0;\n')
varm('v02_ps_direct', '  assign o = mask_pkg::v[7:0];\n')
varm('v03_bare_direct', '  assign o = mask_pkg::v;\n')
varm('v04_bare_tern', '  assign o = s ? mask_pkg::v : \'0;\n')
varm('v05_bs_direct', '  assign o = mask_pkg::v[3];\n')
varm('v06_ips',       '  assign o = mask_pkg::v[k*8 +: 8];\n')
varm('v07_ps_comb',   '  always_comb o = mask_pkg::v[7:0];\n')
varm('v08_unp_elem',  '  assign o = mask_pkg::u[k];\n')
varm('v09_ps_op',     '  assign o = mask_pkg::v[7:0] + 8\'d1;\n')
varm('v10_imp_ps',    '  import mask_pkg::*;\n  assign o = s ? v[7:0] : \'0;\n')
for k, v in list(arms.items()):
    if not k.startswith('v/'): continue
    d = os.path.join(root, k); os.makedirs(d, exist_ok=True)
    open(os.path.join(d, 'dut.sv'), 'w').write(v)
arms['v/v11_longname'] = 'package p;\n  logic [31:0] longer_name;\nendpackage\nmodule top (output logic [7:0] o, output logic [7:0] q);\n  assign o = p::longer_name[7:0];\n  assign q = p :: longer_name;\nendmodule\n'
for k in ('v/v11_longname',):
    d = os.path.join(root, k); os.makedirs(d, exist_ok=True)
    open(os.path.join(d, 'dut.sv'), 'w').write(arms[k])
# grid/q: a folded QUALIFIED package parameter read: its constant's span (R6b) and ts ref (R6c)
PQ = 'package mask_pkg;\n  localparam logic [63:0] MASK = 64\'hDEADBEEF_12345678;\n  localparam int unsigned W = 16;\n  parameter int P = 5;\nendpackage\n'
def qarm(name, body):
    arms['q/' + name] = PQ + 'module top (input logic s, input logic [3:0] k, output logic [15:0] o);\n' + body + 'endmodule\n'
qarm('q01_direct',     '  assign o = mask_pkg::W;\n')
qarm('q02_op',         '  assign o = mask_pkg::W - 1;\n')
qarm('q03_selbound',   '  assign o = mask_pkg::MASK[mask_pkg::W-1:0];\n')
qarm('q04_selbound_bare', '  assign o = mask_pkg::MASK[mask_pkg::W:0];\n')
qarm('q05_tern',       '  assign o = s ? mask_pkg::W : 16\'d0;\n')
qarm('q06_idx',        '  assign o = k[mask_pkg::P - 4];\n')
qarm('q07_comb',       '  always_comb o = mask_pkg::W + 16\'d1;\n')
qarm('q08_decl',       '  logic [mask_pkg::W-1:0] w;\n  assign w = k;\n  assign o = w;\n')
qarm('q09_param',      '  localparam int L = mask_pkg::W - 2;\n  assign o = L;\n')
qarm('q10_tern_selbound', '  assign o = s ? mask_pkg::MASK[mask_pkg::W-1:0] : \'0;\n')
for k, v in list(arms.items()):
    if not k.startswith('q/'): continue
    d = os.path.join(root, k); os.makedirs(d, exist_ok=True)
    open(os.path.join(d, 'dut.sv'), 'w').write(v)
arms['s/s13_q_2d_member'] = ('package q2;\n  typedef logic [1:0] ut_e;\n  typedef ut_e [0:2] row_t;\n'
  '  typedef struct packed { logic [3:0] pad; row_t [0:1] UnitTypes; logic [1:0] cfg; } impl_t;\n'
  '  localparam impl_t IMPL = \'{pad: 4\'h9, UnitTypes: {2\'b01, 2\'b01, 2\'b01, 2\'b10, 2\'b10, 2\'b10}, cfg: 2\'b11};\nendpackage\n'
  'module top (input logic k, output logic [5:0] o, output logic [1:0] p);\n  assign o = q2::IMPL.UnitTypes[1];\n  assign p = q2::IMPL.UnitTypes[0][2];\nendmodule\n')
arms['s/s14_q_unpacked'] = ('package up;\n  typedef struct { logic [7:0] a [2]; int b; } u_t;\n  localparam u_t U = \'{a: \'{8\'h12, 8\'h34}, b: 7};\nendpackage\n'
  'module top (output logic [7:0] o, output logic [3:0] q);\n  assign o = up::U.a[1];\n  assign q = up::U.a[0][3:0];\nendmodule\n')
arms['s/s15_q_nested'] = ('package nq;\n  typedef struct packed { logic [7:0] x; } in_t;\n  typedef struct packed { in_t i; logic [3:0] y; } out_t;\n  localparam out_t N = \'{i: \'{x: 8\'hA5}, y: 4\'h3};\nendpackage\n'
  'module top (output logic [7:0] o);\n  assign o = nq::N.i.x[6:1];\nendmodule\n')
for k in ('s/s13_q_2d_member', 's/s14_q_unpacked', 's/s15_q_nested'):
    d = os.path.join(root, k); os.makedirs(d, exist_ok=True)
    open(os.path.join(d, 'dut.sv'), 'w').write(arms[k])
