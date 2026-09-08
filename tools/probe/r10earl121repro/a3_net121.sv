// r10earl121 arm a3_net121 — the gen-local struct NET flavour of the axis,
// ALONE, because it also carries a PRE-EXISTING difference this pass does not
// own (README residue R2) and would otherwise mask `a1_axis121`'s verdict.
//
// MEASUREMENT ONLY.  LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// Surelog models a `wire`-typed packed struct as a `struct_var` too, so
// `cont_assign::DeepClone`'s `Actual_group<struct_var>` test passes and the
// cell belongs to § `genCaPatKeepTagDefView121` exactly as `a1_axis121`'s
// x1 does: golden keeps the `tagged_pattern` wrappers in the DEFAULT view and
// drops them under `-elabuhdm` (measured on r10earl116's arm `q1_lhs116` cell
// c5, both views).
//
// THE PRE-EXISTING DIFFERENCE, named so the arm's cmp count is not mistaken for
// this law's: golden's `gen_scope` lists the wire-typed struct under
// `vpiVariables` as a `struct_var`; ours emits NO `Variables` vector on that
// gen scope at all, so `gen_scope::Compare`'s vector `SafeCompare` names the
// gen_scope with `RHS: <null>`.  It is there on BOTH binaries and is not
// touched by this pass.
package r121;
  typedef struct packed {
    logic       n_id;
    logic [7:0] n_d;
  } net_t;
endpackage

module a3_net121 #(
    parameter int M = 3
) (
    input  logic       clk,
    input  r121::net_t two_i [M],
    input  logic [7:0] d_i,
    output logic       v_o
);
  logic sink;

  // n1  whole-name gen-local struct NET.
  for (genvar i = 0; i < M; i++) begin : gen_n1
    wire r121::net_t n1_t;
    assign n1_t = '{n_id: sink, n_d: two_i[i].n_d};
  end

  assign sink = d_i[0];
  assign v_o  = gen_n1[0].n1_t.n_id;
endmodule
