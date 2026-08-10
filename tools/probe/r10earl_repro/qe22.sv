// qe22.sv — PASS 22.  qd22 put the ibex_multdiv_fast:147 shape in a TOP
// module's own gen block and measured `ok` everywhere: golden binds only the
// BARE `$signed(v1)` argument and leaves the concat operands unbound, exactly
// as we do.  The corpus binds them.  So the feature is somewhere in the
// TOPOLOGY the corpus adds, and this file crosses it:
//   work@top_earlgrey > .. > ex_block_i > gen_scope(gen_multdiv_single_cycle)
//     > multdiv_i (a CHILD INSTANCE INSTANTIATED FROM A GEN SCOPE)
//       > gen_scope(gen_multiv_single_cycle) > cont_assign :147
// Rows: the same gen block in (A) a top module, (B) a child instantiated
// PLAINLY, (C) a child instantiated FROM A GEN SCOPE.  Its gen-block condition
// is a PARAMETER, as in the corpus (`if (SingleCycleMultiply)`).
module qe22_inner #(
    parameter bit SC = 1'b1
) (
    input  logic [3:0] pa,
    output logic [7:0] oy
);
  logic [7:0] my;
  assign oy = my;

  if (SC) begin : gen_b
    logic signed [7:0] r1, r2, r6;
    logic [3:0] v1;
    logic       s1;

    always_comb begin
      v1 = pa;
      s1 = pa[0];
    end

    assign r1 = $signed(v1);              // E1 sys call, bare arg
    assign r2 = $signed({s1, v1});        // E2 sys call over a concat
    assign r6 = (v1 ^ 4'h5) + {s1, 3'b0}; // E3 nested operations
    assign my = $signed({s1, v1});        // E4 module-LHS negative
  end
endmodule

module qe22 (
    input  logic [3:0] pa,
    output logic [7:0] ob,
    output logic [7:0] oc,
    output logic [7:0] od
);
  // (B) plain child instance
  qe22_inner u_plain (.pa(pa), .oy(ob));

  // (C) child instantiated FROM A GEN SCOPE — the corpus topology
  if (1) begin : gen_outer
    qe22_inner u_gen (.pa(pa), .oy(oc));
  end

  // (A) the same gen block in this TOP module (qd22's row, kept for contrast)
  if (1) begin : gen_top
    logic signed [7:0] t2;
    logic [3:0] w1;
    logic       q1;
    always_comb begin
      w1 = pa;
      q1 = pa[0];
    end
    assign t2 = $signed({q1, w1});
  end
  assign od = 8'h0;
endmodule
