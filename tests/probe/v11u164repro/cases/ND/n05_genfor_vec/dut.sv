// § genNetDeclAssignLhsShared164 — a gen-for vector net declaration from a hierarchical path
module top(output wire [1:0] o);
  if (1) begin : A
    wire [1:0] x;
  end
  for (genvar i = 0; i < 2; i++) begin : G
    wire [1:0] z = A.x;
  end
  assign o = G[0].z;
endmodule
