// r10earl110 arm g6 -- WHICH SCOPE FOLDS.  g3 measured golden folding the
// parameter leaves inside one generate body and NOT inside another; this arm
// varies one axis at a time until the distinguisher is named.
package pk6_110;
  typedef struct packed { logic [31:0] w6; } s6_t;
endpackage

module g6_scope110 #(parameter int unsigned NM = 3) (
  input  pk6_110::s6_t arr6 [4],
  output logic [31:0]  o6
);
  localparam int unsigned SA = 7;
  localparam int unsigned SB = 2;
  logic [31:0] v0, v1, v2, v3, v4, v5, v6, v7, v8, v9;
  // v0  MODULE scope, no generate at all
  assign v0 = { 27'b0, arr6[0].w6[0+:(SA-SB)] };
  // v1  for-generate, PARAMETER bound, genvar-indexed receiver
  for (genvar k1 = 0; k1 < NM; k1++) begin : b1
    assign v1 = { 27'b0, arr6[k1].w6[0+:(SA-SB)] };
  end
  // v2  for-generate, PARAMETER bound, CONSTANT-indexed receiver
  for (genvar k2 = 0; k2 < NM; k2++) begin : b2
    assign v2 = { 27'b0, arr6[0].w6[0+:(SA-SB)] };
  end
  // v3  for-generate, LITERAL bound of 3, constant-indexed receiver
  for (genvar k3 = 0; k3 < 3; k3++) begin : b3
    assign v3 = { 27'b0, arr6[0].w6[0+:(SA-SB)] };
  end
  // v4  for-generate, LITERAL bound of 1, constant-indexed receiver
  for (genvar k4 = 0; k4 < 1; k4++) begin : b4
    assign v4 = { 27'b0, arr6[0].w6[0+:(SA-SB)] };
  end
  // v5  for-generate, LITERAL bound of 1, GENVAR-indexed receiver
  for (genvar k5 = 0; k5 < 1; k5++) begin : b5
    assign v5 = { 27'b0, arr6[k5].w6[0+:(SA-SB)] };
  end
  // v6  SINGLE for-generate nesting level, inner body only
  for (genvar k6 = 0; k6 < 2; k6++) begin : b6
    assign v6 = { 27'b0, arr6[k6].w6[0+:(SA-SB)] };
  end
  // v7  DOUBLE for-generate nesting
  for (genvar k7 = 0; k7 < 2; k7++) begin : b7o
    for (genvar k8 = 0; k8 < 2; k8++) begin : b7i
      assign v7 = { 27'b0, arr6[k7].w6[0+:(SA-SB)] };
    end
  end
  // v8  IF-generate, TRUE arm
  if (NM > 1) begin : b8
    assign v8 = { 27'b0, arr6[0].w6[0+:(SA-SB)] };
  end
  // v9  IF-generate nested INSIDE a for-generate
  for (genvar k9 = 0; k9 < 2; k9++) begin : b9o
    if (NM > 1) begin : b9i
      assign v9 = { 27'b0, arr6[k9].w6[0+:(SA-SB)] };
    end
  end
  assign o6 = v0^v1^v2^v3^v4^v5^v6^v7^v8^v9;
endmodule
