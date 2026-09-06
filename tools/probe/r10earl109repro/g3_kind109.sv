// r10earl109 arm g3 -- THE WRITTEN-KIND MATRIX on an ELAB PORT, in a
// STALE-SCOPE module (the parent instantiates a leaf, so `currentScope` at the
// port-typespec build is the LEAF's body).
// Every port below is the SAME carrier and the SAME scope; only the way the
// LEFT bound is WRITTEN changes.
// MEASUREMENT ONLY.  LHS is ALWAYS golden.
package g3_pkg109;
  parameter int  PKI109 = 7;      // package, int
  parameter      PKU109 = 7;      // package, untyped
endpackage

module g3_leaf109 (input logic a_i, output logic b_o);
  assign b_o = ~a_i;
endmodule

module g3_kid109
  import g3_pkg109::*;
#(
  parameter  int   MaxB109 = 64,
  parameter  int   OVI109  = 5,    // OVERRIDDEN by the parent below
  localparam int   IntP109 = $clog2(MaxB109),   // int,   32-bit, 6
  localparam logic [7:0] LogP109 = 8'd6,        // logic [7:0], 8-bit, 6
  localparam byte  BytP109 = 8'sd6,             // byte,  8-bit, 6
  localparam       UntP109 = 6,                 // untyped literal
  localparam       UntC109 = $clog2(MaxB109),   // untyped, COMPUTED
  localparam shortint ShoP109 = 16'sd6,         // shortint, 16-bit
  localparam int unsigned IusP109 = 6,          // the `int` KEYWORD, UNSIGNED
  localparam int   IblP109 = 8'd6,              // `int`, BASED-literal init
  localparam int signed IsgP109 = 6             // `int signed`, spelled out
) (
  input  logic                 clk_i,
  input  logic [IntP109:0]     k_int_i,      // bare INT param
  input  logic [LogP109:0]     k_log_i,      // bare LOGIC[7:0] param
  input  logic [BytP109:0]     k_byt_i,      // bare BYTE param
  input  logic [UntP109:0]     k_unt_i,      // bare UNTYPED literal param
  input  logic [UntC109:0]     k_untc_i,     // bare UNTYPED computed param
  input  logic [ShoP109:0]     k_sho_i,      // bare SHORTINT param
  input  logic [PKI109:0]      k_pki_i,      // bare PACKAGE int param
  input  logic [PKU109:0]      k_pku_i,      // bare PACKAGE untyped param
  input  logic [OVI109:0]      k_ovi_i,      // bare OVERRIDDEN int param
  input  logic [IntP109-1:0]   k_sub_i,      // EXPRESSION  <param>-<lit>
  input  logic [IntP109+1:0]   k_add_i,      // EXPRESSION  <param>+<lit>
  input  logic [6:0]           k_lit_i,      // LITERAL
  input  logic [$clog2(MaxB109):0] k_clog_i, // SYSTEM CALL
  input  logic [0:IntP109]     k_rev_i,      // bare INT param on the RIGHT
  input  logic [IusP109:0]     k_ius_i,      // bare `int unsigned` param
  input  logic [IblP109:0]     k_ibl_i,      // bare `int` param, 8'd6 init
  input  logic [IsgP109:0]     k_isg_i,      // bare `int signed` param
  output logic                 q_o
);
  logic lb109;
  g3_leaf109 u_leaf (.a_i(clk_i), .b_o(lb109));
  assign q_o = clk_i & lb109 & k_int_i[0] & k_log_i[0] & k_byt_i[0] &
               k_unt_i[0] & k_untc_i[0] & k_sho_i[0] & k_pki_i[0] &
               k_pku_i[0] & k_ovi_i[0] & k_sub_i[0] & k_add_i[0] &
               k_lit_i[0] & k_clog_i[0] & k_rev_i[0] & k_ius_i[0] &
               k_ibl_i[0] & k_isg_i[0];
endmodule

module g3_kind109;
  logic clk, q;
  logic [31:0] w;
  g3_kid109 #(.OVI109(9)) u_k (
    .clk_i(clk), .k_int_i(w), .k_log_i(w), .k_byt_i(w), .k_unt_i(w),
    .k_untc_i(w), .k_sho_i(w), .k_pki_i(w), .k_pku_i(w), .k_ovi_i(w),
    .k_sub_i(w), .k_add_i(w), .k_lit_i(w), .k_clog_i(w), .k_rev_i(w),
    .k_ius_i(w), .k_ibl_i(w), .k_isg_i(w), .q_o(q));
endmodule
