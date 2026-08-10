// qg21.sv — PASS 21.  The two features § genCaLoopParamFold's `!childGen`
// clause confounds.  ModuleEmit computes
//     childGen = prefix.find('.') != npos || parentFull.find('.') != npos
// i.e. ONE flag for "this module is a CHILD INSTANCE" and "this gen scope is
// NESTED in another gen scope", and the in-code comment cites only the nested
// case (hier_path's g_regions).  qf21.sv already showed the CHILD-INSTANCE
// half is wrong for select operands.  This file adds
//   * R6, a NON-SELECT operand in the same child gen loop (does the fold reach
//     it, or is it a select-position law?), and
//   * R7, a select operand in a gen scope NESTED inside the loop body of a
//     child instance (is the nested half still right?).
module qg21_child (
    input  logic [7:0] q,
    output logic [1:0] r1,
    output logic [1:0] r6,
    output logic [1:0] r7
);
  localparam int unsigned NUM_REQS = 2;
  for (genvar i = 0; i < NUM_REQS; i++) begin : gen_rev
    logic [7:0] w6;
    assign r1[i] = q[NUM_REQS-1-i];        // R1 select index (qf21: folds)
    assign w6    = NUM_REQS + i;           // R6 NON-SELECT operand
    assign r6[i] = |w6;
    if (1) begin : gen_n
      assign r7[i] = q[NUM_REQS-1];        // R7 select index, NESTED gen scope
    end
  end
endmodule

module qg21 (
    input  logic [7:0] q,
    output logic [1:0] r1,
    output logic [1:0] r6,
    output logic [1:0] r7
);
  qg21_child u_c (.q(q), .r1(r1), .r6(r6), .r7(r7));
endmodule
