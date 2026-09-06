// r10v109 adversarial arm D -- TYPE SPELLINGS that canonicalise to `int` but
// are not the `int` KEYWORD, an ENUM-typed parameter, and an INTERFACE port
// carrying the law's own written bound.  The gate refuses only ImplicitType;
// a NAMED TYPEDEF of `int` passes both the canonical-type test and the
// type-syntax test.
// MEASUREMENT ONLY.  LHS is ALWAYS golden.
package vd_pkg109;
  typedef int vd_int_t;
  typedef enum int { VD_A = 5, VD_B = 6 } vd_e_t;
endpackage

interface vd_if109 #(
  parameter  int IfMax109 = 64,
  localparam int IfP109   = $clog2(IfMax109)
) ();
  logic [IfP109:0] d;
  modport mp (input d);
endinterface

module vd_leaf109 (input logic a_i, output logic b_o);
  assign b_o = ~a_i;
endmodule

module vd_kid109
  import vd_pkg109::*;
#(
  parameter  int  MaxE109 = 64,
  localparam vd_int_t TdP109 = 6,          // NAMED TYPEDEF of `int`
  localparam vd_e_t   EnP109 = VD_B,       // ENUM whose base is `int`
  localparam int      LclP109 = $clog2(MaxE109)
) (
  input  logic                clk_i,
  input  logic [TdP109:0]     d_td_i,      // typedef-of-int bound
  input  logic [EnP109:0]     d_en_i,      // enum-typed bound
  input  logic [LclP109:0]    d_lcl_i,     // plain `int` control
  vd_if109.mp                 d_if,        // INTERFACE port
  output logic                q_o
);
  logic lb109;
  vd_leaf109 u_leaf (.a_i(clk_i), .b_o(lb109));
  assign q_o = clk_i & lb109 & d_td_i[0] & d_en_i[0] & d_lcl_i[0] & d_if.d[0];
endmodule

module vD_alias109;
  logic clk, q;
  logic [31:0] w;
  vd_if109 u_if ();
  vd_kid109 u_d (.clk_i(clk), .d_td_i(w), .d_en_i(w), .d_lcl_i(w),
                 .d_if(u_if.mp), .q_o(q));
endmodule
