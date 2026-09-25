// § genNetDeclAssignLhsShared164 — a delayed gen-if net declaration from a hierarchical path
module top(output wire o);
  if (1) begin : A
    wire x;
    if (1) begin : B
      wire #1 z = A.x;
    end
  end
  assign o = A.B.z;
endmodule
