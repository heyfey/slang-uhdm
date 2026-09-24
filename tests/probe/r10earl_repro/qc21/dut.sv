// qc21.sv — PASS 21.  qb21.sv showed the `q[NUM_REQS-1]` index fold happening
// in the gen-scope child (`gen_b[0].u_gen`) and NOT in the def listing or the
// plain child (`u_plain`).  Two features are confounded there: GEN SCOPE and
// INSTANCE ORDER (u_gen is the second elaboration of the same definition).
// This file separates them, and adds the if-generate form the corpus head
// actually uses (ibex_if_stage.sv:189 `end else begin : gen_prefetch_buffer`).
module qc21_child (
    input  logic [3:0] q,
    output logic       y1
);
  localparam int unsigned NUM_REQS = 2;
  assign y1 = ~q[NUM_REQS-1];
endmodule

module qc21 (
    input  logic [3:0] q,
    output logic [3:0] o
);
  qc21_child u_p1 (.q(q), .y1(o[0]));   // A: first plain elaboration
  qc21_child u_p2 (.q(q), .y1(o[1]));   // B: SECOND plain elaboration

  if (1) begin : gen_if
    qc21_child u_gi (.q(q), .y1(o[2])); // C: inside an IF-generate
  end

  for (genvar g = 0; g < 1; g++) begin : gen_for
    qc21_child u_gf (.q(q), .y1(o[3])); // D: inside a FOR-generate
  end
endmodule
