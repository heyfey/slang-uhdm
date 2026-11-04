// § genNetDeclAssignLhsShared164 — a net declaration assignment inside a gen-for block
module top(input [1:0] a, output [1:0] o);
  for (genvar i = 0; i < 2; i++) begin : g
    wire z = a[i];
    assign o[i] = z;
  end
endmodule
