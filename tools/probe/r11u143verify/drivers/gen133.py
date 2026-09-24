#!/usr/bin/env python3
"""gen133.py: writes the fresh cases of pass 133's five laws and r11u141's two refinements under cases/."""
import os
B=os.path.join(os.path.dirname(os.path.abspath(__file__)),'..','cases')
C={}
L='impPaLhsDisjointClone133'
C['p133_lhsclone/lc01_gen_for_inst']=f'''// § {L}
// case lc01: header-import module with a parameter port list, instantiated in a generate for
package gp; parameter int GW = 3; parameter int GD = 2; endpackage
module leaf import gp::*; #(parameter int W = GW, parameter int D = GD) (input logic [W-1:0] a, output logic [W-1:0] o);
  assign o = a + D;
endmodule
module top(input logic [5:0] a, output logic [5:0] o);
  for (genvar g = 0; g < 2; g++) begin : gl
    leaf u(.a(a[g*3 +: 3]), .o(o[g*3 +: 3]));
  end
endmodule
'''
C['p133_lhsclone/lc02_pkg_explicit_pkg']=f'''// § {L}
// case lc02: a package explicitly importing one parameter of another package and deriving its own
package base_p; parameter int BW = 5; parameter int BX = 1; endpackage
package der_p;
  import base_p::BW;
  localparam int DW = BW * 2;
endpackage
module top(output logic [9:0] o);
  assign o = der_p::DW;
endmodule
'''
C['p133_lhsclone/lc03_two_pkgs_hdr']=f'''// § {L}
// case lc03: two packages wildcard-imported in the module header, both read by the parameter port list
package pa_p; parameter int AW = 4; endpackage
package pb_p; parameter logic [3:0] BV = 4'h9; endpackage
module sub import pa_p::*, pb_p::*; #(parameter int W = AW, parameter logic [3:0] V = BV) (output logic [W-1:0] o);
  assign o = V;
endmodule
module top(output logic [3:0] o); sub u(.o(o)); endmodule
'''
C['p133_lhsclone/lc04_macro_pkg_param']=f'''// § {L}
// case lc04: the package parameter comes from a macro; header import; the instance overrides the other parameter
`define PW_VAL (3 + 3)
package mp; parameter int PW = `PW_VAL; endpackage
module sub import mp::*; #(parameter int W = PW, parameter int K = 1) (output logic [W-1:0] o);
  assign o = K;
endmodule
module top(output logic [5:0] o); sub #(.K(2)) u(.o(o)); endmodule
'''
L='hpBaseSelMidMemberBare133'
PK='''package p;
  typedef struct packed { logic valid; logic [3:0] sat; } e_t;
  typedef struct packed { e_t f; logic [1:0] tag; } w_t;
endpackage
'''
C['p133_hpmid/hm01_partsel_leaf']=f'''// § {L}
// case hm01: middle member, a part-select leaf
{PK}module dut(input logic [1:0] r, input logic [15:0] flat, output logic [1:0] o);
  p::w_t [1:0] tbl;
  assign tbl = flat;
  assign o = tbl[r].f.sat[2:1];
endmodule
'''
C['p133_hpmid/hm02_2d_base']=f'''// § {L}
// case hm02: a two-dimensional base select before the middle member
{PK}module dut(input logic r, input logic c, input logic [31:0] flat, output logic o);
  p::w_t [1:0][1:0] tbl;
  assign tbl = flat;
  assign o = tbl[r][c].f.valid;
endmodule
'''
C['p133_hpmid/hm03_ff_if_cond']=f'''// § {L}
// case hm03: middle member path as an if condition in always_ff
{PK}module dut(input logic clk, input logic [1:0] r, input logic [15:0] flat, output logic o);
  p::w_t [1:0] tbl;
  assign tbl = flat;
  always_ff @(posedge clk) begin
    if (tbl[r].f.valid) o <= 1'b1;
    else o <= 1'b0;
  end
endmodule
'''
C['p133_hpmid/hm04_port_actual']=f'''// § {L}
// case hm04: middle member path as a port connection actual
{PK}module sink(input logic i, output logic o); assign o = ~i; endmodule
module dut(input logic [1:0] r, input logic [15:0] flat, output logic o);
  p::w_t [1:0] tbl;
  assign tbl = flat;
  sink s(.i(tbl[r].f.valid), .o(o));
endmodule
'''
C['p133_hpmid/hm05_ips_leaf']=f'''// § {L}
// case hm05: middle member, an indexed part-select leaf
{PK}module dut(input logic [1:0] r, input logic [15:0] flat, output logic [1:0] o);
  p::w_t [1:0] tbl;
  assign tbl = flat;
  assign o = tbl[r].f.sat[1 +: 2];
endmodule
'''
L='hpTrailSelIdxNamesByPath133'
PK2='''package p;
  typedef struct packed { logic valid; logic [3:0] sat; } e_t;
endpackage
'''
C['p133_trailidx/tx01_idx_ternary']=f'''// § {L}
// case tx01: trailing select index is a ternary
{PK2}module dut(input logic [1:0] r, input logic c, input logic [1:0] i, input logic [1:0] j, input logic [9:0] flat, output logic o);
  p::e_t [1:0] tbl;
  assign tbl = flat;
  assign o = tbl[r].sat[c ? i : j];
endmodule
'''
C['p133_trailidx/tx02_idx_funccall']=f'''// § {L}
// case tx02: trailing select index is a function call over a port
{PK2}module dut(input logic [1:0] r, input logic [1:0] i, input logic [9:0] flat, output logic o);
  function automatic logic [1:0] inc(input logic [1:0] x); return x + 1; endfunction
  p::e_t [1:0] tbl;
  assign tbl = flat;
  assign o = tbl[r].sat[inc(i)];
endmodule
'''
C['p133_trailidx/tx03_idx_int_var']=f'''// § {L}
// case tx03: trailing select index is a module-level int variable, in always_comb
{PK2}module dut(input logic [1:0] r, input logic [9:0] flat, output logic o);
  p::e_t [1:0] tbl;
  int k;
  assign tbl = flat;
  assign k = 2;
  always_comb o = tbl[r].sat[k];
endmodule
'''
C['p133_trailidx/tx04_idx_sysfunc']=f'''// § {L}
// case tx04: trailing select index under a system function
{PK2}module dut(input logic [1:0] r, input logic [1:0] i, input logic [9:0] flat, output logic o);
  p::e_t [1:0] tbl;
  assign tbl = flat;
  assign o = tbl[r].sat[$unsigned(i)];
endmodule
'''
C['p133_trailidx/tx05_idx_sub_op']=f'''// § {L}
// case tx05: trailing select index is a subtraction of two refs, in a function body
{PK2}module dut(input logic [1:0] r, input logic [1:0] i, input logic [1:0] j, input logic [9:0] flat, output logic o);
  p::e_t [1:0] tbl;
  assign tbl = flat;
  function automatic logic pick(input logic [1:0] a, input logic [1:0] b);
    return tbl[r].sat[a - b];
  endfunction
  assign o = pick(i, j);
endmodule
'''
L='elabPatQualRefQualSpan133'
C['p133_patqual/pq01_positional_pattern']=f'''// § {L}
// case pq01: package pattern parameter written positionally, qualified default
package cp;
  typedef struct packed {{ int unsigned W; bit E; }} c_t;
  localparam c_t Base = '{{16, 1'b1}};
endpackage
module dut #(parameter cp::c_t C = cp::Base) (output logic [31:0] o);
  assign o = C.W;
endmodule
'''
C['p133_patqual/pq02_nested_struct']=f'''// § {L}
// case pq02: nested-struct pattern parameter, qualified default, sub-module
package np;
  typedef struct packed {{ int unsigned A; int unsigned B; }} in_t;
  typedef struct packed {{ in_t I; bit F; }} out_t;
  localparam out_t Def = '{{I: '{{A: 3, B: 5}}, F: 1'b0}};
endpackage
module sub #(parameter np::out_t P = np::Def) (output logic [31:0] o);
  assign o = P.I.B;
endmodule
module top(output logic [31:0] o); sub u(.o(o)); endmodule
'''
C['p133_patqual/pq03_two_params']=f'''// § {L}
// case pq03: two pattern parameters in one list, both qualified defaults
package tp;
  typedef struct packed {{ int unsigned X; int unsigned Y; }} s_t;
  localparam s_t One = '{{X: 1, Y: 2}};
  localparam s_t Two = '{{X: 3, Y: 4}};
endpackage
module dut #(parameter tp::s_t A = tp::One, parameter tp::s_t B = tp::Two) (output logic [31:0] o);
  assign o = A.X + B.Y;
endmodule
'''
C['p133_patqual/pq04_genif_inst']=f'''// § {L}
// case pq04: the sub-module with a qualified pattern default instantiated under a generate if
package gq;
  typedef struct packed {{ int unsigned N; bit M; }} g_t;
  localparam g_t G0 = '{{N: 7, M: 1'b1}};
endpackage
module sub #(parameter gq::g_t P = gq::G0) (output logic [31:0] o);
  assign o = P.N;
endmodule
module top #(parameter bit EN = 1'b1) (output logic [31:0] o);
  if (EN) begin : g
    sub u(.o(o));
  end else begin : h
    assign o = '0;
  end
endmodule
'''
L='unknownParamOperandFile133'
C['p133_unkfile/uk01_mod']=f'''// § {L}
// case uk01: an X parameter under a modulo operation of an int localparam
module top(output int o);
   parameter P = 'x;
   parameter Q = 5;
   localparam int C = P % Q;
   assign o = C;
endmodule
'''
C['p133_unkfile/uk02_and_z']=f'''// § {L}
// case uk02: a Z parameter under a bitwise and of a logic vector localparam
module top(output logic [7:0] o);
   parameter P = 'z;
   parameter Q = 8'hF0;
   localparam logic [7:0] C = P & Q;
   assign o = C;
endmodule
'''
C['p133_unkfile/uk03_sub_override']=f'''// § {L}
// case uk03: the X operand arrives as an instance override
module sub #(parameter P = 1, parameter Q = 2) (output int o);
   localparam int C = P + Q;
   assign o = C;
endmodule
module top(output int o); sub #(.P('x)) u(.o(o)); endmodule
'''
C['p133_unkfile/uk04_shift']=f'''// § {L}
// case uk04: an X parameter as the left operand of a shift
module top(output int o);
   parameter P = 'x;
   localparam int C = P << 2;
   assign o = C;
endmodule
'''
# r11u141 refinements
L='includeInactiveTabNotText141v'
BODY='module helper(input logic x, output logic z);\n  assign z = x;\nendmodule\n'
TOP='module top(input logic [3:0] a, output logic [3:0] y);\n  assign y = a + 1;\nendmodule\n'
C['p141_inctabact/it01_ifndef_defined']=({'defs.svh':'`ifndef PRE\n\t`define W 4\n`else\n`define W 2\n`endif\n','body.svh':BODY},
  f'// § {L}\n// case it01: `ifndef of a macro defined before the include; TAB-led define in the skipped branch\n`define PRE\n`include "defs.svh"\n`include "body.svh"\n'+TOP)
