// qe21.sv — PASS 21.  § genCaLoopParamFold's REACH: which operand positions
// of a FOR-generate gen-scope cont_assign RHS fold a MODULE localparam, and
// in which of the two forms (the SHARED constant re-parented at the module's
// param_assign and typespec-named at the module, vs a USE-SITE constant
// parented at the operand's own parent and typespec-named at the SELECT BASE).
// qd21.sv measured R1 as a use-site fold in golden and a bare ref_obj in ours.
module qe21 (
    input  logic [7:0] q,
    output logic [1:0] r1,
    output logic [1:0] r2,
    output logic [1:0] r3,
    output logic [1:0] r4,
    output logic [1:0] r5
);
  localparam int unsigned NUM_REQS = 2;
  for (genvar i = 0; i < NUM_REQS; i++) begin : gen_rev
    assign r1[i] = q[NUM_REQS-1-i];        // R1 operation bit-select INDEX
    assign r2[i] = q[NUM_REQS];            // R2 bare bit-select INDEX
    assign r3[i] = |q[NUM_REQS-1:0];       // R3 part-select BOUND
    assign r4[i] = q[NUM_REQS-1] & q[i];   // R4 index op, no genvar in it
    assign r5[i] = NUM_REQS[0] & q[i];     // R5 param used as a select BASE
  end
endmodule
