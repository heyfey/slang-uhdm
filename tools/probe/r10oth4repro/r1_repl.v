// r10oth4 -- the R1 arm, WIDENED.  r10oth3's d3_replwidth.v had five cells and
// NO WORKING DRIVER; this one adds the cells that separate "digits = count"
// from every neighbouring model, and rarm.sh + replform.py read it.
//
// Corpus witness: or1200_dc_tag.v:99 `assign tag = {dw-1{1'b0}};` with
// `parameter dw = `OR1200_DCTAG_W+1;` = 22 and `output [dw-3:0] tag;` (20 bits).
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// Every cell is ONE module so replform.py can attribute it.  The folded object
// lives in the ELAB (uhdmtopModules) view only -- the DEF view keeps the
// unfolded operation on both sides (Surelog's fold rule, r10oth2).

// ---- REPLICATION into a continuous assign ----------------------------------

// a1 -- the witness: natural(21) > target(20)
module a1_narrow;
parameter dw = 22;
wire [19:0] t;
assign t = {dw-1{1'b0}};
endmodule

// a2 -- natural(21) < target(32).  Separates size=min(nat,tgt) from size=tgt.
module a2_wide;
parameter dw = 22;
wire [31:0] t;
assign t = {dw-1{1'b0}};
endmodule

// a3 -- natural == target.  The EQUAL control.
module a3_exact;
parameter dw = 21;
wire [19:0] t;
assign t = {dw-1{1'b0}};
endmodule

// a4 -- ones, so the digit string is distinguishable from zero padding
module a4_ones;
parameter dw = 22;
wire [19:0] t;
assign t = {dw-1{1'b1}};
endmodule

// a5 -- count as a LITERAL, no parameter anywhere
module a5_lit;
wire [19:0] t;
assign t = {21{1'b0}};
endmodule

// a6 -- MULTI-BIT replicand, natural(6) < target(20).  Tests that the natural
//       width is count*elemwidth, not count.
module a6_melem;
wire [19:0] t;
assign t = {3{2'b10}};
endmodule

// a7 -- MULTI-BIT replicand, natural(6) > target(4)
module a7_melem_nar;
wire [3:0] t;
assign t = {3{2'b10}};
endmodule

// a8 -- natural(70) > 64: past Surelog's 64-bit SValue
module a8_big;
wire [19:0] t;
assign t = {70{1'b1}};
endmodule

// a9 -- natural(70) into a 96-bit target
module a9_big_wide;
wire [95:0] t;
assign t = {70{1'b1}};
endmodule

// a10 -- 1-bit SCALAR target, natural 2
module a10_scalar;
wire t;
assign t = {2{1'b1}};
endmodule

// ---- PLAIN CONCAT, the neighbour this law must not disturb ------------------

// b1 -- concat natural(4) < target(20)
module b1_cat_wide;
wire [19:0] t;
assign t = {2'b10, 2'b01};
endmodule

// b2 -- concat natural(16) > target(8)
module b2_cat_nar;
wire [7:0] t;
assign t = {8'hF5, 8'h0F};
endmodule

// b3 -- concat natural == target
module b3_cat_exact;
wire [3:0] t;
assign t = {2'b10, 2'b01};
endmodule

// b4 -- concat CONTAINING a replication, natural(4) < target(20)
module b4_cat_repl;
wire [19:0] t;
assign t = {1'b1, {3{1'b0}}};
endmodule

// ---- OTHER CONTEXTS: is the law cont_assign-specific? -----------------------

// c1 -- the same replication in a PROCEDURAL assignment
module c1_proc;
parameter dw = 22;
reg [19:0] t;
always @(*) t = {dw-1{1'b0}};
endmodule

// c2 -- the same replication as an INSTANCE PORT CONNECTION
module c2_child(input [19:0] p);
endmodule
module c2_top;
parameter dw = 22;
c2_child u(.p({dw-1{1'b0}}));
endmodule

// c3 -- the same replication as a PARAMETER value (the known replFoldParamInt32
//       law; kept here as a control that this pass does not move it)
module c3_param;
parameter dw = 22;
parameter [19:0] P = {dw-1{1'b1}};
wire [19:0] t;
assign t = P;
endmodule

// ---- the 64-BIT BOUNDARY: UHDM's get_value refuses VpiSize > 64 -------------
// (templates/ExprEval.cpp:1967 `if (expr->VpiSize() > 64) invalidValue = true;`
// in the vpiBinaryConst arm) -- which is why a8/a9 keep their NATURAL size
// instead of the clamp: adjustSize's `if (!invalidValue) {...} else` fork.

// a11 -- natural 64 (NOT > 64), target 20
module a11_b64;
wire [19:0] t;
assign t = {64{1'b1}};
endmodule

// a12 -- natural 65 (> 64), target 20
module a12_b65;
wire [19:0] t;
assign t = {65{1'b1}};
endmodule

// a13 -- natural 64, target 96 (wider)
module a13_b64_wide;
wire [95:0] t;
assign t = {64{1'b1}};
endmodule

// a14 -- INTEGER (signed, 32-bit) target, natural 21, PROCEDURAL
module a14_int;
integer t;
always @(*) t = {21{1'b1}};
endmodule

// ---- concat past 64 --------------------------------------------------------

// b5 -- concat natural 80 > 64, target 20
module b5_cat_b80;
wire [19:0] t;
assign t = {40'hFFFFFFFFFF, 40'h0000000001};
endmodule

// b6 -- concat natural 80 > 64, target 96
module b6_cat_b80_wide;
wire [95:0] t;
assign t = {40'hFFFFFFFFFF, 40'h0000000001};
endmodule

// b7 -- concat CONTAINING a replication, natural(9) > target(4).  Separates
//       "the vpiConcatOp producer attaches an int_typespec too" (digits would
//       stay 9, the REPLICATION rule) from "it does not" (digits truncate to 4,
//       the CONCAT rule).
module b7_cat_repl_nar;
wire [3:0] t;
assign t = {1'b1, {8{1'b1}}};
endmodule

// b8 -- concat with an X bit, natural(8) < target(20)
module b8_cat_x;
wire [19:0] t;
assign t = {4'b001x, 4'b0000};
endmodule

// b9 -- the SAME x-concat TRUNCATED: natural(8) > target(4).  This is the cell
//       that decides whether the truncating arm's vpiDecompile write also
//       happens for an x/z value (get_value's parseBinary failure is NOT
//       strict, so the arm still runs).
module b9_cat_x_nar;
wire [3:0] t;
assign t = {4'b001x, 4'b0000};
endmodule

// ---- a BARE PARAMETER REF in a cont_assign: NOT this pass's law, but the arm
// ---- found a live difference at c3_param and these two cells name it.
module d1_paramref;
parameter [19:0] Q = 20'h5;
wire [19:0] t;
assign t = Q;
endmodule

module d2_paramref_repl;
parameter [19:0] R = {21{1'b1}};
wire [19:0] t;
assign t = R;
endmodule

// ---- VARIABLE INITIALIZERS: the OTHER tryFoldConst consumer
// ---- (src/ModuleEmit.cpp:17246 `tryFoldConst(*dt->getInitializer())`).
// ---- adjustSize's truncating arm requires a LOGIC typespec; an int_typespec
// ---- target takes the non-truncating arm and a bit_typespec neither.  These
// ---- three cells bound the blast radius of the concat law.
module e1_varinit;
logic [19:0] v = {2'b10, 2'b01};
endmodule

module e2_varinit_int;
int v = {2'b10, 2'b01};
endmodule

module e3_varinit_trunc;
logic [3:0] v = {8'hF5, 8'h0F};
endmodule

module e4_varinit_repl;
logic [19:0] v = {21{1'b1}};
endmodule
