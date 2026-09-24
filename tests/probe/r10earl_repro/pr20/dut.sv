// pr20.sv — PASS 20 witness: the exact REACH of the elab gen-scope cont_assign
// RHS bind for a SAME-SCOPE gen-local variable read INSIDE an operation.
// pq20 measured two competing readings of golden:
//   L37 `assign f_op = loc_nested ^ 4'h5;`   operand0, depth 1  -> BOUND
//   L56 `assign y = f_op ^ h_idx ^ ...;`     operands, depth >1 -> UNBOUND
// and the two candidate discriminators (OPERAND DEPTH vs. how the operand is
// DRIVEN — a process for loc_nested, a cont_assign for f_op/h_idx) are
// confounded there.  Every row below is one cont_assign in the same gen block.
module pr20 (
    input  logic [3:0] a,
    output logic [3:0] y
);

  for (genvar k = 0; k < 1; k++) begin : g
    logic [3:0] v1, v2;            // PROCESS-driven gen locals
    always_comb v1 = a;
    always_comb v2 = ~a;

    logic [3:0] r1; assign r1 = v1 ^ 4'h5;            // R1 operand0, depth 1
    logic [3:0] r2; assign r2 = 4'h5 ^ v1;            // R2 operand1, depth 1
    logic [3:0] r3; assign r3 = v1 ^ v2;              // R3 both, depth 1
    logic [3:0] r4; assign r4 = (v1 ^ 4'h5) ^ 4'h3;   // R4 depth 2
    logic [3:0] r5; assign r5 = {v1[1:0], v2[1:0]};   // R5 concat of selects
    logic [3:0] r7; assign r7 = ~v1;                  // R7 unary, depth 1
    logic [3:0] r8; assign r8 = v1 ^ r1;              // R8 process- vs CA-driven
    logic [3:0] r9; assign r9 = r1 ^ 4'h5;            // R9 CA-driven, depth 1
  end

  assign y = 4'h0;

endmodule
