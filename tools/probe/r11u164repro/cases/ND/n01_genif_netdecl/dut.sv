// § genNetDeclAssignLhsShared164 — a net declaration assignment inside a gen-if block
module top(input a, output o);
  if (1) begin : g
    wire z = a;
    assign o = z;
  end
endmodule
