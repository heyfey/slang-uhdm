// § genNetDeclAssignLhsShared164 — a gen-if typed net declaration (wire logic) from a hierarchical path
module top(output wire o);
  if (1) begin : A
    wire x;
    if (1) begin : B
      wire logic z = A.x;
    end
  end
  assign o = A.B.z;
endmodule
