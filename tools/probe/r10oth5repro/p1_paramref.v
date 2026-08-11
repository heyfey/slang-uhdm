// r10oth5 arm for § elabCaReusesParamConst.
//
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// THE CELL THIS ARM EXISTS FOR (p1, = r10oth4repro/r1_repl.v:201-205 d1_paramref).
// Golden's ELAB view emits ONE constant object and points BOTH the param_assign's
// vpiRhs and the cont_assign's vpiRhs at it; the object's vpiParent is the
// CONT_ASSIGN (last writer).  Ours emitted the param_assign's constant with
// vpiParent=param_assign and MINTED A SECOND constant for the cont_assign.
//
// Every cell is one module so that a per-module instrument can name it.
// `t` is always the cont-assign target; `Q`/`A`/`B` are always the parameter(s).

// ---------------- p1: THE WITNESS.  typed param, sized hex literal, exact width
module p1_bare;
parameter [19:0] Q = 20'h5;
wire [19:0] t;
assign t = Q;
endmodule

// ---------------- p2: TWO cont_assigns read the SAME parameter.  Decides who
// owns vpiParent when the object is shared by three edges (last writer? first?).
module p2_twice;
parameter [19:0] Q = 20'h5;
wire [19:0] t, u;
assign t = Q;
assign u = Q;
endmodule

// ---------------- p3: UNTYPED param whose value is a SIZED literal.  This is the
// shape § readFoldUntypedSizedLitParam (r10oth4) gave the bare logic_typespec to.
module p3_untyped_sized;
parameter Q = 20'h5;
wire [19:0] t;
assign t = Q;
endmodule

// ---------------- p4: UNTYPED, UNSIZED value.  setRange is a no-op here, so the
// shared constant (if any) keeps the DECLARATION typespec.
module p4_untyped_unsized;
parameter Q = 5;
wire [19:0] t;
assign t = Q;
endmodule

// ---------------- p5: LOCALPARAM rather than parameter.
module p5_localparam;
localparam [19:0] Q = 20'h5;
wire [19:0] t;
assign t = Q;
endmodule

// ---------------- p6: NARROWER target than the parameter.  If golden truncates
// it CANNOT share the object; if it shares, the reuse ignores the target width.
module p6_narrow;
parameter [19:0] Q = 20'hABCDE;
wire [3:0] t;
assign t = Q;
endmodule

// ---------------- p7: WIDER target than the parameter.
module p7_wide;
parameter [19:0] Q = 20'h5;
wire [31:0] t;
assign t = Q;
endmodule

// ---------------- p8: the parameter's VALUE is an OPERATION (folds in ELAB only).
module p8_opvalue;
parameter [19:0] Q = 20'h4 + 1;
wire [19:0] t;
assign t = Q;
endmodule

