#!/usr/bin/env python3
"""r10vrgg4/gen_vgrid3.py — the REACH wave: every OTHER declaration site that
carries a size-form `[P]` dimension with P an OVERRIDDEN parameter.

The law claims it reaches ONLY the elaborated interface_array PORT.  These cells
put the same overridden-parameter size dimension on every other kind of range
site there is, so a leak shows up as a BASE/PAT byte difference.
"""
import os
HERE = os.path.dirname(os.path.abspath(__file__))
IFC = """interface ifc4 #(parameter int W = 8) ();
  logic [W-1:0] a;
  modport host (output a);
endinterface
"""
C = {}
def cell(n, b): C[n] = IFC + b

# w1 nets/vars/arrays of every kind, inside an OVERRIDDEN module
cell('w1_var_kinds', """module leaf_w1 #(parameter int R = 4)(input logic clk);
  logic          v_logic [R];
  wire           n_wire  [R];
  bit  [7:0]     v_bit   [R];
  int            v_int   [R];
  logic [R-1:0]  v_packed;
  typedef logic [R-1:0] td_t;
  td_t           v_td;
  localparam int LP [R] = '{default:0};
  logic          v_2d [R][R];
  struct packed { logic [R-1:0] f; } v_st;
endmodule
module top;
  logic clk;
  leaf_w1 #(.R(6)) u (clk);
endmodule
""")
# w2 module/interface INSTANCE arrays sized by the overridden param
cell('w2_inst_arrays', """module sub_w2 (input logic clk); endmodule
module leaf_w2 #(parameter int R = 4)(input logic clk);
  sub_w2 u_arr [R] (clk);
  ifc4   i_arr [R] ();
endmodule
module top;
  logic clk;
  leaf_w2 #(.R(6)) u (clk);
endmodule
""")
# w3 a MODULE array PORT (not interface) sized by the overridden param
cell('w3_module_array_port', """module leaf_w3 #(parameter int R = 4)(
  input logic clk, input logic [7:0] p [R]);
endmodule
module top;
  logic clk;
  logic [7:0] sig [6];
  leaf_w3 #(.R(6)) u (clk, sig);
endmodule
""")
# w4 the interface-array port inside a PROGRAM and inside an INTERFACE
cell('w4_program_port', """program prog_w4 #(parameter int R = 4)(ifc4.host arr[R]);
endprogram
module top;
  ifc4 arr[6]();
  prog_w4 #(.R(6)) u (arr);
endmodule
""")
cell('w5_iface_port', """interface mid_w5 #(parameter int R = 4)(ifc4.host arr[R]);
endinterface
module top;
  ifc4 arr[6]();
  mid_w5 #(.R(6)) u (arr);
endmodule
""")
# w6 a function/task with an array arg sized by the overridden param
cell('w6_subroutine_arg', """module leaf_w6 #(parameter int R = 4)(input logic clk);
  function automatic int f(input int a [R]); return a[0]; endfunction
  task automatic t(input int b [R]); endtask
endmodule
module top;
  logic clk;
  leaf_w6 #(.R(6)) u (clk);
endmodule
""")
# w7 a GENERATE-nested non-iface site
cell('w7_gen_nested', """module leaf_w7 #(parameter int R = 4)(input logic clk);
  if (1) begin : g
    logic v [R];
    logic [R-1:0] p;
  end
  for (genvar i = 0; i < 2; i++) begin : h
    logic w [R];
  end
endmodule
module top;
  logic clk;
  leaf_w7 #(.R(6)) u (clk);
endmodule
""")
# w8 a typedef / param range declared in a package but overridden per-instance
cell('w8_iface_param_dim', """interface ifc_w8 #(parameter int R = 4) ();
  logic a [R];
  logic [R-1:0] b;
  modport host (output a);
endinterface
module top;
  ifc_w8 #(.R(6)) i ();
endmodule
""")
for n, t in C.items():
    d = os.path.join(HERE, n); os.makedirs(d, exist_ok=True)
    open(os.path.join(d, 'dut.sv'), 'w').write(t)
print('CELLS=%d' % len(C))
