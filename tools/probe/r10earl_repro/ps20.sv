// ps20.sv — PASS 20 witness: is the elab gen-scope cont_assign RHS bind
// gated on the LHS being a GEN-LOCAL?  pq20 L37 (LHS gen-local, RHS
// `loc_nested ^ 4'h5`) binds in golden while pq20 L56 (LHS module output,
// RHS an operation over same-scope gen-locals) does not; pr20 showed the
// operand's DEPTH and the way it is DRIVEN are both irrelevant.  The three
// rows below differ ONLY in the LHS and in whether the RHS is a whole ref.
module ps20 (
    input  logic [3:0] a,
    output logic [3:0] y1,
    output logic [3:0] y2
);

  for (genvar k = 0; k < 1; k++) begin : g
    logic [3:0] v1;
    always_comb v1 = a;

    logic [3:0] s1;
    assign s1 = v1 ^ 4'h5;   // S1  LHS gen-local,   RHS operation
    assign y1 = v1 ^ 4'h5;   // S2  LHS module net,  RHS operation
    assign y2 = v1;          // S3  LHS module net,  RHS whole ref
  end

endmodule
