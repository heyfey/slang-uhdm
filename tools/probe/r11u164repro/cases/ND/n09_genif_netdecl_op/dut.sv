// § genNetDeclAssignLhsShared164 — a net declaration assignment of a constant operation inside a gen-if block
module top(output wire o);
  if (1) begin : g
    wire z = 1'b0 | 1'b1;
  end
  assign o = g.z;
endmodule
