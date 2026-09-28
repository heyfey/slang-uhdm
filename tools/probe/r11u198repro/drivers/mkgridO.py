#!/usr/bin/env python3
"""r11u198: writes cases/O (the grid of § genCaUnclonedFoldOwner198): a typed wildcard-imported package parameter
folded inside a top-level generate scope's continuous assignment, by generate kind x target shape x the fold's
immediate parent (concat element, replication count, system-call argument, operation operand).  Each case names its
law in its first line.  usage: mkgridO.py (writes next to this script: ../cases/O/<case>/dut.sv)"""
import os
HERE = os.path.dirname(os.path.abspath(__file__))
LAW = '// § genCaUnclonedFoldOwner198\n'
PK = 'package pk; parameter int unsigned W = $clog2(4); parameter int S = 2; parameter W2 = 2; endpackage\n'
HDR = ('module top import pk::*; #(parameter int unsigned N = 2) (input logic [N-1:0] c, input logic s, '
       'input logic [2:0] q [N], output logic [2:0] y [N], output logic [2:0] z, output logic [7:0] m);\n')
FOR = 'for (genvar i = 0; i < N; i++) begin : g\n    %s\n  end'
FOR1 = 'for (genvar i = 0; i < 1; i++) begin : g\n    %s\n  end'
IF = 'if (N > 1) begin : g\n    %s\n  end'
C = {
 'o01_for_sel_catelem': FOR % 'assign y[i] = {s, W};',
 'o02_if_sel_sysarg': IF % 'assign y[0] = q[0] + $clog2(W);',
 'o03_if_whole_catelem': IF % 'assign z = {s, W};',
 'o04_for1_whole_sysarg': FOR1 % 'assign z = q[0] + $clog2(W);',
 'o05_for_genlocal_catelem': FOR % 'wire [2:0] w; assign w = {s, W}; assign y[i] = w;',
 'o06_if_implicit_catelem': IF % 'assign imp = {s, W};',
 'o08_case_sel_repl': 'case (N)\n    2: begin : gc\n      assign y[0] = {{W{1\'b0}}, s};\n    end\n    default: begin : gd\n      assign y[0] = 3\'d0;\n    end\n  endcase',
 'o09_nested_sel_catelem': 'for (genvar i = 0; i < N; i++) begin : g\n    if (1) begin : h\n      assign y[i] = {s, W};\n    end\n  end',
 'o11_if_sel_sysdirect': IF % 'assign y[0] = $clog2(W);',
 'o12_if_whole_sysdirect': IF % 'assign z = $clog2(W);',
 'o13_for_sel_catinplus': FOR % 'assign y[i] = q[i] + {s, W};',
 'o14_for_sel_plusincat': FOR % 'assign y[i] = {s, q[i][1:0] + W};',
 'o15_for_sel_unaryincat': FOR % 'assign y[i] = {s, ~W};',
 'o16_for_sel_castincat': FOR % 'assign y[i] = {s, 2\'(W)};',
 'o17_for_sel_uu': FOR % 'assign y[i] = c[i] ? \'1 : {s, W};',
 'o18_if_whole_cast': IF % 'assign z = 3\'({s, W});',
 'o19_if_lhsconcat': IF % 'assign {z, m} = {s, W, 8\'h0};',
 'o20_for_sel_sysincat': FOR % 'assign y[i] = {s, $clog2(W)};',
 'o21_module_sel_catelem': 'assign y[0] = {s, W};',
 'o23_for_sel_ternarm_sys': FOR % 'assign y[i] = c[i] ? $clog2(W) : q[i];',
 'o24_for_sel_signedincat': FOR % 'assign y[i] = {s, $signed(W)};',
 'o26_for1_whole_repl': FOR1 % 'assign z = {{W{1\'b0}}, s};',
 'o27_if_sel_int': IF % 'assign y[0] = {s, S};',
 'o28_for_sel_macro': FOR % 'assign y[i] = `CW;',
 'o29_for_sel_replbits': FOR % 'assign y[i] = {{W{s}}, c[i]};',
 'o31_else_sel_catelem': 'if (N == 1) begin : a\n    assign y[0] = 3\'d0;\n  end else begin : b\n    assign y[0] = {s, W};\n  end',
 'o32_if_sel_untyped': IF % 'assign y[0] = {s, W2};',
 'o33_if_whole_sysarg': IF % 'assign z = q[0] + $clog2(W);',
 'o34_for_sel_countones': FOR % 'assign y[i] = q[i] + $countones(W);',
 'o35_if_sel_ternarm': IF % 'assign y[0] = c[0] ? W : q[0];',
 'o36_if_sel_shift': IF % 'assign y[0] = q[0] << W;',
 'o37_if_whole_ternsys': IF % 'assign z = c[0] ? $clog2(W) : q[0];',
 'o38_for_genlocal_sysarg': FOR % 'wire [2:0] w; assign w = q[i] + $clog2(W); assign y[i] = w;',
 'o39_if_whole_replonly': IF % 'assign z = {W{s}};',
 'o40_if_sel_catcat': IF % 'assign y[0] = {{s, W}};',
 'o41_for_sel_castwhole': FOR % 'assign y[i] = 3\'({s, W});',
 'o42_for_sel_negincat': FOR % 'assign y[i] = {s, -W};',
 'o43_for_sel_redincat': FOR % 'assign y[i] = {s, &W, s};',
 'o44_if_sel_notincat': IF % 'assign y[0] = {s, !W, s};',
 'o45_for_sel_eqincat': FOR % 'assign y[i] = {s, W == 2, s};',
 'o46_for_sel_ternconds': FOR % 'assign y[i] = W ? q[i] : 3\'d0;',
 'o47_for_sel_sysnested': FOR % 'assign y[i] = {s, $clog2($clog2(W))};',
 'o48_for_sel_concatrepl2': FOR % 'assign y[i] = {2{s, W}};',
 'o49_case_sel_sysarg': 'case (N)\n    2: begin : gc\n      assign y[0] = q[0] + $clog2(W);\n    end\n    default: begin : gd\n      assign y[0] = 3\'d0;\n    end\n  endcase',
 'o50_if_genlocal_ternsys': IF % 'wire [2:0] w; assign w = c[0] ? $clog2(W) : q[0]; assign y[0] = w;',
 'o52_for_genlocal_namesake': 'logic [2:0] zn;\n  assign zn = 3\'d0;\n  ' + FOR % 'logic [2:0] zn; assign zn = {s, W}; assign y[i] = zn;',
 'o51_for_sel_patwhole': FOR % 'assign y[i] = \'{s, W[0], s};',
}
for name, body in C.items():
    d = os.path.join(HERE, '..', 'cases', 'O', name); os.makedirs(d, exist_ok=True)
    pre = '`define CW {s, W}\n' if 'macro' in name else ''
    txt = LAW + pre + PK + HDR + '  ' + body + '\nendmodule\n'
    open(os.path.join(d, 'dut.sv'), 'w').write(txt)
