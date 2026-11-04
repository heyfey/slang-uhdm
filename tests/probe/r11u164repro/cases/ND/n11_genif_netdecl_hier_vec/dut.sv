// § genNetDeclAssignLhsShared164 — a vector net declaration assignment from a hierarchical path inside nested gen-if blocks
module top(output wire [1:0] o);
  if (1) begin : A
    wire [1:0] x;
    if (1) begin : B
      wire [1:0] x;
      wire [1:0] z = A.B.x;
    end
  end
  assign o = A.x;
endmodule
