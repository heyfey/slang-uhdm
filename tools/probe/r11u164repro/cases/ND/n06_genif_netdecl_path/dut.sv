// § genNetDeclAssignLhsShared164 — a net declaration assignment from a hierarchical path inside nested gen-if blocks (ComplexHierPath's shape)
module top(output wire o);
  if (1) begin : A
    wire x;
    if (1) begin : B
      wire x;
      wire z = A.B.x;
    end
  end
  assign o = A.x;
endmodule
