// r10v109 adversarial arm A -- INT-ENCODED int parameters as an ELAB PORT's
// bare packed bound.  The pass's own g3 exercises only $clog2- and
// literal-initialised `int` params; `isIntEncoded` is TRUE for a `/`, a `%`
// and a signed `**`, and the pristine arms that could stamp a ts ref all
// required `!intEnc`.  The new arm does not read intEnc at all.
// Both a STALE-scope module (child instantiated) and a HOME module (no child).
// MEASUREMENT ONLY.  LHS is ALWAYS golden.
module vA_leaf109 (input logic a_i, output logic b_o);
  assign b_o = ~a_i;
endmodule

module vA_stale109 #(
  parameter  int MaxA109 = 64,
  localparam int DivP109 = MaxA109 / 8,      // isIntEncoded: Divide  -> TRUE
  localparam int ModP109 = MaxA109 % 58,     // isIntEncoded: Mod     -> TRUE
  localparam int PowP109 = 2 ** 3,           // isIntEncoded: signed Power -> TRUE
  localparam int SubP109 = MaxA109 - 58,     // plain arithmetic -> FALSE
  localparam int MulP109 = 3 * 2             // plain arithmetic -> FALSE
) (
  input  logic                clk_i,
  input  logic [DivP109:0]    a_div_i,
  input  logic [ModP109:0]    a_mod_i,
  input  logic [PowP109:0]    a_pow_i,
  input  logic [SubP109:0]    a_sub_i,
  input  logic [MulP109:0]    a_mul_i,
  output logic                q_o
);
  logic lb109;
  vA_leaf109 u_leaf (.a_i(clk_i), .b_o(lb109));
  assign q_o = clk_i & lb109 & a_div_i[0] & a_mod_i[0] & a_pow_i[0] &
               a_sub_i[0] & a_mul_i[0];
endmodule

module vA_home109 #(
  parameter  int MaxB109 = 64,
  localparam int DivQ109 = MaxB109 / 8,
  localparam int ModQ109 = MaxB109 % 58,
  localparam int PowQ109 = 2 ** 3,
  localparam int SubQ109 = MaxB109 - 58,
  localparam int MulQ109 = 3 * 2
) (
  input  logic                clk_i,
  input  logic [DivQ109:0]    b_div_i,
  input  logic [ModQ109:0]    b_mod_i,
  input  logic [PowQ109:0]    b_pow_i,
  input  logic [SubQ109:0]    b_sub_i,
  input  logic [MulQ109:0]    b_mul_i,
  output logic                q_o
);
  assign q_o = clk_i & b_div_i[0] & b_mod_i[0] & b_pow_i[0] &
               b_sub_i[0] & b_mul_i[0];
endmodule

module vA_enc109;
  logic clk, q1, q2;
  logic [31:0] w;
  vA_stale109 u_s (.clk_i(clk), .a_div_i(w), .a_mod_i(w), .a_pow_i(w),
                   .a_sub_i(w), .a_mul_i(w), .q_o(q1));
  vA_home109  u_h (.clk_i(clk), .b_div_i(w), .b_mod_i(w), .b_pow_i(w),
                   .b_sub_i(w), .b_mul_i(w), .q_o(q2));
endmodule
