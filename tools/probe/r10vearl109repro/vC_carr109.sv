// r10v109 adversarial arm C -- CARRIERS AND VALUES the pass's g6 does not
// reach: a NON-overridden top-level `parameter int` (g3 only has an
// OVERRIDDEN one and localparams), a NAMED TYPEDEF whose own packed bound is
// built RECURSIVELY under the same makeTypespec call (the flag stays set for
// the whole nested build), an UNPACKED dimension whose bound is the law's
// shape, a NEGATIVE bound value, a LARGE (word-boundary) value, and a child
// instance inside a GENERATE-IF and a GENERATE-FOR block.
// MEASUREMENT ONLY.  LHS is ALWAYS golden.
module vC_leaf109 (input logic a_i, output logic b_o);
  assign b_o = ~a_i;
endmodule

module vC_kid109 #(
  parameter  int TopP109 = 6,               // NON-overridden `parameter int`
  localparam int NegP109 = 2 - 3,           // -1
  localparam int BigP109 = 300,             // multi-digit, plain-decimal init
  localparam int UpkP109 = 4                // carries an UNPACKED dim
) (
  input  logic                 clk_i,
  input  logic [TopP109:0]     c_top_i,     // parameter int, not overridden
  input  logic [0:NegP109]     c_neg_i,     // NEGATIVE bound value
  input  logic [BigP109:0]     c_big_i,     // word-boundary value
  input  logic [TopP109:0][3:0] c_2d_i,     // 2-D packed, law's bound OUTER
  input  logic [3:0][TopP109:0] c_2e_i,     // 2-D packed, law's bound INNER
  input  logic [TopP109:0]     c_upk_i [UpkP109],  // packed + UNPACKED
  output logic [TopP109:0]     c_out_o,     // OUTPUT carrier
  inout  wire  [TopP109:0]     c_io,        // INOUT carrier
  input  var logic [TopP109:0] c_var_i,     // VAR port
  output logic                 q_o
);
  logic lb109;
  vC_leaf109 u_leaf (.a_i(clk_i), .b_o(lb109));
  assign c_out_o = c_top_i;
  assign q_o = clk_i & lb109 & c_top_i[0] & c_neg_i[0] & c_big_i[0] &
               c_2d_i[0][0] & c_2e_i[0][0] & c_upk_i[0][0] & c_var_i[0];
endmodule

module vC_td109 #(
  parameter int TdP109 = 6
) (
  input  logic clk_i,
  output logic q_o
);
  typedef logic [TdP109:0] vc_word_t;
  vC_tdkid109 u_td (.clk_i(clk_i), .d_i('0), .q_o(q_o));
endmodule

module vC_tdkid109 #(
  parameter int TkP109 = 6
) (
  input  logic clk_i,
  input  vc_pkg109::word_t d_i,   // NAMED TYPEDEF from a package
  output logic q_o
);
  logic lb109;
  vC_leaf109 u_leaf2 (.a_i(clk_i), .b_o(lb109));
  assign q_o = clk_i & lb109 & d_i[0] & (TkP109 != 0);
endmodule

package vc_pkg109;
  parameter int WP109 = 6;
  typedef logic [WP109:0] word_t;
endpackage

module vC_gen109 #(parameter int GP109 = 1) (
  input logic clk_i, input logic [31:0] w_i, output logic q_o
);
  logic qa, qb0, qb1;
  if (GP109 > 0) begin : g_if
    vC_kid109 u_gi (.clk_i(clk_i), .c_top_i(w_i), .c_neg_i(w_i), .c_big_i(w_i),
                    .c_2d_i(w_i), .c_2e_i(w_i), .c_upk_i('{default:'0}),
                    .c_out_o(), .c_io(), .c_var_i(w_i), .q_o(qa));
  end
  for (genvar gi = 0; gi < 2; gi++) begin : g_for
    vC_kid109 u_gf (.clk_i(clk_i), .c_top_i(w_i), .c_neg_i(w_i), .c_big_i(w_i),
                    .c_2d_i(w_i), .c_2e_i(w_i), .c_upk_i('{default:'0}),
                    .c_out_o(), .c_io(), .c_var_i(w_i), .q_o());
  end
  assign q_o = qa;
endmodule

module vC_carr109;
  logic clk, q1, q2, q3;
  logic [31:0] w;
  vC_kid109 u_c (.clk_i(clk), .c_top_i(w), .c_neg_i(w), .c_big_i(w),
                 .c_2d_i(w), .c_2e_i(w), .c_upk_i('{default:'0}),
                 .c_out_o(), .c_io(), .c_var_i(w), .q_o(q1));
  vC_td109  u_t (.clk_i(clk), .q_o(q2));
  vC_gen109 u_g (.clk_i(clk), .w_i(w), .q_o(q3));
endmodule