// ---------------- p9: the parameter's VALUE is a REPLICATION.  = r10oth4's
// d2_paramref_repl, the second cell that exposed this residue.
module p9_replvalue;
parameter [19:0] R = {21{1'b1}};
wire [19:0] t;
assign t = R;
endmodule

// ---------------- p10: CONTROL.  the parameter is inside an OPERATION, so the
// cont_assign's Rhs is a fold of the operation, NOT the parameter's own object.
module p10_in_op;
parameter [19:0] Q = 20'h5;
wire [19:0] t;
assign t = Q + 1;
endmodule

// ---------------- p11: CONTROL.  a PART SELECT of the parameter.
module p11_select;
parameter [19:0] Q = 20'hABCDE;
wire [3:0] t;
assign t = Q[3:0];
endmodule

// ---------------- p12: CONTROL.  a PROCEDURAL read, no cont_assign at all.
module p12_proc;
parameter [19:0] Q = 20'h5;
reg [19:0] t;
always @(*) t = Q;
endmodule

// ---------------- p13: CONTROL.  read only as an INSTANCE PORT CONNECTION.
module p13_child(input wire [19:0] i);
wire [19:0] q;
assign q = i;
endmodule
module p13_top;
parameter [19:0] Q = 20'h5;
p13_child c0(.i(Q));
endmodule

// ---------------- p14: a PORT parameter, OVERRIDDEN at the instance.
module p14_child;
parameter [19:0] Q = 20'h5;
wire [19:0] t;
assign t = Q;
endmodule
module p14_top;
p14_child #(.Q(20'h7)) c0();
endmodule

// ---------------- p15: an `int`-typed parameter (predefined integer, not vector).
module p15_int;
parameter int Q = 5;
wire [31:0] t;
assign t = Q;
endmodule

// ---------------- p16: the SAME module instantiated TWICE.  Two elab copies, so
// the reuse must not alias one instance's constant into the other's cont_assign.
module p16_child;
parameter [19:0] Q = 20'h5;
wire [19:0] t;
assign t = Q;
endmodule
module p16_top;
p16_child #(.Q(20'h1)) c0();
p16_child #(.Q(20'h2)) c1();
endmodule

// ---------------- p17: the parameter is read BOTH by a cont_assign AND by
// another parameter's initializer.  Two consumers of two different kinds.
module p17_alsoparam;
parameter [19:0] Q = 20'h5;
parameter [19:0] P = Q + 1;
wire [19:0] t;
assign t = Q;
endmodule

// ---------------- p18: the RHS is a parameter reference to a parameter whose own
// value is a parameter reference.  A chain, to see how far the object travels.
module p18_chain;
parameter [19:0] A = 20'h5;
parameter [19:0] B = A;
wire [19:0] t;
assign t = B;
endmodule

// ---------------- p19: a SIGNED vector parameter with a NEGATIVE value.
module p19_signed;
parameter signed [19:0] Q = -20'sd5;
wire [19:0] t;
assign t = Q;
endmodule

// ---------------- p20: a 1-BIT parameter onto a scalar net (the ibex_alu shape).
module p20_bit;
parameter bit Q = 1'b1;
wire t;
assign t = Q;
endmodule

// ---------------- p21: WIDE (>64 bit) parameter, where Surelog's SValue cannot
// hold the value.  r10oth4's PartSelect4 lesson says width is not the gate, but
// this is the reuse spelling of the same question.
module p21_w68;
parameter [67:0] Q = 68'h200000000000000;
wire [67:0] t;
assign t = Q;
endmodule

// ---------------- p22: the parameter's value has UNKNOWN bits.
module p22_unknown;
parameter [19:0] Q = 20'hABCDX;
wire [19:0] t;
assign t = Q;
endmodule

// ---------------- C5 RESIDUES.  Pre-existing, recorded nowhere before r10oth4's
// integration because no instrument printed them.  Both are VARIABLE
// INITIALIZERS, not cont_assigns.
// e3: golden's two OPERAND constants carry vpiSize:4 (the target width), ours 8.
module e3_varinit_trunc;
logic [3:0] v = {8'hF5, 8'h0F};
endmodule

// e4: golden's ELAB logic_var carries vpiExpr = the UNFOLDED replication;
// ours emits NO vpiExpr at all, plus an extra vpiVisibility:1.
module e4_varinit_repl;
logic [19:0] v = {21{1'b1}};
endmodule

// e1/e2: the equal controls from r10oth4's r1_repl.v, kept so the blast radius of
// any variable-initializer change is bounded rather than assumed.
module e1_varinit;
logic [19:0] v = {2'b10, 2'b01};
endmodule

module e2_varinit_int;
int v = {2'b10, 2'b01};
endmodule

// e5-e10 cross the OPERAND width against the TARGET width, because the
// C5 report ("golden's operands are vpiSize:4, ours 8") is a single cell and a
// single cell cannot tell `size = target` from `size = min(own, target)`.
module e5_varinit_eq;
logic [7:0] v = {8'hF5, 8'h0F};
endmodule

module e6_varinit_odd;
logic [5:0] v = {8'hF5, 8'h0F};
endmodule

module e7_varinit_small;
logic [3:0] v = {2'b10, 2'b01};
endmodule

module e8_varinit_mixed;
logic [3:0] v = {8'hF5, 2'b01};
endmodule

module e9_varinit_int32;
int v = {8'hF5, 8'h0F};
endmodule

module e10_varinit_nested;
logic [3:0] v = {{2'b10, 2'b01}, 4'hF};
endmodule
