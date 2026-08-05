// vh.sv — pass 11.  vg said golden keeps a module DEF-view import copy TAGGED
// even with a parameter port list; BlackBePipeInt's bp_be_pipe_int block 1 is
// FLAT with both bp_common_pkg listings TAGGED.  vh varies the two remaining
// candidates that separate them:
//   * package `parameter` vs `localparam` spelling of the struct param
//   * a module PARAMETER-PORT-LIST localparam that MEMBER-SELECTS the imported
//     struct param (bp_be_pipe_int does `localparam bp_proc_param_s
//     proc_param_lp = all_cfgs_gp[bp_params_p]` then `proc_param_lp.cc_x_dim`)
package vhp;
  typedef struct packed {           // 96 bits — WIDE, so the package keeps tagged
    logic [31:0] a;
    logic [31:0] b;
    logic [31:0] c;
  } w_t;
  parameter  w_t P1 = '{a: 32'h1, b: 32'h0, c: 32'h0};
  localparam w_t P2 = '{a: 32'h2, b: 32'h0, c: 32'h0};
endpackage

// A: parameter port list, nothing selects the imported params
module vha import vhp::*; #(
  parameter int Aw = 4
) (
  input  logic clk_i,
  output vhp::w_t o1, o2
);
  logic [Aw-1:0] unused;
  assign o1 = P1;
  assign o2 = P2;
endmodule

// B: parameter port list whose OWN localparams member-select both imports
module vhb import vhp::*; #(
  parameter int Aw = 4,
  localparam int X1 = P1.a,
  localparam int X2 = P2.a
) (
  input  logic clk_i,
  output vhp::w_t o1, o2
);
  logic [Aw-1:0] unused;
  assign o1 = P1;
  assign o2 = P2;
endmodule

module vhtop;
  logic clk;
  vhp::w_t a1, a2, b1, b2;
  vha u_a (.clk_i(clk), .o1(a1), .o2(a2));
  vhb u_b (.clk_i(clk), .o1(b1), .o2(b2));
endmodule
