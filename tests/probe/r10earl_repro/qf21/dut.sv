// qf21.sv — PASS 21.  qe21.sv's five operand positions moved INSIDE A CHILD
// INSTANCE.  § genCaLoopParamFold is armed as `!childGen && genBlkIsLoopBody`
// (ModuleEmit ~12257 / ~12493), i.e. it is switched OFF the moment the
// enclosing prefix has a dot — the pass-20 headline shape, a law whose witness
// only ever saw the TOP-module spelling.  qd21.sv already showed golden
// folding row R1 in a child; this file measures ALL FIVE positions there so
// the reach correction is not another one-spelling law.
module qf21_child (
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

module qf21 (
    input  logic [7:0] q,
    output logic [1:0] r1,
    output logic [1:0] r2,
    output logic [1:0] r3,
    output logic [1:0] r4,
    output logic [1:0] r5
);
  qf21_child u_c (.q(q), .r1(r1), .r2(r2), .r3(r3), .r4(r4), .r5(r5));
endmodule
