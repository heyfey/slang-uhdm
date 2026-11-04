// § genNetDeclAssignLhsShared164 — a gen-if net declaration from a selected hierarchical path
module top(output wire o);
  if (1) begin : A
    wire [1:0] x;
    if (1) begin : B
      wire z = A.x[0];
    end
  end
  assign o = A.B.z;
endmodule
