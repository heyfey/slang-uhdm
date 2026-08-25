// v92 adversarial arm 2 — THE GAP UNDER TEST.
// kindOf92 maps ExpressionKind::ElementSelect to OK92::Select unconditionally
// and never walks to the base, unlike the RangeSelect case which DOES walk it.
// `s.m1[0]` and `u2.arr[0]` are ElementSelects whose base is a MemberAccess /
// HierarchicalValue: our emitter mints a hier_path for them, and Surelog's
// reduceExpr hier_path branch hands back decodeHierPath(...,VALUE)==nullptr,
// so writeCont_assign's `(invalidValue==false) && rhstmp` refuses the WHOLE
// write-back and golden MUST keep the ternary.
package vp2;
  typedef struct packed { logic [3:0] m1; logic [3:0] m2; } st_t;
endpackage

module sub2 (input logic [3:0] i, output logic [3:0] o);
  logic [3:0] arr;
  assign arr = i;
  assign o   = arr;
endmodule

module v2_esel #(parameter bit EN = 1) (
    input  logic [7:0] w,
    input  vp2::st_t   s,
    output logic       y_membsel,
    output logic       y_hiersel,
    output logic [3:0] y_membbare,
    output logic       y_bitsel_ctl,
    output logic       y_membsel_op
);
  logic [3:0] so;
  sub2 u2 (.i(w[3:0]), .o(so));
  // 1. ElementSelect over a MemberAccess base  -> hier_path -> MUST KEEP
  assign y_membsel    = EN ? s.m1[0]   : 1'b0;
  // 2. ElementSelect over a HierarchicalValue base -> hier_path -> MUST KEEP
  assign y_hiersel    = EN ? u2.arr[0] : 1'b0;
  // 3. bare MemberAccess (the shape the law already fences) -> MUST KEEP
  assign y_membbare   = EN ? s.m1      : 4'h0;
  // 4. plain bit_select control -> bit_select -> installs
  assign y_bitsel_ctl = EN ? w[3]      : 1'b0;
  // 5. the same member-select INSIDE an operation -> operation arm -> installs
  assign y_membsel_op = EN ? (s.m1[0] ^ w[2]) : 1'b0;
endmodule