C['p141_inctabact/it02_inner_skip_outer_tab_after']=({'defs.svh':'`ifndef NOPE\n`ifdef NOPE2\n\t`define V 1\n`endif\n\t`define W 3\n`endif\n','body.svh':BODY},
  f'// § {L}\n// case it02: an inner skipped branch with a TAB line, then a TAB-led define in the ACTIVE outer branch\n`include "defs.svh"\n`include "body.svh"\n'+TOP)
C['p141_inctabact/it03_elsif_after_taken']=({'defs.svh':'`ifdef ON\n`define W 1\n`elsif OTHER\n\t`define W 2\n`else\n\t`define W 3\n`endif\n','body.svh':BODY},
  f'// § {L}\n// case it03: the first branch taken; TAB-led lines in the skipped elsif and else branches\n`define ON\n`include "defs.svh"\n`include "body.svh"\n'+TOP)
C['p141_inctabact/it04_skip_tab_undef_after']=({'defs.svh':'`ifdef NOPE\n\t`undef ON\n`endif\n`undef ON\n','body.svh':BODY},
  f'// § {L}\n// case it04: a TAB-led undef in a skipped branch, a plain undef after it\n`define ON\n`include "defs.svh"\n`include "body.svh"\n'+TOP)
L='ipsQualBaseRangeSpan141v'
PK3='package p;\n  parameter logic [15:0] A = 16\'h1234;\n  parameter int K = 2;\nendpackage\n'
C['p141_ipsqual/iq01_sub_two_inst']=f'''// § {L}
// case iq01: qualified base in a sub-module parameter default; one instance default, one overridden
{PK3}module sub #(parameter logic [3:0] P = p::A[8 +: 4]) (output logic [3:0] o);
  assign o = P;
endmodule
module top(output logic [3:0] o1, output logic [3:0] o2);
  sub u1(.o(o1));
  sub #(.P(4'h7)) u2(.o(o2));
endmodule
'''
C['p141_ipsqual/iq02_op_start']=f'''// § {L}
// case iq02: qualified base with an operation start index, body localparam
{PK3}module top(output logic [3:0] o);
  localparam logic [3:0] L = p::A[2*2 +: 4];
  assign o = L;
endmodule
'''
C['p141_ipsqual/iq03_genblock_lp']=f'''// § {L}
// case iq03: qualified base in a generate-block localparam
{PK3}module top(output logic [7:0] o);
  if (1) begin : g
    localparam logic [7:0] L = p::A[0 +: 8];
    assign o = L;
  end
endmodule
'''
C['p141_ipsqual/iq04_contassign_ctl']=f'''// § {L}
// case iq04: control, qualified base in a continuous assignment (not a constant context)
{PK3}module top(output logic [3:0] o);
  assign o = p::A[4 +: 4];
endmodule
'''
for k,v in C.items():
    d=os.path.join(B,k); os.makedirs(d,exist_ok=True)
    if isinstance(v,tuple):
        extra,txt=v
        for fn,t in extra.items(): open(os.path.join(d,fn),'w').write(t)
    else: txt=v
    open(os.path.join(d,'dut.sv'),'w').write(txt)
print(len(C),'cases')
