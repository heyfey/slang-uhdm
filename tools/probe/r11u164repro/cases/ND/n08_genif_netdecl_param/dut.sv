// § genNetDeclAssignLhsShared164 — a net declaration assignment of a parameter inside a gen-if block
module top #(parameter P = 1)(output wire o);
  if (1) begin : g
    wire z = P;
  end
  assign o = g.z;
endmodule
