// r10vearl116 ADVERSARIAL arm va1_hier116 — THE HIERARCHICAL WHOLE-NAME Lhs.
//
// MEASUREMENT ONLY.  LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// THE ATTACK.  r10earl116's shipped gate is
//     patFlat9 = patStruct9 && stripImplicitConv(ae.left()).kind
//                              == ExpressionKind::NamedValue
// but UHDM's own gate (cont_assign::DeepClone, clone_tree.cpp:803-820) is
//     any_cast<ref_obj*>(lhs) && ro->Actual_group<struct_var>()
// which says NOTHING about how the name was written.  slang gives a
// HIERARCHICAL reference its OWN expression kind — ExpressionKind::
// HierarchicalValue, NOT NamedValue — so an out-of-module whole-name Lhs
// falls out of `patFlat9` while golden's `ref_obj`/`struct_var` gate still
// accepts it.  If golden FLATTENS there and the patched binary stops
// flattening, that is a pristine-right -> patched-wrong AWAY on legal SV.
//
//   v1  CONTROL: whole-name gen-local struct var (NamedValue)  -- golden FLAT
//   v2  DOWNWARD hierarchical Lhs from a gen scope: u0.hsig
//   v3  DOWNWARD hierarchical Lhs, deeper path: u1.inner.deep
//   v4  DOWNWARD hierarchical Lhs written from the MODULE body (no gen scope)
//   v5  CONTROL: module-scope whole-name var written from a gen scope
package v116p;
  typedef struct packed {
    logic       f_a;
    logic [3:0] f_b;
    logic       f_c;
  } vs_t;
endpackage

module v116_deep (input logic clk);
  v116p::vs_t deep;
endmodule

module v116_sub (input logic clk);
  v116p::vs_t   hsig;
  v116_deep inner (.clk(clk));
endmodule

module va1_hier116 (
    input  logic       clk,
    input  logic [3:0] d_i,
    output logic       v_o
);
  v116p::vs_t mtop;

  v116_sub u0 (.clk(clk));
  v116_sub u1 (.clk(clk));

  // v1 CONTROL -- whole-name gen-local struct VAR (NamedValue). golden FLAT.
  for (genvar i = 0; i < 2; i++) begin : gen_v1
    v116p::vs_t loc;
    assign loc = '{f_a: 1'b1, f_b: d_i, f_c: 1'b0};
  end

  // v2 THE ADVERSARIAL CELL -- DOWNWARD hierarchical whole-name Lhs from a
  //    generate scope.  Lhs is a HierarchicalValueExpression in slang.
  if (1) begin : gen_v2
    assign u0.hsig = '{f_a: 1'b0, f_b: d_i, f_c: 1'b1};
  end

  // v3 DOWNWARD hierarchical Lhs, DEEPER instance path, from a gen scope.
  if (1) begin : gen_v3
    assign u1.inner.deep = '{f_a: 1'b1, f_b: d_i, f_c: 1'b1};
  end

  // v4 DOWNWARD hierarchical Lhs written from the MODULE BODY (no gen scope) --
  //    the module-scope arm of emitBlock, which this law does not gate at all.
  assign u1.hsig = '{f_a: 1'b0, f_b: d_i, f_c: 1'b0};

  // v5 CONTROL -- module-scope whole-name var written from a gen scope.
  if (1) begin : gen_v5
    assign mtop = '{f_a: 1'b1, f_b: d_i, f_c: 1'b1};
  end

  assign v_o = mtop.f_a ^ u0.hsig.f_c ^ u1.inner.deep.f_a;
endmodule