# child-instance depths
MID = ('module mid import pk::*; #(parameter int unsigned N = 2) (input logic s, input logic [2:0] q [N], '
       'output logic [2:0] y [N]);\n  for (genvar i = 0; i < N; i++) begin : g\n    assign y[i] = {s, $clog2(W)};\n  end\nendmodule\n')
TOPD2 = ('module top (input logic s, input logic [2:0] q [2], output logic [2:0] y [2], output logic [2:0] y2 [2]);\n'
         '  mid u (.s(s), .q(q), .y(y));\n  mid u1 (.s(s), .q(q), .y(y2));\nendmodule\n')
MID2 = ('module mid2 (input logic s, input logic [2:0] q [2], output logic [2:0] y [2]);\n'
        '  mid u2 (.s(s), .q(q), .y(y));\nendmodule\n')
TOPD3 = ('module top (input logic s, input logic [2:0] q [2], output logic [2:0] y [2]);\n'
         '  mid2 u1 (.s(s), .q(q), .y(y));\nendmodule\n')
for name, txt in {'o10_depth2_twoinst': PK + MID + TOPD2, 'o22_depth3': PK + MID + MID2 + TOPD3}.items():
    d = os.path.join(HERE, '..', 'cases', 'O', name); os.makedirs(d, exist_ok=True)
    open(os.path.join(d, 'dut.sv'), 'w').write(LAW + txt)
# member target
d = os.path.join(HERE, '..', 'cases', 'O', 'o07_if_member_catelem'); os.makedirs(d, exist_ok=True)
open(os.path.join(d, 'dut.sv'), 'w').write(LAW + PK + 'typedef struct packed {logic [2:0] f; logic [2:0] h;} st_t;\n'
    'module top import pk::*; #(parameter int unsigned N = 2) (input logic s, output st_t o);\n'
    '  if (N > 1) begin : g\n    assign o.f = {s, W};\n  end\n  assign o.h = 3\'d0;\nendmodule\n')
print('written')
