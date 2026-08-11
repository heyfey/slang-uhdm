// r10oth5 arm 2 -- THE OTHER SPELLINGS of § elabCaReusesParamConst.
// "A LAW THAT ONLY EVER SAW ONE SPELLING HAS AN UNMEASURED HALF."
//
// p1_paramref.v established that golden's ELAB cont_assign REUSES the
// parameter's own param_assign Rhs constant object for a HEX-encoded value and
// MINTS A FRESH ONE for a UINT-encoded value.  Surelog's mechanism is
// CompileHelper::adjustSize (CompileHelper.cpp:3949): its `vpiUIntConst` arm
// (and the `orig_size == -1` and signed-binary arms) call
// `clone_tree` under `uniquify`, every other arm MUTATES `c` IN PLACE.  These
// cells cross the encodings, the target widths and the SCOPES.

// ---- q1: BINARY-encoded value, target NARROWER.  adjustSize's logic_typespec
// arm truncates value+decompile+size IN PLACE (no clone) -- so this predicts
// REUSE of a constant whose digits golden has rewritten.
module q1_bin_narrow;
parameter [19:0] Q = 20'b10101010101010101010;
wire [3:0] t;
assign t = Q;
endmodule

// ---- q2: BINARY, target WIDER.  The truncating arm is `if (orig_size > size)`
// only, so it should NOT run -- predicting reuse with the size UNCHANGED (20),
// unlike the HEX cells where the final `else` sets size to the target.
module q2_bin_wide;
parameter [19:0] Q = 20'b10101010101010101010;
wire [31:0] t;
assign t = Q;
endmodule

// ---- q3: DECIMAL-BASED sized literal.  adjustSize's outer guard is
// `if (c->VpiConstType() != vpiDecConst)`, so a dec-const keeps orig_size.
module q3_dec;
parameter [19:0] Q = 20'd5;
wire [3:0] t;
assign t = Q;
endmodule

// ---- q4: SIGNED binary with the MSB set: the `constantIsSigned` arm, which
// DOES clone under uniquify -- predicting a FRESH constant.
module q4_signed_bin;
parameter signed [3:0] Q = 4'sb1000;
wire [7:0] t;
assign t = Q;
endmodule

// ---- q5: UNBASED-UNSIZED fill.  orig_size == -1, which clones -- and this is
// the spelling the EXISTING § unbasedSharedPaConst law already covers, so it is
// also the control that the new law must not disturb.
module q5_unbased;
parameter [19:0] Q = '1;
wire [19:0] t;
assign t = Q;
endmodule

module q5b_unbased_zero;
parameter [19:0] Q = '0;
wire [19:0] t;
assign t = Q;
endmodule

// ---- q6: STRING-typed parameter.
module q6_string;
parameter string Q = "abc";
string t;
assign t = Q;
endmodule

// ---- q7: REAL-typed parameter.
module q7_real;
parameter real Q = 1.5;
real t;
assign t = Q;
endmodule

// ---- q8: a PACKAGE parameter read by a module cont_assign.  Does the shared
// object cross the package/module boundary?
package q8_pkg;
parameter [19:0] Q = 20'h5;
endpackage
module q8_pkgref;
wire [19:0] t;
assign t = q8_pkg::Q;
endmodule

// ---- q9: an IMPORTED package parameter, referenced by its bare name.
module q9_import;
import q8_pkg::*;
wire [19:0] t;
assign t = Q;
endmodule

// ---- q10: the cont_assign lives in a GENERATE block, the parameter in the
// enclosing module.
module q10_gen;
parameter [19:0] Q = 20'h5;
wire [19:0] t;
generate
  if (1) begin : g
    assign t = Q;
  end
endgenerate
endmodule

// ---- q11: the parameter is declared INSIDE the generate block.
module q11_genparam;
wire [19:0] t;
generate
  if (1) begin : g
    parameter [19:0] Q = 20'h5;
    assign t = Q;
  end
endgenerate
endmodule

// ---- q12: an INTERFACE parameter, read by the interface's own cont_assign.
interface q12_if;
parameter [19:0] Q = 20'h5;
wire [19:0] t;
assign t = Q;
endinterface
module q12_top;
q12_if i0();
endmodule

// ---- q13: PART-SELECT LHS.  A select LHS re-compiles the assignment in
// Surelog's netlist pass, so the target width is the SELECT's, not the net's.
module q13_sel_lhs;
parameter [19:0] Q = 20'hABCDE;
wire [19:0] t;
assign t[7:4] = Q;
endmodule

// ---- q14: TWO DIFFERENT parameters, each read by its own cont_assign, so a
// per-symbol map cannot alias them.
module q14_two;
parameter [19:0] A = 20'h5;
parameter [19:0] B = 20'h6;
wire [19:0] t, u;
assign t = A;
assign u = B;
endmodule

// ---- q15: an ENUM-typed parameter.
module q15_enum;
typedef enum logic [3:0] {E0 = 4'h3} e_t;
parameter e_t Q = E0;
wire [3:0] t;
assign t = Q;
endmodule

// ---- q16: the bare parameter reference is the whole RHS but under an explicit
// CAST.  A control: the cast is an operation, so no reuse is expected.
module q16_cast;
parameter [19:0] Q = 20'h5;
wire [3:0] t;
assign t = 4'(Q);
endmodule

// ---- q17: HEX value, target width EQUAL, but the net is declared with a
// TYPEDEF'd vector type rather than an inline range.
module q17_typedef_net;
typedef logic [19:0] w_t;
parameter [19:0] Q = 20'h5;
w_t t;
assign t = Q;
endmodule

// ---- q18: the parameter is read by a cont_assign in a CHILD instance through
// a port default rather than in its own scope -- a hierarchical spelling.
module q18_child;
parameter [19:0] P = 20'h0;
wire [19:0] t;
assign t = P;
endmodule
module q18_top;
parameter [19:0] Q = 20'h5;
q18_child #(.P(Q)) c0();
endmodule
