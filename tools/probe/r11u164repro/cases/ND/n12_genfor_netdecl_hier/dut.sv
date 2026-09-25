// § genNetDeclAssignLhsShared164 — a vector net declaration assignment from a hierarchical path inside a gen-for block
module top(output wire [1:0] o);
  if (1) begin : A
    wire [1:0] x;
  end
  for (genvar i = 0; i < 1; i++) begin : F
    wire [1:0] z = A.x;
  end
  assign o = A.x;
endmodule
