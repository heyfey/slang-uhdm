// § genNetDeclAssignLhsShared164 — a net declaration assignment from a local net inside a gen-if block
module top(output wire o);
  if (1) begin : g
    wire x;
    wire z = x;
  end
  assign o = g.z;
endmodule
